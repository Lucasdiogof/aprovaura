-- Reverte a Etapa 07 (integrações de pagamento). Os entitlements já gravados por
-- provedores permanecem (são dados reais); só as tabelas/funções novas somem.
-- O gate app_pre_request volta à versão da Etapa 05 (20261127000100, seção 8).
drop function if exists payments_ingest_event(text, text, text, text, timestamptz, uuid, text, text, text, timestamptz, timestamptz, boolean, jsonb, jsonb);
drop function if exists get_purchase_account_token();
drop function if exists get_purchase_config();
drop function if exists get_my_subscription();
drop function if exists service_subscriptions_to_check(integer);
drop function if exists service_mark_checked(uuid);
drop function if exists admin_payments_status();
drop function if exists admin_list_payment_events(text, text, integer, integer);
drop function if exists admin_requeue_event(bigint);
drop function if exists admin_reconcile_payment_tax(text, text, bigint);
drop table if exists mp_pending_charges, payment_events, payment_conflicts, provider_subscriptions,
  purchase_account_tokens, payment_catalog, payment_providers_config;

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
notify pgrst, 'reload schema';
