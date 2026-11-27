-- Expansão do acervo: classificação por categoria (ENEM/Vestibulares/Concursos), proveniência, lotes e staging.
-- ADITIVA e REVERSÍVEL (rollback: supabase/rollbacks/20261209000100_content_classification.down.sql).
-- NÃO altera `questions`, `catalog_nodes` nem nenhuma tabela de usuário; não apaga nem recria acervo; ids preservados.
-- Conteúdo novo entra em `content_question_staging` (invisível ao app) e só chega ao catálogo ativo por
-- `content_promote_batch`, função restrita ao service_role, a ser chamada SOMENTE com autorização do dono.

create table if not exists content_categories (
  code text primary key check (code in ('enem', 'vestibular', 'concurso')),
  name text not null,
  order_index int not null
);
insert into content_categories (code, name, order_index) values
  ('enem', 'ENEM', 1), ('vestibular', 'Vestibulares', 2), ('concurso', 'Concursos', 3)
on conflict (code) do nothing;

-- Classificação múltipla individual: uma questão/nó pode estar em 1, 2 ou 3 categorias sem duplicar a entidade.
create table if not exists question_categories (
  question_id uuid not null references questions (id) on delete cascade,
  category text not null references content_categories (code),
  created_at timestamptz not null default now(),
  primary key (question_id, category)
);
create index if not exists question_categories_category_idx on question_categories (category, question_id);

create table if not exists catalog_node_categories (
  catalog_node_id uuid not null references catalog_nodes (id) on delete cascade,
  category text not null references content_categories (code),
  created_at timestamptz not null default now(),
  primary key (catalog_node_id, category)
);
create index if not exists catalog_node_categories_category_idx on catalog_node_categories (category, catalog_node_id);

-- Lotes versionados e retomáveis.
create table if not exists content_batches (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  version int not null default 1 check (version >= 1),
  description text,
  status text not null default 'em_preparo' check (status in ('em_preparo', 'em_staging', 'promovido', 'revertido')),
  created_at timestamptz not null default now(),
  promoted_at timestamptz
);

