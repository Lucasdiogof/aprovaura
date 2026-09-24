-- i18n FASE 2: locale-aware catalog + question reads.
--
-- Every RPC below follows the same two rules:
--
-- 1. p_locale defaults to 'pt-BR', which never joins
--    catalog_node_translations/question_translations at all (their CHECK
--    only allows 'en'/'es') -- a caller that doesn't pass p_locale gets
--    back exactly what it got before this file existed. That's how
--    "don't break existing calls" is satisfied structurally, not just by
--    promise.
--
-- 2. A question's prompt+options are translated ATOMICALLY: a translation
--    row only counts as usable when it exists for this locale AND has the
--    same number of options as the original (see i18n_translations_schema.sql
--    -- an incomplete translation is exactly as unusable as no translation).
--    When it doesn't count, prompt AND options both fall back to pt-BR
--    together -- never prompt in one language with options in another.
--    explanation, on the other hand, falls back independently: it's not
--    part of what "get_catalog_questions.correct_index" is anchored to, so
--    a missing/short translated explanation just shows the pt-BR one next
--    to an otherwise-translated question.
--
-- This is also the reason a translated `options` array MUST preserve the
-- exact same order as the original: Montar Simulado's
-- get_mock_exam_items() un-shuffles by *position* via option_order, which
-- only works if index i in every language's options means the same
-- alternative. That's not just a style preference here -- swapping order
-- would silently point option_order at the wrong translated text.
--
-- Depends on: catalog_schema.sql, questions_schema.sql,
-- catalog_manual_difficulty.sql, quick_practice.sql, error_review_schema.sql,
-- favorites_schema.sql, i18n_translations_schema.sql.
-- Idempotent: safe to run again.

-- ---------------------------------------------------------------------------
-- 1. Catalog nodes
-- ---------------------------------------------------------------------------

-- 1.1 Difficulty-filtered children (existing RPC, now locale-aware).
drop function if exists catalog_children_with_difficulty(text, uuid, text);

create or replace function catalog_children_with_difficulty(
  p_subject text,
  p_parent uuid,
  p_difficulty text,
  p_locale text default 'pt-BR'
) returns table (
  id uuid,
  subject text,
  parent_id uuid,
  title text,
  description text,
  icon text,
  order_index int,
  created_at timestamptz,
  manual_difficulty text
)
language sql
stable
as $$
  with recursive descendants as (
    select n.id, n.id as branch_root
    from catalog_nodes n
    where n.subject = p_subject
      and n.parent_id is not distinct from p_parent
    union all
    select c.id, d.branch_root
    from catalog_nodes c
    join descendants d on c.parent_id = d.id
  )
  select cn.id,
         cn.subject,
         cn.parent_id,
         coalesce(t.title, cn.title) as title,
         coalesce(t.description, cn.description) as description,
         cn.icon,
         cn.order_index,
         cn.created_at,
         cn.manual_difficulty
  from catalog_nodes cn
  left join catalog_node_translations t
    on t.catalog_node_id = cn.id and t.locale = p_locale
  where cn.subject = p_subject
    and cn.parent_id is not distinct from p_parent
    and (
      cn.manual_difficulty = p_difficulty
      or exists (
        select 1
        from descendants d
        join questions q on q.catalog_node_id = d.id
        where d.branch_root = cn.id
          and q.difficulty = p_difficulty
      )
    )
  order by cn.order_index;
$$;

-- 1.2 Unfiltered children ("Todos"). NEW: replaces the plain
-- `.from('catalog_nodes').select()` the client used to run directly --
-- that path can't join a translation table with a locale parameter, and
-- reads the same rows this RPC now returns for p_locale = 'pt-BR', so
-- nothing about what shows up changes, only where the coalesce happens.
create or replace function catalog_children(
  p_subject text,
  p_parent uuid,
  p_locale text default 'pt-BR'
) returns table (
  id uuid,
  subject text,
  parent_id uuid,
  title text,
  description text,
  icon text,
  order_index int,
  created_at timestamptz,
  manual_difficulty text
)
language sql
stable
as $$
  select cn.id,
         cn.subject,
         cn.parent_id,
         coalesce(t.title, cn.title) as title,
         coalesce(t.description, cn.description) as description,
         cn.icon,
         cn.order_index,
         cn.created_at,
         cn.manual_difficulty
  from catalog_nodes cn
  left join catalog_node_translations t
    on t.catalog_node_id = cn.id and t.locale = p_locale
  where cn.subject = p_subject
    and cn.parent_id is not distinct from p_parent
  order by cn.order_index;
