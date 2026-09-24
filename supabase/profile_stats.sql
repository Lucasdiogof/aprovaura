-- Lifetime totals for the Profile screen's progress summary: how many
-- questions the user has ever answered and how many were correct.
-- Derived entirely from user_question_progress (already exists, already
-- has is_correct per row) -- no new table.
--
-- SECURITY INVOKER (default): the existing "users can read their own
-- question progress" policy on user_question_progress already covers
-- this, same as get_daily_question_count() in supabase/daily_goal.sql.
--
-- Run once against a database that already has progress_schema.sql
-- applied.

create or replace function get_profile_stats()
returns table (total_answered integer, correct_answered integer)
language sql
stable
as $$
  select count(*)::int as total_answered,
         count(*) filter (where is_correct)::int as correct_answered
  from user_question_progress
  where user_id = auth.uid();
$$;
