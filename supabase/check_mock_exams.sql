-- Read-only checkup for mock_exams.sql ("Montar simulado").
--
-- Safe to run anytime, changes nothing. Every row should say "ok".
-- The first block checks the migration applied; the second block checks
-- the data invariants the RPCs are supposed to guarantee (all "ok" on an
-- empty database too -- nothing to violate yet).

-- ---------------------------------------------------------------------------
-- Structure
-- ---------------------------------------------------------------------------

select 'table: mock_exams exists' as check, case
  when to_regclass('public.mock_exams') is not null
  then 'ok' else 'MISSING -- run mock_exams.sql' end as result

union all
select 'table: mock_exam_subject_configs exists', case
  when to_regclass('public.mock_exam_subject_configs') is not null
  then 'ok' else 'MISSING -- run mock_exams.sql' end

union all
select 'table: mock_exam_items exists', case
  when to_regclass('public.mock_exam_items') is not null
  then 'ok' else 'MISSING -- run mock_exams.sql' end

union all
select 'RLS enabled on all 3 mock exam tables', case
  when (
    select count(*) from pg_tables
    where schemaname = 'public'
      and tablename in (
        'mock_exams', 'mock_exam_subject_configs', 'mock_exam_items'
      )
      and rowsecurity
  ) = 3 then 'ok' else 'RLS OFF on some table -- run mock_exams.sql' end

union all
select 'RLS: only select policies (no client writes)', case
  when (
    select count(*) from pg_policies
    where schemaname = 'public'
      and tablename in (
        'mock_exams', 'mock_exam_subject_configs', 'mock_exam_items'
      )
      and cmd = 'SELECT'
  ) = 3
  and not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename in (
        'mock_exams', 'mock_exam_subject_configs', 'mock_exam_items'
      )
      and cmd <> 'SELECT'
  ) then 'ok' else 'UNEXPECTED policies -- review pg_policies' end

union all
select 'unique partial index: one in_progress mock exam per user', case
  when exists (
    select 1 from pg_indexes
    where schemaname = 'public'
      and indexname = 'mock_exams_one_active_per_user'
      and indexdef ilike '%unique%'
      and indexdef ilike '%in_progress%'
  ) then 'ok' else 'MISSING -- run mock_exams.sql' end

union all
select 'column: mock_exams.current_item_position exists', case
  when exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'mock_exams'
      and column_name = 'current_item_position'
  ) then 'ok' else 'MISSING -- run mock_exams.sql again' end

union all
select 'all 10 mock exam RPCs exist (one signature each)', case
  when (
    select count(*) from pg_proc
    where pronamespace = 'public'::regnamespace
      and proname in (
        'get_mock_exam_availability', 'create_mock_exam',
        'get_active_mock_exam', 'get_mock_exam_items',
        'answer_mock_exam_item', 'finish_mock_exam',
        'abandon_mock_exam', 'get_mock_exam_result',
        'get_mock_exam_summary', 'set_mock_exam_position'
      )
  ) = 10 then 'ok' else 'MISSING or DUPLICATED -- run mock_exams.sql' end

union all
select 'write RPCs are security definer', case
  when (
    select count(*) from pg_proc
    where pronamespace = 'public'::regnamespace
      and proname in (
        'create_mock_exam', 'answer_mock_exam_item',
        'finish_mock_exam', 'abandon_mock_exam', 'set_mock_exam_position'
      )
      and prosecdef
  ) = 5 then 'ok' else 'NOT security definer -- run mock_exams.sql' end

union all
select 'get_daily_question_count() also counts mock exam answers', case
  when exists (
    select 1 from pg_proc
    where proname = 'get_daily_question_count'
      and prosrc ilike '%mock_exam_items%'
  ) then 'ok' else 'OLD VERSION -- run mock_exams.sql (section 4)' end

-- ---------------------------------------------------------------------------
-- Data invariants
-- ---------------------------------------------------------------------------

union all
select 'no user has more than one in_progress mock exam', case
  when not exists (
    select 1 from mock_exams
    where status = 'in_progress'
    group by user_id having count(*) > 1
  ) then 'ok' else 'VIOLATED' end

union all
select 'exam mode: no graded item in an unfinished mock exam', case
  when not exists (
    select 1 from mock_exam_items i
    join mock_exams e on e.id = i.mock_exam_id
    where e.status <> 'finished' and i.is_correct is not null
  ) then 'ok' else 'LEAK -- is_correct set before finishing' end

union all
select 'every finished mock exam has its score recorded', case
  when not exists (
    select 1 from mock_exams
    where status = 'finished'
      and (scored_count is null or answered_count is null
           or correct_count is null or finished_at is null)
  ) then 'ok' else 'VIOLATED' end

union all
select 'every finished mock exam has exactly one XP award', case
  when not exists (
    select 1 from mock_exams e
    where e.status = 'finished'
      and (
        select count(*) from xp_awards x
        where x.user_id = e.user_id and x.attempt_id = e.id
      ) <> 1
  ) then 'ok' else 'VIOLATED -- missing or duplicated XP' end

union all
select 'no XP award for abandoned or in-progress mock exams', case
  when not exists (
    select 1 from mock_exams e
    join xp_awards x on x.user_id = e.user_id and x.attempt_id = e.id
    where e.status <> 'finished'
  ) then 'ok' else 'VIOLATED' end

union all
select 'option_order is a full permutation of each question''s options', case
  when not exists (
    select 1 from mock_exam_items i
    join questions q on q.id = i.question_id
    where cardinality(i.option_order) <> cardinality(q.options)
       or (
         select array_agg(o order by o) from unnest(i.option_order) o
       ) <> (
         select array_agg(g order by g)
         from generate_series(0, cardinality(q.options) - 1) g
       )
  ) then 'ok' else 'MISMATCH (question options edited after the exam?)' end

union all
select 'result breakdown uses dimension/key (FASE 6 version)', case
  when exists (
    select 1 from pg_proc
    where proname = 'get_mock_exam_result'
      and prosrc ilike '%grouping sets%'
  ) then 'ok' else 'OLD VERSION -- run mock_exams.sql again' end

union all
select 'finished exams: correct + wrong + blank = total', case
  when not exists (
    select 1 from mock_exams e
    join mock_exam_items i on i.mock_exam_id = e.id
    where e.status = 'finished'
    group by e.id
    having count(*) <> count(*) filter (where i.is_correct)
                     + count(*) filter (where i.is_correct = false)
                     + count(*) filter (where i.selected_option is null)
  ) then 'ok' else 'VIOLATED' end

union all
select 'no mock exam has more than 180 questions', case
  when not exists (
    select 1 from mock_exam_items
    group by mock_exam_id having count(*) > 180
  ) then 'ok' else 'VIOLATED' end

union all
select 'every item matches its exam''s subject config', case
  when not exists (
    select 1 from mock_exam_items i
    left join mock_exam_subject_configs c
      on c.mock_exam_id = i.mock_exam_id and c.subject = i.subject
    where c.subject is null
       or (c.difficulty <> 'misto' and c.difficulty <> i.difficulty)
  ) then 'ok' else 'VIOLATED' end;

-- Bonus (not a check): real availability, the same numbers the app's
-- "Montar simulado" screen will show. Run on its own if you want to see it.
-- select * from get_mock_exam_availability();
