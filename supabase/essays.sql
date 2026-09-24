-- Redação: tema → rascunho → envio → correção → resultado.
--
-- O QUE ESTE ARQUIVO É: só o banco (tabelas, RLS, índices, RPCs). A
-- chamada ao Gemini mora na Edge Function `evaluate-essay`, que virá numa
-- fase posterior. Aqui já existem as três RPCs que ela vai usar
-- (start/complete/fail), porque são elas que carregam as regras de posse,
-- cota e idempotência -- a function só orquestra.
--
-- BACKEND É A FONTE DA VERDADE. O cliente nunca manda user_id (sempre
-- auth.uid()), nunca manda nota, nunca decide se ainda tem cota, e nunca
-- escreve em essay_submissions/essay_evaluations direto: tudo passa pelas
-- funções `security definer` abaixo.
--
-- CICLO DE VIDA DA SUBMISSION
--   submitted  -> criada pelo envio, ainda não reivindicada
--   evaluating -> a Edge Function reivindicou e está corrigindo
--   evaluated  -> avaliação gravada (estado final)
--   failed     -> erro recuperável (Gemini fora do ar, cota do free tier,
--                 JSON inválido). NÃO é estado final: dá pra tentar de
--                 novo, e a tentativa não consome cota nova.
-- O texto enviado é imutável desde o primeiro instante. "Refazer" cria uma
-- submission NOVA; nada nunca sobrescreve uma tentativa anterior.
--
-- COTA DIÁRIA (3 por usuário/dia): contada por SUBMISSION distinta, não por
-- chamada. É o que faz "retentar uma redação que falhou por erro técnico"
-- não custar uma cota a mais -- a linha em essay_evaluation_quota já
-- existe, o insert bate no unique e não conta de novo. A proteção vive
-- aqui, no banco; a UI só reflete.
--
-- AURA: +50 uma vez por submission corrigida com sucesso, gravado no mesmo
-- ledger xp_awards do resto do app usando submission_id como attempt_id --
-- a constraint unique (user_id, attempt_id) já garante que duas chamadas
-- da Edge Function não creditam duas vezes. Rascunho e envio não dão nada;
-- só avaliação concluída. A correção também conta como atividade do dia
-- para a ofensiva.
--
-- CUSTO: nada aqui chama serviço externo nem gera cobrança. O teto diário
-- é justamente o que mantém o uso dentro do free tier.
--
-- Idempotente: pode rodar de novo sem quebrar (o SQL Editor do Supabase não
-- é transacional -- se parar no meio, é só rodar o arquivo inteiro de novo).
--
-- Depende de: xp_schema.sql (user_xp), quiz_xp_ledger.sql (xp_awards),
-- streaks_schema.sql (register_activity_completion).

-- ---------------------------------------------------------------------------
-- 1. Tabelas
-- ---------------------------------------------------------------------------

-- 1.1 Temas. Leitura pública, escrita só por SQL à mão (mesma postura de
-- catalog_nodes/questions).
--
-- source_type separa o que é nosso do que é de prova real. A constraint
-- abaixo é a regra "não fingir de oficial" escrita em SQL: um tema
-- 'official' EXIGE banca, ano e fonte; um 'practice' é proibido de ter
-- qualquer um dos três. Não dá pra cadastrar "ENEM 2023" sem a referência.
create table if not exists essay_themes (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  prompt text not null,
  source_type text not null default 'practice'
    check (source_type in ('practice', 'official')),
  exam_name text,
  exam_year integer check (exam_year is null or exam_year between 1960 and 2100),
  source_url text,
  -- [{ "title": ..., "body": ..., "source": ... }, ...]: quantos blocos o
  -- tema precisar, sem virar coluna gigante nem tabela filha só pra isso.
  supporting_texts jsonb not null default '[]'::jsonb
    check (jsonb_typeof(supporting_texts) = 'array'),
  is_active boolean not null default true,
  order_index integer not null default 0,
  created_at timestamptz not null default now(),
  constraint essay_themes_official_needs_source check (
    (source_type = 'official'
      and exam_name is not null and exam_year is not null and source_url is not null)
    or
    (source_type = 'practice'
      and exam_name is null and exam_year is null and source_url is null)
  )
);

create index if not exists essay_themes_active_idx
  on essay_themes (is_active, order_index);

alter table essay_themes enable row level security;

drop policy if exists "essay themes are publicly readable" on essay_themes;
create policy "essay themes are publicly readable"
  on essay_themes for select
  using (true);

