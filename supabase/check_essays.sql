-- Checkup read-only de essays.sql (Redação).
--
-- Pode rodar a qualquer hora, não muda nada. Todas as linhas devem dizer
-- "ok". O primeiro bloco confere que a migration aplicou; o segundo confere
-- as invariantes que as RPCs deveriam garantir (tudo "ok" num banco vazio
-- também -- não há o que violar ainda).

-- ---------------------------------------------------------------------------
-- Estrutura
-- ---------------------------------------------------------------------------

select 'table: essay_themes exists' as check, case
  when to_regclass('public.essay_themes') is not null
  then 'ok' else 'MISSING -- run essays.sql' end as result

union all
select 'table: essay_drafts exists', case
  when to_regclass('public.essay_drafts') is not null
  then 'ok' else 'MISSING -- run essays.sql' end

union all
select 'table: essay_submissions exists', case
  when to_regclass('public.essay_submissions') is not null
  then 'ok' else 'MISSING -- run essays.sql' end

union all
select 'table: essay_evaluations exists', case
  when to_regclass('public.essay_evaluations') is not null
  then 'ok' else 'MISSING -- run essays.sql' end

union all
select 'table: essay_evaluation_quota exists', case
  when to_regclass('public.essay_evaluation_quota') is not null
  then 'ok' else 'MISSING -- run essays.sql' end

union all
select 'rls: enabled on all five tables', case
  when (select count(*) from pg_class c
        join pg_namespace n on n.oid = c.relnamespace
        where n.nspname = 'public'
          and c.relname in ('essay_themes', 'essay_drafts', 'essay_submissions',
                            'essay_evaluations', 'essay_evaluation_quota')
          and c.relrowsecurity) = 5
  then 'ok' else 'RLS OFF on at least one table' end

union all
select 'rls: no write policy on submissions/evaluations/quota', case
  when (select count(*) from pg_policies
        where schemaname = 'public'
          and tablename in ('essay_submissions', 'essay_evaluations',
                            'essay_evaluation_quota')
          and cmd <> 'SELECT') = 0
  then 'ok' else 'a write policy exists -- writes must go through the RPCs' end

union all
select 'index: one evaluation in flight per user', case
  when to_regclass('public.essay_submissions_one_in_flight_per_user') is not null
  then 'ok' else 'MISSING -- concurrent evaluations would burn the free quota' end

union all
select 'constraint: total_score = sum of competencies', case
  when exists (select 1 from pg_constraint
               where conname = 'essay_evaluations_total_matches_sum')
  then 'ok' else 'MISSING -- a bad payload could save an incoherent score' end

union all
select 'constraint: official themes need exam/year/source', case
  when exists (select 1 from pg_constraint
               where conname = 'essay_themes_official_needs_source')
  then 'ok' else 'MISSING -- a theme could pretend to be from a real exam' end

union all
select 'unique: one evaluation per submission', case
  when exists (
    select 1 from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    where t.relname = 'essay_evaluations' and c.contype = 'u'
      and pg_get_constraintdef(c.oid) like '%(submission_id)%')
  then 'ok' else 'MISSING -- a second call could write a second evaluation' end

union all
select 'rpc: ' || fn || ' exists', case
  when exists (select 1 from pg_proc p
               join pg_namespace n on n.oid = p.pronamespace
               where n.nspname = 'public' and p.proname = fn)
  then 'ok' else 'MISSING -- run essays.sql' end
from unnest(array[
  'list_essay_themes_for_user', 'submit_essay', 'list_essay_attempts',
  'get_essay_submission', 'get_essay_quota', 'start_essay_evaluation',
  'complete_essay_evaluation', 'fail_essay_evaluation',
  'essay_daily_evaluation_limit', 'essay_award_amount',
  'essay_min_word_count', 'essay_word_count'
]) as fn

