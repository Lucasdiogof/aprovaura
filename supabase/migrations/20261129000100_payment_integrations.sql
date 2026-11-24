-- Premium/Partners — Etapa 07: integrações de pagamento (Apple, Google Play,
-- Mercado Pago). ADITIVA. Nenhum provedor vem habilitado: a compra só é
-- liberada quando payment_providers_config.enabled = true (decisão de lançamento,
-- fora da UI). O backend decide o acesso; o cliente nunca confirma pagamento.
-- Rollback: supabase/rollbacks/20261129000100_payment_integrations.down.sql

-- ---------------------------------------------------------------------------
-- 1. Configuração por provedor/ambiente e catálogo de planos
-- ---------------------------------------------------------------------------
create table if not exists payment_providers_config (
  provider text not null check (provider in ('apple', 'google', 'mercadopago')),
  environment text not null check (environment in ('sandbox', 'production')),
  enabled boolean not null default false,              -- compra liberada?
  fee_estimate_bps integer check (fee_estimate_bps between 0 and 10000), -- null = sem estimativa (taxa 0 marcada "estimada")
  tax_mode text not null default 'pending' check (tax_mode in ('pending', 'none')),
  notes text,
  updated_at timestamptz not null default now(),
  primary key (provider, environment)
);
insert into payment_providers_config (provider, environment)
select p, e from unnest(array['apple', 'google', 'mercadopago']) p, unnest(array['sandbox', 'production']) e
on conflict do nothing;

-- Preço aqui é REFERÊNCIA (BRL, centavos); lojas cobram o que está no console
-- e o app exibe o preço real retornado por elas. Mercado Pago cobra DESTE valor.
create table if not exists payment_catalog (
  plan text not null check (plan in ('monthly', 'annual')),
  provider text not null check (provider in ('apple', 'google', 'mercadopago')),
  environment text not null default 'production' check (environment in ('sandbox', 'production')),
  external_product_id text not null,      -- Apple productId / Google subscriptionId / MP: id interno do plano
  base_plan_id text,                      -- Google: base plan
  price_cents bigint not null check (price_cents > 0),
  currency text not null default 'BRL' check (currency = 'BRL'),
  period_days integer not null check (period_days > 0),   -- Pix avulso
  verified boolean not null default false, -- true só depois de conferido no console da loja
  active boolean not null default true,
  primary key (plan, provider, environment)
);
insert into payment_catalog (plan, provider, external_product_id, base_plan_id, price_cents, period_days) values
  ('monthly', 'apple', 'aprovaura_premium_monthly', null, 1990, 30),
  ('annual', 'apple', 'aprovaura_premium_annual', null, 19000, 365),
  ('monthly', 'google', 'aprovaura_premium', 'monthly', 1990, 30),
  ('annual', 'google', 'aprovaura_premium', 'annual', 19000, 365),
  ('monthly', 'mercadopago', 'aprovaura_premium_monthly', null, 1990, 30),
  ('annual', 'mercadopago', 'aprovaura_premium_annual', null, 19000, 365)
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- 2. Associação segura compra ↔ conta
-- ---------------------------------------------------------------------------
-- Identificador opaco gerado no servidor (Apple appAccountToken / Google
-- obfuscatedAccountId / Mercado Pago external_reference): sem e-mail nem nome.
create table if not exists purchase_account_tokens (
  user_id uuid primary key references auth.users (id) on delete cascade,
  token uuid not null unique default gen_random_uuid(),
  created_at timestamptz not null default now()
);

create table if not exists provider_subscriptions (
  id uuid primary key default gen_random_uuid(),
  provider text not null check (provider in ('apple', 'google', 'mercadopago')),
  environment text not null check (environment in ('sandbox', 'production')),
  original_ref text not null,             -- Apple originalTransactionId / Google purchaseToken raiz / MP preapproval|pix:id
  user_id uuid not null references auth.users (id) on delete cascade,
  plan text not null check (plan in ('monthly', 'annual')),
  state text not null check (state in ('pending', 'active', 'grace', 'canceled', 'expired', 'refunded', 'revoked')),
  period_end timestamptz,
  auto_renew boolean,
  last_event_at timestamptz not null default now(),   -- barra eventos antigos
  last_checked_at timestamptz,
  created_at timestamptz not null default now(),
  unique (provider, environment, original_ref)
);
create index if not exists provider_subscriptions_user_idx on provider_subscriptions (user_id);

