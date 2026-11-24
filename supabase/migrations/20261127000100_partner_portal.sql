-- Premium/Partners — Etapa 05: portal dos professores parceiros.
-- ADITIVA. O professor é SEMPRE identificado por auth.uid() (nunca por um
-- partner_id vindo do cliente). Dados individuais de estudo só existem para
-- alunos vinculados A ESTE professor E com consentimento vigente (último
-- registro de study_sharing_consents = granted); dados agregados de estudo só
-- saem com coorte mínima. Professor encerrado: apenas histórico financeiro.
-- Rollback: supabase/rollbacks/20261127000100_partner_portal.down.sql

-- ---------------------------------------------------------------------------
-- 1. Auxiliares (sem acesso de cliente)
-- ---------------------------------------------------------------------------
create or replace function _my_partner_id() returns uuid
language sql stable security definer set search_path = public, pg_temp as $$
  select id from partners where user_id = auth.uid();
$$;

-- Parceria ATIVA do chamador, ou 42501.
create or replace function _active_partner_id() returns uuid
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v uuid;
begin
  select id into v from partners where user_id = auth.uid() and partner_active_at(id, now());
  if v is null then raise exception 'forbidden' using errcode = '42501'; end if;
  return v;
end $$;

create or replace function _student_shares(p_student uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce((select granted from study_sharing_consents
                   where user_id = p_student order by id desc limit 1), false);
$$;

-- Situação COMERCIAL do aluno (permitida ao professor): sem e-mail, sem
-- detalhes de pagamento. state: subscriber | trial | courtesy | sub_expired |
-- trial_expired | none.
create or replace function _student_commercial(p_student uuid) returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  with e as (select source, state, plan, starts_at, ends_at from entitlements where user_id = p_student),
  act as (select * from e where state in ('active', 'grace', 'canceled')
          and starts_at <= now() and (ends_at is null or ends_at > now()))
  select jsonb_build_object(
    'state', case
      when exists (select 1 from act where source in ('apple', 'google', 'web')) then 'subscriber'
      when exists (select 1 from act where source = 'trial') then 'trial'
      when exists (select 1 from act where source = 'courtesy') then 'courtesy'
      when exists (select 1 from e where source in ('apple', 'google', 'web') and state <> 'pending') then 'sub_expired'
      when exists (select 1 from e where source = 'trial') then 'trial_expired'
      else 'none' end,
    'plan', (select plan from act where source in ('apple', 'google', 'web')
             order by ends_at desc nulls first limit 1));
$$;

create or replace function _next_payout_date() returns date
language sql stable set search_path = public, pg_temp as $$
  select case when extract(day from (now() at time zone 'America/Sao_Paulo')) = 1
    then (now() at time zone 'America/Sao_Paulo')::date
    else (date_trunc('month', now() at time zone 'America/Sao_Paulo') + interval '1 month')::date end;
$$;

-- Estudo do aluno (última resposta/simulado/redação/Aura) e abertura do app.
create or replace function _student_last_activity(p_student uuid) returns timestamptz
language sql stable security definer set search_path = public, pg_temp as $$
  select greatest(_user_last_study(p_student), (select last_seen_at from user_activity where user_id = p_student));
$$;

create or replace function _partner_finance_summary(p_partner uuid) returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'balance_cents', partner_balance_cents(p_partner),
    'commissions_cents', coalesce((select sum(amount_cents) from commission_ledger
        where partner_id = p_partner and kind = 'commission'), 0),
    'adjustments_cents', coalesce((select sum(amount_cents) from commission_ledger
        where partner_id = p_partner and kind in ('refund_adjustment', 'manual_adjustment')), 0),
    'received_cents', coalesce((select sum(amount_cents) from payouts
        where partner_id = p_partner and status = 'paid'), 0),
    'last_payout', (select jsonb_build_object('amount_cents', amount_cents, 'paid_at', paid_at,
        'competence', competence) from payouts where partner_id = p_partner and status = 'paid'
        order by paid_at desc limit 1),
    'next_payout_date', _next_payout_date());
$$;

