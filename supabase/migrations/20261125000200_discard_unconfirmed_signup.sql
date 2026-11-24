-- Premium/Partners — 0700 (Etapa 02): "corrigir e-mail" no cadastro.
-- Quem digitou o e-mail errado não tem sessão (não confirmou) e a conta
-- pendente segura o nome de usuário. Esta RPC (anon) apaga SOMENTE uma conta
-- cujo e-mail nunca foi provado, e só se a senha informada confere (bcrypt do
-- próprio GoTrue). Sem a senha ninguém consegue apagar a conta pendente de
-- outra pessoa. Resposta única (true/false): não revela se o e-mail existe.
create or replace function discard_unconfirmed_signup(p_email text, p_password text)
returns boolean language plpgsql security definer set search_path = public, extensions, pg_temp as $$
declare u record;
begin
  select id, encrypted_password, email_confirmed_at into u from auth.users
  where lower(email) = lower(btrim(p_email)) limit 1;
  if not found or u.email_confirmed_at is not null or email_is_verified(u.id) then
    perform pg_sleep(0.3); return false;     -- atraso fixo: não distingue os casos
  end if;
  if u.encrypted_password is null or u.encrypted_password <> crypt(p_password, u.encrypted_password) then
    perform pg_sleep(0.3); return false;
  end if;
  delete from auth.users where id = u.id;
  perform audit_event('signup.discard_unconfirmed', 'user', u.id::text, null, null, null);
  return true;
end $$;
select app_grant_functions(array['discard_unconfirmed_signup'], array['anon', 'authenticated']);

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
      '/rpc/get_my_partner_profile', '/rpc/partner_update_pix', '/rpc/partner_my_summary',
      '/rpc/get_legal_status', '/rpc/record_legal_acceptance', '/rpc/get_study_sharing',
      '/rpc/set_study_sharing', '/rpc/discard_unconfirmed_signup')
     or v_path like '/rpc/admin\_%' then
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
select app_grant_functions(array['app_pre_request'], array['anon', 'authenticated']);
notify pgrst, 'reload config';
