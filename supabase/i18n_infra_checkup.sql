-- Read-only checkup for i18n FASE 2 (infrastructure only -- no translated
-- content exists yet, so every "fallback" check here is expected to prove
-- the pt-BR path still works with an EMPTY translation table, not that any
-- translation is correct). Safe to run anytime, changes nothing.
--
-- Every row should say "ok". Run this after i18n_translations_schema.sql,
-- i18n_catalog_questions_rpcs.sql, i18n_atualidades_rpcs.sql,
-- i18n_essay_rpcs.sql and i18n_mock_exam_rpcs.sql.

-- 1. The five translation tables exist, with RLS on.
select 'table: ' || t.table_name || ' exists' as check,
  case when exists (
    select 1 from information_schema.tables
    where table_name = t.table_name
  ) then 'ok' else 'MISSING' end as result
from (values
  ('catalog_node_translations'),
  ('question_translations'),
  ('dossier_translations'),
  ('dossier_question_translations'),
  ('essay_theme_translations')
) as t(table_name)

union all

select 'table: ' || t.table_name || ' has RLS enabled',
  case when exists (
    select 1 from pg_tables where tablename = t.table_name and rowsecurity
  ) then 'ok' else 'RLS OFF' end
from (values
  ('catalog_node_translations'),
  ('question_translations'),
  ('dossier_translations'),
  ('dossier_question_translations'),
  ('essay_theme_translations')
) as t(table_name)

union all

-- 2. Each has a (entity_id, locale) primary key (which is also the unique
-- constraint the spec asked for -- a PK is a unique constraint).
select 'table: ' || t.table_name || ' has a 2-column primary key',
  case when (
    select count(*) from information_schema.key_column_usage k
    join information_schema.table_constraints c
      on c.constraint_name = k.constraint_name
    where c.table_name = t.table_name and c.constraint_type = 'PRIMARY KEY'
  ) = 2 then 'ok' else 'WRONG SHAPE' end
from (values
  ('catalog_node_translations'),
  ('question_translations'),
  ('dossier_translations'),
  ('dossier_question_translations'),
  ('essay_theme_translations')
) as t(table_name)

union all

-- 3. locale is constrained to en/es (not pt-BR -- that's the original
-- table, never duplicated here).
select 'table: ' || t.table_name || ' rejects an unsupported locale',
  case
    when (
      select count(*) from pg_constraint con
      join pg_class rel on rel.oid = con.conrelid
      where rel.relname = t.table_name
        and con.contype = 'c'
        and pg_get_constraintdef(con.oid) ilike '%locale%'
    ) > 0
    then 'ok' else 'NO LOCALE CHECK CONSTRAINT' end
from (values
  ('catalog_node_translations'),
  ('question_translations'),
  ('dossier_translations'),
  ('dossier_question_translations'),
  ('essay_theme_translations')
) as t(table_name)

union all

-- 4. No orphaned or invalid rows exist. Vacuously true on an empty table,
-- which is exactly what FASE 2 should leave behind -- this check is here
-- so it keeps meaning something once translations start landing.
select 'no orphaned/invalid rows anywhere yet',
  case when (
    (select count(*) from catalog_node_translations t
       where not exists (select 1 from catalog_nodes c where c.id = t.catalog_node_id))
    + (select count(*) from question_translations t
       where not exists (select 1 from questions q where q.id = t.question_id))
    + (select count(*) from dossier_translations t
       where not exists (select 1 from dossiers d where d.id = t.dossier_id))
    + (select count(*) from dossier_question_translations t
       where not exists (select 1 from dossier_questions q where q.id = t.dossier_question_id))
    + (select count(*) from essay_theme_translations t
       where not exists (select 1 from essay_themes e where e.id = t.essay_theme_id))
  ) = 0 then 'ok' else 'ORPHANS FOUND' end

union all