-- Tentativa de usar uma assinatura já ligada a outra conta (sem transferência automática).
create table if not exists payment_conflicts (
  id bigint generated always as identity primary key,
  provider text not null, environment text not null, original_ref text not null,
  existing_user uuid, attempted_user uuid, at timestamptz not null default now(), resolved boolean not null default false
);

-- Registro de eventos: idempotência, tentativas, falhas. SEM payload bruto
-- (só um resumo mínimo sem dados pessoais).
create table if not exists payment_events (
  id bigint generated always as identity primary key,
  provider text not null check (provider in ('apple', 'google', 'mercadopago')),
  environment text not null check (environment in ('sandbox', 'production')),
  event_id text not null,
  type text not null,
  occurred_at timestamptz not null,
  original_ref text,
  status text not null default 'received' check (status in ('received', 'processed', 'failed', 'conflict')),
  attempts integer not null default 0,
  last_error text,
  received_at timestamptz not null default now(),
  processed_at timestamptz,
  unique (provider, environment, event_id)
);
create index if not exists payment_events_status_idx on payment_events (status, received_at);

-- Pix avulso / checkout pendente (retomável após fechar a página).
create table if not exists mp_pending_charges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  plan text not null check (plan in ('monthly', 'annual')),
  method text not null check (method in ('pix', 'card')),
  mp_ref text,                              -- id do pagamento (pix) ou preapproval (card)
  amount_cents bigint not null,
  qr_code text, qr_base64 text, checkout_url text,
  status text not null default 'pending' check (status in ('pending', 'approved', 'expired', 'cancelled', 'rejected', 'superseded')),
  expires_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists mp_pending_user_idx on mp_pending_charges (user_id, created_at desc);

-- ---------------------------------------------------------------------------
-- 3. Entrada única de eventos (só service_role): normaliza -> entitlement -> financeiro
-- ---------------------------------------------------------------------------
create or replace function payments_ingest_event(
  p_provider text, p_env text, p_event_id text, p_type text, p_occurred_at timestamptz,
  p_account_token uuid, p_original_ref text, p_plan text, p_state text,
  p_period_start timestamptz, p_period_end timestamptz, p_auto_renew boolean,
  p_payment jsonb default null, p_refund jsonb default null
) returns jsonb language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_ev payment_events%rowtype; v_sub provider_subscriptions%rowtype; v_user uuid; v_stale boolean := false;
  v_src text; v_ref text; v_end timestamptz := p_period_end; v_start timestamptz := p_period_start;
  v_cfg payment_providers_config%rowtype; v_gross bigint; v_fee bigint; v_tax bigint; v_fs text; v_ts text;
  v_days integer; v_state text := p_state;
