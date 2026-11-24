-- Premium/Partners — Etapa 04: portal administrativo (RPCs de leitura/gestão).
-- ADITIVA e compatível: nenhuma tabela existente perde dado; o modelo comercial
-- continua desligado. Toda função admin_* chama require_admin() (42501).
-- Rollback: supabase/rollbacks/20261126000100_admin_portal.down.sql

-- ---------------------------------------------------------------------------
-- 1. Configuração: percentual padrão de comissão
-- ---------------------------------------------------------------------------
alter table commercial_config
  add column if not exists default_commission_bps integer not null default 5000
  check (default_commission_bps between 0 and 10000);

-- ---------------------------------------------------------------------------
-- 2. Última atividade conhecida no app (≠ último login, ≠ último estudo)
--    Uma linha por conta; escrita limitada a 1 por 10 min no servidor.
-- ---------------------------------------------------------------------------
create table if not exists user_activity (
  user_id uuid primary key references auth.users (id) on delete cascade,
  first_seen_at timestamptz not null default now(),
  last_seen_at timestamptz not null default now(),
  platform text check (platform is null or platform in ('android', 'ios', 'web'))
);

create or replace function touch_activity(p_platform text default null) returns void
language plpgsql volatile security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then return; end if;
  insert into user_activity (user_id, platform)
  values (auth.uid(), case when p_platform in ('android', 'ios', 'web') then p_platform end)
  on conflict (user_id) do update
    set last_seen_at = now(),
        platform = coalesce(case when p_platform in ('android', 'ios', 'web') then p_platform end,
                            user_activity.platform)
    where user_activity.last_seen_at < now() - interval '10 minutes';
end $$;

-- ---------------------------------------------------------------------------
-- 3. Auxiliares internos (sem acesso de cliente)
-- ---------------------------------------------------------------------------
create or replace function _scrub(p jsonb) returns jsonb
language sql immutable set search_path = public, pg_temp as $$
  select case when p is null then null
    else p - 'pix_key' - 'raw' - 'password' - 'token' - 'secret' - 'encrypted_password' end;
$$;

create or replace function _tz_day_start(p_day date) returns timestamptz
language sql immutable set search_path = public, pg_temp as $$
  select p_day::timestamp at time zone 'America/Sao_Paulo';
$$;

-- Último estudo: resposta, simulado, redação ou Aura. NÃO é login nem abertura do app.
create or replace function _user_last_study(p_user uuid) returns timestamptz
language sql stable security definer set search_path = public, pg_temp as $$
  select greatest(
    (select max(updated_at) from user_question_progress where user_id = p_user),
    (select max(updated_at) from mock_exams where user_id = p_user),
    (select max(submitted_at) from essay_submissions where user_id = p_user),
    (select max(created_at) from xp_awards where user_id = p_user));
$$;

create or replace function _admin_access_match(p_user uuid, p_mode text) returns boolean
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare a jsonb := compute_access(p_user);
begin
  return case p_mode
    when 'premium' then (a->>'has_access')::boolean
    when 'none' then not (a->>'has_access')::boolean
    when 'paid' then exists (select 1 from jsonb_array_elements(a->'sources') s
                             where s->>'source' in ('apple', 'google', 'web'))
    else exists (select 1 from jsonb_array_elements(a->'sources') s where s->>'source' = p_mode)
  end;
end $$;

