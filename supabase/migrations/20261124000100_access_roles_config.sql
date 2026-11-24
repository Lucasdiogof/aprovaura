-- Premium/Partners — 0100: auditoria, papéis, configuração comercial.
-- ADITIVA e não destrutiva: só cria objetos novos. Nenhuma tabela/função
-- existente é alterada. O modelo comercial continua DESLIGADO
-- (commercial_config.enforcement_enabled = false).
-- Rollback: supabase/rollbacks/20261124000100_access_roles_config.down.sql
-- Nunca use `supabase db push` neste projeto; aplicar com o runner documentado
-- em docs/PREMIUM_PARTNERS.md.

-- ---------------------------------------------------------------------------
-- 1. Utilitários internos
-- ---------------------------------------------------------------------------

-- Tabelas de histórico/financeiro são append-only: nada de update/delete.
create or replace function forbid_mutation() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin
  raise exception '% is append-only', tg_table_name using errcode = 'P0011';
end $$;

-- Aplica EXECUTE a uma lista de funções (por nome) e retira de todo o resto.
-- p_roles: quem recebe. Vazio = só service_role/postgres.
create or replace function app_grant_functions(p_names text[], p_roles text[])
returns void language plpgsql set search_path = public, pg_temp as $$
declare r record; v_role text;
begin
  for r in
    select p.oid::regprocedure as sig from pg_proc p
    where p.pronamespace = 'public'::regnamespace and p.proname = any (p_names)
  loop
    execute format('revoke all on function %s from public, anon, authenticated', r.sig);
    foreach v_role in array p_roles loop
      execute format('grant execute on function %s to %s', r.sig, v_role);
    end loop;
  end loop;
end $$;

-- Bloqueia o acesso direto (PostgREST) às tabelas novas: tudo passa por RPC
-- security definer. RLS ligada sem policies = defesa em profundidade.
create or replace function app_lock_tables(p_names text[])
returns void language plpgsql set search_path = public, pg_temp as $$
declare v_name text;
begin
  foreach v_name in array p_names loop
    execute format('alter table public.%I enable row level security', v_name);
    execute format('revoke all on table public.%I from public, anon, authenticated', v_name);
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- 2. Auditoria administrativa (append-only)
-- ---------------------------------------------------------------------------

create table if not exists admin_audit_log (
  id bigint generated always as identity primary key,
  occurred_at timestamptz not null default now(),
  actor_id uuid,                -- null = service role / SQL direto
  action text not null,
  target_type text,
  target_id text,
  before_data jsonb,
  after_data jsonb,
  note text
);
create index if not exists admin_audit_log_target_idx
  on admin_audit_log (target_type, target_id, occurred_at desc);

drop trigger if exists admin_audit_log_immutable on admin_audit_log;
create trigger admin_audit_log_immutable
  before update or delete on admin_audit_log
  for each row execute function forbid_mutation();

create or replace function audit_event(
  p_action text, p_target_type text, p_target_id text,
  p_before jsonb default null, p_after jsonb default null, p_note text default null
) returns void language sql security definer set search_path = public, pg_temp as $$
  insert into admin_audit_log (actor_id, action, target_type, target_id, before_data, after_data, note)
  values (auth.uid(), p_action, p_target_type, p_target_id, p_before, p_after, p_note);
$$;

-- ---------------------------------------------------------------------------
-- 3. Administradores
-- ---------------------------------------------------------------------------
-- Papel de ADMIN vive só aqui (nunca em user_metadata/app_metadata, que o
-- usuário pode editar ou que seriam confiados ao cliente). Um aluno vira admin
-- na MESMA conta; o histórico dele não muda. Professor é outra tabela.

create table if not exists app_admins (
  user_id uuid primary key references auth.users (id) on delete restrict,
  granted_at timestamptz not null default now(),
  granted_by uuid,
  revoked_at timestamptz,
  revoked_by uuid,
  note text
);

-- E-mail confirmado é exigido no momento da checagem (não só na concessão).
create or replace function is_admin(p_user uuid default auth.uid())
returns boolean language sql stable security definer set search_path = public, pg_temp as $$
  select p_user is not null and exists (
    select 1 from app_admins a join auth.users u on u.id = a.user_id
    where a.user_id = p_user and a.revoked_at is null and u.email_confirmed_at is not null
  );
$$;