begin
  if p_provider not in ('apple', 'google', 'mercadopago') or p_env not in ('sandbox', 'production')
     or coalesce(p_event_id, '') = '' or coalesce(p_original_ref, '') = ''
     or p_state not in ('pending', 'active', 'grace', 'canceled', 'expired', 'refunded', 'revoked')
     or p_plan not in ('monthly', 'annual') then
    raise exception 'invalid event' using errcode = 'P0050';
  end if;
  perform pg_advisory_xact_lock(hashtextextended('sub:' || p_provider || ':' || p_env || ':' || p_original_ref, 0));
  insert into payment_events (provider, environment, event_id, type, occurred_at, original_ref)
  values (p_provider, p_env, p_event_id, p_type, p_occurred_at, p_original_ref)
  on conflict (provider, environment, event_id) do nothing;
  select * into v_ev from payment_events where provider = p_provider and environment = p_env and event_id = p_event_id;
  if v_ev.status in ('processed', 'conflict') then return jsonb_build_object('status', v_ev.status, 'duplicate', true); end if;
  update payment_events set attempts = attempts + 1 where id = v_ev.id;

  begin
    select * into v_sub from provider_subscriptions where provider = p_provider and environment = p_env and original_ref = p_original_ref;
    if found then
      v_user := v_sub.user_id;
      if p_account_token is not null and v_user is distinct from (select user_id from purchase_account_tokens where token = p_account_token) then
        insert into payment_conflicts (provider, environment, original_ref, existing_user, attempted_user)
        values (p_provider, p_env, p_original_ref, v_user, (select user_id from purchase_account_tokens where token = p_account_token));
        update payment_events set status = 'conflict', last_error = 'account_conflict', processed_at = now() where id = v_ev.id;
        return jsonb_build_object('status', 'conflict');
      end if;
      v_stale := p_occurred_at < v_sub.last_event_at;
    else
      select user_id into v_user from purchase_account_tokens where token = p_account_token;
      if v_user is null then raise exception 'unlinked purchase' using errcode = 'P0080'; end if;
    end if;

    v_src := case p_provider when 'mercadopago' then 'web' else p_provider end;
    if p_type = 'pix_paid' then     -- Pix avulso: acesso por período fixo, empilhando após o vigente
      select period_days into v_days from payment_catalog where plan = p_plan and provider = p_provider and environment = 'production';
      select greatest(now(), coalesce(max(ends_at), now())) into v_start from entitlements
        where user_id = v_user and source = 'web' and state in ('active', 'canceled') and ends_at > now();
      v_end := v_start + make_interval(days => v_days);
      v_state := 'canceled';        -- sem renovação automática; vale até o fim do período
    end if;
    if v_state in ('expired', 'refunded', 'revoked') then v_end := least(coalesce(v_end, now()), now()); end if;
    v_ref := case when p_env = 'sandbox' then 'sandbox:' else '' end || p_original_ref;

    if not v_stale then
      insert into provider_subscriptions (provider, environment, original_ref, user_id, plan, state, period_end, auto_renew, last_event_at)
      values (p_provider, p_env, p_original_ref, v_user, p_plan, v_state, v_end, case when p_type = 'pix_paid' then false else p_auto_renew end, p_occurred_at)
      on conflict (provider, environment, original_ref) do update set plan = excluded.plan, state = excluded.state,
        period_end = excluded.period_end, auto_renew = excluded.auto_renew, last_event_at = excluded.last_event_at;
      perform service_upsert_entitlement(v_user, v_src, v_ref, v_state, p_plan, v_start, v_end,
        case when p_type = 'pix_paid' then false else p_auto_renew end);
    end if;

    -- Financeiro: só produção (sandbox nunca gera receita nem comissão).
    if p_env = 'production' and p_payment is not null then
      select * into v_cfg from payment_providers_config where provider = p_provider and environment = 'production';
      v_gross := (p_payment->>'gross_cents')::bigint;
      v_fs := coalesce(p_payment->>'fee_source', 'estimated');
      v_ts := coalesce(p_payment->>'tax_source', 'estimated');
      v_fee := (p_payment->>'fee_cents')::bigint;
      v_tax := (p_payment->>'tax_cents')::bigint;
      if v_fee is null then
        v_fee := coalesce(floor(v_gross * v_cfg.fee_estimate_bps / 10000.0)::bigint, 0); v_fs := 'estimated';
      end if;
      if v_tax is null then
        v_tax := 0; v_ts := case when v_cfg.tax_mode = 'none' then 'reported' else 'estimated' end;
      end if;
      perform record_confirmed_payment(p_provider, p_payment->>'external_id', v_user, p_plan, v_gross, v_fee, v_tax,
        coalesce((p_payment->>'paid_at')::timestamptz, p_occurred_at), null, v_fs, v_ts);
      if p_payment ? 'settled_cents' then
        perform record_payment_settlement(p_provider, p_payment->>'external_id', (p_payment->>'settled_cents')::bigint,
          coalesce((p_payment->>'settled_at')::timestamptz, p_occurred_at));
      end if;
    end if;
    if p_env = 'production' and p_refund is not null then
      perform record_payment_refund(p_provider, p_refund->>'external_id', coalesce((p_refund->>'at')::timestamptz, p_occurred_at),
        coalesce((p_refund->>'charged_back')::boolean, false), (p_refund->>'refund_cents')::bigint,
        coalesce((p_refund->>'fee_refund_cents')::bigint, 0), coalesce((p_refund->>'tax_refund_cents')::bigint, 0),
        p_refund->>'external_ref');
    end if;
    update payment_events set status = 'processed', processed_at = now(), last_error = null where id = v_ev.id;
    return jsonb_build_object('status', 'processed', 'user_id', v_user, 'stale', v_stale);
  exception when others then
    update payment_events set status = 'failed', last_error = left(sqlstate || ' ' || sqlerrm, 200) where id = v_ev.id;
    return jsonb_build_object('status', 'failed', 'error', sqlstate);
  end;