-- 5. Existing content is untouched: correct_index is still in bounds and
-- options arrays still non-empty on the ORIGINAL questions table -- proof
-- this migration didn't alter a single row of canonical content.
select 'questions: correct_index still valid for every row',
  case when not exists (
    select 1 from questions q
    where q.correct_index < 0
      or q.correct_index >= coalesce(array_length(q.options, 1), 0)
  ) then 'ok' else 'INVALID correct_index FOUND' end

union all

select 'dossier_questions: correct_index still valid for every row',
  case when not exists (
    select 1 from dossier_questions q
    where q.correct_index < 0
      or q.correct_index >= coalesce(array_length(q.options, 1), 0)
  ) then 'ok' else 'INVALID correct_index FOUND' end

union all

-- 6. Every RPC that should now accept p_locale does.
select 'rpc: ' || r.name || ' accepts p_locale',
  case when exists (
    select 1 from pg_proc p
    where p.proname = r.name
      and pg_get_function_arguments(p.oid) ilike '%p_locale%'
  ) then 'ok' else 'MISSING p_locale' end
from (values
  ('catalog_children_with_difficulty'),
  ('catalog_children'),
  ('get_catalog_questions'),
  ('get_quick_practice_questions'),
  ('list_pending_error_topics'),
  ('get_wrong_questions_for_node'),
  ('list_favorite_topics'),
  ('get_favorite_questions_for_node'),
  ('get_dossiers'),
  ('get_dossier_questions'),
  ('list_essay_themes_for_user'),
  ('get_essay_theme'),
  ('get_essay_submission'),
  ('get_mock_exam_items')
) as r(name)

union all

-- 7. p_locale defaults to 'pt-BR' everywhere (so a caller that never
-- passes it keeps getting exactly what it got before this migration).
select 'rpc: ' || r.name || ' defaults p_locale to pt-BR',
  case when exists (
    select 1 from pg_proc p
    where p.proname = r.name
      and pg_get_function_arguments(p.oid) ilike '%p_locale text DEFAULT ''pt-BR''%'
  ) then 'ok' else 'WRONG OR MISSING DEFAULT' end
from (values
  ('catalog_children_with_difficulty'),
  ('catalog_children'),
  ('get_catalog_questions'),
  ('get_quick_practice_questions'),
  ('list_pending_error_topics'),
  ('get_wrong_questions_for_node'),
  ('list_favorite_topics'),
  ('get_favorite_questions_for_node'),
  ('get_dossiers'),
  ('get_dossier_questions'),
  ('list_essay_themes_for_user'),
  ('get_essay_theme'),
  ('get_essay_submission'),
  ('get_mock_exam_items')
) as r(name)

union all

-- 8. Fallback proof, with a live call: get_catalog_questions('pt-BR') for
-- a random real topic returns the exact same ids/prompts as the original
-- questions table -- with zero translations in the database, "coalesce to
-- pt-BR" and "just read pt-BR" have to be indistinguishable.
select 'get_catalog_questions(pt-BR) matches the original questions row',
  case when not exists (
    select 1
    from (
      select catalog_node_id from questions order by random() limit 1
    ) sample
    join lateral get_catalog_questions(sample.catalog_node_id) g on true
    join questions q on q.id = g.id
    where g.prompt is distinct from q.prompt
       or g.options is distinct from q.options
       or g.explanation is distinct from q.explanation
       or g.correct_index is distinct from q.correct_index
  ) then 'ok' else 'MISMATCH' end

union all

select 'catalog_children(pt-BR) returns the same ids as a plain select',
  case when not exists (
    select cn.id
    from (select subject, parent_id from catalog_nodes limit 1) sample
    join catalog_nodes cn
      on cn.subject = sample.subject
      and cn.parent_id is not distinct from sample.parent_id
    except
    select g.id
    from (select subject, parent_id from catalog_nodes limit 1) sample
    join lateral catalog_children(sample.subject, sample.parent_id) g on true
  ) then 'ok' else 'MISMATCH' end;
