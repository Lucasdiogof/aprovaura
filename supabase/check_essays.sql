-- Checkup read-only de essays.sql (Redação).
--
-- Pode rodar a qualquer hora, não muda nada. Todas as linhas devem dizer
-- "ok". A primeira parte confere que a migration aplicou; a segunda confere
-- as invariantes que as RPCs deveriam garantir (tudo "ok" num banco vazio
-- também -- não há o que violar ainda).
--
-- UMA instrução só, de propósito: o SQL Editor do Supabase mostra apenas o
-- resultado da última instrução de cada execução, então dois blocos
-- separados fariam o primeiro sumir da tela.

-- ---------------------------------------------------------------------------
-- Estrutura
-- ---------------------------------------------------------------------------

with checks as (
select 1 as ord, 'table: essay_themes exists' as check, case
  when to_regclass('public.essay_themes') is not null
  then 'ok' else 'MISSING -- run essays.sql' end as result

union all
select 1, 'table: essay_drafts exists', case
  when to_regclass('public.essay_drafts') is not null
  then 'ok' else 'MISSING -- run essays.sql' end

union all
select 1, 'table: essay_submissions exists', case
  when to_regclass('public.essay_submissions') is not null
  then 'ok' else 'MISSING -- run essays.sql' end

union all
select 1, 'table: essay_evaluations exists', case
  when to_regclass('public.essay_evaluations') is not null
  then 'ok' else 'MISSING -- run essays.sql' end

union all
select 1, 'table: essay_evaluation_quota exists', case
  when to_regclass('public.essay_evaluation_quota') is not null
  then 'ok' else 'MISSING -- run essays.sql' end

union all
select 1, 'rls: enabled on all five tables', case
  when (select count(*) from pg_class c
        join pg_namespace n on n.oid = c.relnamespace
        where n.nspname = 'public'
          and c.relname in ('essay_themes', 'essay_drafts', 'essay_submissions',
                            'essay_evaluations', 'essay_evaluation_quota')
          and c.relrowsecurity) = 5
  then 'ok' else 'RLS OFF on at least one table' end

union all
select 1, 'rls: no write policy on submissions/evaluations/quota', case
  when (select count(*) from pg_policies
        where schemaname = 'public'
          and tablename in ('essay_submissions', 'essay_evaluations',
                            'essay_evaluation_quota')
          and cmd <> 'SELECT') = 0
  then 'ok' else 'a write policy exists -- writes must go through the RPCs' end

union all
select 1, 'column: submissions carry a client request id', case
  when exists (select 1 from information_schema.columns
               where table_schema = 'public' and table_name = 'essay_submissions'
                 and column_name = 'client_request_id')
  then 'ok' else 'MISSING -- a retry could create a second submission' end

union all
select 1, 'index: one submission per client request id', case
  when to_regclass('public.essay_submissions_client_request_idx') is not null
  then 'ok' else 'MISSING -- double tap could duplicate a submission' end

union all
select 1, 'index: one evaluation in flight per user', case
  when to_regclass('public.essay_submissions_one_in_flight_per_user') is not null
  then 'ok' else 'MISSING -- concurrent evaluations would burn the free quota' end

union all
select 1, 'constraint: total_score = sum of competencies', case
  when exists (select 1 from pg_constraint
               where conname = 'essay_evaluations_total_matches_sum')
  then 'ok' else 'MISSING -- a bad payload could save an incoherent score' end

union all
select 1, 'constraint: official themes need exam/year/source', case
  when exists (select 1 from pg_constraint
               where conname = 'essay_themes_official_needs_source')
  then 'ok' else 'MISSING -- a theme could pretend to be from a real exam' end

union all
select 1, 'unique: one evaluation per submission', case
  when exists (
    select 1 from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    where t.relname = 'essay_evaluations' and c.contype = 'u'
      and pg_get_constraintdef(c.oid) like '%(submission_id)%')
  then 'ok' else 'MISSING -- a second call could write a second evaluation' end

union all
select 1, 'rpc: ' || fn || ' exists', case
  when exists (select 1 from pg_proc p
               join pg_namespace n on n.oid = p.pronamespace
               where n.nspname = 'public' and p.proname = fn)
  then 'ok' else 'MISSING -- run essays.sql' end
from unnest(array[
  'list_essay_themes_for_user', 'save_essay_draft', 'delete_essay_draft',
  'submit_essay_draft', 'list_essay_attempts',
  'get_essay_submission', 'get_essay_quota', 'start_essay_evaluation',
  'complete_essay_evaluation', 'fail_essay_evaluation',
  'essay_daily_evaluation_limit', 'essay_award_amount',
  'essay_min_word_count', 'essay_word_count',
  'essay_evaluation_stale_after'
]) as fn

union all
select 1, 'rpc: writing functions are security definer', case
  when (select count(*) from pg_proc p
        join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public' and p.prosecdef
          and p.proname in ('save_essay_draft', 'delete_essay_draft',
                            'submit_essay_draft', 'start_essay_evaluation',
                            'complete_essay_evaluation',
                            'fail_essay_evaluation')) = 6
  then 'ok' else 'at least one writing RPC is not security definer' end

union all
select 1, 'rpc: reading functions are NOT security definer', case
  when (select count(*) from pg_proc p
        join pg_namespace n on n.oid = p.pronamespace
        where n.nspname = 'public' and p.prosecdef
          and p.proname in ('list_essay_themes_for_user', 'list_essay_attempts',
                            'get_essay_submission', 'get_essay_quota')) = 0
  then 'ok' else 'a read-only RPC has elevated privilege it does not need' end

union all
select 1, 'config: daily limit is 3', case
  when essay_daily_evaluation_limit() = 3
  then 'ok' else 'limit is ' || essay_daily_evaluation_limit()::text end

union all
select 1, 'config: award is 50 Aura', case
  when essay_award_amount() = 50
  then 'ok' else 'award is ' || essay_award_amount()::text end

union all
select 1, 'seed: practice themes loaded', case
  when (select count(*) from essay_themes where source_type = 'practice') >= 5
  then 'ok' else 'expected at least 5 practice themes' end

-- ---------------------------------------------------------------------------
-- Invariantes de dados
-- ---------------------------------------------------------------------------

union all
select 2, 'data: no theme fakes an official exam', case
  when not exists (
    select 1 from essay_themes
    where source_type = 'practice'
      and (exam_name is not null or exam_year is not null or source_url is not null))
  then 'ok' else 'a practice theme carries exam metadata' end

union all
select 2, 'data: every evaluation belongs to its submission''s owner', case
  when not exists (
    select 1 from essay_evaluations ev
    join essay_submissions s on s.id = ev.submission_id
    where ev.user_id <> s.user_id)
  then 'ok' else 'an evaluation is attributed to the wrong user' end

union all
select 2, 'data: evaluated submissions have an evaluation', case
  when not exists (
    select 1 from essay_submissions s
    where s.status = 'evaluated'
      and not exists (select 1 from essay_evaluations ev
                      where ev.submission_id = s.id))
  then 'ok' else 'a submission says evaluated with no evaluation row' end

union all
select 2, 'data: only evaluated submissions have an evaluation', case
  when not exists (
    select 1 from essay_evaluations ev
    join essay_submissions s on s.id = ev.submission_id
    where s.status <> 'evaluated')
  then 'ok' else 'an evaluation hangs off a submission that is not evaluated' end

union all
select 2, 'data: at most one evaluation in flight per user', case
  when not exists (
    select 1 from essay_submissions
    where status = 'evaluating'
    group by user_id having count(*) > 1)
  then 'ok' else 'a user has two evaluations in flight' end

union all
select 2, 'data: nobody exceeded the daily limit', case
  when not exists (
    select 1 from essay_evaluation_quota
    group by user_id, quota_date
    having count(*) > essay_daily_evaluation_limit())
  then 'ok' else 'a user got more evaluations in a day than the limit' end

union all
select 2, 'data: Aura credited at most once per submission', case
  when not exists (
    select 1 from xp_awards a
    join essay_submissions s on s.id = a.attempt_id
    group by a.user_id, a.attempt_id having count(*) > 1)
  then 'ok' else 'a submission was credited twice' end

union all
select 2, 'data: Aura for essays is always the award amount', case
  when not exists (
    select 1 from xp_awards a
    join essay_submissions s on s.id = a.attempt_id
    where a.amount <> essay_award_amount())
  then 'ok' else 'an essay award has an unexpected amount' end

union all
select 2, 'data: only evaluated submissions were credited', case
  when not exists (
    select 1 from xp_awards a
    join essay_submissions s on s.id = a.attempt_id
    where s.status <> 'evaluated')
  then 'ok' else 'Aura was credited for a submission that is not evaluated' end

union all
select 2, 'data: submitted text is never empty', case
  when not exists (select 1 from essay_submissions where length(btrim(body)) = 0)
  then 'ok' else 'an empty essay was submitted' end

union all
select 2, 'data: no request id produced two submissions', case
  when not exists (
    select 1 from essay_submissions
    where client_request_id is not null
    group by user_id, client_request_id having count(*) > 1)
  then 'ok' else 'a retry created a duplicate submission' end

union all
select 2, 'data: every submission belongs to a real user', case
  when not exists (
    select 1 from essay_submissions s
    left join auth.users u on u.id = s.user_id
    where u.id is null)
  then 'ok' else 'a submission is orphaned' end

union all
select 2, 'data: no marking is stuck in flight', case
  when not exists (
    select 1 from essay_submissions
    where status = 'evaluating'
      and evaluation_started_at < now() - essay_evaluation_stale_after())
  then 'ok'
  -- start_essay_evaluation enterra estas na proxima tentativa do dono;
  -- se aparecerem aqui, alguem esta preso esperando uma correcao morta.
  else 'a marking has been evaluating for longer than the stale window' end

union all
select 2, 'data: nobody has two markings in flight', case
  when not exists (
    select 1 from essay_submissions where status = 'evaluating'
    group by user_id having count(*) > 1)
  then 'ok' else 'a user has more than one evaluation in flight' end

union all
select 2, 'data: no draft survived the submit that froze it', case
  when not exists (
    select 1 from essay_drafts d
    join essay_submissions s
      on s.user_id = d.user_id and s.theme_id = d.theme_id
    where d.updated_at <= s.submitted_at)
  then 'ok'
  -- submit_essay_draft deletes the draft in the same transaction, so any
  -- draft that exists must be newer than the last submission of its theme.
  else 'a draft predates a submission of the same theme' end
)
select "check", result from checks order by ord, "check";