end $$;

-- ---------------------------------------------------------------------------
-- 4. Conta: token de compra, assinatura própria, configuração pública
-- ---------------------------------------------------------------------------
create or replace function get_purchase_account_token() returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_uid uuid := auth.uid(); v_t uuid;
begin
  if v_uid is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if must_verify_email(v_uid) then
    raise sqlstate 'PT403' using message = 'email_unverified', hint = 'Confirm your e-mail first.';
  end if;
  insert into purchase_account_tokens (user_id) values (v_uid) on conflict (user_id) do nothing;
  select token into v_t from purchase_account_tokens where user_id = v_uid;
  return v_t;
end $$;

-- Configuração visível ao app: só o que ele precisa (nada secreto).
create or replace function get_purchase_config() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'enabled', coalesce((select jsonb_object_agg(provider, e) from (
        select provider, bool_or(enabled) e from payment_providers_config group by provider) t), '{}'::jsonb),
    'catalog', coalesce((select jsonb_agg(jsonb_build_object('plan', plan, 'provider', provider,
        'product_id', external_product_id, 'base_plan_id', base_plan_id, 'reference_price_cents', price_cents))
        from payment_catalog where active and environment = 'production'), '[]'::jsonb));
$$;

create or replace function get_my_subscription() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'subscriptions', coalesce((select jsonb_agg(jsonb_build_object('provider', provider, 'plan', plan, 'state', state,
        'period_end', period_end, 'auto_renew', auto_renew, 'sandbox', environment = 'sandbox', 'since', created_at)
        order by created_at desc) from provider_subscriptions where user_id = auth.uid()), '[]'::jsonb),
    'pending_charge', (select to_jsonb(c) - 'user_id' from mp_pending_charges c where c.user_id = auth.uid()
        and c.status = 'pending' and (c.expires_at is null or c.expires_at > now()) order by c.created_at desc limit 1));
$$;

-- ---------------------------------------------------------------------------
-- 5. Reconciliação periódica e operação administrativa
-- ---------------------------------------------------------------------------
create or replace function service_subscriptions_to_check(p_limit integer default 50) returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce(jsonb_agg(to_jsonb(s)), '[]'::jsonb) from (
    select id, provider, environment, original_ref, user_id, plan, state, period_end from provider_subscriptions
    where (provider <> 'mercadopago' or original_ref not like 'pix:%')
      and state in ('pending', 'active', 'grace', 'canceled')
      and (last_checked_at is null or last_checked_at < now() - interval '12 hours')
      and (period_end is null or period_end < now() + interval '2 days')
    order by last_checked_at nulls first limit least(greatest(p_limit, 1), 200)) s;
$$;
create or replace function service_mark_checked(p_id uuid) returns void
language sql security definer set search_path = public, pg_temp as $$
  update provider_subscriptions set last_checked_at = now() where id = p_id;
$$;

create or replace function admin_payments_status() returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  perform require_admin();
  return jsonb_build_object(
    'config', (select jsonb_agg(jsonb_build_object('provider', provider, 'environment', environment, 'enabled', enabled,
        'fee_estimate_bps', fee_estimate_bps, 'tax_mode', tax_mode) order by provider, environment) from payment_providers_config),
    'catalog', (select jsonb_agg(jsonb_build_object('plan', plan, 'provider', provider, 'environment', environment,
        'product_id', external_product_id, 'base_plan_id', base_plan_id, 'price_cents', price_cents, 'verified', verified)
        order by provider, plan) from payment_catalog),
    'events', (select jsonb_object_agg(provider, j) from (
        select provider, jsonb_build_object('last_at', max(received_at), 'failed', count(*) filter (where status = 'failed'),
          'conflicts', count(*) filter (where status = 'conflict'), 'total', count(*)) j
        from payment_events group by provider) t),
    'pending_reconciliation', (select count(*) from payments where reconciliation_status = 'pending'),
    'unresolved_conflicts', (select count(*) from payment_conflicts where not resolved),
    'subscriptions', (select jsonb_build_object('active', count(*) filter (where state in ('active', 'grace', 'canceled')),
        'total', count(*)) from provider_subscriptions));
end $$;