$$;

-- ---------------------------------------------------------------------------
-- 2. Questions
-- ---------------------------------------------------------------------------

-- 2.1 A topic's own question bank. NEW: replaces the plain
-- `.from('questions').select()` path (QuestionRepositoryImpl), same
-- reasoning as catalog_children above.
create or replace function get_catalog_questions(
  p_catalog_node_id uuid,
  p_difficulty text default null,
  p_locale text default 'pt-BR'
) returns table (
  id uuid,
  prompt text,
  options text[],
  correct_index int,
  explanation text,
  difficulty text
)
language sql
stable
as $$
  select
    q.id,
    case when v.ok then qt.prompt else q.prompt end as prompt,
    case when v.ok then qt.options else q.options end as options,
    q.correct_index,
    coalesce(case when v.ok then qt.explanation end, q.explanation)
      as explanation,
    q.difficulty
  from questions q
  left join question_translations qt
    on qt.question_id = q.id and qt.locale = p_locale
  cross join lateral (
    select qt.question_id is not null
      and array_length(qt.options, 1) = array_length(q.options, 1) as ok
  ) v
  where q.catalog_node_id = p_catalog_node_id
    and (p_difficulty is null or q.difficulty = p_difficulty)
  order by q.order_index;
$$;

-- 2.2 Prática Rápida deck (existing RPC, now locale-aware). Selection
-- itself is untouched: still "never answered", still one per subject per
-- round, still random -- only the text of what comes back changes.
create or replace function get_quick_practice_questions(
  p_limit integer default 10,
  p_locale text default 'pt-BR'
)
returns table (
  id uuid,
  catalog_node_id uuid,
  prompt text,
  options text[],
  correct_index int,
  explanation text,
  difficulty text,
  subject text
)
language sql
stable
as $$
  with unanswered as (
    select q.id,
           q.catalog_node_id,
           q.prompt,
           q.options,
           q.correct_index,
           q.explanation,
           q.difficulty,
           cn.subject,
           row_number() over (
             partition by cn.subject order by random()
           ) as round_index
    from questions q
    join catalog_nodes cn on cn.id = q.catalog_node_id
    where not exists (
      select 1
      from user_question_progress up
      where up.user_id = auth.uid()
        and up.question_id = q.id
    )
  )
  select
    u.id,
    u.catalog_node_id,
    case when v.ok then qt.prompt else u.prompt end,
    case when v.ok then qt.options else u.options end,
    u.correct_index,
    coalesce(case when v.ok then qt.explanation end, u.explanation),
    u.difficulty,
    u.subject
  from unanswered u
  left join question_translations qt
    on qt.question_id = u.id and qt.locale = p_locale
  cross join lateral (
    select qt.question_id is not null
      and array_length(qt.options, 1) = array_length(u.options, 1) as ok
  ) v
  order by u.round_index, random()
  limit greatest(p_limit, 1);
$$;

-- ---------------------------------------------------------------------------
-- 3. Revisar erros
-- ---------------------------------------------------------------------------

-- 3.1 Topic grouping (existing RPC, now locale-aware titles).
create or replace function list_pending_error_topics(p_locale text default 'pt-BR')
returns table (
  catalog_node_id uuid,
  subject text,
  title text,
  parent_title text,
  wrong_count integer,
  last_wrong_at timestamptz
)
language sql
stable
as $$
  select q.catalog_node_id,
         cn.subject,
         coalesce(t.title, cn.title) as title,
         coalesce(pt.title, parent.title) as parent_title,
         count(*)::int as wrong_count,
         max(up.updated_at) as last_wrong_at
  from user_question_progress up
  join questions q on q.id = up.question_id
  join catalog_nodes cn on cn.id = q.catalog_node_id
  left join catalog_nodes parent on parent.id = cn.parent_id
  left join catalog_node_translations t
    on t.catalog_node_id = cn.id and t.locale = p_locale
  left join catalog_node_translations pt
    on pt.catalog_node_id = parent.id and pt.locale = p_locale
  where up.user_id = auth.uid()
    and up.is_correct = false
  group by q.catalog_node_id, cn.subject, cn.title, t.title, parent.title, pt.title
  order by last_wrong_at desc;