-- Proveniência. Ano/instituição/banca só existem se a origem for oficial autorizada (nada inventado).
create table if not exists question_provenance (
  question_id uuid primary key references questions (id) on delete cascade,
  origin text not null check (origin in ('legado_nao_registrado', 'autoral', 'autoral_baseada_em_referencias', 'oficial_autorizada')),
  institution text,
  banca text,
  exam_year int,
  source_url text,
  license text,
  consulted_at date,
  content_version int not null default 1 check (content_version >= 1),
  validation_state text not null default 'publicavel'
    check (validation_state in ('rascunho', 'aguardando_revisao', 'em_revisao', 'aprovada_validacao_automatizada',
                                'revisao_especializada_pendente', 'rejeitada', 'desatualizada', 'publicavel')),
  reference_date date,
  expires_at date,
  batch_id uuid references content_batches (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint question_provenance_official_only check (
    origin = 'oficial_autorizada' or (institution is null and banca is null and exam_year is null)),
  constraint question_provenance_official_documented check (
    origin <> 'oficial_autorizada' or (source_url is not null and license is not null and consulted_at is not null))
);
create index if not exists question_provenance_expires_idx on question_provenance (expires_at) where expires_at is not null;
create index if not exists question_provenance_batch_idx on question_provenance (batch_id);

-- Staging: nunca legível por anon/authenticated (RLS ligado, sem policy, sem grant).
create table if not exists content_question_staging (
  id uuid primary key default gen_random_uuid(),
  batch_id uuid not null references content_batches (id) on delete cascade,
  source_key text not null,
  subject text not null,
  topic_key text not null,
  categories text[] not null check (cardinality(categories) between 1 and 3 and categories <@ array['enem', 'vestibular', 'concurso']),
  locale text not null default 'pt-BR',
  prompt text not null,
  options text[] not null check (cardinality(options) = 4),
  correct_index int not null check (correct_index between 0 and 3),
  explanation text not null,
  difficulty text not null check (difficulty in ('facil', 'medio', 'dificil')),
  provenance jsonb not null default '{}'::jsonb,
  validation_state text not null default 'rascunho'
    check (validation_state in ('rascunho', 'aguardando_revisao', 'em_revisao', 'aprovada_validacao_automatizada',
                                'revisao_especializada_pendente', 'rejeitada', 'desatualizada', 'publicavel')),
  reject_reason text,
  reference_date date,
  expires_at date,
  promoted_question_id uuid references questions (id) on delete set null,
  created_at timestamptz not null default now(),
  unique (batch_id, source_key)
);
create index if not exists content_question_staging_state_idx on content_question_staging (batch_id, validation_state);

alter table content_question_staging enable row level security;
alter table content_batches enable row level security;
revoke all on content_question_staging, content_batches from anon, authenticated;

-- Leitura pública dos metadados de classificação (mesma postura de `questions`).
alter table content_categories enable row level security;
alter table question_categories enable row level security;
alter table catalog_node_categories enable row level security;
alter table question_provenance enable row level security;
drop policy if exists "content categories are publicly readable" on content_categories;
create policy "content categories are publicly readable" on content_categories for select using (true);
drop policy if exists "question categories are publicly readable" on question_categories;
create policy "question categories are publicly readable" on question_categories for select using (true);
drop policy if exists "node categories are publicly readable" on catalog_node_categories;
create policy "node categories are publicly readable" on catalog_node_categories for select using (true);
-- Proveniência é interna (inclui estado de validação e URLs de trabalho): sem leitura pública.
revoke all on question_provenance from anon, authenticated;

-- Cobertura: questões ÚNICAS por categoria (questão em 2 categorias conta 1 vez em cada e 1 vez no total).
create or replace view content_coverage with (security_invoker = true) as
select c.code as category,
       count(qc.question_id) as unique_questions
from content_categories c
left join question_categories qc on qc.category = c.code
group by c.code
union all
select 'total_unico', (select count(*) from questions)
union all
select 'sem_categoria', (select count(*) from questions q where not exists (select 1 from question_categories qc where qc.question_id = q.id));

-- Promoção controlada: staging 'publicavel' -> questions (+categorias +proveniência). Só service_role.
create or replace function content_promote_batch(p_batch_code text, p_topic_map jsonb)
returns int
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_batch content_batches%rowtype;
  r content_question_staging%rowtype;
  v_node uuid;
  v_qid uuid;
  v_n int := 0;
begin
  select * into v_batch from content_batches where code = p_batch_code for update;
  if not found then raise exception 'lote % inexistente', p_batch_code; end if;
  for r in select * from content_question_staging where batch_id = v_batch.id and validation_state = 'publicavel'
           and promoted_question_id is null order by source_key loop
    v_node := nullif(p_topic_map ->> r.topic_key, '')::uuid;
    if v_node is null or not exists (select 1 from catalog_nodes where id = v_node) then
      raise exception 'tópico % sem nó de catálogo no mapa', r.topic_key;
    end if;
    -- id determinístico: reimportar o mesmo lote não duplica.
    v_qid := md5('aura-content:' || v_batch.code || ':' || r.source_key)::uuid;
    insert into questions (id, catalog_node_id, prompt, options, correct_index, explanation, difficulty, order_index)
    values (v_qid, v_node, r.prompt, r.options, r.correct_index, r.explanation, r.difficulty, 0)
    on conflict (id) do nothing;
    insert into question_categories (question_id, category)
      select v_qid, unnest(r.categories) on conflict do nothing;
    insert into question_provenance (question_id, origin, institution, banca, exam_year, source_url, license, consulted_at,
                                     content_version, validation_state, reference_date, expires_at, batch_id)
    values (v_qid, coalesce(r.provenance ->> 'origin', 'autoral'), r.provenance ->> 'institution', r.provenance ->> 'banca',
            nullif(r.provenance ->> 'exam_year', '')::int, r.provenance ->> 'source_url', r.provenance ->> 'license',
            nullif(r.provenance ->> 'consulted_at', '')::date, v_batch.version, 'publicavel', r.reference_date, r.expires_at, v_batch.id)
    on conflict (question_id) do nothing;
    update content_question_staging set promoted_question_id = v_qid where id = r.id;
    v_n := v_n + 1;
  end loop;
  update content_batches set status = 'promovido', promoted_at = now() where id = v_batch.id;
  return v_n;
end $$;

-- Reversão segura do lote: só remove questões do lote SEM nenhum vínculo de usuário (progresso, favorito, simulado, reporte).
create or replace function content_unpromote_batch(p_batch_code text)
returns int
language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_batch content_batches%rowtype;
  v_n int;
begin
  select * into v_batch from content_batches where code = p_batch_code for update;
  if not found then raise exception 'lote % inexistente', p_batch_code; end if;
  if exists (
    select 1 from content_question_staging s
    where s.batch_id = v_batch.id and s.promoted_question_id is not null
      and (exists (select 1 from user_question_progress p where p.question_id = s.promoted_question_id)
        or exists (select 1 from user_question_favorites f where f.question_id = s.promoted_question_id)
        or exists (select 1 from mock_exam_items m where m.question_id = s.promoted_question_id)
        or exists (select 1 from question_reports qr where qr.question_id = s.promoted_question_id))
  ) then
    raise exception 'lote % tem questões com histórico de usuário; reverta por desativação, não por remoção', p_batch_code;
  end if;
  delete from questions where id in (select promoted_question_id from content_question_staging
                                     where batch_id = v_batch.id and promoted_question_id is not null);
  get diagnostics v_n = row_count;
  update content_batches set status = 'revertido' where id = v_batch.id;
  return v_n;
end $$;

revoke all on function content_promote_batch(text, jsonb), content_unpromote_batch(text) from public, anon, authenticated;
grant execute on function content_promote_batch(text, jsonb), content_unpromote_batch(text) to service_role;