-- ---------------------------------------------------------------------------
-- 2. Código de indicação (cadastro por link): anon, só professor ATIVO
-- ---------------------------------------------------------------------------
create or replace function resolve_referral_code(p_code text) returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object('partner_id', p.id, 'display_name', p.display_name)
  from partners p
  where upper(btrim(coalesce(p_code, ''))) ~ '^[A-Z0-9]{4,12}$'
    and p.referral_code = upper(btrim(p_code)) and partner_active_at(p.id, now());
$$;

-- ---------------------------------------------------------------------------
-- 3. Minha parceria
-- ---------------------------------------------------------------------------
create or replace function partner_portal_me() returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare p partners%rowtype;
begin
  select * into p from partners where user_id = auth.uid();
  if not found then raise exception 'forbidden' using errcode = '42501'; end if;
  return jsonb_build_object(
    'id', p.id, 'display_name', p.display_name, 'referral_code', p.referral_code,
    'status', p.status, 'active', partner_active_at(p.id, now()),
    'commission_bps', p.commission_bps, 'started_at', p.started_at, 'ended_at', p.ended_at,
    'pix_key_type', p.pix_key_type,
    -- chave mascarada: só o final
    'pix_key_masked', case when p.pix_key is null then null
      else repeat('•', 6) || right(p.pix_key, least(4, char_length(p.pix_key))) end,
    'link', 'https://aprovaura.lucksrei.com/?ref=' || p.referral_code,
    'next_payout_date', _next_payout_date(),
    'min_cohort', 5);
end $$;

-- ---------------------------------------------------------------------------
-- 4. Painel: comercial + financeiro (compartilhável: não é estudo individual)
-- ---------------------------------------------------------------------------
create or replace function partner_dashboard(p_from date, p_to date) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare
  v_pid uuid := _active_partner_id(); v_from timestamptz; v_to timestamptz;
  v_com jsonb; v_series jsonb; p partners%rowtype;
begin
  if p_from is null or p_to is null or p_from > p_to or p_to - p_from > 730 then
    raise exception 'invalid period' using errcode = 'P0060';
  end if;
  v_from := _tz_day_start(p_from); v_to := _tz_day_start(p_to + 1);
  select * into p from partners where id = v_pid;

  with s as (
    select l.student_id, l.linked_at, _student_commercial(l.student_id) c,
           exists (select 1 from email_verifications ev where ev.user_id = l.student_id) verified,
           exists (select 1 from entitlements e where e.user_id = l.student_id and e.source = 'trial'
                   and (e.ends_at <= now() or e.state in ('expired', 'revoked'))) trial_ended
    from partner_links l where l.partner_id = v_pid
  )
  select jsonb_build_object(
    'students', count(*),
    'new_in_period', count(*) filter (where linked_at >= v_from and linked_at < v_to),
    'verified_emails', count(*) filter (where verified),
    'subscribers', count(*) filter (where c->>'state' = 'subscriber'),
    'monthly', count(*) filter (where c->>'state' = 'subscriber' and c->>'plan' = 'monthly'),
    'annual', count(*) filter (where c->>'state' = 'subscriber' and c->>'plan' = 'annual'),
    'trial', count(*) filter (where c->>'state' = 'trial'),
    'trial_expired', count(*) filter (where trial_ended),
    'subscription_expired', count(*) filter (where c->>'state' = 'sub_expired'),
    'courtesy', count(*) filter (where c->>'state' = 'courtesy'),
    'paid_ever', (select count(distinct e.user_id) from entitlements e
        join partner_links l2 on l2.student_id = e.user_id and l2.partner_id = v_pid
        where e.source in ('apple', 'google', 'web') and e.state not in ('pending', 'revoked'))
  ) into v_com from s;

  select coalesce(jsonb_agg(jsonb_build_object('date', g.d, 'referrals', coalesce(r.n, 0),
      'subscriptions', coalesce(sb.n, 0)) order by g.d), '[]'::jsonb) into v_series
  from generate_series(p_from::timestamp, p_to::timestamp, interval '1 day') gs(d)
  cross join lateral (select gs.d::date d) g
  left join (select (linked_at at time zone 'America/Sao_Paulo')::date d, count(*) n from partner_links
             where partner_id = v_pid and linked_at >= v_from and linked_at < v_to group by 1) r on r.d = g.d
  left join (select (e.created_at at time zone 'America/Sao_Paulo')::date d, count(*) n from entitlements e
             join partner_links l on l.student_id = e.user_id and l.partner_id = v_pid
             where e.source in ('apple', 'google', 'web') and e.state not in ('pending', 'revoked')
               and e.created_at >= v_from and e.created_at < v_to group by 1) sb on sb.d = g.d;

  return jsonb_build_object(
    'commercial', v_com, 'series', v_series,
    'finance', _partner_finance_summary(v_pid) || jsonb_build_object(
      'commission_bps', p.commission_bps,
      'commissions_period_cents', coalesce((select sum(amount_cents) from commission_ledger
          where partner_id = v_pid and kind = 'commission' and created_at >= v_from and created_at < v_to), 0)));
