-- "Montar simulado": o usuário escolhe, por matéria, dificuldade (facil /
-- medio / dificil / misto) e quantidade; o servidor sorteia as questões,
-- congela a ordem das questões E das alternativas, e a sessão fica salva de
-- verdade até ser finalizada ou descartada.
--
-- MODO PROVA -- a regra que manda em tudo aqui:
--   Enquanto o simulado está 'in_progress' o app só sabe QUAL alternativa
--   foi marcada. Nada que revele acerto/erro sai do banco: is_correct fica
--   null, get_mock_exam_items() devolve correct_index/explanation null, e
--   NADA é escrito em user_question_progress (senão Revisar erros / barra
--   de domínio do tópico entregariam o resultado antes da hora). Tudo isso
--   só acontece dentro de finish_mock_exam().
--
--   Limite honesto: a tabela questions é de leitura pública desde sempre
--   (o quiz normal corrige no client). Alguém chamando a API na mão
--   consegue ler correct_index de qualquer questão -- isso é da
--   arquitetura do app inteiro, não deste arquivo. O que este arquivo
--   garante é que o APP nunca recebe nem deduz o resultado durante a prova.
--
-- BACKEND É A FONTE DA VERDADE: disponibilidade, validação da config,
-- sorteio, correção, nota, progresso e XP são todos calculados aqui. O
-- Flutter só manda a config, a alternativa marcada, e "finalizar".
--
-- QUESTÃO REMOVIDA DEPOIS DE CRIAR O SIMULADO: mock_exam_items.question_id
-- é "on delete cascade" -- se a questão for apagada do banco, o item some
-- junto. A sessão não quebra (as posições restantes continuam em ordem, só
-- fica um buraco na numeração interna), a questão é ignorada na correção,
-- e o denominador da nota (scored_count) é recalculado sobre os itens que
-- ainda existem no momento da finalização. question_count guarda o total
-- pedido na criação, só para histórico.
--
-- Idempotente: pode rodar de novo sem quebrar (o SQL Editor do Supabase não
-- é transacional -- se parar no meio, é só rodar o arquivo inteiro de novo).
--
-- Depende de: questions_schema.sql, difficulty_schema.sql,
-- progress_schema.sql (user_question_progress), quiz_xp_ledger.sql
-- (award_quiz_xp), daily_goal.sql (substituído no fim deste arquivo).

-- ---------------------------------------------------------------------------
-- 1. Tabelas
-- ---------------------------------------------------------------------------

create table if not exists mock_exams (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  status text not null default 'in_progress'
    check (status in ('in_progress', 'finished', 'abandoned')),
  -- Total pedido na criação (histórico). A nota usa scored_count.
  question_count integer not null check (question_count between 1 and 180),
  -- Preenchidos só por finish_mock_exam(), numa única vez.
  scored_count integer,
  answered_count integer,
  correct_count integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  finished_at timestamptz,
  abandoned_at timestamptz
);

-- Questão que o usuário estava VENDO por último (item_position), gravada
-- por set_mock_exam_position() a cada navegação -- é para onde "Continuar
-- simulado" volta, mesmo que ela já esteja respondida. Null = nunca
-- navegou: o app abre na primeira questão sem resposta. Adicionada depois
-- da primeira versão deste arquivo, daí o "add column if not exists" (rodar
-- o arquivo de novo num banco que já tem a tabela só acrescenta a coluna).
alter table mock_exams
  add column if not exists current_item_position integer;

create index if not exists mock_exams_user_created_idx
  on mock_exams (user_id, created_at desc);

-- No máximo UM simulado em andamento por usuário, garantido pelo banco:
-- um segundo insert 'in_progress' para o mesmo user_id viola este índice,
-- mesmo que duas criações corram ao mesmo tempo.
create unique index if not exists mock_exams_one_active_per_user
  on mock_exams (user_id)
  where status = 'in_progress';

create table if not exists mock_exam_subject_configs (
  mock_exam_id uuid not null references mock_exams (id) on delete cascade,
  subject text not null,
  difficulty text not null
    check (difficulty in ('facil', 'medio', 'dificil', 'misto')),
  question_count integer not null check (question_count >= 1),
  primary key (mock_exam_id, subject)
);