create or replace function admin_list_payment_events(p_status text default null, p_provider text default null,
  p_limit integer default 25, p_offset integer default 0) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_pg integer[] := _page(p_limit, p_offset);
begin
  perform require_admin();
  if (p_status is not null and p_status not in ('received', 'processed', 'failed', 'conflict'))
     or (p_provider is not null and p_provider not in ('apple', 'google', 'mercadopago')) then
    raise exception 'invalid filter' using errcode = 'P0060';
  end if;
  return jsonb_build_object(
    'total', (select count(*) from payment_events where (p_status is null or status = p_status) and (p_provider is null or provider = p_provider)),
    'rows', coalesce((select jsonb_agg(to_jsonb(x) order by x.id desc) from (
      select id, provider, environment, event_id, type, occurred_at, status, attempts, last_error, received_at, processed_at
      from payment_events where (p_status is null or status = p_status) and (p_provider is null or provider = p_provider)
      order by id desc limit v_pg[1] offset v_pg[2]) x), '[]'::jsonb));
end $$;

-- Reprocessamento seguro: só recoloca um evento FALHO na fila; a reconciliação
-- relê o estado oficial no provedor (nenhum pagamento é criado à mão).
create or replace function admin_requeue_event(p_id bigint) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare e payment_events%rowtype;
begin
  perform require_admin();
  select * into e from payment_events where id = p_id for update;
  if not found or e.status <> 'failed' then raise exception 'event not requeueable' using errcode = 'P0042'; end if;
  update payment_events set status = 'received' where id = p_id;
  update provider_subscriptions set last_checked_at = null
    where provider = e.provider and environment = e.environment and original_ref = e.original_ref;
  perform audit_event('payment.event_requeue', 'payment_event', p_id::text, null, null, null);
end $$;

-- Imposto sobre venda é registro da própria Lucksrei (não do provedor): conciliar
-- um pagamento com imposto efetivo, mantendo a taxa já gravada.
create or replace function admin_reconcile_payment_tax(p_provider text, p_external_id text, p_tax_cents bigint) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare p payments%rowtype; v jsonb;
begin
  perform require_admin();
  select * into p from payments where provider = p_provider and external_id = p_external_id;
  if not found then raise exception 'payment not found' using errcode = 'P0040'; end if;
  v := record_payment_reconciliation(p_provider, p_external_id, p.fee_cents, coalesce(p_tax_cents, 0));
  perform audit_event('payment.reconcile_tax', 'payment', p.id::text, null, jsonb_build_object('tax_cents', p_tax_cents), null);
  return v;
end $$;

-- ---------------------------------------------------------------------------
-- 6. Gate: rotas de compra liberadas para quem ainda não tem Premium
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
      '/rpc/resolve_referral_code', '/rpc/touch_activity',
      '/rpc/get_purchase_config', '/rpc/get_my_subscription')
     or v_path like '/rpc/admin\_%' or v_path like '/rpc/partner\_%' then
    return;
  end if;
  v_uid := auth.uid();
  -- get_purchase_account_token passa pelo gate de e-mail (mas não exige Premium).
  if v_uid is not null and must_verify_email(v_uid) then
    raise sqlstate 'PT403' using message = 'email_unverified',
      hint = 'Confirm your e-mail with the 6-digit code.';
  end if;
  if v_path = '/rpc/get_purchase_account_token' then return; end if;
  if not commercial_enforced() then return; end if;
  if v_uid is not null and access_allowed(v_uid) then return; end if;
  raise sqlstate 'PT402' using message = 'premium_required',
    hint = 'An active Premium entitlement is required.';
end $$;

-- ---------------------------------------------------------------------------
-- 7. Permissões
-- ---------------------------------------------------------------------------
select app_lock_tables(array['payment_providers_config', 'payment_catalog', 'purchase_account_tokens',
  'provider_subscriptions', 'payment_conflicts', 'payment_events', 'mp_pending_charges']);
select app_grant_functions(array['payments_ingest_event', 'service_subscriptions_to_check', 'service_mark_checked'], array[]::text[]);
select app_grant_functions(array['get_purchase_account_token', 'get_purchase_config', 'get_my_subscription',
  'admin_payments_status', 'admin_list_payment_events', 'admin_requeue_event', 'admin_reconcile_payment_tax'], array['authenticated']);
select app_grant_functions(array['app_pre_request'], array['anon', 'authenticated']);
notify pgrst, 'reload schema';
