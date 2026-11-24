-- Premium/Partners — Etapa 09 (parte 1): documentos legais versionados, faixa etária
-- declarada e compartilhamento de estatísticas seguro por padrão. ADITIVA e inerte.
-- Rollback: supabase/rollbacks/20261201000100_legal_versions_age_sharing.down.sql

-- ---------------------------------------------------------------------------
-- 1. Documentos legais: vigência, idiomas, exigência de novo aceite
-- ---------------------------------------------------------------------------
alter table legal_documents add column if not exists effective_at timestamptz;
alter table legal_documents add column if not exists urls jsonb not null default '{}'::jsonb; -- {"pt":..,"en":..,"es":..}
alter table legal_documents add column if not exists requires_reaccept boolean not null default true;
alter table legal_documents add column if not exists summary jsonb not null default '{}'::jsonb; -- resumo das mudanças por idioma
update legal_documents set effective_at = published_at where effective_at is null;

-- Aceite também registra o aparelho/plataforma (sem IP): prova de "quem, quando, onde".
alter table legal_acceptances add column if not exists platform text;

create or replace function get_legal_status() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce(jsonb_agg(jsonb_build_object('kind', d.kind, 'version', d.version, 'url', d.url,
      'urls', d.urls, 'effective_at', d.effective_at, 'requires_reaccept', d.requires_reaccept,
      'summary', d.summary,
      'accepted', exists (select 1 from legal_acceptances a where a.user_id = auth.uid()
                          and a.kind = d.kind and a.version = d.version))
    order by d.kind), '[]'::jsonb)
  from legal_documents d
  where d.is_current and auth.uid() is not null and coalesce(d.effective_at, now()) <= now();
$$;

create or replace function record_legal_acceptance(p_kind text, p_version text, p_platform text default null)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  if not exists (select 1 from legal_documents where kind = p_kind and version = p_version and is_current) then
    raise exception 'unknown or outdated document' using errcode = 'P0050';
  end if;
  insert into legal_acceptances (user_id, kind, version, source, platform)
  values (auth.uid(), p_kind, p_version, 'app', left(p_platform, 20))
  on conflict do nothing;
end $$;
-- A assinatura antiga (2 argumentos) some: PostgREST resolveria a chamada de forma ambígua.
drop function if exists record_legal_acceptance(text, text);

-- Histórico de aceites do próprio usuário (consulta no app).
create or replace function get_my_legal_history() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce(jsonb_agg(jsonb_build_object('kind', kind, 'version', version, 'accepted_at', accepted_at,
      'source', source) order by accepted_at desc), '[]'::jsonb)
  from legal_acceptances where user_id = auth.uid();
$$;

-- Ativação coordenada de uma nova versão (só service_role / banco): torna a versão
-- vigente SEM apagar aceites antigos. Uso: select publish_legal_version('terms','2026-12-01', ...).
create or replace function publish_legal_version(
  p_kind text, p_version text, p_url text, p_urls jsonb, p_effective timestamptz,
  p_requires_reaccept boolean default true, p_summary jsonb default '{}'::jsonb
) returns void language plpgsql security definer set search_path = public, pg_temp as $$
begin
  update legal_documents set is_current = false where kind = p_kind and is_current;
  insert into legal_documents (kind, version, url, urls, effective_at, requires_reaccept, summary, is_current)
  values (p_kind, p_version, p_url, coalesce(p_urls, '{}'::jsonb), p_effective, p_requires_reaccept,
          coalesce(p_summary, '{}'::jsonb), true)
  on conflict (kind, version) do update set url = excluded.url, urls = excluded.urls,
    effective_at = excluded.effective_at, requires_reaccept = excluded.requires_reaccept,
    summary = excluded.summary, is_current = true;
end $$;

-- ---------------------------------------------------------------------------
-- 2. Faixa etária declarada (minimização: só a faixa, nunca a data de nascimento)
-- ---------------------------------------------------------------------------
create table if not exists user_age_declarations (
  user_id uuid primary key references auth.users (id) on delete cascade,
  age_band text not null check (age_band in ('under_13', '13_15', '16_17', 'adult')),
  declared_at timestamptz not null default now(),
  source text not null default 'app'
);