end $$;

-- ---------------------------------------------------------------------------
-- 5. Estudo agregado (só alunos com consentimento; coorte mínima = 5)
-- ---------------------------------------------------------------------------
create or replace function partner_usage(p_from date, p_to date) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare
  v_pid uuid := _active_partner_id(); v_from timestamptz; v_to timestamptz;
  v_ids uuid[]; v_total integer; v_min constant integer := 5; v_res jsonb;
begin
  if p_from is null or p_to is null or p_from > p_to or p_to - p_from > 730 then
    raise exception 'invalid period' using errcode = 'P0060';
  end if;
  v_from := _tz_day_start(p_from); v_to := _tz_day_start(p_to + 1);
  select count(*) into v_total from partner_links where partner_id = v_pid;
  select coalesce(array_agg(l.student_id), '{}') into v_ids from partner_links l
    where l.partner_id = v_pid and _student_shares(l.student_id);
  if coalesce(array_length(v_ids, 1), 0) < v_min then
    return jsonb_build_object('suppressed', true, 'consented', coalesce(array_length(v_ids, 1), 0),
      'total', v_total, 'min_cohort', v_min);
  end if;

  with act as (
    select user_id, (updated_at at time zone 'America/Sao_Paulo')::date d from user_question_progress
      where user_id = any (v_ids) and updated_at >= v_from and updated_at < v_to
    union all select user_id, (updated_at at time zone 'America/Sao_Paulo')::date from mock_exams
      where user_id = any (v_ids) and updated_at >= v_from and updated_at < v_to
    union all select user_id, (submitted_at at time zone 'America/Sao_Paulo')::date from essay_submissions
      where user_id = any (v_ids) and submitted_at >= v_from and submitted_at < v_to
    union all select user_id, (created_at at time zone 'America/Sao_Paulo')::date from xp_awards
      where user_id = any (v_ids) and created_at >= v_from and created_at < v_to
  ), days as (select distinct user_id, d from act)
  select jsonb_build_object(
    'suppressed', false, 'consented', array_length(v_ids, 1), 'total', v_total, 'min_cohort', v_min,
    'active_students', (select count(distinct user_id) from days),
    'avg_study_days', (select round(count(*)::numeric / array_length(v_ids, 1), 2) from days),
    'questions_total', (select count(*) from user_question_progress where user_id = any (v_ids)),
    'questions_in_period', (select count(*) from user_question_progress
        where user_id = any (v_ids) and answered_at >= v_from and answered_at < v_to),
    'accuracy_total', (select round(avg(is_correct::int)::numeric, 4) from user_question_progress
        where user_id = any (v_ids)),
    'accuracy_in_period', (select round(avg(is_correct::int)::numeric, 4) from user_question_progress
        where user_id = any (v_ids) and answered_at >= v_from and answered_at < v_to),
    'mock_exams_total', (select count(*) from mock_exams where user_id = any (v_ids) and status = 'finished'),
    'mock_exams_in_period', (select count(*) from mock_exams where user_id = any (v_ids)
        and status = 'finished' and finished_at >= v_from and finished_at < v_to),
    'essays_total', (select count(*) from essay_evaluations where user_id = any (v_ids)),
    'essays_in_period', (select count(*) from essay_evaluations where user_id = any (v_ids)
        and evaluated_at >= v_from and evaluated_at < v_to),
    'by_subject', coalesce((select jsonb_agg(jsonb_build_object('subject', t.subject, 'answered', t.n,
        'correct', t.c) order by t.n desc) from (
        select cn.subject, count(*) n, count(*) filter (where p.is_correct) c
        from user_question_progress p join questions q on q.id = p.question_id
        join catalog_nodes cn on cn.id = q.catalog_node_id
        where p.user_id = any (v_ids) group by cn.subject) t), '[]'::jsonb),
    'aura_levels', (select jsonb_build_object(
        'l1_2', count(*) filter (where lv <= 2), 'l3_5', count(*) filter (where lv between 3 and 5),
        'l6_10', count(*) filter (where lv between 6 and 10), 'l11_plus', count(*) filter (where lv > 10))
        from (select (coalesce(x.total_xp, 0) / 100) + 1 as lv
              from unnest(v_ids) u(id) left join user_xp x on x.user_id = u.id) q),
    'series', coalesce((select jsonb_agg(jsonb_build_object('date', g.d, 'active', coalesce(a.n, 0))
        order by g.d) from generate_series(p_from::timestamp, p_to::timestamp, interval '1 day') gs(d)
        cross join lateral (select gs.d::date d) g
        left join (select d, count(*) n from days group by d) a on a.d = g.d), '[]'::jsonb)
  ) into v_res;
  return v_res;
