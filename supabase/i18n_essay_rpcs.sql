-- i18n FASE 2: locale-aware Redação theme reads.
--
-- Different fallback rule than questions: essay_themes' fields
-- (title/description/prompt/supporting_texts) have no positional
-- dependency on each other the way a question's options[] is anchored to
-- correct_index -- there's nothing here an inconsistent mix could
-- silently break. So each field falls back to pt-BR independently
-- (coalesce per column), same as catalog_nodes/dossiers, not the
-- "prompt+options together or not at all" rule questions need.
--
-- What NEVER gets translated, on purpose: the essay itself
-- (essay_drafts.body, essay_submissions.body) and everything derived from
-- grading it (essay_evaluations.*). Those are the person's own writing
-- and the model's feedback on it, not reference content -- none of the
-- RPCs below touch those tables' text columns, only essay_themes'.
-- get_essay_submission only translates theme_title; the submission body
-- and evaluation feedback pass through exactly as stored, in whatever
-- language they already are.
--
-- start_essay_evaluation() (essays.sql, section 4) is deliberately left
-- alone: it feeds the Gemini grading prompt from the CANONICAL pt-BR
-- theme (title/prompt/supporting_texts), regardless of which locale the
-- person viewed the theme in before writing -- the essay itself is always
-- written in Portuguese (it's practice for a Portuguese-language exam),
-- so the grading context should be too. Translating what a non-Portuguese
-- reader saw on screen is a display concern; it was never meant to change
-- what the grader reads.
--
-- Depends on: essays.sql, i18n_translations_schema.sql.
-- Idempotent: safe to run again.

drop function if exists list_essay_themes_for_user();

create or replace function list_essay_themes_for_user(p_locale text default 'pt-BR')
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
         coalesce(tt.title, t.title),
         coalesce(tt.description, t.description),
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
  left join essay_theme_translations tt
    on tt.essay_theme_id = t.id and tt.locale = p_locale
  left join last_submission ls on ls.theme_id = t.id
  left join essay_evaluations ev on ev.submission_id = ls.id
  where t.is_active
  order by t.order_index, t.title;
$$;

-- NEW: replaces EssayRepositoryImpl.getTheme()'s plain
-- `.from('essay_themes').select().eq('id', ...)`, same reasoning as
-- catalog_children/get_dossiers -- a runtime locale can't be joined from a
-- plain PostgREST select.
create or replace function get_essay_theme(
  p_theme_id uuid,
  p_locale text default 'pt-BR'
) returns table (
  id uuid,
  title text,
  description text,
  prompt text,
  source_type text,
  exam_name text,
  exam_year integer,
  source_url text,
  supporting_texts jsonb
)
language sql
stable
as $$
  select
    t.id,
    coalesce(tt.title, t.title),
    coalesce(tt.description, t.description),
    coalesce(tt.prompt, t.prompt),
    t.source_type,
    t.exam_name,
    t.exam_year,
    t.source_url,
    coalesce(tt.supporting_texts, t.supporting_texts)
  from essay_themes t
  left join essay_theme_translations tt
    on tt.essay_theme_id = t.id and tt.locale = p_locale
  where t.id = p_theme_id;
$$;

-- get_essay_submission: only theme_title gains p_locale. The submitted
-- body, status, failure_reason and every evaluation column are the
-- person's own attempt and its grading -- never translated, so they don't
-- change with locale.
drop function if exists get_essay_submission(uuid);

create or replace function get_essay_submission(
  p_submission_id uuid,
  p_locale text default 'pt-BR'
) returns table (
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
  select s.id, s.theme_id, coalesce(tt.title, t.title), s.body, s.word_count,
         s.status, s.failure_reason, s.submitted_at, s.evaluated_at,
         ev.total_score, ev.c1_score, ev.c2_score, ev.c3_score, ev.c4_score,
         ev.c5_score, ev.competencies, ev.general_feedback, ev.strengths,
         ev.priority_improvements,
         coalesce(ev.possible_theme_deviation, false),
         coalesce(ev.insufficient_text, false)
  from essay_submissions s
  join essay_themes t on t.id = s.theme_id
  left join essay_theme_translations tt
    on tt.essay_theme_id = t.id and tt.locale = p_locale
  left join essay_evaluations ev on ev.submission_id = s.id
  where s.id = p_submission_id and s.user_id = auth.uid();
$$;
