-- i18n FASE 2: locale-aware Montar Simulado question text.
--
-- Only get_mock_exam_items() needs this: every other mock exam RPC
-- (availability, create, answer, finish, summary/result) deals in
-- subject/difficulty keys and counts, never displayed question text.
--
-- option_order (mock_exam_items) stores the frozen shuffle as 0-based
-- positions into the ORIGINAL questions.options array -- that math is the
-- same regardless of language. What changes with p_locale is only which
-- array (translated or original) those positions are pulled from, which
-- is exactly why the "translated options must keep the same order as the
-- original" rule in i18n_catalog_questions_rpcs.sql matters here
-- specifically: get_mock_exam_items un-shuffles by position, so index i
-- has to mean the same alternative in every language or this reveals the
-- wrong option as correct after finishing.
--
-- correct_index/is_correct/explanation still only appear once
-- e.status = 'finished', unchanged from before this file.
--
-- Depends on: mock_exams.sql, i18n_translations_schema.sql.
-- Idempotent: safe to run again.

drop function if exists get_mock_exam_items(uuid);

create or replace function get_mock_exam_items(
  p_mock_exam_id uuid,
  p_locale text default 'pt-BR'
)
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
         case when v.ok then qt.prompt else q.prompt end,
         array(
           select (case when v.ok then qt.options else q.options end)[o + 1]
           from unnest(i.option_order) with ordinality as u(o, n)
           order by u.n
         ),
         array_position(i.option_order, i.selected_option) - 1,
         case when e.status = 'finished'
           then array_position(i.option_order, q.correct_index) - 1
         end,
         case when e.status = 'finished' then i.is_correct end,
         case when e.status = 'finished'
           then coalesce(case when v.ok then qt.explanation end, q.explanation)
         end
  from mock_exam_items i
  join mock_exams e on e.id = i.mock_exam_id
  join questions q on q.id = i.question_id
  left join question_translations qt
    on qt.question_id = q.id and qt.locale = p_locale
  cross join lateral (
    select qt.question_id is not null
      and array_length(qt.options, 1) = array_length(q.options, 1) as ok
  ) v
  where i.mock_exam_id = p_mock_exam_id
    and e.user_id = auth.uid()
  order by i.item_position;
$$;
