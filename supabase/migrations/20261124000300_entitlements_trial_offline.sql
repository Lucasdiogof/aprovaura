-- Premium/Partners — 0300: entitlements, teste de 72h, decisão de acesso,
-- autorização offline assinada. Aditiva. Depende de 0100 e 0200.
-- Rollback: supabase/rollbacks/20261124000300_entitlements_trial_offline.down.sql

-- ---------------------------------------------------------------------------
-- 1. Entitlements armazenados (trial, lojas, web, cortesia).
--    Administrador e professor parceiro NÃO são linhas: são derivados em tempo
--    real dos papéis, para que perder o papel perca o Premium na hora.
-- ---------------------------------------------------------------------------

create table if not exists entitlements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  source text not null check (source in ('trial', 'apple', 'google', 'web', 'courtesy')),
  state text not null check (state in
    ('pending', 'active', 'grace', 'canceled', 'expired', 'refunded', 'revoked')),
  plan text check (plan in ('monthly', 'annual')),
  starts_at timestamptz not null default now(),
  -- Fim do período pago (ou da tolerância). 'canceled' continua valendo até aqui.
  ends_at timestamptz,
  auto_renew boolean,
  external_ref text,              -- id da assinatura no provedor (idempotência)
  note text,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists entitlements_user_idx on entitlements (user_id);
create unique index if not exists entitlements_source_ref_uq
  on entitlements (source, external_ref) where external_ref is not null;
create unique index if not exists entitlements_one_trial_uq
  on entitlements (user_id) where source = 'trial';

-- Histórico de mudanças (append-only, sem FK para sobreviver à conta).
create table if not exists entitlement_events (
  id bigint generated always as identity primary key,
  entitlement_id uuid not null,
  user_id uuid not null,
  occurred_at timestamptz not null default now(),
  event text not null,
  from_state text,
  to_state text,
  data jsonb
);
create index if not exists entitlement_events_ent_idx on entitlement_events (entitlement_id, occurred_at);
drop trigger if exists entitlement_events_immutable on entitlement_events;
create trigger entitlement_events_immutable
  before update or delete on entitlement_events
  for each row execute function forbid_mutation();

create or replace function entitlements_history() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if tg_op = 'INSERT' then
    insert into entitlement_events (entitlement_id, user_id, event, to_state, data)
    values (new.id, new.user_id, 'created', new.state, to_jsonb(new));
  elsif new.state is distinct from old.state or new.ends_at is distinct from old.ends_at then
    insert into entitlement_events (entitlement_id, user_id, event, from_state, to_state, data)
    values (new.id, new.user_id, 'changed', old.state, new.state,
            jsonb_build_object('ends_at', new.ends_at, 'plan', new.plan, 'auto_renew', new.auto_renew));
  end if;
  new.updated_at := now();
  return new;
end $$;
-- BEFORE para poder carimbar updated_at; o histórico usa NEW já definitivo.
drop trigger if exists entitlements_history_trg on entitlements;
create trigger entitlements_history_trg before insert or update on entitlements
  for each row execute function entitlements_history();

-- Teste grátis: um por pessoa, mesmo se a conta for apagada e recriada.
-- Sem FK: sobrevive à exclusão. Guarda só hash do e-mail normalizado.
create table if not exists trial_grants (
  user_id uuid primary key,
  email_fingerprint text not null unique,
  granted_at timestamptz not null default now(),
  ends_at timestamptz not null
);