end $$;

-- ---------------------------------------------------------------------------
-- 6. Meus alunos
-- ---------------------------------------------------------------------------
create or replace function partner_list_students(
  p_search text default null, p_filter text default null, p_sort text default 'linked',
  p_dir text default 'desc', p_limit integer default 25, p_offset integer default 0
) returns jsonb language plpgsql stable security definer set search_path = public, pg_temp as $$
declare
  v_pid uuid := _active_partner_id(); v_pg integer[] := _page(p_limit, p_offset);
  v_dir text := case when lower(p_dir) = 'asc' then 'asc' else 'desc' end; v_order text; v_where text := 'true';
  v_res jsonb;
begin
  if p_filter is not null and p_filter not in
     ('subscribers', 'trial', 'expired', 'courtesy', 'recent', 'inactive') then
    raise exception 'invalid filter' using errcode = 'P0060';
  end if;
  v_order := case p_sort when 'name' then 'lower(b.name)' when 'created' then 'b.created_at'
    when 'answered' then 'b.answered' when 'activity' then 'b.last_activity' else 'b.linked_at' end;
  if p_search is not null and btrim(p_search) <> '' then
    v_where := v_where || ' and (lower(b.name) like ''%'' || $1 || ''%'' escape ''\'' or lower(coalesce(b.username, '''')) like ''%'' || $1 || ''%'' escape ''\'')';
  end if;
  v_where := v_where || case p_filter
    when 'subscribers' then ' and b.cstate = ''subscriber'''
    when 'trial' then ' and b.cstate = ''trial'''
    when 'expired' then ' and b.cstate in (''sub_expired'', ''trial_expired'')'
    when 'courtesy' then ' and b.cstate = ''courtesy'''
    when 'recent' then ' and b.shared and b.last_activity >= now() - interval ''14 days'''
    when 'inactive' then ' and b.shared and (b.last_activity is null or b.last_activity < now() - interval ''14 days'')'
    else '' end;
  execute format($q$
    with b as (
      select l.student_id id, coalesce(pr.name, '') as name, pr.username, au.created_at, l.linked_at,
             c.c->>'state' as cstate, c.c->>'plan' as plan, sh.shared,
             case when sh.shared then _student_last_activity(l.student_id) end as last_activity,
             case when sh.shared then (select count(*) from user_question_progress where user_id = l.student_id) end as answered,
             case when sh.shared then (select round(avg(is_correct::int)::numeric, 4)
                    from user_question_progress where user_id = l.student_id) end as accuracy
      from partner_links l
      join auth.users au on au.id = l.student_id
      left join profiles pr on pr.id = l.student_id
      cross join lateral (select _student_commercial(l.student_id) c) c
      cross join lateral (select _student_shares(l.student_id) shared) sh
      where l.partner_id = $2
    ), f as (
      select b.*, count(*) over () total from b where %s order by %s %s nulls last, b.id limit $3 offset $4
    )
    select jsonb_build_object('total', coalesce(max(f.total), 0), 'rows', coalesce(jsonb_agg(jsonb_build_object(
      'id', f.id, 'name', f.name, 'username', f.username, 'created_at', f.created_at, 'linked_at', f.linked_at,
      'state', f.cstate, 'plan', f.plan, 'shared', f.shared, 'last_activity', f.last_activity,
      'answered', f.answered, 'accuracy', f.accuracy) order by %s %s nulls last, f.id), '[]'::jsonb))
    from f
  $q$, v_where, v_order, v_dir, replace(v_order, 'b.', 'f.'), v_dir)
  into v_res
  using case when p_search is null then null else _like_escape(p_search) end, v_pid, v_pg[1], v_pg[2];
  return v_res;
end $$;

create or replace function partner_student_detail(p_student uuid) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_pid uuid := _active_partner_id(); l partner_links%rowtype; v_shared boolean; v_xp integer;
begin
  select * into l from partner_links where student_id = p_student and partner_id = v_pid;
  if not found then raise exception 'forbidden' using errcode = '42501'; end if;
  v_shared := _student_shares(p_student);
  select coalesce(total_xp, 0) into v_xp from user_xp where user_id = p_student;
  v_xp := coalesce(v_xp, 0);
  return jsonb_build_object(
    'student', jsonb_build_object(
      'id', p_student, 'name', (select name from profiles where id = p_student),
      'created_at', (select created_at from auth.users where id = p_student),
      'linked_at', l.linked_at, 'commercial', _student_commercial(p_student), 'shared', v_shared),
    'stats', case when not v_shared then null else jsonb_build_object(
      'last_activity', _student_last_activity(p_student),
      'answered', (select count(*) from user_question_progress where user_id = p_student),
      'correct', (select count(*) from user_question_progress where user_id = p_student and is_correct),
      'answered_today', (select count(*) from user_question_progress where user_id = p_student
          and (updated_at at time zone 'America/Sao_Paulo')::date = (now() at time zone 'America/Sao_Paulo')::date),
      'by_subject', coalesce((select jsonb_agg(jsonb_build_object('subject', t.subject, 'answered', t.n,
          'correct', t.c) order by t.n desc) from (
          select cn.subject, count(*) n, count(*) filter (where p.is_correct) c
          from user_question_progress p join questions q on q.id = p.question_id
          join catalog_nodes cn on cn.id = q.catalog_node_id
          where p.user_id = p_student group by cn.subject) t), '[]'::jsonb),
      'aura', v_xp, 'level', (v_xp / 100) + 1,
      'streak', (select jsonb_build_object('current', current_streak, 'longest', longest_streak)
                 from user_streaks where user_id = p_student),
      'mock_exams_finished', (select count(*) from mock_exams where user_id = p_student and status = 'finished'),
      'essays_evaluated', (select count(*) from essay_evaluations where user_id = p_student),
      'series', coalesce((select jsonb_agg(jsonb_build_object('date', g.d, 'answered', coalesce(a.n, 0),
          'correct', coalesce(a.c, 0)) order by g.d)
          from generate_series(current_date - 29, current_date, interval '1 day') gs(d)
          cross join lateral (select gs.d::date d) g
          left join (select (updated_at at time zone 'America/Sao_Paulo')::date d, count(*) n,
                            count(*) filter (where is_correct) c
                     from user_question_progress where user_id = p_student
                       and updated_at >= now() - interval '31 days' group by 1) a on a.d = g.d), '[]'::jsonb)) end);
end $$;

-- ---------------------------------------------------------------------------
-- 7. Financeiro do próprio professor (ativo OU encerrado); sem dados de alunos
-- ---------------------------------------------------------------------------
create or replace function partner_finance(p_limit integer default 25, p_offset integer default 0)
returns jsonb language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_pid uuid := _my_partner_id(); v_pg integer[] := _page(p_limit, p_offset); p partners%rowtype;
begin
  if v_pid is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into p from partners where id = v_pid;
  return jsonb_build_object(
    'partner', jsonb_build_object('status', p.status, 'active', partner_active_at(v_pid, now()),
      'commission_bps', p.commission_bps),
    'summary', _partner_finance_summary(v_pid),
    'by_competence', coalesce((select jsonb_agg(jsonb_build_object('competence', t.competence,
        'commissions_cents', t.com, 'adjustments_cents', t.adj, 'payouts_cents', t.pay,
        'balance_cents', t.com + t.adj + t.pay) order by t.competence desc) from (
        select competence,
          coalesce(sum(amount_cents) filter (where kind = 'commission'), 0)::bigint com,
          coalesce(sum(amount_cents) filter (where kind in ('refund_adjustment', 'manual_adjustment')), 0)::bigint adj,
          coalesce(sum(amount_cents) filter (where kind in ('payout', 'payout_reversal')), 0)::bigint pay
        from commission_ledger where partner_id = v_pid group by competence
        order by competence desc limit 60) t), '[]'::jsonb),
    'payouts', coalesce((select jsonb_agg(jsonb_build_object('competence', x.competence,
        'amount_cents', x.amount_cents, 'status', x.status, 'paid_at', x.paid_at) order by x.paid_at desc)
        from (select * from payouts where partner_id = v_pid order by paid_at desc limit 36) x), '[]'::jsonb),
    'ledger_total', (select count(*) from commission_ledger where partner_id = v_pid),
    'ledger', coalesce((select jsonb_agg(jsonb_build_object('id', y.id, 'kind', y.kind,
        'amount_cents', y.amount_cents, 'competence', y.competence, 'at', y.created_at,
        'plan', pay.plan, 'paid_at', pay.paid_at, 'payment_status', pay.status) order by y.id desc)
        from (select * from commission_ledger where partner_id = v_pid order by id desc
              limit v_pg[1] offset v_pg[2]) y
        left join payments pay on pay.id = y.payment_id), '[]'::jsonb));
end $$;

-- ---------------------------------------------------------------------------
-- 8. Gate: rotas do professor (qualquer papel de parceiro, inclusive encerrado,
--    sem exigir Premium) e resolução de código no cadastro.
-- ---------------------------------------------------------------------------
create or replace function app_pre_request() returns void
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_path text; v_role text := current_setting('role', true); v_uid uuid;
begin
  if v_role is null or v_role not in ('anon', 'authenticated') then return; end if;
  if not commercial_enforced()
     and not coalesce((select email_verification_required from commercial_config), false) then
    return;
  end if;
  v_path := coalesce(current_setting('request.path', true), '');
  if v_path in ('', '/', '/profiles', '/rpc/is_username_available', '/rpc/get_my_access',
      '/rpc/get_public_app_config', '/rpc/list_active_partners', '/rpc/search_active_partners',
      '/rpc/link_partner', '/rpc/get_my_partner', '/rpc/request_partner_change',
      '/rpc/get_my_partner_profile', '/rpc/get_legal_status', '/rpc/record_legal_acceptance',
      '/rpc/get_study_sharing', '/rpc/set_study_sharing', '/rpc/discard_unconfirmed_signup',
      '/rpc/resolve_referral_code', '/rpc/touch_activity')
     or v_path like '/rpc/admin\_%' or v_path like '/rpc/partner\_%' then
    return;
  end if;
  v_uid := auth.uid();
  if v_uid is not null and must_verify_email(v_uid) then
    raise sqlstate 'PT403' using message = 'email_unverified',
      hint = 'Confirm your e-mail with the 6-digit code.';
  end if;
  if not commercial_enforced() then return; end if;
  if v_uid is not null and access_allowed(v_uid) then return; end if;
  raise sqlstate 'PT402' using message = 'premium_required',
    hint = 'An active Premium entitlement is required.';
end $$;

-- ---------------------------------------------------------------------------
-- 9. Permissões
-- ---------------------------------------------------------------------------
select app_grant_functions(array['_my_partner_id', '_active_partner_id', '_student_shares',
  '_student_commercial', '_next_payout_date', '_student_last_activity', '_partner_finance_summary'],
  array[]::text[]);
select app_grant_functions(array['resolve_referral_code', 'app_pre_request'], array['anon', 'authenticated']);
select app_grant_functions(array['partner_portal_me', 'partner_dashboard', 'partner_usage',
  'partner_list_students', 'partner_student_detail', 'partner_finance'], array['authenticated']);
notify pgrst, 'reload schema';
