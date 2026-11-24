-- Premium/Partners — 0200: programa de professores (AprovaAura Partners).
-- Aditiva. Depende de 0100. Sem turmas/simulados/chat: só vínculo e dados
-- comerciais. Acesso direto bloqueado; tudo por RPC security definer.
-- Rollback: supabase/rollbacks/20261124000200_partners.down.sql

create table if not exists partners (
  id uuid primary key default gen_random_uuid(),
  -- RESTRICT: apagar a conta de um parceiro exige encerrar a parceria antes
  -- (preserva o histórico financeiro que aponta para ele).
  user_id uuid not null unique references auth.users (id) on delete restrict,
  display_name text not null check (char_length(btrim(display_name)) between 2 and 80),
  referral_code text not null unique check (referral_code ~ '^[A-Z0-9]{4,12}$'),
  status text not null default 'active' check (status in ('pending', 'active', 'suspended', 'ended')),
  -- Percentual em pontos-base (5000 = 50%). Individual e configurável.
  commission_bps integer not null default 5000 check (commission_bps between 0 and 10000),
  pix_key_type text check (pix_key_type in ('cpf', 'cnpj', 'email', 'phone', 'random')),
  pix_key text check (pix_key is null or char_length(pix_key) between 5 and 140),
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint partners_pix_pair check ((pix_key is null) = (pix_key_type is null)),
  constraint partners_end_after_start check (ended_at is null or ended_at >= started_at)
);

-- Vínculo ATUAL aluno -> professor (um por aluno).
create table if not exists partner_links (
  student_id uuid primary key references auth.users (id) on delete cascade,
  partner_id uuid not null references partners (id) on delete restrict,
  source text not null check (source in ('signup', 'self_late', 'admin_change', 'admin_manual')),
  linked_at timestamptz not null default now()
);
create index if not exists partner_links_partner_idx on partner_links (partner_id);

-- Histórico (append-only). Sem FK em student_id: sobrevive à exclusão da conta.
create table if not exists partner_link_history (
  id bigint generated always as identity primary key,
  student_id uuid not null,
  from_partner_id uuid,
  to_partner_id uuid,
  action text not null check (action in ('linked', 'changed', 'removed')),
  source text not null,
  performed_by uuid,
  request_id uuid,
  occurred_at timestamptz not null default now()
);
create index if not exists partner_link_history_student_idx on partner_link_history (student_id, occurred_at);
drop trigger if exists partner_link_history_immutable on partner_link_history;
create trigger partner_link_history_immutable
  before update or delete on partner_link_history
  for each row execute function forbid_mutation();

create table if not exists partner_change_requests (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references auth.users (id) on delete cascade,
  from_partner_id uuid not null references partners (id),
  to_partner_id uuid not null references partners (id),
  reason text check (reason is null or char_length(reason) <= 500),
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  requested_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid,
  review_note text,
  constraint pcr_distinct check (from_partner_id <> to_partner_id)
);
create unique index if not exists partner_change_one_pending
  on partner_change_requests (student_id) where status = 'pending';

-- Histórico de alterações de parceiros -> admin_audit_log.
create or replace function partners_audit() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  new.updated_at := now();
  return new;
end $$;
drop trigger if exists partners_touch on partners;
create trigger partners_touch before update on partners
  for each row execute function partners_audit();

create or replace function partners_audit_log() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  perform audit_event('partner.' || lower(tg_op), 'partner', coalesce(new.id, old.id)::text,
    case when tg_op = 'INSERT' then null else to_jsonb(old) end,
    case when tg_op = 'DELETE' then null else to_jsonb(new) end, null);
  return coalesce(new, old);
end $$;
drop trigger if exists partners_audit_trg on partners;
create trigger partners_audit_trg after insert or update or delete on partners
  for each row execute function partners_audit_log();

-- Parceria ativa num instante (usado por Premium de professor e comissões).
create or replace function partner_active_at(p_partner uuid, p_at timestamptz default now())
returns boolean language sql stable security definer set search_path = public, pg_temp as $$
  select exists (select 1 from partners p where p.id = p_partner and p.status = 'active'
    and p.started_at <= p_at and (p.ended_at is null or p.ended_at > p_at));
$$;

create or replace function partner_user_active(p_user uuid) returns boolean
language sql stable security definer set search_path = public, pg_temp as $$
  select p_user is not null and exists (select 1 from partners p where p.user_id = p_user
    and partner_active_at(p.id, now()));
$$;

