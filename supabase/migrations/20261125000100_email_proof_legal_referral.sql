-- Premium/Partners — 0600 (Etapa 02): prova real de posse do e-mail, trial
-- ancorado na confirmação, termos/consentimentos, busca de professores e
-- gate revisado. ADITIVA e compatível com os apps publicados: com
-- email_verification_required = false e enforcement_enabled = false nada muda.
-- Rollback: supabase/rollbacks/20261125000100_email_proof_legal_referral.down.sql

-- ---------------------------------------------------------------------------
-- 1. Prova de posse do e-mail
--    auth.users.email_confirmed_at NÃO é prova: com mailer_autoconfirm ligado o
--    Supabase confirma na criação. Prova = a confirmação aconteceu DEPOIS da
--    criação (UPDATE feito pelo GoTrue ao validar o código) ou atestado do dono.
-- ---------------------------------------------------------------------------

create table if not exists email_verifications (
  user_id uuid primary key references auth.users (id) on delete cascade,
  verified_at timestamptz not null,
  method text not null check (method in ('otp', 'owner_attested')),
  note text,
  recorded_at timestamptz not null default now()
);

create or replace function email_is_verified(p_user uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select p_user is not null and exists (select 1 from email_verifications where user_id = p_user);
$$;

-- Atestado do dono (service_role): só para contas que o próprio dono reconhece
-- (ex.: a conta administrativa criada antes da confirmação real existir).
create or replace function owner_attest_email(p_user uuid, p_note text default null) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if not exists (select 1 from auth.users where id = p_user) then
    raise exception 'user not found' using errcode = 'P0013';
  end if;
  insert into email_verifications (user_id, verified_at, method, note)
  values (p_user, now(), 'owner_attested', p_note)
  on conflict (user_id) do nothing;
  perform audit_event('email.owner_attest', 'user', p_user::text, null,
    jsonb_build_object('user_id', p_user), p_note);
end $$;

-- Administradores hoje existentes já foram reconhecidos pelo dono na Etapa 01.
insert into email_verifications (user_id, verified_at, method, note)
select user_id, now(), 'owner_attested', 'migration 0600: administrador pré-existente'
from app_admins where revoked_at is null
on conflict (user_id) do nothing;

-- Administrador exige prova de e-mail (não mais email_confirmed_at).
create or replace function is_admin(p_user uuid default auth.uid()) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select p_user is not null and exists (
    select 1 from app_admins a where a.user_id = p_user and a.revoked_at is null
      and exists (select 1 from email_verifications v where v.user_id = a.user_id));
$$;

create or replace function bootstrap_first_admin(p_user_id uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if exists (select 1 from app_admins where revoked_at is null) then
    raise exception 'an active admin already exists' using errcode = 'P0012';
  end if;
  if not email_is_verified(p_user_id) then
    raise exception 'user has no verified e-mail (use owner_attest_email)' using errcode = 'P0013';
  end if;
  insert into app_admins (user_id, granted_by, note) values (p_user_id, null, 'bootstrap')
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
    if not email_is_verified(p_user) then
      raise exception 'user has no verified e-mail' using errcode = 'P0013';
    end if;
    insert into app_admins (user_id, granted_by, note) values (p_user, auth.uid(), p_note)
    on conflict (user_id) do update
      set revoked_at = null, revoked_by = null, granted_at = now(), granted_by = auth.uid(), note = p_note;
  else
    update app_admins set revoked_at = now(), revoked_by = auth.uid(), note = coalesce(p_note, note)
    where user_id = p_user and revoked_at is null;
    if not exists (select 1 from app_admins a where a.revoked_at is null and email_is_verified(a.user_id)) then
      raise exception 'cannot remove the last administrator' using errcode = 'P0014';
    end if;
  end if;
  perform audit_event(case when p_enable then 'admin.grant' else 'admin.revoke' end,
    'user', p_user::text, v_before, (select to_jsonb(a) from app_admins a where user_id = p_user), p_note);
end $$;

-- ---------------------------------------------------------------------------
-- 2. Termos e privacidade: versionamento e aceite
-- ---------------------------------------------------------------------------

create table if not exists legal_documents (
  kind text not null check (kind in ('terms', 'privacy')),
  version text not null,
  url text not null,
  published_at timestamptz not null default now(),
  is_current boolean not null default false,
  primary key (kind, version)
);
create unique index if not exists legal_documents_one_current on legal_documents (kind) where is_current;

create table if not exists legal_acceptances (
  user_id uuid not null references auth.users (id) on delete cascade,
  kind text not null,
  version text not null,
  accepted_at timestamptz not null default now(),
  source text not null check (source in ('signup', 'app')),
  primary key (user_id, kind, version),
  foreign key (kind, version) references legal_documents (kind, version)
);

-- A política de privacidade atual já é pública. Os TERMOS DE USO ainda não
-- existem: nenhum documento incompleto é publicado aqui.
insert into legal_documents (kind, version, url, is_current)
values ('privacy', '2026-09-28', 'https://lucksrei.com/projects/aura/privacy/', true)
on conflict (kind, version) do nothing;

-- Consentimento de COMPARTILHAMENTO de estatísticas de estudo com professores
-- vinculados. Histórico append-only; padrão = não compartilhado. O aceite dos
-- termos NÃO é este consentimento. Menores: exige consentimento do responsável.
-- Nenhuma função de leitura para professores existe nesta etapa; redações e
-- dados pessoais nunca fazem parte do escopo.
create table if not exists study_sharing_consents (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  scope text not null default 'study_stats' check (scope = 'study_stats'),
  granted boolean not null,
  consent_version text not null,
  declared_minor boolean not null default false,
  guardian_consent boolean not null default false,
  source text not null default 'app',
  recorded_at timestamptz not null default now(),
  constraint minor_needs_guardian check (not (granted and declared_minor) or guardian_consent)
);
create index if not exists study_sharing_consents_user_idx on study_sharing_consents (user_id, recorded_at desc);
drop trigger if exists study_sharing_consents_immutable on study_sharing_consents;
create trigger study_sharing_consents_immutable before update or delete on study_sharing_consents
  for each row execute function forbid_mutation();

create or replace function get_legal_status() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce(jsonb_agg(jsonb_build_object('kind', d.kind, 'version', d.version, 'url', d.url,
      'accepted', exists (select 1 from legal_acceptances a where a.user_id = auth.uid()
                          and a.kind = d.kind and a.version = d.version))
    order by d.kind), '[]'::jsonb)
  from legal_documents d where d.is_current and auth.uid() is not null;
$$;

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

-- Aceite dado no cadastro (user_metadata.legal_accept = {kind: version}) vira
-- registro quando a posse do e-mail é provada. Só vale para a versão VIGENTE.
create or replace function _apply_signup_legal(p_user uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_meta jsonb; d record;
begin
  select raw_user_meta_data->'legal_accept' into v_meta from auth.users where id = p_user;
  if v_meta is null or jsonb_typeof(v_meta) <> 'object' then return; end if;
  for d in select kind, version from legal_documents where is_current loop
    if v_meta->>d.kind = d.version then
      insert into legal_acceptances (user_id, kind, version, source, accepted_at)
      select p_user, d.kind, d.version, 'signup', u.created_at from auth.users u where u.id = p_user
      on conflict do nothing;
    end if;
  end loop;
end $$;

create or replace function get_study_sharing() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce((select jsonb_build_object('granted', c.granted, 'version', c.consent_version,
      'declared_minor', c.declared_minor, 'guardian_consent', c.guardian_consent, 'recorded_at', c.recorded_at)
    from study_sharing_consents c where c.user_id = auth.uid() order by c.id desc limit 1),
    jsonb_build_object('granted', false)) where auth.uid() is not null;
$$;

create or replace function set_study_sharing(
  p_granted boolean, p_version text, p_declared_minor boolean default false,
  p_guardian_consent boolean default false
) returns void language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  if p_granted and p_declared_minor and not p_guardian_consent then
    raise exception 'guardian consent required for minors' using errcode = 'P0051';
  end if;
  insert into study_sharing_consents (user_id, granted, consent_version, declared_minor, guardian_consent)
  values (auth.uid(), p_granted, p_version, p_declared_minor, p_guardian_consent);
end $$;

-- ---------------------------------------------------------------------------
-- 3. Indicação de professor: busca paginada + código no metadado
-- ---------------------------------------------------------------------------

-- Cadastro (anon): só id e nome de divulgação de professores ATIVOS, com busca
-- e paginação. Sem e-mail, Pix ou qualquer dado privado.
create or replace function search_active_partners(
  p_query text default null, p_limit integer default 30, p_offset integer default 0
) returns table (partner_id uuid, display_name text)
language sql stable security definer set search_path = public, pg_temp as $$
  select p.id, p.display_name from partners p
  where partner_active_at(p.id, now())
    and (p_query is null or btrim(p_query) = ''
         or lower(p.display_name) like '%' || replace(replace(replace(lower(btrim(p_query)),
              '\', '\\'), '%', '\%'), '_', '\_') || '%' escape '\')
  order by lower(p.display_name), p.id
  limit least(greatest(coalesce(p_limit, 30), 1), 50) offset greatest(coalesce(p_offset, 0), 0);
$$;

create or replace function _apply_signup_referral(p_user uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_pid uuid; v_code text;
begin
  begin
    select nullif(u.raw_user_meta_data->>'referral_partner_id', '')::uuid,
           nullif(btrim(u.raw_user_meta_data->>'referral_code'), '')
      into v_pid, v_code from auth.users u where u.id = p_user;
  exception when others then
    return;
  end;
  if v_pid is null and v_code is not null then
    select id into v_pid from partners where referral_code = upper(v_code);
  end if;
  if v_pid is null then return; end if;
  begin
    perform _link_once(p_user, v_pid, 'signup');
  exception when others then
    null; -- indicação inválida/inativa/já escolhida nunca bloqueia a conta
  end;
end $$;

-- ---------------------------------------------------------------------------
-- 4. Configuração: verificação de e-mail obrigatória (DESLIGADA)
-- ---------------------------------------------------------------------------

alter table commercial_config
  add column if not exists email_verification_required boolean not null default false,
  add column if not exists email_verification_since timestamptz,
  add column if not exists legacy_verification_deadline timestamptz;

create or replace function must_verify_email(p_user uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce((
    select c.email_verification_required and not email_is_verified(p_user)
      and (u.created_at >= coalesce(c.email_verification_since, 'infinity'::timestamptz)
           or (c.legacy_verification_deadline is not null and now() > c.legacy_verification_deadline))
    from commercial_config c, auth.users u where u.id = p_user), false);
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

-- ---------------------------------------------------------------------------
-- 5. Trial ancorado na confirmação efetiva; gatilho de confirmação
-- ---------------------------------------------------------------------------

create or replace function maybe_grant_trial(p_user uuid) returns void
language plpgsql security definer set search_path = public, extensions, pg_temp as $$
declare v_cfg commercial_config%rowtype; u record; v_ver timestamptz; v_end timestamptz;
begin
  select * into v_cfg from commercial_config;
  if v_cfg.launch_marker is null then return; end if;
  select id, email, created_at into u from auth.users where id = p_user;
  if not found or u.email is null then return; end if;
  -- Sem prova real de posse (confirmação por código) não há teste.
  select verified_at into v_ver from email_verifications where user_id = p_user and method = 'otp';
  if v_ver is null then return; end if;
  if u.created_at < v_cfg.launch_marker then return; end if;        -- usuário existente
  if is_admin(p_user) or partner_user_active(p_user) then return; end if;
  perform pg_advisory_xact_lock(hashtextextended('trial:' || p_user::text, 0));
  v_end := v_ver + make_interval(hours => v_cfg.trial_hours);       -- 72h a partir da confirmação
  insert into trial_grants (user_id, email_fingerprint, ends_at)
  values (p_user, email_fingerprint(u.email), v_end) on conflict do nothing;
  if found then
    insert into entitlements (user_id, source, state, starts_at, ends_at, note)
    values (p_user, 'trial', 'active', v_ver, v_end, 'auto') on conflict do nothing;
  end if;
end $$;

-- Disparado pelo GoTrue quando o código de 6 dígitos é validado (UPDATE de
-- email_confirmed_at de nulo para preenchido). Nunca pode derrubar o login: todo
-- passo está protegido.
create or replace function on_auth_email_confirmed() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  begin
    insert into email_verifications (user_id, verified_at, method)
    values (new.id, new.email_confirmed_at, 'otp') on conflict (user_id) do nothing;
  exception when others then
    return new;
  end;
  begin perform _apply_signup_referral(new.id); exception when others then null; end;
  begin perform _apply_signup_legal(new.id); exception when others then null; end;
  begin perform maybe_grant_trial(new.id); exception when others then null; end;
  return new;
end $$;

drop trigger if exists on_auth_email_confirmed_trg on auth.users;
create trigger on_auth_email_confirmed_trg
  after update of email_confirmed_at on auth.users
  for each row when (old.email_confirmed_at is null and new.email_confirmed_at is not null)
  execute function on_auth_email_confirmed();

-- ---------------------------------------------------------------------------
-- 6. get_my_access: prova de e-mail e autorização sem modelo curta (24h)
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
  perform _apply_signup_legal(v_uid);
  perform maybe_grant_trial(v_uid);
  v_acc := compute_access(v_uid);
  v_enforced := v_cfg.enforcement_enabled and not v_cfg.emergency_disable;
  v_allowed := (not v_enforced) or (v_acc->>'has_access')::boolean;
  v_staff := (v_acc->'roles'->>'admin')::boolean or (v_acc->'roles'->>'partner')::boolean;
  v_until := nullif(v_acc->>'access_until', '')::timestamptz;
  -- Sem o modelo ligado a autorização é curta (24h): uma permissão antiga e
  -- permissiva não sobrevive à ativação por mais que isso.
  v_exp := case
    when not v_enforced then v_now + interval '24 hours'
    else least(coalesce(v_until, 'infinity'::timestamptz),
               v_now + make_interval(hours => case when v_staff
                 then v_cfg.offline_ttl_hours_staff else v_cfg.offline_ttl_hours_user end))
  end;
  if v_allowed and not must_verify_email(v_uid) then
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
    'email_verified', email_is_verified(v_uid), 'must_verify_email', must_verify_email(v_uid),
    'min_version', jsonb_build_object('android', v_cfg.min_version_android,
      'ios', v_cfg.min_version_ios, 'web', v_cfg.min_version_web),
    'offline_grant', v_token);
end $$;

-- ---------------------------------------------------------------------------
-- 7. Gate revisado: confirmação/recuperação (GoTrue) não passam por aqui;
--    perfil, indicação, termos, consentimento e contratação ficam liberados;
--    conteúdo protegido continua exigindo acesso (402) e e-mail provado (403).
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
      '/rpc/get_my_partner_profile', '/rpc/partner_update_pix', '/rpc/partner_my_summary',
      '/rpc/get_legal_status', '/rpc/record_legal_acceptance', '/rpc/get_study_sharing',
      '/rpc/set_study_sharing')
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

-- ---------------------------------------------------------------------------
-- 8. Estratégia para e-mails antigos (preparada, NÃO executada)
-- ---------------------------------------------------------------------------

-- Faz um usuário legado provar a posse: tira o "confirmado" fictício; no próximo
-- login o app leva à tela do código e o GoTrue confirma de verdade. Preserva a
-- conta e todos os dados. Admins/atestados ficam de fora.
create or replace function require_email_reverification(p_user uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if email_is_verified(p_user) then return; end if;
  update auth.users set email_confirmed_at = null, confirmation_sent_at = null where id = p_user;
  perform audit_event('email.reverify_required', 'user', p_user::text, null, null, null);
end $$;

select app_lock_tables(array['email_verifications', 'legal_documents', 'legal_acceptances', 'study_sharing_consents']);
select app_grant_functions(array['email_is_verified', 'owner_attest_email', 'bootstrap_first_admin',
  'must_verify_email', 'maybe_grant_trial', 'on_auth_email_confirmed', '_apply_signup_legal',
  '_apply_signup_referral', 'require_email_reverification', 'is_admin'], array[]::text[]);
select app_grant_functions(array['search_active_partners', 'get_public_app_config'], array['anon', 'authenticated']);
select app_grant_functions(array['get_legal_status', 'record_legal_acceptance', 'get_study_sharing',
  'set_study_sharing', 'get_my_access', 'admin_update_commercial_config', 'admin_set_admin'], array['authenticated']);
select app_grant_functions(array['app_pre_request'], array['anon', 'authenticated']);
notify pgrst, 'reload config';
