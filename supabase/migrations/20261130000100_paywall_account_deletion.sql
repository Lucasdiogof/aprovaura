-- Premium/Partners — Etapa 08: paywall e integração final. ADITIVA.
--  1. Exclusão de conta sem travar por FK: professor (anonimiza e preserva o
--     histórico financeiro) e administrador (nunca o último).
--  2. get_my_access_context(): motivo do bloqueio para o paywall (só texto/estado).
--  3. get_my_payment_history(): histórico de pagamentos do próprio usuário.
--  4. Gate: libera as duas RPCs novas (a conta bloqueada precisa consultá-las).
-- Rollback: supabase/rollbacks/20261130000100_paywall_account_deletion.down.sql

-- ---------------------------------------------------------------------------
-- 1a. Professor: a linha de partners sobrevive à conta (payments/ledger/payouts
--     apontam para ela), mas é anonimizada e encerrada.
-- ---------------------------------------------------------------------------
alter table partners alter column user_id drop not null;
alter table partners drop constraint if exists partners_user_id_fkey;
alter table partners add constraint partners_user_id_fkey
  foreign key (user_id) references auth.users (id) on delete set null;

create or replace function partners_anonymize_on_account_delete() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin
  -- Só reage à perda da conta (FK ON DELETE SET NULL), nunca a edições comuns.
  if old.user_id is not null and new.user_id is null then
    new.status := 'ended';
    new.ended_at := coalesce(new.ended_at, now());
    new.display_name := 'Professor removido';
    new.pix_key := null;
    new.pix_key_type := null;
    new.updated_at := now();
  end if;
  return new;
end $$;
drop trigger if exists partners_anonymize_trg on partners;
create trigger partners_anonymize_trg before update of user_id on partners
  for each row execute function partners_anonymize_on_account_delete();

-- ---------------------------------------------------------------------------
-- 1b. Administrador: a linha some junto com a conta, mas o último admin ativo
--     nunca pode ser removido (a exclusão inteira falha, nada é apagado).
-- ---------------------------------------------------------------------------
alter table app_admins drop constraint if exists app_admins_user_id_fkey;
alter table app_admins add constraint app_admins_user_id_fkey
  foreign key (user_id) references auth.users (id) on delete cascade;

create or replace function app_admins_protect_last() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin
  if old.revoked_at is null and not exists (
    select 1 from app_admins a join auth.users u on u.id = a.user_id
    where a.user_id <> old.user_id and a.revoked_at is null and u.email_confirmed_at is not null) then
    raise exception 'cannot remove the last administrator' using errcode = 'P0014';
  end if;
  return old;
end $$;
drop trigger if exists app_admins_protect_last_trg on app_admins;
create trigger app_admins_protect_last_trg before delete on app_admins
  for each row execute function app_admins_protect_last();

-- Dados do pagamento que identificam a pessoa (payload bruto do provedor) são
-- minimizados quando a conta some; valores, datas e comissões ficam (obrigação
-- contábil). Sem FK em payments.user_id: o id vira apenas uma referência opaca.
create or replace function payments_minimize_on_account_delete() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  update payments set raw = null where user_id = old.id and raw is not null;
  return old;
end $$;
drop trigger if exists payments_minimize_trg on auth.users;
create trigger payments_minimize_trg before delete on auth.users
  for each row execute function payments_minimize_on_account_delete();

-- ---------------------------------------------------------------------------
-- 2. Contexto do bloqueio (só para escolher o texto do paywall)
-- ---------------------------------------------------------------------------
create or replace function get_my_access_context() returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare
  v_uid uuid := auth.uid(); v_reason text := 'none'; v_marker timestamptz; v_created timestamptz;
begin
  if v_uid is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  select launch_marker into v_marker from commercial_config;
  select created_at into v_created from auth.users where id = v_uid;
  if exists (select 1 from entitlements where user_id = v_uid and source in ('apple', 'google', 'web')
             and state in ('expired', 'refunded', 'revoked', 'canceled')) then
    v_reason := 'subscription_expired';
  elsif exists (select 1 from entitlements where user_id = v_uid and source = 'trial') then
    v_reason := 'trial_expired';
  elsif v_marker is not null and v_created < v_marker then
    v_reason := 'existing_user';
  end if;
  return jsonb_build_object(
    'reason', v_reason,
    'pending_payment', exists (select 1 from entitlements where user_id = v_uid and state = 'pending')
      or exists (select 1 from mp_pending_charges where user_id = v_uid and status = 'pending'
                 and (expires_at is null or expires_at > now())));
end $$;

-- ---------------------------------------------------------------------------
-- 3. Histórico de pagamentos do próprio usuário (sandbox nunca entra em payments)
-- ---------------------------------------------------------------------------
create or replace function get_my_payment_history() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce(jsonb_agg(jsonb_build_object(
      'provider', provider, 'plan', plan, 'amount_cents', gross_cents, 'status', status, 'paid_at', paid_at)
    order by paid_at desc), '[]'::jsonb)
  from (select * from payments where user_id = auth.uid() order by paid_at desc limit 50) p;
$$;

-- ---------------------------------------------------------------------------
-- 4. Gate: mesmas regras da versão anterior + as duas RPCs novas
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
      '/rpc/get_purchase_config', '/rpc/get_my_subscription',
      '/rpc/get_my_access_context', '/rpc/get_my_payment_history')
     or v_path like '/rpc/admin\_%' or v_path like '/rpc/partner\_%' then
    return;
  end if;
  v_uid := auth.uid();
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

select app_grant_functions(array['get_my_access_context', 'get_my_payment_history'], array['authenticated']);
select app_grant_functions(array['app_pre_request'], array['anon', 'authenticated']);
notify pgrst, 'reload schema';