create or replace function require_admin() returns void
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  if not is_admin(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;
end $$;

-- Provisionamento do PRIMEIRO administrador: só service_role (SQL/CLI do
-- dono), só enquanto não existir admin ativo, só para conta com e-mail
-- confirmado. Quem é o dono é decidido por um humano passando o user_id —
-- nunca inferido por nome ou e-mail.
create or replace function bootstrap_first_admin(p_user_id uuid)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if exists (select 1 from app_admins where revoked_at is null) then
    raise exception 'an active admin already exists' using errcode = 'P0012';
  end if;
  if not exists (select 1 from auth.users where id = p_user_id and email_confirmed_at is not null) then
    raise exception 'user not found or e-mail not confirmed' using errcode = 'P0013';
  end if;
  insert into app_admins (user_id, granted_by, note)
  values (p_user_id, null, 'bootstrap')
  on conflict (user_id) do update
    set revoked_at = null, revoked_by = null, granted_at = now(), granted_by = null, note = 'bootstrap';
  perform audit_event('admin.bootstrap', 'user', p_user_id::text, null,
    jsonb_build_object('user_id', p_user_id), 'first administrator');
end $$;

create or replace function admin_set_admin(p_user uuid, p_enable boolean, p_note text default null)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare v_before jsonb;
begin
  perform require_admin();
  select to_jsonb(a) into v_before from app_admins a where user_id = p_user;
  if p_enable then
    if not exists (select 1 from auth.users where id = p_user and email_confirmed_at is not null) then
      raise exception 'user not found or e-mail not confirmed' using errcode = 'P0013';
    end if;
    insert into app_admins (user_id, granted_by, note) values (p_user, auth.uid(), p_note)
    on conflict (user_id) do update
      set revoked_at = null, revoked_by = null, granted_at = now(), granted_by = auth.uid(), note = p_note;
  else
    update app_admins set revoked_at = now(), revoked_by = auth.uid(), note = coalesce(p_note, note)
    where user_id = p_user and revoked_at is null;
    if not exists (select 1 from app_admins a join auth.users u on u.id = a.user_id
                   where a.revoked_at is null and u.email_confirmed_at is not null) then
      raise exception 'cannot remove the last administrator' using errcode = 'P0014';
    end if;
  end if;
  perform audit_event(case when p_enable then 'admin.grant' else 'admin.revoke' end,
    'user', p_user::text, v_before, (select to_jsonb(a) from app_admins a where user_id = p_user), p_note);
end $$;

-- ---------------------------------------------------------------------------
-- 4. Configuração comercial centralizada (linha única)
-- ---------------------------------------------------------------------------

create table if not exists commercial_config (
  id boolean primary key default true check (id),
  -- Interruptor do modelo Premium. DESLIGADO até a etapa de lançamento.
  enforcement_enabled boolean not null default false,
  -- Desativação emergencial: vence enforcement_enabled.
  emergency_disable boolean not null default false,
  -- Marco do lançamento comercial (definido na ativação). Quem criou a conta
  -- ANTES dele é "usuário existente": sem teste grátis.
  launch_marker timestamptz,
  -- Carência opcional para usuários existentes (transição suave).
  legacy_grace_until timestamptz,
  trial_hours integer not null default 72 check (trial_hours between 1 and 720),
  -- Versão mínima por plataforma: só orienta a tela "atualize o app". A
  -- autorização real é o entitlement no servidor, nunca a versão do cliente.
  min_version_android text,
  min_version_ios text,
  min_version_web text,
  essay_daily_limit integer not null default 3 check (essay_daily_limit between 0 and 50),
  offline_ttl_hours_user integer not null default 168 check (offline_ttl_hours_user between 1 and 720),
  offline_ttl_hours_staff integer not null default 24 check (offline_ttl_hours_staff between 1 and 168),
  updated_at timestamptz not null default now(),
  updated_by uuid,
  constraint enforcement_needs_marker check (not enforcement_enabled or launch_marker is not null)
);
insert into commercial_config (id) values (true) on conflict (id) do nothing;

create or replace function commercial_enforced() returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce((select enforcement_enabled and not emergency_disable from commercial_config), false);
$$;

-- Leitura pública (inclusive anon) do que o app precisa saber ANTES do login.
create or replace function get_public_app_config() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'enforced', (enforcement_enabled and not emergency_disable),
    'trial_hours', trial_hours,
    'min_version', jsonb_build_object('android', min_version_android,
                                      'ios', min_version_ios, 'web', min_version_web),
    'server_time', now())
  from commercial_config;
$$;

create or replace function admin_update_commercial_config(p_patch jsonb) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_before jsonb;
begin
  perform require_admin();
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
    updated_at = now(), updated_by = auth.uid();
  perform audit_event('config.update', 'commercial_config', 'singleton', v_before,
    (select to_jsonb(c) from commercial_config c), null);
end $$;

-- O INTERRUPTOR DE LANÇAMENTO. Nesta etapa ele NÃO é acionado.
-- Ativar fixa o marco de lançamento (uma única vez). Desativar não apaga o marco.
create or replace function admin_set_commercial_enforcement(p_enabled boolean) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_before jsonb;
begin
  perform require_admin();
  select to_jsonb(c) into v_before from commercial_config c;
  update commercial_config set
    enforcement_enabled = p_enabled,
    launch_marker = case when p_enabled then coalesce(launch_marker, now()) else launch_marker end,
    updated_at = now(), updated_by = auth.uid();
  perform audit_event(case when p_enabled then 'commercial.enable' else 'commercial.disable' end,
    'commercial_config', 'singleton', v_before, (select to_jsonb(c) from commercial_config c), null);
end $$;

-- ---------------------------------------------------------------------------
-- 5. Permissões e bloqueio de acesso direto
-- ---------------------------------------------------------------------------
select app_lock_tables(array['admin_audit_log', 'app_admins', 'commercial_config']);

select app_grant_functions(array['forbid_mutation', 'audit_event', 'require_admin',
  'bootstrap_first_admin', 'app_grant_functions', 'app_lock_tables'], array[]::text[]);
-- is_admin/commercial_enforced NÃO são chamáveis pelo cliente (permitiria
-- sondar uuids de administradores); o app lê o próprio papel via get_my_access.
select app_grant_functions(array['is_admin', 'commercial_enforced'], array[]::text[]);
select app_grant_functions(array['get_public_app_config'], array['anon', 'authenticated']);
select app_grant_functions(array['admin_set_admin', 'admin_update_commercial_config',
  'admin_set_commercial_enforcement'], array['authenticated']);