-- 1.2 Rascunho: o ÚNICO registro mutável da feature. Um por usuário por
-- tema -- o autosave do editor sobrescreve este mesmo registro em vez de
-- empilhar versões.
create table if not exists essay_drafts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  theme_id uuid not null references essay_themes (id) on delete cascade,
  body text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, theme_id)
);

create index if not exists essay_drafts_user_idx on essay_drafts (user_id);

alter table essay_drafts enable row level security;

-- Rascunho é CRUD comum do próprio usuário (mesma postura de
-- user_question_favorites): sem nota, sem cota, sem nada que valha a pena
-- proteger com RPC. As policies abaixo já garantem que ninguém enxerga nem
-- escreve o rascunho de outro.
drop policy if exists "users read their own drafts" on essay_drafts;
create policy "users read their own drafts"
  on essay_drafts for select using (auth.uid() = user_id);

drop policy if exists "users write their own drafts" on essay_drafts;
create policy "users write their own drafts"
  on essay_drafts for insert with check (auth.uid() = user_id);

drop policy if exists "users update their own drafts" on essay_drafts;
create policy "users update their own drafts"
  on essay_drafts for update using (auth.uid() = user_id);

drop policy if exists "users delete their own drafts" on essay_drafts;
create policy "users delete their own drafts"
  on essay_drafts for delete using (auth.uid() = user_id);

-- 1.3 Envio: snapshot imutável. Sem policy de update/delete de propósito --
-- nem o dono altera uma tentativa já enviada.
create table if not exists essay_submissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  theme_id uuid not null references essay_themes (id) on delete cascade,
  body text not null,
  word_count integer not null default 0,
  status text not null default 'submitted'
    check (status in ('submitted', 'evaluating', 'evaluated', 'failed')),
  -- Motivo legível por máquina do último erro ('provider_unavailable',
  -- 'rate_limited', 'invalid_output', ...). A UI traduz; nunca mostra isto.
  failure_reason text,
  submitted_at timestamptz not null default now(),
  evaluation_started_at timestamptz,
  evaluated_at timestamptz
);

create index if not exists essay_submissions_user_theme_idx
  on essay_submissions (user_id, theme_id, submitted_at desc);

-- Uma correção em voo por usuário. Não trava tentar outro tema depois --
-- trava disparar várias correções ao mesmo tempo, que é o que gastaria a
-- cota do free tier de uma vez.
create unique index if not exists essay_submissions_one_in_flight_per_user
  on essay_submissions (user_id)
  where status = 'evaluating';

alter table essay_submissions enable row level security;

drop policy if exists "users read their own submissions" on essay_submissions;
create policy "users read their own submissions"
  on essay_submissions for select using (auth.uid() = user_id);