$$;

-- 3.2 The wrong questions for one topic (existing RPC, now locale-aware,
-- explicit columns instead of `returns setof questions`).
drop function if exists get_wrong_questions_for_node(uuid);

create or replace function get_wrong_questions_for_node(
  p_catalog_node_id uuid,
  p_locale text default 'pt-BR'
) returns table (
  id uuid,
  catalog_node_id uuid,
  prompt text,
  options text[],
  correct_index int,
  explanation text,
  order_index int,
  difficulty text,
  created_at timestamptz
)
language sql
stable
as $$
  select
    q.id,
    q.catalog_node_id,
    case when v.ok then qt.prompt else q.prompt end,
    case when v.ok then qt.options else q.options end,
    q.correct_index,
    coalesce(case when v.ok then qt.explanation end, q.explanation),
    q.order_index,
    q.difficulty,
    q.created_at
  from questions q
  join user_question_progress up on up.question_id = q.id
  left join question_translations qt
    on qt.question_id = q.id and qt.locale = p_locale
  cross join lateral (
    select qt.question_id is not null
      and array_length(qt.options, 1) = array_length(q.options, 1) as ok
  ) v
  where q.catalog_node_id = p_catalog_node_id
    and up.user_id = auth.uid()
    and up.is_correct = false
  order by q.order_index;
$$;

-- ---------------------------------------------------------------------------
-- 4. Favoritos
-- ---------------------------------------------------------------------------

-- 4.1 Topic grouping (existing RPC, now locale-aware titles).
create or replace function list_favorite_topics(p_locale text default 'pt-BR')
returns table (
  catalog_node_id uuid,
  subject text,
  title text,
  parent_title text,
  favorite_count integer,
  last_favorited_at timestamptz
)
language sql
stable
as $$
  select q.catalog_node_id,
         cn.subject,
         coalesce(t.title, cn.title) as title,
         coalesce(pt.title, parent.title) as parent_title,
         count(*)::int as favorite_count,
         max(f.created_at) as last_favorited_at
  from user_question_favorites f
  join questions q on q.id = f.question_id
  join catalog_nodes cn on cn.id = q.catalog_node_id
  left join catalog_nodes parent on parent.id = cn.parent_id
  left join catalog_node_translations t
    on t.catalog_node_id = cn.id and t.locale = p_locale
  left join catalog_node_translations pt
    on pt.catalog_node_id = parent.id and pt.locale = p_locale
  where f.user_id = auth.uid()
  group by q.catalog_node_id, cn.subject, cn.title, t.title, parent.title, pt.title
  order by last_favorited_at desc;
$$;

-- 4.2 The favorited questions for one topic (existing RPC, now
-- locale-aware, explicit columns instead of `returns setof questions`).
drop function if exists get_favorite_questions_for_node(uuid);

create or replace function get_favorite_questions_for_node(
  p_catalog_node_id uuid,
  p_locale text default 'pt-BR'
) returns table (
  id uuid,
  catalog_node_id uuid,
  prompt text,
  options text[],
  correct_index int,
  explanation text,
  order_index int,
  difficulty text,
  created_at timestamptz
)
language sql
stable
as $$
  select
    q.id,
    q.catalog_node_id,
    case when v.ok then qt.prompt else q.prompt end,
    case when v.ok then qt.options else q.options end,
    q.correct_index,
    coalesce(case when v.ok then qt.explanation end, q.explanation),
    q.order_index,
    q.difficulty,
    q.created_at
  from questions q
  join user_question_favorites f on f.question_id = q.id
  left join question_translations qt
    on qt.question_id = q.id and qt.locale = p_locale
  cross join lateral (
    select qt.question_id is not null
      and array_length(qt.options, 1) = array_length(q.options, 1) as ok
  ) v
  where q.catalog_node_id = p_catalog_node_id
    and f.user_id = auth.uid()
  order by q.order_index;
$$;