-- Chaves do servidor (assinatura offline). Ninguém do cliente lê.
create table if not exists server_secrets (
  name text primary key,
  value jsonb not null,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 2. Teste de 72h
-- ---------------------------------------------------------------------------

-- Normaliza e-mail para barrar a1+x@gmail.com / a.1@gmail.com como "outra pessoa".
create or replace function email_fingerprint(p_email text) returns text
language plpgsql immutable set search_path = public, extensions, pg_temp as $$
declare v_local text; v_domain text; v_at int;
begin
  p_email := lower(btrim(p_email));
  v_at := position('@' in p_email);
  if v_at = 0 then return encode(digest(p_email, 'sha256'), 'hex'); end if;
  v_local := split_part(split_part(p_email, '@', 1), '+', 1);
  v_domain := split_part(p_email, '@', 2);
  if v_domain in ('gmail.com', 'googlemail.com') then
    v_domain := 'gmail.com';
    v_local := replace(v_local, '.', '');
  end if;
  return encode(digest(v_local || '@' || v_domain, 'sha256'), 'hex');
end $$;

-- Concede (no máximo uma vez) o teste a quem é elegível. Horário do SERVIDOR.
-- Elegível: marco de lançamento definido, conta criada DEPOIS dele, e-mail
-- confirmado, não é admin/professor e o e-mail nunca teve teste.
create or replace function maybe_grant_trial(p_user uuid) returns void
language plpgsql security definer set search_path = public, extensions, pg_temp as $$
declare v_cfg commercial_config%rowtype; u record; v_end timestamptz;
begin
  select * into v_cfg from commercial_config;
  if v_cfg.launch_marker is null then return; end if;
  select id, email, email_confirmed_at, created_at into u from auth.users where id = p_user;
  if not found or u.email_confirmed_at is null or u.email is null then return; end if;
  if u.created_at < v_cfg.launch_marker then return; end if;     -- usuário existente
  if is_admin(p_user) or partner_user_active(p_user) then return; end if;
  perform pg_advisory_xact_lock(hashtextextended('trial:' || p_user::text, 0));
  v_end := now() + make_interval(hours => v_cfg.trial_hours);
  insert into trial_grants (user_id, email_fingerprint, ends_at)
  values (p_user, email_fingerprint(u.email), v_end)
  on conflict do nothing;
  if found then
    insert into entitlements (user_id, source, state, starts_at, ends_at, note)
    values (p_user, 'trial', 'active', now(), v_end, 'auto')
    on conflict do nothing;
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 3. Decisão de acesso (fonte única)
-- ---------------------------------------------------------------------------

create or replace function compute_access(p_user uuid) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare
  v_now timestamptz := now(); v_cfg commercial_config%rowtype;
  v_admin boolean := is_admin(p_user); v_partner boolean := partner_user_active(p_user);
  v_sources jsonb; v_open boolean; v_until timestamptz; v_legacy boolean := false;
begin
  select * into v_cfg from commercial_config;
  select u.created_at < v_cfg.launch_marker into v_legacy from auth.users u where u.id = p_user;
  with src as (
    select 'admin'::text as source, 'active'::text as state, null::timestamptz as until where v_admin
    union all
    select 'partner', 'active', p.ended_at from partners p
      where v_partner and p.user_id = p_user
    union all
    select e.source, e.state, e.ends_at from entitlements e
      where e.user_id = p_user and e.state in ('active', 'grace', 'canceled')
        and e.starts_at <= v_now and (e.ends_at is null or e.ends_at > v_now)
    union all
    select 'transition', 'active', v_cfg.legacy_grace_until
      where coalesce(v_legacy, false) and v_cfg.legacy_grace_until > v_now
  )
  select coalesce(jsonb_agg(jsonb_build_object('source', source, 'state', state, 'until', until)), '[]'::jsonb),
         coalesce(bool_or(until is null), false), max(until)
  into v_sources, v_open, v_until from src;
  return jsonb_build_object(
    'has_access', jsonb_array_length(v_sources) > 0,
    'sources', v_sources,
    'access_until', case when v_open then null else v_until end,
    'indefinite', v_open and jsonb_array_length(v_sources) > 0,
    'roles', jsonb_build_object('admin', v_admin, 'partner', v_partner,
                                'student', not v_admin and not v_partner));
end $$;

-- Usada pelo gate de API: modelo desligado => todos passam.
create or replace function access_allowed(p_user uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select not commercial_enforced() or coalesce((compute_access(p_user)->>'has_access')::boolean, false);
$$;

-- ---------------------------------------------------------------------------
-- 4. Assinatura RSA (RS256) em SQL — sem Edge Function e sem chave no cliente.
--    A chave privada fica em server_secrets('access_rsa') e é inserida fora
--    do repositório. O app só embute a chave pública.
-- ---------------------------------------------------------------------------

create or replace function _hex_to_num(p_hex text) returns numeric
language plpgsql immutable set search_path = public, pg_temp as $$
declare v numeric := 0;
begin
  for i in 1..length(p_hex) loop
    v := v * 16 + ('x' || substr(p_hex, i, 1))::bit(4)::int;
  end loop;
  return v;
end $$;

create or replace function _num_to_hex(p_num numeric, p_len int) returns text
language plpgsql immutable set search_path = public, pg_temp as $$
declare v numeric := p_num; s text := '';
begin
  while v > 0 loop
    s := substr('0123456789abcdef', mod(v, 16)::int + 1, 1) || s;
    v := div(v, 16);
  end loop;
  return lpad(s, p_len, '0');
end $$;

create or replace function _modpow_hex(p_base numeric, p_exp_hex text, p_mod numeric) returns numeric
language plpgsql immutable set search_path = public, pg_temp as $$
declare r numeric := 1; d int;
begin
  for i in 1..length(p_exp_hex) loop
    d := ('x' || substr(p_exp_hex, i, 1))::bit(4)::int;
    for j in reverse 3..0 loop
      r := mod(r * r, p_mod);
      if ((d >> j) & 1) = 1 then r := mod(r * p_base, p_mod); end if;
    end loop;
  end loop;
  return r;
end $$;

create or replace function _b64url(p_bytes bytea) returns text
language sql immutable set search_path = public, pg_temp as $$
  select rtrim(translate(replace(encode(p_bytes, 'base64'), E'\n', ''), '+/', '-_'), '=');
$$;

-- Devolve null se não houver chave configurada (o app apenas fica sem token).
create or replace function sign_access_token(p_payload jsonb) returns text
language plpgsql security definer set search_path = public, extensions, pg_temp as $$
declare
  v_key jsonb; v_header text; v_input text; v_em text; v_sig numeric;
begin
  select value into v_key from server_secrets where name = 'access_rsa';
  if v_key is null then return null; end if;
  v_header := '{"alg":"RS256","typ":"AGT","kid":"' || (v_key->>'kid') || '"}';
  v_input := _b64url(convert_to(v_header, 'UTF8')) || '.' || _b64url(convert_to(p_payload::text, 'UTF8'));
  -- EMSA-PKCS1-v1_5 para RSA-2048: 00 01 FF… 00 DigestInfo(SHA-256) hash
  v_em := '0001' || repeat('ff', 202) || '00' || '3031300d060960864801650304020105000420'
          || encode(digest(v_input, 'sha256'), 'hex');
  v_sig := _modpow_hex(_hex_to_num(v_em), v_key->>'d', _hex_to_num(v_key->>'n'));
  return v_input || '.' || _b64url(decode(_num_to_hex(v_sig, 512), 'hex'));
end $$;

-- ---------------------------------------------------------------------------
-- 5. RPC principal do app: papéis, acesso, config e autorização offline
-- ---------------------------------------------------------------------------

create or replace function get_my_access() returns jsonb
language plpgsql volatile security definer set search_path = public, extensions, pg_temp as $$
declare
  v_uid uuid := auth.uid(); v_cfg commercial_config%rowtype; v_acc jsonb;
  v_enforced boolean; v_allowed boolean; v_staff boolean; v_until timestamptz;
  v_exp timestamptz; v_token text; v_now timestamptz := now();
begin
  if v_uid is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  select * into v_cfg from commercial_config;
  perform _apply_signup_referral(v_uid);
  perform maybe_grant_trial(v_uid);
  v_acc := compute_access(v_uid);
  v_enforced := v_cfg.enforcement_enabled and not v_cfg.emergency_disable;
  v_allowed := (not v_enforced) or (v_acc->>'has_access')::boolean;
  v_staff := (v_acc->'roles'->>'admin')::boolean or (v_acc->'roles'->>'partner')::boolean;
  v_until := nullif(v_acc->>'access_until', '')::timestamptz;
  v_exp := case
    when not v_enforced then v_now + interval '30 days'
    else least(coalesce(v_until, 'infinity'::timestamptz),
               v_now + make_interval(hours => case when v_staff
                 then v_cfg.offline_ttl_hours_staff else v_cfg.offline_ttl_hours_user end))
  end;
  if v_allowed then
    v_token := sign_access_token(jsonb_build_object(
      'v', 1, 'sub', v_uid, 'iat', floor(extract(epoch from v_now))::bigint,
      'exp', floor(extract(epoch from v_exp))::bigint, 'enforced', v_enforced,
      'allowed', true, 'roles', v_acc->'roles',
      'sources', (select coalesce(jsonb_agg(s->>'source'), '[]'::jsonb) from jsonb_array_elements(v_acc->'sources') s)));
  end if;
  return jsonb_build_object(
    'server_time', v_now, 'enforced', v_enforced, 'allowed', v_allowed,
    'has_access', v_acc->'has_access', 'roles', v_acc->'roles', 'sources', v_acc->'sources',
    'access_until', v_acc->'access_until', 'indefinite', v_acc->'indefinite',
    'min_version', jsonb_build_object('android', v_cfg.min_version_android,
      'ios', v_cfg.min_version_ios, 'web', v_cfg.min_version_web),
    'offline_grant', v_token);
end $$;

-- ---------------------------------------------------------------------------
-- 6. Operações administrativas e de provedores
-- ---------------------------------------------------------------------------

create or replace function admin_grant_courtesy(p_user uuid, p_ends_at timestamptz, p_note text default null)
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare v_id uuid;
begin
  perform require_admin();
  if p_ends_at is null or p_ends_at <= now() then
    raise exception 'ends_at must be in the future' using errcode = 'P0030';
  end if;
  if not exists (select 1 from auth.users where id = p_user) then
    raise exception 'user not found' using errcode = 'P0013';
  end if;
  insert into entitlements (user_id, source, state, starts_at, ends_at, note, created_by)
  values (p_user, 'courtesy', 'active', now(), p_ends_at, p_note, auth.uid()) returning id into v_id;
  perform audit_event('entitlement.courtesy', 'user', p_user::text, null,
    jsonb_build_object('entitlement_id', v_id, 'ends_at', p_ends_at), p_note);
  return v_id;
end $$;

create or replace function admin_revoke_entitlement(p_id uuid, p_note text default null) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_before jsonb;
begin
  perform require_admin();
  select to_jsonb(e) into v_before from entitlements e where id = p_id;
  if v_before is null then raise exception 'entitlement not found' using errcode = 'P0013'; end if;
  update entitlements set state = 'revoked', ends_at = least(coalesce(ends_at, now()), now()) where id = p_id;
  perform audit_event('entitlement.revoke', 'entitlement', p_id::text, v_before,
    (select to_jsonb(e) from entitlements e where id = p_id), p_note);
end $$;

-- Webhooks/validação de recibos (futuro) escrevem aqui; só service_role.
-- Idempotente por (source, external_ref). Não mexe nas outras fontes de acesso.
create or replace function service_upsert_entitlement(
  p_user uuid, p_source text, p_external_ref text, p_state text, p_plan text,
  p_starts_at timestamptz, p_ends_at timestamptz, p_auto_renew boolean default null
) returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare v_id uuid;
begin
  if p_source not in ('apple', 'google', 'web') or p_external_ref is null then
    raise exception 'invalid provider entitlement' using errcode = 'P0031';
  end if;
  insert into entitlements (user_id, source, state, plan, starts_at, ends_at, auto_renew, external_ref)
  values (p_user, p_source, p_state, p_plan, coalesce(p_starts_at, now()), p_ends_at, p_auto_renew, p_external_ref)
  on conflict (source, external_ref) where external_ref is not null do update
    set state = excluded.state, plan = excluded.plan, ends_at = excluded.ends_at,
        auto_renew = excluded.auto_renew
    where entitlements.user_id = excluded.user_id
  returning id into v_id;
  return v_id;
end $$;

select app_lock_tables(array['entitlements', 'entitlement_events', 'trial_grants', 'server_secrets']);
select app_grant_functions(array['entitlements_history', 'email_fingerprint', 'maybe_grant_trial',
  'compute_access', 'access_allowed', '_hex_to_num', '_num_to_hex', '_modpow_hex', '_b64url',
  'sign_access_token', 'service_upsert_entitlement'], array[]::text[]);
select app_grant_functions(array['get_my_access', 'admin_grant_courtesy', 'admin_revoke_entitlement'],
  array['authenticated']);