create table if not exists mock_exam_items (
  mock_exam_id uuid not null references mock_exams (id) on delete cascade,
  -- Ordem da questão no simulado, 1-based, sorteada UMA vez na criação.
  item_position integer not null check (item_position >= 1),
  question_id uuid not null references questions (id) on delete cascade,
  -- Retrato de onde a questão veio (para "Misto", a dificuldade real da
  -- questão sorteada), para o resultado por matéria/dificuldade não mudar
  -- se a questão for reclassificada depois.
  subject text not null,
  difficulty text not null,
  -- Permutação dos índices ORIGINAIS de questions.options, sorteada UMA vez
  -- na criação: option_order[1] é o índice original mostrado em 1º lugar.
  -- Mesma ordem ao fechar/reabrir/trocar de aparelho.
  option_order integer[] not null,
  -- Alternativa marcada, no espaço de índices ORIGINAL (0-based) -- já
  -- convertida pelo servidor a partir da posição que o app mostrou.
  selected_option integer check (selected_option >= 0),
  -- Primeira vez que esta questão foi respondida (trocar a alternativa
  -- depois não mexe). É o que a meta diária conta.
  answered_at timestamptz,
  -- null até finish_mock_exam(). Nunca preenchido durante a prova.
  is_correct boolean,
  primary key (mock_exam_id, item_position),
  unique (mock_exam_id, question_id)
);

-- Para o cascade de "apagar questão" não varrer a tabela inteira.
create index if not exists mock_exam_items_question_idx
  on mock_exam_items (question_id);

-- ---------------------------------------------------------------------------
-- 2. RLS: cada usuário só LÊ o que é seu. Nenhuma policy de escrita --
--    toda escrita passa pelas RPCs security definer abaixo, mesmo padrão de
--    user_streaks / user_xp / user_question_progress.
-- ---------------------------------------------------------------------------

alter table mock_exams enable row level security;
alter table mock_exam_subject_configs enable row level security;
alter table mock_exam_items enable row level security;

drop policy if exists "users can read their own mock exams" on mock_exams;
create policy "users can read their own mock exams"
  on mock_exams for select
  using (auth.uid() = user_id);

drop policy if exists "users can read their own mock exam configs"
  on mock_exam_subject_configs;
create policy "users can read their own mock exam configs"
  on mock_exam_subject_configs for select
  using (
    exists (
      select 1 from mock_exams e
      where e.id = mock_exam_id and e.user_id = auth.uid()
    )
  );

drop policy if exists "users can read their own mock exam items"
  on mock_exam_items;