-- 1.4 Avaliação. Uma por submission (unique), com as 5 competências do
-- ENEM. total_score é conferido contra a soma por constraint: JSON torto do
-- provider não vira nota salva.
create table if not exists essay_evaluations (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid not null unique
    references essay_submissions (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  total_score integer not null check (total_score between 0 and 1000),
  c1_score integer not null check (c1_score between 0 and 200),
  c2_score integer not null check (c2_score between 0 and 200),
  c3_score integer not null check (c3_score between 0 and 200),
  c4_score integer not null check (c4_score between 0 and 200),
  c5_score integer not null check (c5_score between 0 and 200),
  -- [{ "competency": "c1", "summary": ..., "strengths": [...],
  --    "improvements": [...], "evidence": [...] }, ...]
  competencies jsonb not null default '[]'::jsonb
    check (jsonb_typeof(competencies) = 'array'),
  general_feedback text,
  strengths jsonb not null default '[]'::jsonb
    check (jsonb_typeof(strengths) = 'array'),
  priority_improvements jsonb not null default '[]'::jsonb
    check (jsonb_typeof(priority_improvements) = 'array'),
  possible_theme_deviation boolean not null default false,
  insufficient_text boolean not null default false,
  -- Quem corrigiu. Guardado por linha porque a qualidade da correção muda
  -- quando o modelo ou o prompt mudam -- sem isto, daqui a seis meses não
  -- dá pra saber se uma nota veio do modelo velho. Nada aqui é específico
  -- do Gemini: trocar de provider é gravar outro par provider/model.
  provider text not null,
  model text not null,
  prompt_version text not null,
  evaluated_at timestamptz not null default now(),
  constraint essay_evaluations_total_matches_sum check (
    total_score = c1_score + c2_score + c3_score + c4_score + c5_score
  )
);

create index if not exists essay_evaluations_user_idx
  on essay_evaluations (user_id, evaluated_at desc);

alter table essay_evaluations enable row level security;

drop policy if exists "users read their own evaluations" on essay_evaluations;
create policy "users read their own evaluations"
  on essay_evaluations for select using (auth.uid() = user_id);

-- 1.5 Cota diária. Uma linha por (usuário, dia, submission): é a chave
-- unique que faz a retentativa da MESMA redação não consumir cota de novo.
-- Guardar por submission em vez de um contador simples é o que dá essa
-- propriedade de graça.
create table if not exists essay_evaluation_quota (
  user_id uuid not null references auth.users (id) on delete cascade,
  quota_date date not null,
  submission_id uuid not null references essay_submissions (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, quota_date, submission_id)
);

alter table essay_evaluation_quota enable row level security;

drop policy if exists "users read their own quota" on essay_evaluation_quota;
create policy "users read their own quota"
  on essay_evaluation_quota for select using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 2. Constantes da feature
-- ---------------------------------------------------------------------------

-- Um lugar só para os números que as RPCs abaixo compartilham. Trocar o
-- teto diário é trocar esta função (e rodar o arquivo de novo).
create or replace function essay_daily_evaluation_limit()
returns integer language sql immutable as $$ select 3 $$;

create or replace function essay_award_amount()
returns integer language sql immutable as $$ select 50 $$;

-- Texto curto demais não vale uma chamada ao provider. O corte é
-- deliberadamente baixo: quem escreveu 40 palavras merece uma resposta do
-- app ("texto insuficiente"), não uma nota inventada.
create or replace function essay_min_word_count()
returns integer language sql immutable as $$ select 50 $$;

create or replace function essay_word_count(p_body text)
returns integer language sql immutable as $$
  select coalesce(
    array_length(
      array_remove(regexp_split_to_array(coalesce(p_body, ''), '\s+'), ''),
      1
    ),
    0
  );
$$;

-- ---------------------------------------------------------------------------
-- 3. RPCs do app
-- ---------------------------------------------------------------------------

-- As quatro funções de leitura abaixo rodam como o chamador (SECURITY
-- INVOKER, o padrão): tudo que elas leem já é liberado pelas policies --
-- temas são públicos, o resto é do próprio usuário. Privilégio elevado só
-- onde escrever exige, na seção 4.
--
-- 3.1 A lista de temas já com o estado do usuário em cada um: nota da
-- última correção, se tem rascunho, se tem correção em andamento. Um único
-- round trip -- a alternativa seria a tela pedir tema por tema.
--
-- last_score é null quando nunca houve correção. A tela mostra nada nesse
-- caso: nunca "0", nunca barra de progresso (redação não tem percentual).
drop function if exists list_essay_themes_for_user();
create or replace function list_essay_themes_for_user()
returns table (
  id uuid,
  title text,
  description text,
  source_type text,
  exam_name text,
  exam_year integer,
  has_draft boolean,
  last_status text,
  last_score integer,
  attempt_count integer
)
language sql
stable
as $$
  with last_submission as (
    select distinct on (s.theme_id)
           s.theme_id, s.status, s.id
    from essay_submissions s
    where s.user_id = auth.uid()
    order by s.theme_id, s.submitted_at desc
  )
  select t.id,
         t.title,
         t.description,
         t.source_type,
         t.exam_name,
         t.exam_year,
         exists (
           select 1 from essay_drafts d
           where d.user_id = auth.uid() and d.theme_id = t.id
             and length(btrim(d.body)) > 0
         ) as has_draft,
         ls.status as last_status,
         ev.total_score as last_score,
         (select count(*)::int from essay_submissions s2
           where s2.user_id = auth.uid() and s2.theme_id = t.id) as attempt_count
  from essay_themes t
  left join last_submission ls on ls.theme_id = t.id
  left join essay_evaluations ev on ev.submission_id = ls.id
  where t.is_active
  order by t.order_index, t.title;
$$;

-- 3.2 Envio: congela o rascunho numa submission nova e limpa o rascunho.
-- Recusa texto curto demais aqui, antes de existir qualquer submission --
-- é a primeira das duas barreiras que impedem gastar chamada à toa.
drop function if exists submit_essay(uuid);
create or replace function submit_essay(p_theme_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_body text;
  v_words integer;
  v_id uuid;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  select d.body into v_body
  from essay_drafts d
  where d.user_id = v_user_id and d.theme_id = p_theme_id;

  if v_body is null then
    raise exception 'no draft to submit' using errcode = 'P0002';
  end if;

  v_words := essay_word_count(v_body);
  if v_words < essay_min_word_count() then
    raise exception 'text too short'
      using errcode = 'P0003', detail = v_words::text;
  end if;

  insert into essay_submissions (user_id, theme_id, body, word_count)
  values (v_user_id, p_theme_id, v_body, v_words)
  returning id into v_id;

  delete from essay_drafts
  where user_id = v_user_id and theme_id = p_theme_id;

  return v_id;
end;
$$;

-- 3.3 O histórico de tentativas de um tema, do mais recente para o mais
-- antigo. Nota só aparece para as que foram corrigidas.
drop function if exists list_essay_attempts(uuid);
create or replace function list_essay_attempts(p_theme_id uuid)
returns table (
  id uuid,
  status text,
  word_count integer,
  total_score integer,
  submitted_at timestamptz,
  evaluated_at timestamptz
)
language sql
stable
as $$
  select s.id, s.status, s.word_count, ev.total_score, s.submitted_at, s.evaluated_at
  from essay_submissions s
  left join essay_evaluations ev on ev.submission_id = s.id
  where s.user_id = auth.uid() and s.theme_id = p_theme_id
  order by s.submitted_at desc;
$$;

-- 3.4 Uma tentativa inteira: o texto enviado e, se houver, a correção.
-- É isto que o polling chama: enquanto status for submitted/evaluating a
-- avaliação vem null, e o app só precisa reconsultar. Como o estado mora
-- no servidor, fechar o app no meio não perde nada.
drop function if exists get_essay_submission(uuid);
create or replace function get_essay_submission(p_submission_id uuid)
returns table (
  id uuid,
  theme_id uuid,
  theme_title text,
  body text,
  word_count integer,
  status text,
  failure_reason text,
  submitted_at timestamptz,
  evaluated_at timestamptz,
  total_score integer,
  c1_score integer,
  c2_score integer,
  c3_score integer,
  c4_score integer,
  c5_score integer,
  competencies jsonb,
  general_feedback text,
  strengths jsonb,
  priority_improvements jsonb,
  possible_theme_deviation boolean,
  insufficient_text boolean
)
language sql
stable
as $$
  select s.id, s.theme_id, t.title, s.body, s.word_count, s.status,
         s.failure_reason, s.submitted_at, s.evaluated_at,
         ev.total_score, ev.c1_score, ev.c2_score, ev.c3_score, ev.c4_score,
         ev.c5_score, ev.competencies, ev.general_feedback, ev.strengths,
         ev.priority_improvements,
         coalesce(ev.possible_theme_deviation, false),
         coalesce(ev.insufficient_text, false)
  from essay_submissions s
  join essay_themes t on t.id = s.theme_id
  left join essay_evaluations ev on ev.submission_id = s.id
  where s.id = p_submission_id and s.user_id = auth.uid();
$$;

-- 3.5 Quanto ainda resta hoje. A tela usa para avisar ANTES do usuário
-- escrever uma redação inteira e só então descobrir que não tem cota.
-- Continua sendo só um espelho: quem decide é start_essay_evaluation().
drop function if exists get_essay_quota();
create or replace function get_essay_quota()
returns table (used integer, total integer)
language sql
stable
as $$
  select (
    select count(*)::int from essay_evaluation_quota q
    where q.user_id = auth.uid()
      and q.quota_date = (now() at time zone 'America/Sao_Paulo')::date
  ), essay_daily_evaluation_limit();
$$;

-- ---------------------------------------------------------------------------
-- 4. RPCs da Edge Function (evaluate-essay)
-- ---------------------------------------------------------------------------

-- 4.1 Reivindica a submission para correção e devolve o que o modelo
-- precisa ler. Concentra as quatro recusas que evitam chamada inútil ao
-- provider: não é sua, já está corrigida, já tem uma correção em voo, ou
-- acabou a cota do dia.
--
-- A cota é debitada AQUI, antes da chamada: a linha em
-- essay_evaluation_quota é por submission, então retentar a mesma redação
-- depois de uma falha técnica encontra a linha já existente e não debita de
-- novo -- o teto continua valendo para redações distintas.
drop function if exists start_essay_evaluation(uuid);
create or replace function start_essay_evaluation(p_submission_id uuid)
returns table (
  body text,
  theme_title text,
  theme_prompt text,
  supporting_texts jsonb,
  word_count integer
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_status text;
  v_today date := (now() at time zone 'America/Sao_Paulo')::date;
  v_used integer;
  v_inserted boolean;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  select s.status into v_status
  from essay_submissions s
  where s.id = p_submission_id and s.user_id = v_user_id
  for update;

  if v_status is null then
    raise exception 'submission not found' using errcode = 'P0002';
  end if;
  if v_status = 'evaluated' then
    raise exception 'already evaluated' using errcode = 'P0004';
  end if;
  if v_status = 'evaluating' then
    raise exception 'already evaluating' using errcode = 'P0005';
  end if;

  -- Debita a cota (ou reencontra o débito desta mesma submission).
  insert into essay_evaluation_quota (user_id, quota_date, submission_id)
  values (v_user_id, v_today, p_submission_id)
  on conflict (user_id, quota_date, submission_id) do nothing;
  v_inserted := found;

  if v_inserted then
    select count(*)::int into v_used
    from essay_evaluation_quota q
    where q.user_id = v_user_id and q.quota_date = v_today;

    if v_used > essay_daily_evaluation_limit() then
      -- Devolve a cota que acabou de ser debitada: esta correção não vai
      -- acontecer, então não pode ficar contada contra o usuário.
      delete from essay_evaluation_quota
      where user_id = v_user_id and quota_date = v_today
        and submission_id = p_submission_id;
      raise exception 'daily limit reached' using errcode = 'P0006';
    end if;
  end if;

  update essay_submissions
  set status = 'evaluating',
      evaluation_started_at = now(),
      failure_reason = null
  where id = p_submission_id;

  return query
  select s.body, t.title, t.prompt, t.supporting_texts, s.word_count
  from essay_submissions s
  join essay_themes t on t.id = s.theme_id
  where s.id = p_submission_id;
end;
$$;

-- 4.2 Grava a correção, credita a Aura e marca a atividade do dia.
--
-- Idempotente em duas frentes: o insert da avaliação bate no unique de
-- submission_id se a function for chamada duas vezes, e o crédito passa
-- por xp_awards com attempt_id = submission_id, que é exatamente a
-- constraint que já impede o resto do app de creditar duas vezes. Chamar
-- isto de novo devolve a nota existente sem tocar em nada.
drop function if exists complete_essay_evaluation(uuid, jsonb, text, text, text);
create or replace function complete_essay_evaluation(
  p_submission_id uuid,
  p_result jsonb,
  p_provider text,
  p_model text,
  p_prompt_version text
) returns table (total_score integer, awarded integer)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_owner uuid;
  v_c1 integer := (p_result -> 'c1' ->> 'score')::integer;
  v_c2 integer := (p_result -> 'c2' ->> 'score')::integer;
  v_c3 integer := (p_result -> 'c3' ->> 'score')::integer;
  v_c4 integer := (p_result -> 'c4' ->> 'score')::integer;
  v_c5 integer := (p_result -> 'c5' ->> 'score')::integer;
  v_total integer;
  v_existing integer;
  v_awarded integer := 0;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  select s.user_id into v_owner
  from essay_submissions s
  where s.id = p_submission_id
  for update;

  if v_owner is null or v_owner <> v_user_id then
    raise exception 'submission not found' using errcode = 'P0002';
  end if;

  -- Já corrigida: devolve o que está gravado, não regrava nem recredita.
  select ev.total_score into v_existing
  from essay_evaluations ev where ev.submission_id = p_submission_id;
  if v_existing is not null then
    return query select v_existing, 0;
    return;
  end if;

  if v_c1 is null or v_c2 is null or v_c3 is null or v_c4 is null or v_c5 is null then
    raise exception 'incomplete evaluation payload' using errcode = 'P0007';
  end if;
  v_total := v_c1 + v_c2 + v_c3 + v_c4 + v_c5;

  insert into essay_evaluations (
    submission_id, user_id, total_score,
    c1_score, c2_score, c3_score, c4_score, c5_score,
    competencies, general_feedback, strengths, priority_improvements,
    possible_theme_deviation, insufficient_text,
    provider, model, prompt_version
  ) values (
    p_submission_id, v_user_id, v_total,
    v_c1, v_c2, v_c3, v_c4, v_c5,
    coalesce(p_result -> 'competencies', '[]'::jsonb),
    p_result ->> 'general_feedback',
    coalesce(p_result -> 'strengths', '[]'::jsonb),
    coalesce(p_result -> 'priority_improvements', '[]'::jsonb),
    coalesce((p_result ->> 'possible_theme_deviation')::boolean, false),
    coalesce((p_result ->> 'insufficient_text')::boolean, false),
    p_provider, p_model, p_prompt_version
  );

  update essay_submissions
  set status = 'evaluated', evaluated_at = now(), failure_reason = null
  where id = p_submission_id;

  -- +50 Aura, uma vez por submission. submission_id É o attempt_id.
  insert into xp_awards (user_id, attempt_id, amount)
  values (v_user_id, p_submission_id, essay_award_amount())
  on conflict (user_id, attempt_id) do nothing
  returning amount into v_awarded;

  if v_awarded is not null then
    insert into user_xp (user_id, total_xp)
    values (v_user_id, v_awarded)
    on conflict (user_id)
    do update set total_xp = user_xp.total_xp + v_awarded, updated_at = now();
    perform register_activity_completion();
  else
    v_awarded := 0;
  end if;

  return query select v_total, v_awarded;
end;
$$;

-- 4.3 Falha recuperável. O texto continua lá, o status volta para 'failed'
-- e a cota debitada fica registrada NAQUELA submission -- por isso a
-- retentativa não paga de novo. Nada é apagado, nunca.
drop function if exists fail_essay_evaluation(uuid, text);
create or replace function fail_essay_evaluation(
  p_submission_id uuid,
  p_reason text
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  update essay_submissions
  set status = 'failed', failure_reason = p_reason
  where id = p_submission_id
    and user_id = v_user_id
    and status <> 'evaluated';
end;
$$;

-- ---------------------------------------------------------------------------
-- 5. Temas de treino iniciais
-- ---------------------------------------------------------------------------
-- São temas do Aura, não de prova nenhuma: source_type 'practice', sem
-- banca e sem ano (a constraint da 1.1 impede o contrário). A tela mostra
-- "Aura · Tema de treino".
--
-- Idempotente pelo título: rodar de novo não duplica.

insert into essay_themes (title, description, prompt, order_index)
select v.title, v.description, v.prompt, v.order_index
from (values
  (
    'Os limites da privacidade na era dos dados',
    'Até onde vai o direito de não ser rastreado.',
    'A partir da leitura dos textos motivadores e com base nos conhecimentos construídos ao longo de sua formação, redija um texto dissertativo-argumentativo em modalidade escrita formal da língua portuguesa sobre o tema "Os limites da privacidade na era dos dados", apresentando proposta de intervenção que respeite os direitos humanos.',
    1
  ),
  (
    'O trabalho por aplicativo e a proteção de quem entrega',
    'Autonomia prometida, proteção que não veio junto.',
    'A partir da leitura dos textos motivadores e com base nos conhecimentos construídos ao longo de sua formação, redija um texto dissertativo-argumentativo em modalidade escrita formal da língua portuguesa sobre o tema "O trabalho por aplicativo e a proteção de quem entrega", apresentando proposta de intervenção que respeite os direitos humanos.',
    2
  ),
  (
    'Desinformação e o direito de saber',
    'Quando a mentira circula mais rápido que a correção.',
    'A partir da leitura dos textos motivadores e com base nos conhecimentos construídos ao longo de sua formação, redija um texto dissertativo-argumentativo em modalidade escrita formal da língua portuguesa sobre o tema "Desinformação e o direito de saber", apresentando proposta de intervenção que respeite os direitos humanos.',
    3
  ),
  (
    'Saúde mental de estudantes em ano de vestibular',
    'A cobrança que forma e a cobrança que adoece.',
    'A partir da leitura dos textos motivadores e com base nos conhecimentos construídos ao longo de sua formação, redija um texto dissertativo-argumentativo em modalidade escrita formal da língua portuguesa sobre o tema "Saúde mental de estudantes em ano de vestibular", apresentando proposta de intervenção que respeite os direitos humanos.',
    4
  ),
  (
    'Água: escassez, desperdício e desigualdade no Brasil',
    'O mesmo país que tem muita água tem quem não tem nenhuma.',
    'A partir da leitura dos textos motivadores e com base nos conhecimentos construídos ao longo de sua formação, redija um texto dissertativo-argumentativo em modalidade escrita formal da língua portuguesa sobre o tema "Água: escassez, desperdício e desigualdade no Brasil", apresentando proposta de intervenção que respeite os direitos humanos.',
    5
  )
) as v(title, description, prompt, order_index)
where not exists (
  select 1 from essay_themes t where t.title = v.title
);