create or replace function _new_referral_code() returns text
language plpgsql volatile set search_path = public, pg_temp as $$
declare v_alpha constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; v_code text; v_try int := 0;
begin
  loop
    v_code := '';
    for i in 1..6 loop
      v_code := v_code || substr(v_alpha, 1 + floor(random() * length(v_alpha))::int, 1);
    end loop;
    exit when not exists (select 1 from partners where referral_code = v_code);
    v_try := v_try + 1;
    if v_try > 20 then raise exception 'could not generate referral code'; end if;
  end loop;
  return v_code;
end $$;

create or replace function admin_create_partner(
  p_user uuid, p_display_name text, p_referral_code text default null, p_commission_bps integer default 5000
) returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare v_id uuid;
begin
  perform require_admin();
  if not exists (select 1 from auth.users where id = p_user) then
    raise exception 'user not found' using errcode = 'P0013';
  end if;
  insert into partners (user_id, display_name, referral_code, commission_bps, created_by)
  values (p_user, p_display_name, upper(coalesce(nullif(btrim(p_referral_code), ''), _new_referral_code())),
          p_commission_bps, auth.uid())
  returning id into v_id;
  return v_id;
end $$;

-- Atualiza dados do parceiro. Mudar percentual/indicação só vale para
-- pagamentos FUTUROS (cada pagamento guarda o seu próprio snapshot).
create or replace function admin_update_partner(p_partner uuid, p_patch jsonb) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_status text;
begin
  perform require_admin();
  v_status := p_patch->>'status';
  update partners set
    display_name = coalesce(p_patch->>'display_name', display_name),
    referral_code = upper(coalesce(p_patch->>'referral_code', referral_code)),
    commission_bps = coalesce((p_patch->>'commission_bps')::integer, commission_bps),
    status = coalesce(v_status, status),
    ended_at = case
      when v_status = 'ended' then coalesce(ended_at, now())
      when v_status = 'active' then null
      else ended_at end,
    pix_key_type = case when p_patch ? 'pix_key_type' then nullif(p_patch->>'pix_key_type', '') else pix_key_type end,
    pix_key = case when p_patch ? 'pix_key' then nullif(p_patch->>'pix_key', '') else pix_key end
  where id = p_partner;
  if not found then raise exception 'partner not found' using errcode = 'P0013'; end if;
end $$;

-- Lista pública de indicação: só professores ATIVOS, sem dados sensíveis.
create or replace function list_active_partners()
returns table (partner_id uuid, display_name text)
language sql stable security definer set search_path = public, pg_temp as $$
  select p.id, p.display_name from partners p
  where partner_active_at(p.id, now()) order by lower(p.display_name);
$$;

create or replace function _record_link(p_student uuid, p_from uuid, p_to uuid, p_action text,
  p_source text, p_by uuid, p_request uuid) returns void
language sql security definer set search_path = public, pg_temp as $$
  insert into partner_link_history (student_id, from_partner_id, to_partner_id, action, source, performed_by, request_id)
  values (p_student, p_from, p_to, p_action, p_source, p_by, p_request);
$$;