union all
select 'rpc: writing functions are security definer', case
  when (select count(*) from pg_proc p
        join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public' and p.prosecdef
          and p.proname in ('submit_essay', 'start_essay_evaluation',
                            'complete_essay_evaluation',
                            'fail_essay_evaluation')) = 4
  then 'ok' else 'at least one writing RPC is not security definer' end

union all
select 'rpc: reading functions are NOT security definer', case
  when (select count(*) from pg_proc p
        join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public' and p.prosecdef
          and p.proname in ('list_essay_themes_for_user', 'list_essay_attempts',
                            'get_essay_submission', 'get_essay_quota')) = 0
  then 'ok' else 'a read-only RPC has elevated privilege it does not need' end

union all
select 'config: daily limit is 3', case
  when essay_daily_evaluation_limit() = 3
  then 'ok' else 'limit is ' || essay_daily_evaluation_limit()::text end

union all
select 'config: award is 50 Aura', case
  when essay_award_amount() = 50
  then 'ok' else 'award is ' || essay_award_amount()::text end

union all
select 'seed: practice themes loaded', case
  when (select count(*) from essay_themes where source_type = 'practice') >= 5
  then 'ok' else 'expected at least 5 practice themes' end;

-- ---------------------------------------------------------------------------
-- Invariantes de dados
-- ---------------------------------------------------------------------------

select 'data: no theme fakes an official exam' as check, case
  when not exists (
    select 1 from essay_themes
    where source_type = 'practice'
      and (exam_name is not null or exam_year is not null or source_url is not null))
  then 'ok' else 'a practice theme carries exam metadata' end as result

union all
select 'data: every evaluation belongs to its submission''s owner', case
  when not exists (
    select 1 from essay_evaluations ev
    join essay_submissions s on s.id = ev.submission_id
    where ev.user_id <> s.user_id)
  then 'ok' else 'an evaluation is attributed to the wrong user' end

union all
select 'data: evaluated submissions have an evaluation', case
  when not exists (
    select 1 from essay_submissions s
    where s.status = 'evaluated'
      and not exists (select 1 from essay_evaluations ev
                      where ev.submission_id = s.id))
  then 'ok' else 'a submission says evaluated with no evaluation row' end

union all
select 'data: only evaluated submissions have an evaluation', case
  when not exists (
    select 1 from essay_evaluations ev
    join essay_submissions s on s.id = ev.submission_id
    where s.status <> 'evaluated')
  then 'ok' else 'an evaluation hangs off a submission that is not evaluated' end

union all
select 'data: at most one evaluation in flight per user', case
  when not exists (
    select 1 from essay_submissions
    where status = 'evaluating'
    group by user_id having count(*) > 1)
  then 'ok' else 'a user has two evaluations in flight' end

union all
select 'data: nobody exceeded the daily limit', case
  when not exists (
    select 1 from essay_evaluation_quota
    group by user_id, quota_date
    having count(*) > essay_daily_evaluation_limit())
  then 'ok' else 'a user got more evaluations in a day than the limit' end

union all
select 'data: Aura credited at most once per submission', case
  when not exists (
    select 1 from xp_awards a
    join essay_submissions s on s.id = a.attempt_id
    group by a.user_id, a.attempt_id having count(*) > 1)
  then 'ok' else 'a submission was credited twice' end

union all
select 'data: Aura for essays is always the award amount', case
  when not exists (
    select 1 from xp_awards a
    join essay_submissions s on s.id = a.attempt_id
    where a.amount <> essay_award_amount())
  then 'ok' else 'an essay award has an unexpected amount' end

union all
select 'data: only evaluated submissions were credited', case
  when not exists (
    select 1 from xp_awards a
    join essay_submissions s on s.id = a.attempt_id
    where s.status <> 'evaluated')
  then 'ok' else 'Aura was credited for a submission that is not evaluated' end

union all
select 'data: submitted text is never empty', case
  when not exists (select 1 from essay_submissions where length(btrim(body)) = 0)
  then 'ok' else 'an empty essay was submitted' end;