create policy "users can read their own mock exam items"
  on mock_exam_items for select
  using (
    exists (
      select 1 from mock_exams e
      where e.id = mock_exam_id and e.user_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------------
-- 3. RPCs. Dropa por NOME (todas as assinaturas) antes de recriar, para que
--    rodar de novo depois de mudar parâmetros/retorno nunca falhe.
-- ---------------------------------------------------------------------------

do $$
declare
  r record;
begin
  for r in
    select p.oid::regprocedure as signature
    from pg_proc p
    where p.pronamespace = 'public'::regnamespace
      and p.proname in (
        'get_mock_exam_availability',
        'create_mock_exam',
        'get_active_mock_exam',
        'get_mock_exam_items',
        'answer_mock_exam_item',
        'finish_mock_exam',
        'abandon_mock_exam',
        'get_mock_exam_result',
        'set_mock_exam_position'
      )
  loop
    execute 'drop function ' || r.signature;
  end loop;
end;
$$;

-- 3.1 Disponibilidade real por matéria + dificuldade, agregada no banco
-- (o app nunca baixa questões para contar). 'misto' = fácil + médio +
-- difícil daquela matéria. Atualidades fica de fora (dossiês têm banco
-- próprio, e a regra do simulado exclui a matéria explicitamente).
create function get_mock_exam_availability()
returns table (subject text, difficulty text, available_count integer)
language sql
stable
as $$
  with counts as (
    select cn.subject, q.difficulty, count(*)::int as n
    from questions q
    join catalog_nodes cn on cn.id = q.catalog_node_id
    where cn.subject <> 'atualidades'
    group by cn.subject, q.difficulty
  )
  select c.subject, c.difficulty, c.n
  from counts c
  union all
  select c.subject, 'misto', sum(c.n)::int
  from counts c
  group by c.subject
  order by 1, 2;
$$;

-- 3.2 Cria o simulado. p_config:
--   [{"subject": "geografia", "difficulty": "dificil", "question_count": 40},
--    {"subject": "historia",  "difficulty": "misto",   "question_count": 30}]
--
-- Tudo ou nada: qualquer raise desfaz a função inteira (nenhum simulado
-- pela metade). Erros conhecidos, para o app tratar pelo "message":
--   mock_exam_already_active         detail = id do simulado em andamento
--   mock_exam_invalid_config         detail = o que está errado
--   mock_exam_total_exceeded         detail = total pedido
--   mock_exam_insufficient_questions detail = subject:difficulty:disponível
create function create_mock_exam(p_config jsonb)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_exam_id uuid;
  v_active_id uuid;
  v_entry record;
  v_total integer;
  v_available integer;
  v_inserted integer;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  -- Checagem amigável antes do trabalho todo. A garantia de verdade é o
  -- índice único parcial (tratado no insert abaixo).
  select e.id into v_active_id
  from mock_exams e
  where e.user_id = v_user_id and e.status = 'in_progress';
  if v_active_id is not null then
    raise exception using
      message = 'mock_exam_already_active',
      detail = v_active_id::text;
  end if;

  if p_config is null
     or jsonb_typeof(p_config) <> 'array'
     or jsonb_array_length(p_config) = 0 then
    raise exception using
      message = 'mock_exam_invalid_config',
      detail = 'config must be a non-empty array';
  end if;

  for v_entry in
    select c.subject, c.difficulty, c.question_count
    from jsonb_to_recordset(p_config)
      as c(subject text, difficulty text, question_count integer)
  loop
    if v_entry.subject is null
       or v_entry.subject = 'atualidades'
       or v_entry.difficulty is null
       or v_entry.difficulty not in ('facil', 'medio', 'dificil', 'misto')
       or v_entry.question_count is null
       or v_entry.question_count < 1 then
      raise exception using
        message = 'mock_exam_invalid_config',
        detail = format(
          'invalid entry %s:%s:%s',
          v_entry.subject, v_entry.difficulty, v_entry.question_count
        );
    end if;

    select count(*)::int into v_available
    from questions q
    join catalog_nodes cn on cn.id = q.catalog_node_id
    where cn.subject = v_entry.subject
      and (v_entry.difficulty = 'misto' or q.difficulty = v_entry.difficulty);

    if v_available < v_entry.question_count then
      raise exception using
        message = 'mock_exam_insufficient_questions',
        detail = format(
          '%s:%s:%s', v_entry.subject, v_entry.difficulty, v_available
        );
    end if;
  end loop;

  if (
    select count(*) <> count(distinct c.subject)
    from jsonb_to_recordset(p_config) as c(subject text)
  ) then
    raise exception using
      message = 'mock_exam_invalid_config',
      detail = 'each subject can appear only once';
  end if;

  select sum(c.question_count)::int into v_total
  from jsonb_to_recordset(p_config) as c(question_count integer);
  if v_total > 180 then
    raise exception using
      message = 'mock_exam_total_exceeded',
      detail = v_total::text;
  end if;

  begin
    insert into mock_exams (user_id, status, question_count)
    values (v_user_id, 'in_progress', v_total)
    returning id into v_exam_id;
  exception when unique_violation then
    -- Outra criação ganhou a corrida entre a checagem lá em cima e aqui.
    select e.id into v_active_id
    from mock_exams e
    where e.user_id = v_user_id and e.status = 'in_progress';
    raise exception using
      message = 'mock_exam_already_active',
      detail = coalesce(v_active_id::text, '');
  end;

  insert into mock_exam_subject_configs
    (mock_exam_id, subject, difficulty, question_count)
  select v_exam_id, c.subject, c.difficulty, c.question_count
  from jsonb_to_recordset(p_config)
    as c(subject text, difficulty text, question_count integer);

  -- Sorteio: dentro de cada matéria, ordem aleatória no pool daquela
  -- dificuldade (ou no pool inteiro da matéria, para 'misto' -- aleatório
  -- de verdade, sem cota por dificuldade), fica com as N primeiras. Depois
  -- o conjunto todo recebe posições em ordem aleatória, para as matérias
  -- saírem misturadas. A ordem das alternativas de cada questão é sorteada
  -- aqui também. Nada disso é sorteado de novo depois.
  insert into mock_exam_items
    (mock_exam_id, item_position, question_id, subject, difficulty, option_order)
  select v_exam_id,
         row_number() over (order by random()),
         picked.id,
         picked.subject,
         picked.difficulty,
         array(
           select g
           from generate_series(0, cardinality(picked.options) - 1) g
           order by random()
         )
  from (
    select q.id,
           q.options,
           q.difficulty,
           cn.subject,
           c.question_count,
           row_number() over (
             partition by cn.subject order by random()
           ) as rn
    from jsonb_to_recordset(p_config)
      as c(subject text, difficulty text, question_count integer)
    join catalog_nodes cn on cn.subject = c.subject
    join questions q
      on q.catalog_node_id = cn.id
     and (c.difficulty = 'misto' or q.difficulty = c.difficulty)
  ) picked
  where picked.rn <= picked.question_count;

  -- Cinto e suspensório: se o banco mudou entre a checagem e o sorteio,
  -- falha em vez de devolver um simulado menor fingindo sucesso.
  get diagnostics v_inserted = row_count;
  if v_inserted <> v_total then
    raise exception using
      message = 'mock_exam_insufficient_questions',
      detail = format('requested %s, drew %s', v_total, v_inserted);
  end if;

  return v_exam_id;
end;
$$;

-- 3.3 O simulado em andamento do usuário (0 ou 1 linha). question_count
-- aqui são os itens que ainda existem; answered_count é quantos já têm
-- alternativa marcada -- é o "37/90" do card de continuar.
-- current_item_position: onde retomar (ver a coluna em mock_exams).
create function get_active_mock_exam()
returns table (
  id uuid,
  created_at timestamptz,
  question_count integer,
  answered_count integer,
  current_item_position integer
)
language sql
stable
as $$
  select e.id,
         e.created_at,
         count(i.item_position)::int,
         count(i.selected_option)::int,
         e.current_item_position
  from mock_exams e
  left join mock_exam_items i on i.mock_exam_id = e.id
  where e.user_id = auth.uid()
    and e.status = 'in_progress'
  group by e.id, e.created_at, e.current_item_position;
$$;

-- 3.3b Guarda qual questão o usuário está vendo, para "Continuar simulado"
-- voltar exatamente nela. Só aceita posição que existe neste simulado e
-- simulado em andamento do próprio usuário. Não toca em resposta nenhuma
-- e não revela nada: é só um marcador de navegação.
-- Erros: mock_exam_not_found, mock_exam_not_in_progress,
--        mock_exam_invalid_answer (posição inexistente).
create function set_mock_exam_position(
  p_mock_exam_id uuid,
  p_position integer
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_status text;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  select e.status into v_status
  from mock_exams e
  where e.id = p_mock_exam_id and e.user_id = v_user_id
  for share;

  if not found then
    raise exception using message = 'mock_exam_not_found';
  end if;
  if v_status <> 'in_progress' then
    raise exception using
      message = 'mock_exam_not_in_progress',
      detail = v_status;
  end if;
  if not exists (
    select 1 from mock_exam_items i
    where i.mock_exam_id = p_mock_exam_id and i.item_position = p_position
  ) then
    raise exception using
      message = 'mock_exam_invalid_answer',
      detail = format('position %s', p_position);
  end if;

  update mock_exams e
  set current_item_position = p_position,
      updated_at = now()
  where e.id = p_mock_exam_id;
end;
$$;

-- 3.4 As questões do simulado, na ordem congelada, com as alternativas já
-- na ordem congelada. selected_index / correct_index são posições NA ORDEM
-- MOSTRADA (0-based). Durante a prova, correct_index, is_correct e
-- explanation vêm SEMPRE null -- só aparecem depois de finalizado.
-- SECURITY INVOKER: a RLS de mock_exam_items já limita ao próprio usuário.
create function get_mock_exam_items(p_mock_exam_id uuid)
returns table (
  item_position integer,
  question_id uuid,
  subject text,
  difficulty text,
  prompt text,
  options text[],
  selected_index integer,
  correct_index integer,
  is_correct boolean,
  explanation text
)
language sql
stable
as $$
  select i.item_position,
         i.question_id,
         i.subject,
         i.difficulty,
         q.prompt,
         array(
           select q.options[o + 1]
           from unnest(i.option_order) with ordinality as u(o, n)
           order by u.n
         ),
         array_position(i.option_order, i.selected_option) - 1,
         case when e.status = 'finished'
           then array_position(i.option_order, q.correct_index) - 1
         end,
         case when e.status = 'finished' then i.is_correct end,
         case when e.status = 'finished' then q.explanation end
  from mock_exam_items i
  join mock_exams e on e.id = i.mock_exam_id
  join questions q on q.id = i.question_id
  where i.mock_exam_id = p_mock_exam_id
    and e.user_id = auth.uid()
  order by i.item_position;
$$;

-- 3.5 Marca (ou TROCA) a alternativa de uma questão -- enquanto o simulado
-- está em andamento, a última escolha é a que vale (B e depois C -> C). Só
-- grava a escolha:
-- não corrige, não toca user_question_progress, não devolve nada que
-- revele o resultado. p_selected_index é a posição NA ORDEM MOSTRADA; o
-- servidor converte para o índice original via option_order. Repetir a
-- mesma chamada é inofensivo (mesmo estado final); answered_at guarda a
-- primeira resposta.
-- Erros: mock_exam_not_found, mock_exam_not_in_progress,
--        mock_exam_invalid_answer.
create function answer_mock_exam_item(
  p_mock_exam_id uuid,
  p_position integer,
  p_selected_index integer
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_status text;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  -- FOR SHARE: espera um finish/abandon concorrente terminar, então nunca
  -- dá para gravar resposta num simulado que já está sendo corrigido.
  select e.status into v_status
  from mock_exams e
  where e.id = p_mock_exam_id and e.user_id = v_user_id
  for share;

  if not found then
    raise exception using message = 'mock_exam_not_found';
  end if;
  if v_status <> 'in_progress' then
    raise exception using
      message = 'mock_exam_not_in_progress',
      detail = v_status;
  end if;

  update mock_exam_items i
  set selected_option = i.option_order[p_selected_index + 1],
      answered_at = coalesce(i.answered_at, now())
  where i.mock_exam_id = p_mock_exam_id
    and i.item_position = p_position
    and p_selected_index >= 0
    and p_selected_index < cardinality(i.option_order);

  if not found then
    raise exception using
      message = 'mock_exam_invalid_answer',
      detail = format('position %s, index %s', p_position, p_selected_index);
  end if;

  update mock_exams e
  set updated_at = now()
  where e.id = p_mock_exam_id;
end;
$$;

-- 3.6 Finaliza: corrige tudo no servidor, grava a nota, e SÓ AGORA aplica
-- as respostas ao progresso normal (erros entram em Revisar erros, acertos
-- contam domínio) e concede o XP pela regra que já existe
-- (award_quiz_xp: 10 por acerto, attempt_id = id do simulado).
--
-- Idempotente: a linha do simulado é travada (FOR UPDATE); se já estiver
-- 'finished', só devolve a nota gravada, sem nenhum efeito novo. Mesmo que
-- o XP fosse chamado de novo, award_quiz_xp ignora attempt_id repetido.
--
-- Progresso: mesma tabela e mesmo upsert de register_question_answered(),
-- com duas diferenças deliberadas:
--   * updated_at/answered_at = quando a questão foi respondida NA PROVA
--     (não a hora de finalizar). Assim a meta diária não conta de novo, no
--     dia da finalização, uma questão respondida num dia anterior.
--   * a resposta mais recente vence: se o usuário respondeu a mesma
--     questão fora do simulado DEPOIS de respondê-la na prova, a resposta
--     da prova (mais antiga) não sobrescreve.
-- Questão em branco (sem alternativa) conta como não-acerto na nota, mas
-- não é escrita no progresso -- ela nunca foi respondida.
-- Erros: mock_exam_not_found, mock_exam_abandoned.
create function finish_mock_exam(p_mock_exam_id uuid)
returns table (
  scored_count integer,
  answered_count integer,
  correct_count integer
)
language plpgsql
security definer
set search_path = public
as $$
#variable_conflict use_column
declare
  v_user_id uuid := auth.uid();
  v_exam mock_exams%rowtype;
  v_scored integer;
  v_answered integer;
  v_correct integer;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  select * into v_exam
  from mock_exams e
  where e.id = p_mock_exam_id and e.user_id = v_user_id
  for update;

  if not found then
    raise exception using message = 'mock_exam_not_found';
  end if;
  if v_exam.status = 'abandoned' then
    raise exception using message = 'mock_exam_abandoned';
  end if;
  if v_exam.status = 'finished' then
    return query
      select v_exam.scored_count, v_exam.answered_count, v_exam.correct_count;
    return;
  end if;

  -- Correção, só com o gabarito do banco.
  update mock_exam_items i
  set is_correct = (i.selected_option = q.correct_index)
  from questions q
  where q.id = i.question_id
    and i.mock_exam_id = p_mock_exam_id
    and i.selected_option is not null;

  select count(*)::int,
         count(i.selected_option)::int,
         (count(*) filter (where i.is_correct))::int
  into v_scored, v_answered, v_correct
  from mock_exam_items i
  where i.mock_exam_id = p_mock_exam_id;

  insert into user_question_progress
    (user_id, question_id, is_correct, answered_at, updated_at)
  select v_user_id, i.question_id, i.is_correct, i.answered_at, i.answered_at
  from mock_exam_items i
  where i.mock_exam_id = p_mock_exam_id
    and i.selected_option is not null
  on conflict (user_id, question_id)
  do update set is_correct = excluded.is_correct,
                updated_at = excluded.updated_at
  where user_question_progress.updated_at <= excluded.updated_at;

  perform award_quiz_xp(p_mock_exam_id, v_correct);

  update mock_exams e
  set status = 'finished',
      finished_at = now(),
      updated_at = now(),
      scored_count = v_scored,
      answered_count = v_answered,
      correct_count = v_correct
  where e.id = p_mock_exam_id;

  return query select v_scored, v_answered, v_correct;
end;
$$;

-- 3.7 Descarta o simulado em andamento: status 'abandoned' e mais nada --
-- sem correção, sem progresso, sem Revisar erros, sem XP. O registro fica
-- guardado (histórico/auditoria). Descartar de novo é um no-op.
-- Erros: mock_exam_not_found, mock_exam_already_finished.
create function abandon_mock_exam(p_mock_exam_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_status text;
begin
  if v_user_id is null then
    raise exception 'not authenticated';
  end if;

  select e.status into v_status
  from mock_exams e
  where e.id = p_mock_exam_id and e.user_id = v_user_id
  for update;

  if not found then
    raise exception using message = 'mock_exam_not_found';
  end if;
  if v_status = 'finished' then
    raise exception using message = 'mock_exam_already_finished';
  end if;
  if v_status = 'abandoned' then
    return;
  end if;

  update mock_exams e
  set status = 'abandoned',
      abandoned_at = now(),
      updated_at = now()
  where e.id = p_mock_exam_id;
end;
$$;

-- 3.8 Resultado por matéria + dificuldade (a dificuldade real de cada
-- questão, inclusive as sorteadas via 'misto'). Só devolve linhas para um
-- simulado FINALIZADO do próprio usuário -- em andamento, volta vazio.
-- question_count inclui questões em branco (contam como não-acerto).
create function get_mock_exam_result(p_mock_exam_id uuid)
returns table (
  subject text,
  difficulty text,
  question_count integer,
  answered_count integer,
  correct_count integer
)
language sql
stable
as $$
  select i.subject,
         i.difficulty,
         count(*)::int,
         count(i.selected_option)::int,
         (count(*) filter (where i.is_correct))::int
  from mock_exam_items i
  join mock_exams e on e.id = i.mock_exam_id
  where i.mock_exam_id = p_mock_exam_id
    and e.user_id = auth.uid()
    and e.status = 'finished'
  group by i.subject, i.difficulty
  order by i.subject, i.difficulty;
$$;

-- ---------------------------------------------------------------------------
-- 4. Meta diária -- SUBSTITUI a versão de daily_goal.sql.
--
-- Regra que não muda: questão respondida hoje conta, acertando ou errando,
-- cada questão uma vez só. O que muda: no modo prova a resposta só chega a
-- user_question_progress na finalização, então agora também entram as
-- respostas de simulado (mock_exam_items.answered_at), deduplicadas por
-- question_id com o UNION:
--   * simulado em andamento: conta pelo answered_at do item;
--   * simulado finalizado no mesmo dia: a questão está nos dois lados com
--     o mesmo question_id -> conta 1;
--   * simulado respondido ontem e finalizado hoje: finish_mock_exam grava
--     updated_at = answered_at (ontem), então não conta de novo hoje;
--   * simulado descartado: as questões respondidas continuam contando para
--     o dia em que foram respondidas (a atividade aconteceu).
-- Nenhum contador paralelo: tudo derivado dos registros.
-- Mesma assinatura e retorno de antes -> create or replace basta, o app
-- não precisa mudar nada.
-- ---------------------------------------------------------------------------

create or replace function get_daily_question_count(
  p_timezone text default 'America/Sao_Paulo'
)
returns integer
language sql
stable
as $$
  select count(*)::int
  from (
    select up.question_id
    from user_question_progress up
    where up.user_id = auth.uid()
      and (up.updated_at at time zone p_timezone)::date
        = (now() at time zone p_timezone)::date
    union
    select i.question_id
    from mock_exam_items i
    join mock_exams e on e.id = i.mock_exam_id
    where e.user_id = auth.uid()
      and i.answered_at is not null
      and (i.answered_at at time zone p_timezone)::date
        = (now() at time zone p_timezone)::date
  ) answered_today;
$$;
