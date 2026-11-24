-- Premium/Partners — 0500: gate central de API (INERTE com o modelo desligado)
-- e limite de redações configurável. Compatível com os apps publicados: com
-- commercial_config.enforcement_enabled = false nada muda para ninguém.
-- Rollback: supabase/rollbacks/20261124000500_enforcement_gate_essay.down.sql

-- 1. Limite diário de redações vem da configuração (padrão 3, como antes).
-- plpgsql: o corpo só é resolvido na execução.
create or replace function essay_daily_evaluation_limit()
returns integer language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  return coalesce((select essay_daily_limit from commercial_config), 3);
end $$;

-- 2. Gate central: PostgREST chama isto ANTES de cada requisição (tabelas e
-- RPCs, inclusive chamadas diretas à API). Com o modelo ligado, quem não tem
-- Premium recebe HTTP 402 (PT402) em tudo, exceto na lista abaixo (conta,
-- perfil, acesso, indicação, cadastro). service_role e o próprio Auth não
-- passam por aqui. Desligado => retorna na primeira linha.
create or replace function app_pre_request() returns void
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_path text; v_role text := current_setting('role', true);
begin
  if v_role is null or v_role not in ('anon', 'authenticated') then return; end if;
  if not commercial_enforced() then return; end if;
  v_path := coalesce(current_setting('request.path', true), '');
  if v_path in ('', '/', '/profiles', '/rpc/is_username_available', '/rpc/get_my_access',
      '/rpc/get_public_app_config', '/rpc/list_active_partners', '/rpc/link_partner',
      '/rpc/get_my_partner', '/rpc/request_partner_change', '/rpc/get_my_partner_profile',
      '/rpc/partner_update_pix', '/rpc/partner_my_summary')
     or v_path like '/rpc/admin\_%' then
    return;
  end if;
  if auth.uid() is not null and access_allowed(auth.uid()) then return; end if;
  raise sqlstate 'PT402' using message = 'premium_required',
    hint = 'An active Premium entitlement is required.';
end $$;

select app_grant_functions(array['essay_daily_evaluation_limit'], array['anon', 'authenticated']);
select app_grant_functions(array['app_pre_request'], array['anon', 'authenticated']);

-- 3. Liga o gate no PostgREST. Seguro com o modelo desligado.
alter role authenticator set pgrst.db_pre_request = 'public.app_pre_request';
notify pgrst, 'reload config';
