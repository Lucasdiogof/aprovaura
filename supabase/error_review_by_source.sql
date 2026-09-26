-- "Revisar erros" mixed mock-exam wrong answers together with regular
-- practice wrong answers -- both wrote the same user_question_progress
-- row (one per question, last answer wins), with nothing recording which
-- kind of attempt it came from. This adds that: a `source` column, set by
-- whichever RPC does the write, and a filter on list_pending_error_topics
-- so the app can show "da prática" and "dos simulados" separately.
--
-- Honest limit, same one the table already had before this: only the
-- MOST RECENT attempt's source is known, not full history. If a question
-- was last answered wrong in a mock exam, it shows as a mock-exam error
-- even if it was also gotten wrong in practice before that -- exactly how
-- is_correct itself already only reflects the latest attempt. Existing
-- rows default to 'practice' (there's no way to recover their real origin
-- retroactively).
--
-- Idempotent: safe to run again (the Supabase SQL editor isn't
-- transactional -- if it stops partway, just run the whole file again).
--
-- Depende de: progress_schema.sql, error_review_schema.sql,
-- i18n_catalog_questions_rpcs.sql (list_pending_error_topics(p_locale)),
-- mock_exams.sql (finish_mock_exam).

alter table user_question_progress
  add column if not exists source text not null default 'practice'
    check (source in ('practice', 'mock_exam'));

-- Stale overloads from before this file (a leftover 0-arg version from
-- before the i18n p_locale param was added, plus the 1-arg version this
-- file replaces with a 2-arg one) -- Postgres tells overloads apart by
-- argument types, so create or replace alone would leave both behind.
drop function if exists list_pending_error_topics();
drop function if exists list_pending_error_topics(text);

create function list_pending_error_topics(
  p_locale text default 'pt-BR',
  p_source text default null
)
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
    and (p_source is null or up.source = p_source)
  group by q.catalog_node_id, cn.subject, cn.title, t.title, parent.title, pt.title
  order by last_wrong_at desc;
$$;

-- Same as progress_schema.sql's version, plus tagging the row 'practice'.
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

  insert into user_question_progress
    (user_id, question_id, is_correct, source, answered_at, updated_at)
  values (v_user_id, p_question_id, p_is_correct, 'practice', now(), now())
  on conflict (user_id, question_id)
  do update set is_correct = excluded.is_correct,
                source = 'practice',
                updated_at = now();
end;
$$;

-- Same as mock_exams.sql's version, plus tagging the row 'mock_exam'.
create or replace function finish_mock_exam(p_mock_exam_id uuid)
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
    (user_id, question_id, is_correct, source, answered_at, updated_at)
  select v_user_id, i.question_id, i.is_correct, 'mock_exam', i.answered_at, i.answered_at
  from mock_exam_items i
  where i.mock_exam_id = p_mock_exam_id
    and i.selected_option is not null
  on conflict (user_id, question_id)
  do update set is_correct = excluded.is_correct,
                source = 'mock_exam',
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
