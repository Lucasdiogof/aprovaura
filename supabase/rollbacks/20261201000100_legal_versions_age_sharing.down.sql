-- Reverte a Etapa 09 (parte 1) PRESERVANDO as proteções de menores (decisão de segurança).
--
-- Restaurado às versões anteriores (20261125000100 / 20261130000100):
--   record_legal_acceptance(2 args), get_legal_status, get_public_app_config, app_pre_request.
-- Removido: get_my_legal_history, publish_legal_version.
-- MANTIDO DE PROPÓSITO (não é "esquecimento"):
--   * tabela user_age_declarations + get_my_age_band/set_my_age_band;
--   * _student_shares exigindo faixa 'adult' e set_study_sharing validando no servidor.
--   Restaurar as versões antigas (sem a regra de idade) reabriria o compartilhamento de
--   estatísticas de menores com professores, o que contraria a decisão "seguro por padrão".
--   Se for realmente necessário voltar ao comportamento antigo, rode o bloco INSEGURO ao fim
--   (comentado) só com decisão explícita do dono.
-- Colunas adicionadas (effective_at, urls, requires_reaccept, summary, platform) são aditivas e inertes: ficam.

-- 1. Aceite legal: assinatura antiga (2 args).
drop function if exists record_legal_acceptance(text, text, text);
create or replace function record_legal_acceptance(p_kind text, p_version text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  if not exists (select 1 from legal_documents where kind = p_kind and version = p_version and is_current) then
    raise exception 'unknown or outdated document' using errcode = 'P0050';
  end if;
  insert into legal_acceptances (user_id, kind, version, source) values (auth.uid(), p_kind, p_version, 'app')
  on conflict do nothing;
end $$;

create or replace function get_legal_status() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce(jsonb_agg(jsonb_build_object('kind', d.kind, 'version', d.version, 'url', d.url,
      'accepted', exists (select 1 from legal_acceptances a where a.user_id = auth.uid()
                          and a.kind = d.kind and a.version = d.version))
    order by d.kind), '[]'::jsonb)
  from legal_documents d where d.is_current and auth.uid() is not null;
$$;

drop function if exists get_my_legal_history();
drop function if exists publish_legal_version(text, text, text, jsonb, timestamptz, boolean, jsonb);

-- 2. Configuração pública sem vigência/idiomas.
create or replace function get_public_app_config() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'enforced', (enforcement_enabled and not emergency_disable),
    'trial_hours', trial_hours,
    'email_verification_required', email_verification_required,
    'has_active_partners', exists (select 1 from partners p where partner_active_at(p.id, now())),
    'legal', coalesce((select jsonb_agg(jsonb_build_object('kind', d.kind, 'version', d.version, 'url', d.url)
                                       order by d.kind) from legal_documents d where d.is_current), '[]'::jsonb),
    'min_version', jsonb_build_object('android', min_version_android, 'ios', min_version_ios, 'web', min_version_web),
    'server_time', now())
  from commercial_config;
$$;

-- 3. Gate (versão da Etapa 08).
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

select app_grant_functions(array['record_legal_acceptance', 'get_legal_status'], array['authenticated']);
select app_grant_functions(array['get_public_app_config'], array['anon', 'authenticated']);
select app_grant_functions(array['app_pre_request'], array['anon', 'authenticated']);
notify pgrst, 'reload schema';

-- ---------------------------------------------------------------------------
-- BLOCO INSEGURO (NÃO EXECUTAR sem decisão explícita do dono): volta ao compartilhamento sem regra de idade.
-- create or replace function _student_shares(p_student uuid) returns boolean
-- language sql stable security definer set search_path = public, pg_temp as $f$
--   select coalesce((select granted from study_sharing_consents where user_id = p_student order by id desc limit 1), false);
-- $f$;
-- (set_study_sharing antigo: ver 20261125000100.)
-- drop function if exists get_my_age_band(); drop function if exists set_my_age_band(text); drop table if exists user_age_declarations;
-- ---------------------------------------------------------------------------
