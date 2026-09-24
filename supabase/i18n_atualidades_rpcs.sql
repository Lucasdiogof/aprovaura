-- i18n FASE 2: locale-aware Atualidades reads. Same two rules as
-- i18n_catalog_questions_rpcs.sql (p_locale defaults to 'pt-BR' and never
-- joins a translation table; a dossier_question's prompt+options fall back
-- to pt-BR atomically, explanation falls back independently).
--
-- Both RPCs below are NEW: AtualidadesRepositoryImpl.getDossiers() and
-- DossierQuestionRepositoryImpl.getQuestions() used to run plain
-- `.from(...).select()` calls, which can't join a translation table with a
-- runtime locale. Same non-change for p_locale = 'pt-BR' as the catalog
-- ones -- this doesn't touch what NÃO traduzir os 7 dossiês nesta fase
-- means in practice: dossier_translations/dossier_question_translations
-- are empty until FASE 12, so every coalesce here always falls through to
-- the original column regardless of what locale is requested.
--
-- Depends on: dossiers_schema.sql, dossier_questions_schema.sql,
-- i18n_translations_schema.sql. Idempotent: safe to run again.

create or replace function get_dossiers(
  p_area text,
  p_locale text default 'pt-BR'
) returns table (
  id uuid,
  area text,
  title text,
  summary text,
  context text,
  what_happened text,
  why_it_happened text,
  who_is_involved text,
  consequences text,
  key_takeaways text,
  sources text[],
  read_minutes int,
  status text,
  reference_period_start date,
  reference_period_end date,
  order_index int,
  published_at timestamptz,
  updated_at timestamptz
)
language sql
stable
as $$
  select
    d.id,
    d.area,
    coalesce(t.title, d.title),
    coalesce(t.summary, d.summary),
    coalesce(t.context, d.context),
    coalesce(t.what_happened, d.what_happened),
    coalesce(t.why_it_happened, d.why_it_happened),
    coalesce(t.who_is_involved, d.who_is_involved),
    coalesce(t.consequences, d.consequences),
    coalesce(t.key_takeaways, d.key_takeaways),
    d.sources,
    d.read_minutes,
    d.status,
    d.reference_period_start,
    d.reference_period_end,
    d.order_index,
    d.published_at,
    d.updated_at
  from dossiers d
  left join dossier_translations t
    on t.dossier_id = d.id and t.locale = p_locale
  where d.area = p_area
  order by d.order_index;
$$;

create or replace function get_dossier_questions(
  p_dossier_id uuid,
  p_locale text default 'pt-BR'
) returns table (
  id uuid,
  dossier_id uuid,
  prompt text,
  options text[],
  correct_index int,
  explanation text,
  order_index int,
  created_at timestamptz
)
language sql
stable
as $$
  select
    q.id,
    q.dossier_id,
    case when v.ok then qt.prompt else q.prompt end,
    case when v.ok then qt.options else q.options end,
    q.correct_index,
    coalesce(case when v.ok then qt.explanation end, q.explanation),
    q.order_index,
    q.created_at
  from dossier_questions q
  left join dossier_question_translations qt
    on qt.dossier_question_id = q.id and qt.locale = p_locale
  cross join lateral (
    select qt.dossier_question_id is not null
      and array_length(qt.options, 1) = array_length(q.options, 1) as ok
  ) v
  where q.dossier_id = p_dossier_id
  order by q.order_index;
$$;
