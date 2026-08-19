-- Progresso por pergunta: cada questao respondida conta uma unica vez pra
-- cada usuario (acerto ou erro, tanto faz), e o progresso de qualquer no
-- da arvore de catalogo (materia/conteudo/atividade) e sempre derivado
-- somando as questoes das folhas descendentes -- nunca armazenado direto.

create table if not exists user_question_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  question_id uuid not null references questions (id) on delete cascade,
  is_correct boolean not null,
  answered_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, question_id)
);

create index if not exists user_question_progress_user_idx
  on user_question_progress (user_id);

alter table user_question_progress enable row level security;

-- No insert/update policy on purpose, same as user_streaks: writes only
-- happen through register_question_answered() below.
create policy "users can read their own question progress"
  on user_question_progress for select
  using (auth.uid() = user_id);

-- Called when an answer is confirmed (selection locked in, not just tapped).
-- Upserts so re-answering the same question updates is_correct/answered_at
-- without creating a second row -- that's what keeps each question worth
-- at most 1 toward progress no matter how many times it's retried.
create or replace function register_question_answered(
  p_question_id uuid,
  p_is_correct boolean
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

  insert into user_question_progress (user_id, question_id, is_correct, answered_at, updated_at)
  values (v_user_id, p_question_id, p_is_correct, now(), now())
  on conflict (user_id, question_id)
  do update set is_correct = excluded.is_correct, updated_at = now();
end;
$$;

-- Batch progress for a set of catalog_nodes in one round trip (avoids one
-- query per card): for each id in p_node_ids, walks its subtree down to the
-- leaves via a recursive CTE, sums the leaves' questions as "total", and
-- counts how many of those the caller has answered as "completed". A node
-- with zero descendant questions simply doesn't appear in the result --
-- the client treats a missing id as 0/0 (0%), never 100%.
-- p_difficulty narrows both total and completed to that level, so the bars
-- match whatever level the topic list is currently filtered to (null/omitted
-- means "Todos" -- every difficulty counts, same as before).
create or replace function catalog_node_progress(
  p_node_ids uuid[],
  p_difficulty text default null
)
returns table (node_id uuid, total integer, completed integer)
language sql
stable
as $$
  with recursive descendants as (
    select n.id, n.id as branch_root
    from catalog_nodes n
    where n.id = any(p_node_ids)
    union all
    select c.id, d.branch_root
    from catalog_nodes c
    join descendants d on c.parent_id = d.id
  )
  select d.branch_root as node_id,
         count(q.id)::int as total,
         count(up.question_id)::int as completed
  from descendants d
  join questions q on q.catalog_node_id = d.id
  left join user_question_progress up
    on up.question_id = q.id and up.user_id = auth.uid()
  where p_difficulty is null or q.difficulty = p_difficulty
  group by d.branch_root;
$$;