create or replace function _like_escape(p text) returns text
language sql immutable set search_path = public, pg_temp as $$
  select replace(replace(replace(lower(btrim(p)), '\', '\\'), '%', '\%'), '_', '\_');
$$;

create or replace function _page(p_limit integer, p_offset integer, p_max integer default 100) returns integer[]
language sql immutable set search_path = public, pg_temp as $$
  select array[least(greatest(coalesce(p_limit, 25), 1), p_max), greatest(coalesce(p_offset, 0), 0)];
$$;

create or replace function admin_assert() returns boolean
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin perform require_admin(); return true; end $$;

-- Usado pela Edge Function de provisionamento (service_role).
create or replace function service_find_user_by_email(p_email text) returns uuid
language sql stable security definer set search_path = public, pg_temp as $$
  select id from auth.users where lower(email) = lower(btrim(p_email)) limit 1;
$$;

-- ---------------------------------------------------------------------------
-- 4. Dashboard
-- ---------------------------------------------------------------------------
create or replace function admin_dashboard(p_from date, p_to date) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare
  v_from timestamptz; v_to timestamptz; v_users jsonb; v_study jsonb; v_fin jsonb; v_series jsonb;
begin
  perform require_admin();
  if p_from is null or p_to is null or p_from > p_to or p_to - p_from > 730 then
    raise exception 'invalid period' using errcode = 'P0060';
  end if;
  v_from := _tz_day_start(p_from); v_to := _tz_day_start(p_to + 1);

  with u as (
    select au.id, au.created_at, compute_access(au.id) as acc,
           exists (select 1 from email_verifications ev where ev.user_id = au.id) as verified
    from auth.users au
  ), src as (
    select u.id, s->>'source' as source from u, jsonb_array_elements(u.acc->'sources') s
  )
  select jsonb_build_object(
    'total', (select count(*) from u),
    'new_in_period', (select count(*) from u where created_at >= v_from and created_at < v_to),
    'verified_emails', (select count(*) from u where verified),
    'premium_active', (select count(*) from u where (acc->>'has_access')::boolean),
    'trial_active', (select count(distinct id) from src where source = 'trial'),
    'courtesy_active', (select count(distinct id) from src where source = 'courtesy'),
    'paid_active', (select count(distinct id) from src where source in ('apple', 'google', 'web')),
    'partner_premium', (select count(distinct id) from src where source = 'partner'),
    'admin_premium', (select count(distinct id) from src where source = 'admin'),
    'trials_expired', (select count(*) from entitlements e where e.source = 'trial'
        and (e.state in ('expired', 'revoked') or (e.ends_at is not null and e.ends_at <= now()))),
    'subscriptions_expired', (select count(*) from entitlements e
        where e.source in ('apple', 'google', 'web')
        and (e.state = 'expired' or (e.state in ('active', 'grace', 'canceled')
             and e.ends_at is not null and e.ends_at <= now()))),
    'trials_total', (select count(distinct user_id) from entitlements where source = 'trial'),
    'paid_users_ever', (select count(distinct user_id) from entitlements
        where source in ('apple', 'google', 'web') and state not in ('pending', 'revoked')),
    'partners_active', (select count(*) from partners p where partner_active_at(p.id, now())),
    'partners_inactive', (select count(*) from partners p where not partner_active_at(p.id, now())),
    'students_with_referral', (select count(*) from partner_links),
    'students_without_referral', (select count(*) from u) - (select count(*) from partner_links),
    'active_in_period', (select count(distinct x) from (
        select user_id x from user_question_progress where updated_at >= v_from and updated_at < v_to
        union all select user_id from mock_exams where updated_at >= v_from and updated_at < v_to
        union all select user_id from essay_submissions where submitted_at >= v_from and submitted_at < v_to
        union all select user_id from xp_awards where created_at >= v_from and created_at < v_to
        union all select user_id from user_activity where last_seen_at >= v_from and last_seen_at < v_to) a)
  ) into v_users;

  select jsonb_build_object(
    'questions_total', (select count(*) from user_question_progress),
    'questions_in_period', (select count(*) from user_question_progress
        where answered_at >= v_from and answered_at < v_to),
    'accuracy_total', (select round(avg(is_correct::int)::numeric, 4) from user_question_progress),
    'accuracy_in_period', (select round(avg(is_correct::int)::numeric, 4) from user_question_progress
        where answered_at >= v_from and answered_at < v_to),
    'essays_evaluated_total', (select count(*) from essay_evaluations),
    'essays_evaluated_in_period', (select count(*) from essay_evaluations
        where evaluated_at >= v_from and evaluated_at < v_to),
    'mock_exams_finished_total', (select count(*) from mock_exams where status = 'finished'),
    'mock_exams_finished_in_period', (select count(*) from mock_exams
        where status = 'finished' and finished_at >= v_from and finished_at < v_to)
  ) into v_study;

  select jsonb_build_object(
    'gross_cents', coalesce(sum(gross_cents) filter (where status = 'confirmed'), 0),
    'fee_cents', coalesce(sum(fee_cents) filter (where status = 'confirmed'), 0),
    'tax_cents', coalesce(sum(tax_cents) filter (where status = 'confirmed'), 0),
    'net_cents', coalesce(sum(net_cents) filter (where status = 'confirmed'), 0),
    'commission_cents', coalesce(sum(commission_cents) filter (where status = 'confirmed'), 0),
    'lucksrei_cents', coalesce(sum(lucksrei_cents) filter (where status = 'confirmed'), 0),
    'payments_count', count(*) filter (where status = 'confirmed'),
    'refunded_count', count(*) filter (where status <> 'confirmed'),
    'pending_payouts_cents', (select coalesce(sum(amount_cents), 0) from commission_ledger),
    'paid_payouts_cents', (select coalesce(sum(amount_cents), 0) from payouts
        where status = 'paid' and paid_at >= v_from and paid_at < v_to)
  ) into v_fin
  from payments where paid_at >= v_from and paid_at < v_to;

  select coalesce(jsonb_agg(jsonb_build_object('date', g.d, 'signups', coalesce(s.n, 0),
      'answers', coalesce(a.n, 0), 'gross_cents', coalesce(p.g, 0)) order by g.d), '[]'::jsonb)
  into v_series
  from generate_series(p_from::timestamp, p_to::timestamp, interval '1 day') as gs(d)
  cross join lateral (select gs.d::date as d) g
  left join (select (created_at at time zone 'America/Sao_Paulo')::date d, count(*) n from auth.users
             where created_at >= v_from and created_at < v_to group by 1) s on s.d = g.d
  left join (select (answered_at at time zone 'America/Sao_Paulo')::date d, count(*) n
             from user_question_progress where answered_at >= v_from and answered_at < v_to group by 1) a on a.d = g.d
  left join (select (paid_at at time zone 'America/Sao_Paulo')::date d, sum(gross_cents) g from payments
             where status = 'confirmed' and paid_at >= v_from and paid_at < v_to group by 1) p on p.d = g.d;

  return jsonb_build_object('period', jsonb_build_object('from', p_from, 'to', p_to),
    'users', v_users, 'study', v_study, 'finance', v_fin, 'series', v_series);
end $$;

-- ---------------------------------------------------------------------------
-- 5. Usuários
-- ---------------------------------------------------------------------------
create or replace function admin_list_users(
  p_search text default null, p_access text default null, p_partner uuid default null,
  p_referral text default null, p_email text default null,
  p_from date default null, p_to date default null,
  p_sort text default 'created', p_dir text default 'desc',
  p_limit integer default 25, p_offset integer default 0
) returns jsonb language plpgsql stable security definer set search_path = public, pg_temp as $$
declare
  v_pg integer[] := _page(p_limit, p_offset); v_where text := 'true'; v_order text;
  v_dir text := case when lower(p_dir) = 'asc' then 'asc' else 'desc' end; v_res jsonb;
begin
  perform require_admin();
  if p_access is not null and p_access not in ('premium', 'none', 'paid', 'trial', 'courtesy', 'partner', 'admin') then
    raise exception 'invalid access filter' using errcode = 'P0060';
  end if;
  if p_referral is not null and p_referral not in ('with', 'without') then
    raise exception 'invalid referral filter' using errcode = 'P0060';
  end if;
  if p_email is not null and p_email not in ('verified', 'unverified') then
    raise exception 'invalid email filter' using errcode = 'P0060';
  end if;
  v_order := case p_sort
    when 'name' then 'lower(b.name)' when 'email' then 'lower(b.email)'
    when 'activity' then 'b.last_seen_at' when 'login' then 'b.last_sign_in_at'
    else 'b.created_at' end;
  if p_search is not null and btrim(p_search) <> '' then
    v_where := v_where || ' and (lower(b.name) like ''%'' || $1 || ''%'' escape ''\'' or lower(coalesce(b.username, '''')) like ''%'' || $1 || ''%'' escape ''\'' or lower(b.email) like ''%'' || $1 || ''%'' escape ''\'')';
  end if;
  if p_partner is not null then v_where := v_where || ' and b.partner_id = $2'; end if;
  if p_referral = 'with' then v_where := v_where || ' and b.partner_id is not null'; end if;
  if p_referral = 'without' then v_where := v_where || ' and b.partner_id is null'; end if;
  if p_email = 'verified' then v_where := v_where || ' and b.verified'; end if;
  if p_email = 'unverified' then v_where := v_where || ' and not b.verified'; end if;
  if p_from is not null then v_where := v_where || ' and b.created_at >= _tz_day_start($4)'; end if;
  if p_to is not null then v_where := v_where || ' and b.created_at < _tz_day_start($5 + 1)'; end if;
  if p_access is not null then v_where := v_where || ' and _admin_access_match(b.id, $3)'; end if;

  execute format($q$
    with b as (
      select au.id, coalesce(pr.name, '') as name, pr.username, coalesce(au.email, '') as email,
             au.created_at, au.last_sign_in_at, ua.last_seen_at, pl.partner_id,
             exists (select 1 from email_verifications ev where ev.user_id = au.id) as verified
      from auth.users au
      left join profiles pr on pr.id = au.id
      left join user_activity ua on ua.user_id = au.id
      left join partner_links pl on pl.student_id = au.id
    ), f as (
      select b.*, count(*) over () as total from b where %s
      order by %s %s nulls last, b.id limit $6 offset $7
    )
    select jsonb_build_object('total', coalesce(max(f.total), 0), 'rows', coalesce(jsonb_agg(jsonb_build_object(
      'id', f.id, 'name', f.name, 'username', f.username, 'email', f.email, 'created_at', f.created_at,
      'last_sign_in_at', f.last_sign_in_at, 'last_seen_at', f.last_seen_at,
      'last_study_at', _user_last_study(f.id), 'email_verified', f.verified,
      'partner_id', f.partner_id,
      'partner_name', (select display_name from partners where id = f.partner_id),
      'access', compute_access(f.id)) order by %s %s nulls last, f.id), '[]'::jsonb))
    from f
  $q$, v_where, v_order, v_dir, replace(v_order, 'b.', 'f.'), v_dir)
  into v_res
  using case when p_search is null then null else _like_escape(p_search) end,
        p_partner, p_access, p_from, p_to, v_pg[1], v_pg[2];
  return v_res;
end $$;

create or replace function admin_get_user(p_user uuid) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_acc jsonb; v_xp integer;
begin
  perform require_admin();
  if not exists (select 1 from auth.users where id = p_user) then
    raise exception 'user not found' using errcode = 'P0013';
  end if;
  v_acc := compute_access(p_user);
  select coalesce(total_xp, 0) into v_xp from user_xp where user_id = p_user;
  v_xp := coalesce(v_xp, 0);
  return jsonb_build_object(
    'account', (select jsonb_build_object(
        'id', au.id, 'email', au.email, 'created_at', au.created_at, 'last_sign_in_at', au.last_sign_in_at,
        'email_confirmed_at', au.email_confirmed_at, 'name', pr.name, 'username', pr.username,
        'goal', pr.goal, 'exam_year', pr.exam_year,
        'email_proof', (select jsonb_build_object('verified_at', ev.verified_at, 'method', ev.method)
                        from email_verifications ev where ev.user_id = au.id),
        'roles', v_acc->'roles',
        'admin_since', (select granted_at from app_admins a where a.user_id = au.id and a.revoked_at is null),
        'partner_id', (select id from partners where user_id = au.id),
        'last_seen_at', (select last_seen_at from user_activity where user_id = au.id),
        'last_seen_platform', (select platform from user_activity where user_id = au.id),
        'last_study_at', _user_last_study(au.id))
      from auth.users au left join profiles pr on pr.id = au.id where au.id = p_user),
    'premium', jsonb_build_object(
      'access', v_acc,
      'entitlements', coalesce((select jsonb_agg(jsonb_build_object('id', e.id, 'source', e.source,
          'state', e.state, 'plan', e.plan, 'starts_at', e.starts_at, 'ends_at', e.ends_at,
          'auto_renew', e.auto_renew, 'note', e.note, 'created_at', e.created_at,
          'created_by_name', (select name from profiles where id = e.created_by),
          'effective', case when e.state in ('active', 'grace', 'canceled')
              and e.starts_at <= now() and (e.ends_at is null or e.ends_at > now()) then 'active'
              when e.state in ('active', 'grace', 'canceled') and e.starts_at > now() then 'scheduled'
              when e.state in ('active', 'grace', 'canceled') then 'expired' else e.state end)
          order by e.created_at desc) from entitlements e where e.user_id = p_user), '[]'::jsonb),
      'events', coalesce((select jsonb_agg(jsonb_build_object('at', x.occurred_at, 'event', x.event,
          'from', x.from_state, 'to', x.to_state, 'entitlement_id', x.entitlement_id)
          order by x.occurred_at desc) from (select * from entitlement_events where user_id = p_user
          order by occurred_at desc limit 100) x), '[]'::jsonb),
      'audit', coalesce((select jsonb_agg(jsonb_build_object('at', l.occurred_at, 'action', l.action,
          'actor_name', (select name from profiles where id = l.actor_id), 'note', l.note,
          'after', _scrub(l.after_data)) order by l.occurred_at desc)
          from (select * from admin_audit_log where target_type = 'user' and target_id = p_user::text
                and action like 'entitlement.%' order by occurred_at desc limit 50) l), '[]'::jsonb)),
    'partner', jsonb_build_object(
      'current', (select jsonb_build_object('partner_id', pl.partner_id, 'display_name', p.display_name,
          'status', p.status, 'linked_at', pl.linked_at, 'source', pl.source)
          from partner_links pl join partners p on p.id = pl.partner_id where pl.student_id = p_user),
      'history', coalesce((select jsonb_agg(jsonb_build_object('at', h.occurred_at, 'action', h.action,
          'source', h.source, 'from_name', (select display_name from partners where id = h.from_partner_id),
          'to_name', (select display_name from partners where id = h.to_partner_id),
          'by_name', (select name from profiles where id = h.performed_by)) order by h.id desc)
          from partner_link_history h where h.student_id = p_user), '[]'::jsonb),
      'requests', coalesce((select jsonb_agg(jsonb_build_object('id', r.id, 'status', r.status,
          'reason', r.reason, 'requested_at', r.requested_at, 'reviewed_at', r.reviewed_at,
          'from_name', (select display_name from partners where id = r.from_partner_id),
          'to_name', (select display_name from partners where id = r.to_partner_id),
          'reviewer_name', (select name from profiles where id = r.reviewed_by),
          'review_note', r.review_note) order by r.requested_at desc)
          from partner_change_requests r where r.student_id = p_user), '[]'::jsonb)),
    'stats', jsonb_build_object(
      'answered', (select count(*) from user_question_progress where user_id = p_user),
      'correct', (select count(*) from user_question_progress where user_id = p_user and is_correct),
      'answered_today', (select count(*) from user_question_progress where user_id = p_user
          and (updated_at at time zone 'America/Sao_Paulo')::date = (now() at time zone 'America/Sao_Paulo')::date),
      'by_subject', coalesce((select jsonb_agg(jsonb_build_object('subject', t.subject, 'answered', t.n,
          'correct', t.c) order by t.n desc) from (
          select cn.subject, count(*) n, count(*) filter (where p.is_correct) c
          from user_question_progress p join questions q on q.id = p.question_id
          join catalog_nodes cn on cn.id = q.catalog_node_id
          where p.user_id = p_user group by cn.subject) t), '[]'::jsonb),
      'aura', v_xp, 'level', (v_xp / 100) + 1,
      'streak', (select jsonb_build_object('current', current_streak, 'longest', longest_streak,
          'last_activity_date', last_activity_date) from user_streaks where user_id = p_user),
      'mock_exams', jsonb_build_object(
          'total', (select count(*) from mock_exams where user_id = p_user),
          'finished', (select count(*) from mock_exams where user_id = p_user and status = 'finished'),
          'avg_accuracy', (select round(avg(correct_count::numeric / nullif(scored_count, 0)), 4)
              from mock_exams where user_id = p_user and status = 'finished')),
      'essays', jsonb_build_object(
          'submitted', (select count(*) from essay_submissions where user_id = p_user),
          'evaluated', (select count(*) from essay_evaluations where user_id = p_user),
          'avg_score', (select round(avg(total_score)::numeric, 1) from essay_evaluations where user_id = p_user)),
      'regions_found', (select count(*) from user_region_progress where user_id = p_user)),
    'finance', jsonb_build_object(
      'payments', coalesce((select jsonb_agg(jsonb_build_object('id', pay.id, 'provider', pay.provider,
          'plan', pay.plan, 'status', pay.status, 'paid_at', pay.paid_at, 'gross_cents', pay.gross_cents,
          'fee_cents', pay.fee_cents, 'tax_cents', pay.tax_cents, 'net_cents', pay.net_cents,
          'commission_cents', pay.commission_cents, 'lucksrei_cents', pay.lucksrei_cents,
          'partner_name', (select display_name from partners where id = pay.partner_id),
          'refunded_at', pay.refunded_at) order by pay.paid_at desc)
          from payments pay where pay.user_id = p_user), '[]'::jsonb)));
end $$;

-- ---------------------------------------------------------------------------
-- 6. Premium administrativo (cortesia) — nunca gera comissão (não é pagamento)
-- ---------------------------------------------------------------------------
create or replace function admin_grant_premium(
  p_user uuid, p_days integer default null, p_ends_at timestamptz default null,
  p_indefinite boolean default false, p_note text default null
) returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare v_id uuid; v_ends timestamptz; v_modes integer;
begin
  perform require_admin();
  v_modes := (p_days is not null)::int + (p_ends_at is not null)::int + coalesce(p_indefinite, false)::int;
  if v_modes <> 1 then raise exception 'choose exactly one duration' using errcode = 'P0030'; end if;
  if p_days is not null and p_days not between 1 and 3650 then
    raise exception 'days out of range' using errcode = 'P0030';
  end if;
  v_ends := case when p_days is not null then now() + make_interval(days => p_days)
                 when p_ends_at is not null then p_ends_at else null end;
  if v_ends is not null and v_ends <= now() then
    raise exception 'ends_at must be in the future' using errcode = 'P0030';
  end if;
  if p_note is not null and char_length(p_note) > 300 then
    raise exception 'note too long' using errcode = 'P0030';
  end if;
  if not exists (select 1 from auth.users where id = p_user) then
    raise exception 'user not found' using errcode = 'P0013';
  end if;
  perform pg_advisory_xact_lock(hashtextextended('courtesy:' || p_user::text, 0));
  insert into entitlements (user_id, source, state, starts_at, ends_at, note, created_by)
  values (p_user, 'courtesy', 'active', now(), v_ends, nullif(btrim(p_note), ''), auth.uid())
  returning id into v_id;
  perform audit_event('entitlement.courtesy', 'user', p_user::text, null,
    jsonb_build_object('entitlement_id', v_id, 'ends_at', v_ends, 'indefinite', v_ends is null),
    nullif(btrim(p_note), ''));
  return v_id;
end $$;

-- Só cortesia é revogável pelo portal: Apple/Google/Mercado Pago/trial são do
-- provedor (ou do sistema) e uma fonte nunca revoga outra.
create or replace function admin_revoke_entitlement(p_id uuid, p_note text default null) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_before jsonb;
begin
  perform require_admin();
  select to_jsonb(e) into v_before from entitlements e where id = p_id for update;
  if v_before is null then raise exception 'entitlement not found' using errcode = 'P0013'; end if;
  if v_before->>'source' <> 'courtesy' then
    raise exception 'only courtesy can be revoked here' using errcode = 'P0032';
  end if;
  if v_before->>'state' in ('revoked', 'expired') then return; end if;
  update entitlements set state = 'revoked', ends_at = least(coalesce(ends_at, now()), now()) where id = p_id;
  perform audit_event('entitlement.revoke', 'user', v_before->>'user_id', v_before,
    (select to_jsonb(e) from entitlements e where id = p_id), p_note);
end $$;

-- ---------------------------------------------------------------------------
-- 7. Professores parceiros
-- ---------------------------------------------------------------------------
create or replace function _validate_partner_fields(p_name text, p_code text, p_bps integer,
  p_pix_type text, p_pix_key text) returns void
language plpgsql immutable set search_path = public, pg_temp as $$
begin
  if p_name is not null and char_length(btrim(p_name)) not between 2 and 80 then
    raise exception 'invalid display name' using errcode = 'P0050';
  end if;
  if p_code is not null and upper(p_code) !~ '^[A-Z0-9]{4,12}$' then
    raise exception 'invalid referral code' using errcode = 'P0050';
  end if;
  if p_bps is not null and p_bps not between 0 and 10000 then
    raise exception 'invalid commission' using errcode = 'P0050';
  end if;
  if (p_pix_type is null) <> (p_pix_key is null) then
    raise exception 'pix type and key go together' using errcode = 'P0050';
  end if;
  if p_pix_type is not null and (p_pix_type not in ('cpf', 'cnpj', 'email', 'phone', 'random')
     or char_length(p_pix_key) not between 5 and 140) then
    raise exception 'invalid pix key' using errcode = 'P0050';
  end if;
end $$;

create or replace function admin_promote_partner(
  p_user uuid, p_display_name text, p_referral_code text default null, p_commission_bps integer default null,
  p_pix_key_type text default null, p_pix_key text default null
) returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare v_id uuid; v_bps integer; v_code text; v_existing partners%rowtype;
begin
  perform require_admin();
  v_code := nullif(upper(btrim(coalesce(p_referral_code, ''))), '');
  perform _validate_partner_fields(p_display_name, v_code, p_commission_bps,
    nullif(btrim(p_pix_key_type), ''), nullif(btrim(p_pix_key), ''));
  if not exists (select 1 from auth.users where id = p_user) then
    raise exception 'user not found' using errcode = 'P0013';
  end if;
  v_bps := coalesce(p_commission_bps, (select default_commission_bps from commercial_config));
  perform pg_advisory_xact_lock(hashtextextended('partner:' || p_user::text, 0));
  select * into v_existing from partners where user_id = p_user for update;
  if found then
    if v_existing.status = 'active' then
      raise exception 'user is already an active partner' using errcode = 'P0051';
    end if;
    -- Reativa a MESMA parceria (preserva histórico e financeiro).
    update partners set status = 'active', ended_at = null, started_at = now(),
      display_name = btrim(p_display_name), commission_bps = v_bps,
      referral_code = coalesce(v_code, referral_code),
      pix_key_type = coalesce(nullif(btrim(p_pix_key_type), ''), pix_key_type),
      pix_key = coalesce(nullif(btrim(p_pix_key), ''), pix_key)
    where id = v_existing.id;
    return v_existing.id;
  end if;
  insert into partners (user_id, display_name, referral_code, commission_bps, pix_key_type, pix_key, created_by)
  values (p_user, btrim(p_display_name), coalesce(v_code, _new_referral_code()), v_bps,
          nullif(btrim(p_pix_key_type), ''), nullif(btrim(p_pix_key), ''), auth.uid())
  returning id into v_id;
  return v_id;
exception when unique_violation then
  raise exception 'referral code already in use' using errcode = 'P0052';
end $$;

create or replace function admin_update_partner(p_partner uuid, p_patch jsonb) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_status text; v_has_pix boolean := p_patch ? 'pix_key_type' or p_patch ? 'pix_key';
        v_pt text; v_pk text; v_name text; v_code text; v_bps integer;
begin
  perform require_admin();
  v_status := p_patch->>'status';
  if v_status is not null and v_status not in ('pending', 'active', 'suspended', 'ended') then
    raise exception 'invalid status' using errcode = 'P0050';
  end if;
  v_name := p_patch->>'display_name'; v_code := nullif(upper(btrim(coalesce(p_patch->>'referral_code', ''))), '');
  v_bps := (p_patch->>'commission_bps')::integer;
  if v_has_pix then
    v_pt := nullif(btrim(coalesce(p_patch->>'pix_key_type', '')), '');
    v_pk := nullif(btrim(coalesce(p_patch->>'pix_key', '')), '');
  end if;
  perform _validate_partner_fields(v_name, v_code, v_bps, v_pt, v_pk);
  update partners set
    display_name = coalesce(btrim(v_name), display_name),
    referral_code = coalesce(v_code, referral_code),
    commission_bps = coalesce(v_bps, commission_bps),
    status = coalesce(v_status, status),
    ended_at = case when v_status = 'ended' then coalesce(ended_at, now())
                    when v_status = 'active' then null else ended_at end,
    pix_key_type = case when v_has_pix then v_pt else pix_key_type end,
    pix_key = case when v_has_pix then v_pk else pix_key end
  where id = p_partner;
  if not found then raise exception 'partner not found' using errcode = 'P0013'; end if;
exception when unique_violation then
  raise exception 'referral code already in use' using errcode = 'P0052';
end $$;

create or replace function admin_list_partners(
  p_search text default null, p_status text default null, p_limit integer default 25, p_offset integer default 0
) returns jsonb language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_pg integer[] := _page(p_limit, p_offset, 200); v_q text := _like_escape(coalesce(p_search, ''));
begin
  perform require_admin();
  return (select jsonb_build_object('total', coalesce(max(t.total), 0), 'rows', coalesce(jsonb_agg(
    jsonb_build_object('id', t.id, 'user_id', t.user_id, 'display_name', t.display_name,
      'referral_code', t.referral_code, 'status', t.status, 'active', partner_active_at(t.id, now()),
      'commission_bps', t.commission_bps, 'started_at', t.started_at, 'ended_at', t.ended_at,
      'email', t.email, 'students', (select count(*) from partner_links where partner_id = t.id),
      'balance_cents', partner_balance_cents(t.id)) order by t.sort_name, t.id), '[]'::jsonb))
    from (select p.*, au.email, lower(p.display_name) as sort_name, count(*) over () as total
          from partners p join auth.users au on au.id = p.user_id
          where (p_status is null or p.status = p_status)
            and (v_q = '' or lower(p.display_name) like '%' || v_q || '%' escape '\'
                 or lower(au.email) like '%' || v_q || '%' escape '\'
                 or lower(p.referral_code) like '%' || v_q || '%' escape '\')
          order by lower(p.display_name), p.id limit v_pg[1] offset v_pg[2]) t);
end $$;

create or replace function admin_get_partner(p_partner uuid) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_p partners%rowtype;
begin
  perform require_admin();
  select * into v_p from partners where id = p_partner;
  if not found then raise exception 'partner not found' using errcode = 'P0013'; end if;
  return jsonb_build_object(
    'partner', jsonb_build_object('id', v_p.id, 'user_id', v_p.user_id, 'display_name', v_p.display_name,
      'referral_code', v_p.referral_code, 'status', v_p.status, 'active', partner_active_at(v_p.id, now()),
      'commission_bps', v_p.commission_bps, 'pix_key_type', v_p.pix_key_type, 'pix_key', v_p.pix_key,
      'started_at', v_p.started_at, 'ended_at', v_p.ended_at,
      'email', (select email from auth.users where id = v_p.user_id),
      'account_name', (select name from profiles where id = v_p.user_id)),
    'stats', jsonb_build_object(
      'students', (select count(*) from partner_links where partner_id = p_partner),
      'paying_students', (select count(distinct user_id) from payments
          where partner_id = p_partner and status = 'confirmed'),
      'payments', (select count(*) from payments where partner_id = p_partner and status = 'confirmed'),
      'gross_cents', (select coalesce(sum(gross_cents), 0) from payments where partner_id = p_partner and status = 'confirmed'),
      'net_cents', (select coalesce(sum(net_cents), 0) from payments where partner_id = p_partner and status = 'confirmed'),
      'commission_cents', (select coalesce(sum(commission_cents), 0) from payments where partner_id = p_partner and status = 'confirmed'),
      'balance_cents', partner_balance_cents(p_partner),
      'paid_out_cents', (select coalesce(sum(amount_cents), 0) from payouts where partner_id = p_partner and status = 'paid')),
    'students', coalesce((select jsonb_agg(jsonb_build_object('id', s.student_id, 'name', pr.name,
        'username', pr.username, 'linked_at', s.linked_at, 'source', s.source) order by s.linked_at desc)
        from (select * from partner_links where partner_id = p_partner order by linked_at desc limit 500) s
        left join profiles pr on pr.id = s.student_id), '[]'::jsonb),
    'history', coalesce((select jsonb_agg(jsonb_build_object('at', l.occurred_at, 'action', l.action,
        'actor_name', (select name from profiles where id = l.actor_id), 'note', l.note,
        'before', _scrub(l.before_data), 'after', _scrub(l.after_data)) order by l.occurred_at desc)
        from (select * from admin_audit_log where target_type = 'partner' and target_id = p_partner::text
              order by occurred_at desc limit 100) l), '[]'::jsonb),
    'link_history', jsonb_build_object(
      'joined', (select count(*) from partner_link_history where to_partner_id = p_partner),
      'left', (select count(*) from partner_link_history where from_partner_id = p_partner)));
end $$;

-- ---------------------------------------------------------------------------
-- 8. Vínculo aluno → professor (administrativo, auditável, só afeta o futuro)
-- ---------------------------------------------------------------------------
-- O aluno escolhe uma vez; depois só por solicitação. Se o administrador REMOVEU
-- o vínculo, o aluno pode escolher de novo (senão ficaria sem caminho).
create or replace function _link_once(p_student uuid, p_partner uuid, p_source text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_last text;
begin
  if p_student is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  perform pg_advisory_xact_lock(hashtextextended('plink:' || p_student::text, 0));
  select action into v_last from partner_link_history where student_id = p_student order by id desc limit 1;
  if exists (select 1 from partner_links where student_id = p_student)
     or (v_last is not null and v_last <> 'removed') then
    raise exception 'partner already chosen; request a change' using errcode = 'P0020';
  end if;
  if not partner_active_at(p_partner, now()) then
    raise exception 'partner not available' using errcode = 'P0021';
  end if;
  if exists (select 1 from partners where id = p_partner and user_id = p_student) then
    raise exception 'cannot link to yourself' using errcode = 'P0022';
  end if;
  insert into partner_links (student_id, partner_id, source) values (p_student, p_partner, p_source);
  perform _record_link(p_student, null, p_partner, 'linked', p_source, p_student, null);
end $$;

create or replace function get_my_partner() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'linked', l.student_id is not null,
    'partner_id', l.partner_id, 'display_name', p.display_name, 'linked_at', l.linked_at,
    'ever_chose', coalesce((select h.action <> 'removed' from partner_link_history h
                            where h.student_id = auth.uid() order by h.id desc limit 1), false),
    'pending_request', (select to_jsonb(r) - 'student_id' - 'reviewed_by' from partner_change_requests r
                        where r.student_id = auth.uid() and r.status = 'pending'))
  from (select 1) s
  left join partner_links l on l.student_id = auth.uid()
  left join partners p on p.id = l.partner_id
  where auth.uid() is not null;
$$;

create or replace function admin_set_student_partner(p_student uuid, p_partner uuid, p_note text default null)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare v_cur uuid;
begin
  perform require_admin();
  if p_note is not null and char_length(p_note) > 300 then
    raise exception 'note too long' using errcode = 'P0050';
  end if;
  if not exists (select 1 from auth.users where id = p_student) then
    raise exception 'user not found' using errcode = 'P0013';
  end if;
  perform pg_advisory_xact_lock(hashtextextended('plink:' || p_student::text, 0));
  select partner_id into v_cur from partner_links where student_id = p_student for update;
  if p_partner is null then
    if v_cur is null then raise exception 'student has no partner' using errcode = 'P0053'; end if;
    delete from partner_links where student_id = p_student;
    perform _record_link(p_student, v_cur, null, 'removed', 'admin_manual', auth.uid(), null);
  else
    if not partner_active_at(p_partner, now()) then
      raise exception 'partner not available' using errcode = 'P0021';
    end if;
    if exists (select 1 from partners where id = p_partner and user_id = p_student) then
      raise exception 'cannot link to yourself' using errcode = 'P0022';
    end if;
    if v_cur = p_partner then raise exception 'same partner' using errcode = 'P0024'; end if;
    if v_cur is null then
      insert into partner_links (student_id, partner_id, source) values (p_student, p_partner, 'admin_manual');
      perform _record_link(p_student, null, p_partner, 'linked', 'admin_manual', auth.uid(), null);
    else
      update partner_links set partner_id = p_partner, source = 'admin_change', linked_at = now()
      where student_id = p_student;
      perform _record_link(p_student, v_cur, p_partner, 'changed', 'admin_change', auth.uid(), null);
    end if;
  end if;
  -- Uma solicitação pendente fica obsoleta quando o administrador decide direto.
  update partner_change_requests set status = 'rejected', reviewed_at = now(), reviewed_by = auth.uid(),
    review_note = 'superseded by administrative change'
  where student_id = p_student and status = 'pending';
  perform audit_event('partner.link', 'user', p_student::text,
    jsonb_build_object('partner_id', v_cur), jsonb_build_object('partner_id', p_partner), p_note);
end $$;

-- ---------------------------------------------------------------------------
-- 9. Solicitações de troca
-- ---------------------------------------------------------------------------
create or replace function admin_pending_change_count() returns integer
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  perform require_admin();
  return (select count(*) from partner_change_requests where status = 'pending');
end $$;

create or replace function admin_list_change_requests(
  p_status text default null, p_limit integer default 25, p_offset integer default 0
) returns jsonb language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_pg integer[] := _page(p_limit, p_offset);
begin
  perform require_admin();
  if p_status is not null and p_status not in ('pending', 'approved', 'rejected') then
    raise exception 'invalid status' using errcode = 'P0060';
  end if;
  return (select jsonb_build_object('total', coalesce(max(t.total), 0),
    'pending', (select count(*) from partner_change_requests where status = 'pending'),
    'rows', coalesce(jsonb_agg(jsonb_build_object('id', t.id, 'student_id', t.student_id,
      'student_name', t.student_name, 'student_username', t.student_username,
      'from_partner_id', t.from_partner_id, 'from_name', t.from_name,
      'to_partner_id', t.to_partner_id, 'to_name', t.to_name,
      'to_active', partner_active_at(t.to_partner_id, now()), 'reason', t.reason, 'status', t.status,
      'requested_at', t.requested_at, 'reviewed_at', t.reviewed_at, 'reviewer_name', t.reviewer_name,
      'review_note', t.review_note) order by (t.status = 'pending') desc, t.requested_at desc), '[]'::jsonb))
    from (select r.*, pr.name as student_name, pr.username as student_username,
                 pf.display_name as from_name, pt.display_name as to_name, rv.name as reviewer_name,
                 count(*) over () as total
          from partner_change_requests r
          left join profiles pr on pr.id = r.student_id
          left join partners pf on pf.id = r.from_partner_id
          left join partners pt on pt.id = r.to_partner_id
          left join profiles rv on rv.id = r.reviewed_by
          where p_status is null or r.status = p_status
          order by (r.status = 'pending') desc, r.requested_at desc limit v_pg[1] offset v_pg[2]) t);
end $$;

drop function if exists admin_review_partner_change(uuid, boolean, text);
create or replace function admin_review_partner_change(p_request uuid, p_approve boolean, p_note text default null)
returns jsonb language plpgsql security definer set search_path = public, pg_temp as $$
declare r partner_change_requests%rowtype; v_rows integer;
begin
  perform require_admin();
  if p_note is not null and char_length(p_note) > 300 then
    raise exception 'note too long' using errcode = 'P0050';
  end if;
  select * into r from partner_change_requests where id = p_request for update;
  if not found then raise exception 'request not found' using errcode = 'P0013'; end if;
  if r.status <> 'pending' then
    -- Outro administrador já decidiu: devolve o estado atual (idempotente).
    return jsonb_build_object('result', 'already_processed', 'status', r.status);
  end if;
  perform pg_advisory_xact_lock(hashtextextended('plink:' || r.student_id::text, 0));
  if p_approve then
    if not partner_active_at(r.to_partner_id, now()) then
      raise exception 'partner not available' using errcode = 'P0021';
    end if;
    update partner_links set partner_id = r.to_partner_id, source = 'admin_change', linked_at = now()
    where student_id = r.student_id and partner_id = r.from_partner_id;
    get diagnostics v_rows = row_count;
    if v_rows = 0 then
      -- O vínculo mudou desde o pedido: a solicitação ficou obsoleta.
      update partner_change_requests set status = 'rejected', reviewed_at = now(), reviewed_by = auth.uid(),
        review_note = coalesce(p_note, 'obsolete: link changed since the request') where id = p_request;
      perform audit_event('partner.change.obsolete', 'partner_change_request', p_request::text,
        to_jsonb(r), null, p_note);
      return jsonb_build_object('result', 'obsolete', 'status', 'rejected');
    end if;
    perform _record_link(r.student_id, r.from_partner_id, r.to_partner_id, 'changed',
                         'admin_change', auth.uid(), r.id);
  end if;
  update partner_change_requests set status = case when p_approve then 'approved' else 'rejected' end,
    reviewed_at = now(), reviewed_by = auth.uid(), review_note = p_note where id = p_request;
  perform audit_event(case when p_approve then 'partner.change.approve' else 'partner.change.reject' end,
    'partner_change_request', p_request::text, to_jsonb(r), null, p_note);
  return jsonb_build_object('result', 'ok', 'status', case when p_approve then 'approved' else 'rejected' end);
end $$;

-- ---------------------------------------------------------------------------
-- 10. Assinaturas e entitlements (dados reais; papéis aparecem como derivados)
-- ---------------------------------------------------------------------------
create or replace function admin_list_subscriptions(
  p_source text default null, p_state text default null, p_search text default null,
  p_limit integer default 25, p_offset integer default 0
) returns jsonb language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_pg integer[] := _page(p_limit, p_offset); v_q text := _like_escape(coalesce(p_search, ''));
begin
  perform require_admin();
  if p_source is not null and p_source not in ('apple', 'google', 'web', 'trial', 'courtesy', 'partner', 'admin') then
    raise exception 'invalid source' using errcode = 'P0060';
  end if;
  if p_state is not null and p_state not in
     ('active', 'grace', 'canceled', 'expired', 'refunded', 'revoked', 'pending') then
    raise exception 'invalid state' using errcode = 'P0060';
  end if;
  return (with all_rows as (
      select e.id::text as id, e.user_id, e.source, e.plan,
        case when e.state in ('active', 'grace', 'canceled') and e.ends_at is not null and e.ends_at <= now()
             then 'expired' else e.state end as state,
        e.starts_at, e.ends_at, e.auto_renew, e.note, e.created_at as ts
      from entitlements e
      union all
      select 'partner:' || p.id::text, p.user_id, 'partner', null,
        case when partner_active_at(p.id, now()) then 'active' else 'expired' end,
        p.started_at, p.ended_at, null, null, p.started_at from partners p
      union all
      select 'admin:' || a.user_id::text, a.user_id, 'admin', null,
        case when a.revoked_at is null then 'active' else 'revoked' end,
        a.granted_at, a.revoked_at, null, null, a.granted_at from app_admins a
    ), f as (
      select r.*, au.email, pr.name, count(*) over () as total
      from all_rows r join auth.users au on au.id = r.user_id left join profiles pr on pr.id = r.user_id
      where (p_source is null or r.source = p_source) and (p_state is null or r.state = p_state)
        and (v_q = '' or lower(au.email) like '%' || v_q || '%' escape '\'
             or lower(coalesce(pr.name, '')) like '%' || v_q || '%' escape '\')
      order by r.ts desc, r.id limit v_pg[1] offset v_pg[2])
    select jsonb_build_object('total', coalesce(max(total), 0), 'rows', coalesce(jsonb_agg(jsonb_build_object(
      'id', id, 'user_id', user_id, 'name', name, 'email', email, 'source', source, 'plan', plan,
      'state', state, 'starts_at', starts_at, 'ends_at', ends_at, 'auto_renew', auto_renew,
      'note', note, 'at', ts) order by ts desc, id), '[]'::jsonb)) from f);
end $$;

-- ---------------------------------------------------------------------------
-- 11. Configurações comerciais
-- ---------------------------------------------------------------------------
create or replace function admin_get_config() returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare c commercial_config%rowtype;
begin
  perform require_admin();
  select * into c from commercial_config;
  return jsonb_build_object(
    'enforcement_enabled', c.enforcement_enabled, 'emergency_disable', c.emergency_disable,
    'enforced', c.enforcement_enabled and not c.emergency_disable,
    'launch_marker', c.launch_marker, 'legacy_grace_until', c.legacy_grace_until,
    'trial_hours', c.trial_hours, 'essay_daily_limit', c.essay_daily_limit,
    'offline_ttl_hours_user', c.offline_ttl_hours_user, 'offline_ttl_hours_staff', c.offline_ttl_hours_staff,
    'min_version_android', c.min_version_android, 'min_version_ios', c.min_version_ios,
    'min_version_web', c.min_version_web, 'default_commission_bps', c.default_commission_bps,
    'email_verification_required', c.email_verification_required,
    'email_verification_since', c.email_verification_since,
    'legacy_verification_deadline', c.legacy_verification_deadline,
    'updated_at', c.updated_at,
    'prices', jsonb_build_object('currency', 'BRL', 'monthly_cents', 1990, 'annual_cents', 19000),
    'payout_day', 1);
end $$;

create or replace function admin_update_commercial_config(p_patch jsonb) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_before jsonb; k text;
begin
  perform require_admin();
  for k in select jsonb_object_keys(p_patch) loop
    if k in ('min_version_android', 'min_version_ios', 'min_version_web')
       and nullif(p_patch->>k, '') is not null and (p_patch->>k) !~ '^\d+(\.\d+){0,2}$' then
      raise exception 'invalid version' using errcode = 'P0060';
    end if;
  end loop;
  select to_jsonb(c) into v_before from commercial_config c;
  update commercial_config set
    emergency_disable = coalesce((p_patch->>'emergency_disable')::boolean, emergency_disable),
    legacy_grace_until = case when p_patch ? 'legacy_grace_until'
      then nullif(p_patch->>'legacy_grace_until', '')::timestamptz else legacy_grace_until end,
    trial_hours = coalesce((p_patch->>'trial_hours')::integer, trial_hours),
    min_version_android = case when p_patch ? 'min_version_android'
      then nullif(p_patch->>'min_version_android', '') else min_version_android end,
    min_version_ios = case when p_patch ? 'min_version_ios'
      then nullif(p_patch->>'min_version_ios', '') else min_version_ios end,
    min_version_web = case when p_patch ? 'min_version_web'
      then nullif(p_patch->>'min_version_web', '') else min_version_web end,
    essay_daily_limit = coalesce((p_patch->>'essay_daily_limit')::integer, essay_daily_limit),
    offline_ttl_hours_user = coalesce((p_patch->>'offline_ttl_hours_user')::integer, offline_ttl_hours_user),
    offline_ttl_hours_staff = coalesce((p_patch->>'offline_ttl_hours_staff')::integer, offline_ttl_hours_staff),
    default_commission_bps = coalesce((p_patch->>'default_commission_bps')::integer, default_commission_bps),
    email_verification_required = coalesce((p_patch->>'email_verification_required')::boolean, email_verification_required),
    email_verification_since = case
      when coalesce((p_patch->>'email_verification_required')::boolean, false) then coalesce(email_verification_since, now())
      else email_verification_since end,
    legacy_verification_deadline = case when p_patch ? 'legacy_verification_deadline'
      then nullif(p_patch->>'legacy_verification_deadline', '')::timestamptz else legacy_verification_deadline end,
    updated_at = now(), updated_by = auth.uid();
  perform audit_event('config.update', 'commercial_config', 'singleton', v_before,
    (select to_jsonb(c) from commercial_config c), null);
end $$;

-- ---------------------------------------------------------------------------
-- 12. Auditoria (somente leitura; segredos removidos)
-- ---------------------------------------------------------------------------
create or replace function _audit_row(l admin_audit_log) returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object('id', l.id, 'at', l.occurred_at, 'actor_id', l.actor_id,
    'actor_name', (select name from profiles where id = l.actor_id), 'action', l.action,
    'target_type', l.target_type, 'target_id', l.target_id,
    'target_name', case l.target_type
      when 'user' then (select name from profiles where id::text = l.target_id)
      when 'partner' then (select display_name from partners where id::text = l.target_id)
      else null end,
    'note', l.note, 'before', _scrub(l.before_data), 'after', _scrub(l.after_data));
$$;

create or replace function admin_list_audit(
  p_actor uuid default null, p_action text default null, p_target text default null,
  p_from date default null, p_to date default null, p_limit integer default 25, p_offset integer default 0
) returns jsonb language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_pg integer[] := _page(p_limit, p_offset);
begin
  perform require_admin();
  if p_target is not null and char_length(p_target) > 64 then
    raise exception 'invalid target' using errcode = 'P0060';
  end if;
  return (with f as (
      select l as rec, l.id as id, count(*) over () as total from admin_audit_log l
      where (p_actor is null or l.actor_id = p_actor)
        and (p_action is null or l.action = p_action)
        and (p_target is null or l.target_id = p_target
             or l.after_data->>'user_id' = p_target or l.before_data->>'user_id' = p_target
             or l.after_data->>'partner_id' = p_target or l.before_data->>'partner_id' = p_target)
        and (p_from is null or l.occurred_at >= _tz_day_start(p_from))
        and (p_to is null or l.occurred_at < _tz_day_start(p_to + 1))
      order by l.id desc limit v_pg[1] offset v_pg[2])
    select jsonb_build_object('total', coalesce(max(total), 0),
      'rows', coalesce(jsonb_agg(_audit_row(f.rec) order by f.id desc), '[]'::jsonb)) from f);
end $$;

create or replace function admin_audit_actions() returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  perform require_admin();
  return coalesce((select jsonb_agg(a order by a) from (select distinct action a from admin_audit_log) x), '[]'::jsonb);
end $$;

create or replace function admin_audit_neighbors(p_id bigint) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare l admin_audit_log%rowtype;
begin
  perform require_admin();
  select * into l from admin_audit_log where id = p_id;
  if not found then raise exception 'audit entry not found' using errcode = 'P0013'; end if;
  return jsonb_build_object(
    'before', coalesce((select jsonb_agg(_audit_row(n) order by n.id desc) from (
        select * from admin_audit_log where target_type is not distinct from l.target_type
          and target_id is not distinct from l.target_id and id < l.id order by id desc limit 3) n), '[]'::jsonb),
    'after', coalesce((select jsonb_agg(_audit_row(n) order by n.id) from (
        select * from admin_audit_log where target_type is not distinct from l.target_type
          and target_id is not distinct from l.target_id and id > l.id order by id limit 3) n), '[]'::jsonb));
end $$;

-- ---------------------------------------------------------------------------
-- 13. Permissões
-- ---------------------------------------------------------------------------
select app_lock_tables(array['user_activity']);
select app_grant_functions(array['_scrub', '_tz_day_start', '_user_last_study', '_admin_access_match',
  '_like_escape', '_page', '_validate_partner_fields', '_audit_row', '_link_once',
  'service_find_user_by_email'], array[]::text[]);
select app_grant_functions(array['touch_activity', 'get_my_partner', 'admin_assert', 'admin_dashboard',
  'admin_list_users', 'admin_get_user', 'admin_grant_premium', 'admin_revoke_entitlement',
  'admin_promote_partner', 'admin_update_partner', 'admin_list_partners', 'admin_get_partner',
  'admin_set_student_partner', 'admin_pending_change_count', 'admin_list_change_requests',
  'admin_review_partner_change', 'admin_list_subscriptions', 'admin_get_config',
  'admin_update_commercial_config', 'admin_list_audit', 'admin_audit_actions', 'admin_audit_neighbors'],
  array['authenticated']);
notify pgrst, 'reload schema';