create or replace function get_my_age_band() returns text
language sql stable security definer set search_path = public, pg_temp as $$
  select age_band from user_age_declarations where user_id = auth.uid();
$$;

create or replace function set_my_age_band(p_band text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if auth.uid() is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  if p_band not in ('under_13', '13_15', '16_17', 'adult') then
    raise exception 'invalid age band' using errcode = 'P0053';
  end if;
  insert into user_age_declarations (user_id, age_band) values (auth.uid(), p_band)
  on conflict (user_id) do update set age_band = excluded.age_band, declared_at = now();
  -- Declarar-se menor encerra qualquer compartilhamento ativo (histórico preservado).
  if p_band <> 'adult' and coalesce((select granted from study_sharing_consents
       where user_id = auth.uid() order by id desc limit 1), false) then
    insert into study_sharing_consents (user_id, granted, consent_version, declared_minor, guardian_consent, source)
    values (auth.uid(), false, 'auto-minor', true, false, 'age_declaration');
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- 3. Compartilhamento com professor: seguro por padrão
--    Individual/agregado só quando: último consentimento = concedido E a pessoa
--    declarou ser maior de 18 anos. Faixa desconhecida ou menor => NÃO compartilha.
--    (Consentimento parental verificável é decisão do dono: bloqueador de
--    lançamento para habilitar menores; ver docs/PREMIUM_PARTNERS.md §20.)
-- ---------------------------------------------------------------------------
create or replace function _student_shares(p_student uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce((select granted from study_sharing_consents
                   where user_id = p_student order by id desc limit 1), false)
     and coalesce((select age_band = 'adult' from user_age_declarations where user_id = p_student), false);
$$;

create or replace function set_study_sharing(
  p_granted boolean, p_version text, p_declared_minor boolean default false,
  p_guardian_consent boolean default false
) returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare v_band text;
begin
  if auth.uid() is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  select age_band into v_band from user_age_declarations where user_id = auth.uid();
  -- Os parâmetros de menor/responsável vindos do cliente NÃO valem: a faixa é a registrada no servidor.
  if p_granted and coalesce(v_band, 'unknown') <> 'adult' then
    raise exception 'sharing requires an adult declaration' using errcode = 'P0051';
  end if;
  insert into study_sharing_consents (user_id, granted, consent_version, declared_minor, guardian_consent)
  values (auth.uid(), p_granted, left(p_version, 40), coalesce(v_band, 'unknown') <> 'adult', false);
end $$;

-- ---------------------------------------------------------------------------
-- 4. Configuração pública: vigência e idiomas dos documentos
-- ---------------------------------------------------------------------------
create or replace function get_public_app_config() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'enforced', (enforcement_enabled and not emergency_disable),
    'trial_hours', trial_hours,
    'email_verification_required', email_verification_required,
    'has_active_partners', exists (select 1 from partners p where partner_active_at(p.id, now())),
    'legal', coalesce((select jsonb_agg(jsonb_build_object('kind', d.kind, 'version', d.version, 'url', d.url,
        'urls', d.urls, 'effective_at', d.effective_at) order by d.kind)
        from legal_documents d where d.is_current and coalesce(d.effective_at, now()) <= now()), '[]'::jsonb),
    'min_version', jsonb_build_object('android', min_version_android, 'ios', min_version_ios, 'web', min_version_web),
    'server_time', now())
  from commercial_config;
$$;

-- ---------------------------------------------------------------------------
-- 5. Gate: libera consulta/aceite de documentos, faixa etária e histórico (conta
--    sem Premium precisa aceitar termos e consultar documentos).
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
      '/rpc/get_my_access_context', '/rpc/get_my_payment_history',
      '/rpc/get_my_legal_history', '/rpc/get_my_age_band', '/rpc/set_my_age_band')
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

select app_lock_tables(array['user_age_declarations']);
select app_grant_functions(array['get_legal_status', 'record_legal_acceptance', 'get_my_legal_history',
  'get_my_age_band', 'set_my_age_band', 'set_study_sharing'], array['authenticated']);
select app_grant_functions(array['get_public_app_config'], array['anon', 'authenticated']);
select app_grant_functions(array['publish_legal_version'], array[]::text[]);
select app_grant_functions(array['app_pre_request'], array['anon', 'authenticated']);
notify pgrst, 'reload schema';