-- Vínculo ÚNICO feito pelo próprio aluno. Depois do primeiro, só por
-- solicitação aprovada (request_partner_change).
create or replace function _link_once(p_student uuid, p_partner uuid, p_source text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if p_student is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  perform pg_advisory_xact_lock(hashtextextended('plink:' || p_student::text, 0));
  if exists (select 1 from partner_links where student_id = p_student)
     or exists (select 1 from partner_link_history where student_id = p_student) then
    raise exception 'partner already chosen; request a change' using errcode = 'P0020';
  end if;
  if not partner_active_at(p_partner, now()) then
    raise exception 'partner not available' using errcode = 'P0021';
  end if;
  if exists (select 1 from partners where id = p_partner and user_id = p_student) then
    raise exception 'cannot link to yourself' using errcode = 'P0022';
  end if;
  insert into partner_links (student_id, partner_id, source) values (p_student, p_partner, p_source);
  perform _record_link(p_student, null, p_partner, 'linked', p_source, p_student, null);
end $$;

create or replace function link_partner(p_partner_id uuid default null, p_code text default null)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare v_partner uuid := p_partner_id;
begin
  if v_partner is null and p_code is not null then
    select id into v_partner from partners where referral_code = upper(btrim(p_code));
  end if;
  if v_partner is null then raise exception 'partner not found' using errcode = 'P0021'; end if;
  perform _link_once(auth.uid(), v_partner, 'self_late');
end $$;

-- Indicação escolhida no cadastro (user_metadata.referral_partner_id). O
-- metadado é editável pelo usuário, mas isso só equivale a escolher UM
-- professor, o mesmo direito de link_partner; nenhuma outra coisa depende dele.
create or replace function _apply_signup_referral(p_user uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_pid uuid;
begin
  begin
    select (u.raw_user_meta_data->>'referral_partner_id')::uuid into v_pid
    from auth.users u where u.id = p_user;
  exception when others then
    return;
  end;
  if v_pid is null then return; end if;
  begin
    perform _link_once(p_user, v_pid, 'signup');
  exception when others then
    null; -- indicação inválida/já escolhida nunca bloqueia o acesso
  end;
end $$;

create or replace function get_my_partner() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'linked', l.student_id is not null,
    'partner_id', l.partner_id, 'display_name', p.display_name, 'linked_at', l.linked_at,
    'ever_chose', exists (select 1 from partner_link_history h where h.student_id = auth.uid()),
    'pending_request', (select to_jsonb(r) - 'student_id' - 'reviewed_by' from partner_change_requests r
                        where r.student_id = auth.uid() and r.status = 'pending'))
  from (select 1) s
  left join partner_links l on l.student_id = auth.uid()
  left join partners p on p.id = l.partner_id
  where auth.uid() is not null;
$$;

create or replace function request_partner_change(p_new_partner uuid, p_reason text default null)
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare v_uid uuid := auth.uid(); v_from uuid; v_id uuid;
begin
  if v_uid is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  select partner_id into v_from from partner_links where student_id = v_uid;
  if v_from is null then raise exception 'no current partner; use link_partner' using errcode = 'P0023'; end if;
  if v_from = p_new_partner then raise exception 'same partner' using errcode = 'P0024'; end if;
  if not partner_active_at(p_new_partner, now()) then
    raise exception 'partner not available' using errcode = 'P0021';
  end if;
  insert into partner_change_requests (student_id, from_partner_id, to_partner_id, reason)
  values (v_uid, v_from, p_new_partner, p_reason) returning id into v_id;
  return v_id;
exception when unique_violation then
  raise exception 'a request is already pending' using errcode = 'P0025';
end $$;

create or replace function admin_review_partner_change(p_request uuid, p_approve boolean, p_note text default null)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare r partner_change_requests%rowtype;
begin
  perform require_admin();
  select * into r from partner_change_requests where id = p_request for update;
  if not found or r.status <> 'pending' then
    raise exception 'request not pending' using errcode = 'P0026';
  end if;
  if p_approve then
    if not partner_active_at(r.to_partner_id, now()) then
      raise exception 'partner not available' using errcode = 'P0021';
    end if;
    update partner_links set partner_id = r.to_partner_id, source = 'admin_change', linked_at = now()
    where student_id = r.student_id;
    perform _record_link(r.student_id, r.from_partner_id, r.to_partner_id, 'changed',
                         'admin_change', auth.uid(), r.id);
  end if;
  update partner_change_requests set status = case when p_approve then 'approved' else 'rejected' end,
    reviewed_at = now(), reviewed_by = auth.uid(), review_note = p_note where id = p_request;
  perform audit_event(case when p_approve then 'partner.change.approve' else 'partner.change.reject' end,
    'partner_change_request', p_request::text, to_jsonb(r), null, p_note);
end $$;

-- Perfil do próprio parceiro (isolamento: só a própria linha).
create or replace function get_my_partner_profile() returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object('partner_id', p.id, 'display_name', p.display_name,
    'referral_code', p.referral_code, 'status', p.status, 'commission_bps', p.commission_bps,
    'pix_key_type', p.pix_key_type, 'pix_key', p.pix_key, 'started_at', p.started_at,
    'ended_at', p.ended_at, 'active', partner_active_at(p.id, now()))
  from partners p where p.user_id = auth.uid();
$$;

create or replace function partner_update_pix(p_type text, p_key text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if p_type not in ('cpf', 'cnpj', 'email', 'phone', 'random') or p_key is null then
    raise exception 'invalid pix key' using errcode = 'P0027';
  end if;
  update partners set pix_key_type = p_type, pix_key = btrim(p_key) where user_id = auth.uid();
  if not found then raise exception 'not a partner' using errcode = '42501'; end if;
end $$;

select app_lock_tables(array['partners', 'partner_links', 'partner_link_history', 'partner_change_requests']);
select app_grant_functions(array['partners_audit', 'partners_audit_log', 'partner_active_at',
  'partner_user_active', '_new_referral_code', '_record_link', '_link_once', '_apply_signup_referral'],
  array[]::text[]);
select app_grant_functions(array['list_active_partners'], array['anon', 'authenticated']);
select app_grant_functions(array['link_partner', 'get_my_partner', 'request_partner_change',
  'get_my_partner_profile', 'partner_update_pix', 'admin_create_partner', 'admin_update_partner',
  'admin_review_partner_change'], array['authenticated']);
