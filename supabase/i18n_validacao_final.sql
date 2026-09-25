-- i18n FASE 15: final validation of all translated content. Read-only.
--
-- One result set (the SQL Editor only shows the last one). Every row with
-- ok = false is a problem. Rows whose item starts with "info:" are
-- informational only and always ok = true.
--
-- Covers the five *_translations tables. Map region names live in Dart
-- (lib/features/map_quiz/l10n/map_region_names.dart) and are checked by
-- test/features/map_quiz/map_region_names_test.dart instead.
--
-- What is checked:
--   1. coverage: every original row has an en and an es translation;
--   2. options: a translated question has exactly as many options as the
--      original (correct_index is positional and is only ever read from the
--      original row, so equal cardinality is what keeps the right answer
--      marked);
--   3. no blank option, prompt or title;
--   4. explanation parity: a translation has an explanation iff the
--      original does (a missing one would silently fall back to... nothing,
--      since the RPC uses the translated row as a unit);
--   5. info: prompts identical to the pt-BR original (may be legitimate,
--      e.g. a name, but worth a glance).

with locales(locale) as (values ('en'), ('es')),
coverage as (
  select 'coverage catalog_nodes ' || l.locale as item,
         (select count(*) from catalog_node_translations t where t.locale = l.locale) as got,
         (select count(*) from catalog_nodes) as want
  from locales l
  union all
  select 'coverage questions ' || l.locale,
         (select count(*) from question_translations t where t.locale = l.locale),
         (select count(*) from questions)
  from locales l
  union all
  select 'coverage dossiers ' || l.locale,
         (select count(*) from dossier_translations t where t.locale = l.locale),
         (select count(*) from dossiers)
  from locales l
  union all
  select 'coverage dossier_questions ' || l.locale,
         (select count(*) from dossier_question_translations t where t.locale = l.locale),
         (select count(*) from dossier_questions)
  from locales l
  union all
  select 'coverage essay_themes ' || l.locale,
         (select count(*) from essay_theme_translations t where t.locale = l.locale),
         (select count(*) from essay_themes)
  from locales l
),
problems(item, n) as (
  select 'questions: option count differs', count(*)
  from question_translations t join questions q on q.id = t.question_id
  where cardinality(t.options) <> cardinality(q.options)
  union all
  select 'dossier_questions: option count differs', count(*)
  from dossier_question_translations t join dossier_questions q on q.id = t.dossier_question_id
  where cardinality(t.options) <> cardinality(q.options)
  union all
  select 'questions: blank prompt or option', count(*)
  from question_translations t
  where btrim(t.prompt) = ''
     or exists (select 1 from unnest(t.options) o where coalesce(btrim(o), '') = '')
  union all
  select 'dossier_questions: blank prompt or option', count(*)
  from dossier_question_translations t
  where btrim(t.prompt) = ''
     or exists (select 1 from unnest(t.options) o where coalesce(btrim(o), '') = '')
  union all
  select 'blank titles (catalog, dossiers, essays)', count(*)
  from (
    select title from catalog_node_translations
    union all select title from dossier_translations
    union all select title from essay_theme_translations
  ) x
  where btrim(title) = ''
  union all
  select 'questions: explanation parity', count(*)
  from question_translations t join questions q on q.id = t.question_id
  where (nullif(btrim(t.explanation), '') is null) <> (nullif(btrim(q.explanation), '') is null)
  union all
  select 'dossier_questions: explanation parity', count(*)
  from dossier_question_translations t join dossier_questions q on q.id = t.dossier_question_id
  where (nullif(btrim(t.explanation), '') is null) <> (nullif(btrim(q.explanation), '') is null)
),
info(item, n) as (
  select 'info: question prompts identical to pt-BR', count(*)
  from question_translations t join questions q on q.id = t.question_id
  where t.prompt = q.prompt
  union all
  select 'info: catalog titles identical to pt-BR', count(*)
  from catalog_node_translations t join catalog_nodes c on c.id = t.catalog_node_id
  where t.title = c.title
)
select item, got || '/' || want as detail, got = want as ok from coverage
union all
select item, n::text, n = 0 from problems
union all
select item, n::text, true from info
order by ok, item;
