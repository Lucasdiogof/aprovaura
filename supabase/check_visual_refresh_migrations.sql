-- Read-only checkup for the 5 migrations created during the visual refresh
-- (FASES 3, 4, 6, 7): daily_goal.sql, quiz_xp_ledger.sql,
-- question_reports.sql, profile_stats.sql, progress_domain_only.sql.
--
-- Safe to run anytime, doesn't change anything. Every row should say "ok".
-- Anything else means that migration didn't fully apply.

select 'function: get_daily_question_count() exists' as check, case
  when exists (
    select 1 from pg_proc where proname = 'get_daily_question_count'
  ) then 'ok' else 'MISSING -- run daily_goal.sql' end as result

union all
select 'function: award_quiz_xp() exists', case
  when exists (select 1 from pg_proc where proname = 'award_quiz_xp')
  then 'ok' else 'MISSING -- run quiz_xp_ledger.sql' end

union all
select 'function: old award_activity_xp() was dropped', case
  when exists (select 1 from pg_proc where proname = 'award_activity_xp')
  then 'STILL THERE -- run quiz_xp_ledger.sql (it drops this)'
  else 'ok' end

union all
select 'table: xp_awards exists', case
  when exists (
    select 1 from information_schema.tables
    where table_name = 'xp_awards'
  ) then 'ok' else 'MISSING -- run quiz_xp_ledger.sql' end

union all
select 'table: xp_awards has RLS enabled', case
  when exists (
    select 1 from pg_tables
    where tablename = 'xp_awards' and rowsecurity
  ) then 'ok' else 'RLS OFF -- run quiz_xp_ledger.sql' end

union all
select 'function: get_profile_stats() exists', case
  when exists (select 1 from pg_proc where proname = 'get_profile_stats')
  then 'ok' else 'MISSING -- run profile_stats.sql' end

union all
select 'table: question_reports exists', case
  when exists (
    select 1 from information_schema.tables
    where table_name = 'question_reports'
  ) then 'ok' else 'MISSING -- run question_reports.sql' end

union all
select 'table: question_reports has RLS enabled', case
  when exists (
    select 1 from pg_tables
    where tablename = 'question_reports' and rowsecurity
  ) then 'ok' else 'RLS OFF -- run question_reports.sql' end

union all
select 'policy: question_reports insert policy exists', case
  when exists (
    select 1 from pg_policies
    where tablename = 'question_reports' and cmd = 'INSERT'
  ) then 'ok' else 'MISSING -- run question_reports.sql' end

union all
-- The real point of progress_domain_only.sql: catalog_node_progress()'s
-- body must reference is_correct now, not just count(up.question_id).
select 'function: catalog_node_progress() counts only correct answers', case
  when pg_get_functiondef('catalog_node_progress(uuid[], text)'::regprocedure)
    like '%filter (where up.is_correct)%'
  then 'ok'
  else 'STALE -- run progress_domain_only.sql' end;
