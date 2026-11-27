-- Quem é professor parceiro não pode ser indicado/vinculado a outro professor (decisão do dono, 27/11/2026).
-- Vale para todos os caminhos: escolha no cadastro, link_partner, troca por solicitação e vínculo manual do admin.
-- (Remover vínculo continua permitido.) Erro P0026. Idempotente; só substitui funções.
-- Rollback: reaplicar as definições anteriores em 20261124000200_partners.sql e 20261126000100_admin_portal.sql.

create or replace function _link_once(p_student uuid, p_partner uuid, p_source text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_last text;
begin
  if p_student is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  if exists (select 1 from partners where user_id = p_student) then
    raise exception 'partners cannot be referred by another partner' using errcode = 'P0026';
  end if;
  perform pg_advisory_xact_lock(hashtextextended('plink:' || p_student::text, 0));
  select action into v_last from partner_link_history where student_id = p_student order by id desc limit 1;
  if exists (select 1 from partner_links where student_id = p_student)
     or (v_last is not null and v_last <> 'removed') then
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

create or replace function request_partner_change(p_new_partner uuid, p_reason text default null)
returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare v_uid uuid := auth.uid(); v_from uuid; v_id uuid;
begin
  if v_uid is null then raise exception 'not authenticated' using errcode = '28000'; end if;
  if exists (select 1 from partners where user_id = v_uid) then
    raise exception 'partners cannot be referred by another partner' using errcode = 'P0026';
  end if;
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

create or replace function admin_set_student_partner(p_student uuid, p_partner uuid, p_note text default null)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare v_cur uuid;
begin
  perform require_admin();
  if p_note is not null and char_length(p_note) > 300 then
    raise exception 'note too long' using errcode = 'P0050';
  end if;
  if not exists (select 1 from auth.users where id = p_student) then
    raise exception 'user not found' using errcode = 'P0013';
  end if;
  perform pg_advisory_xact_lock(hashtextextended('plink:' || p_student::text, 0));
  select partner_id into v_cur from partner_links where student_id = p_student for update;
  if p_partner is null then
    if v_cur is null then raise exception 'student has no partner' using errcode = 'P0053'; end if;
    delete from partner_links where student_id = p_student;
    perform _record_link(p_student, v_cur, null, 'removed', 'admin_manual', auth.uid(), null);
  else
    if exists (select 1 from partners where user_id = p_student) then
      raise exception 'partners cannot be referred by another partner' using errcode = 'P0026';
    end if;
    if not partner_active_at(p_partner, now()) then
      raise exception 'partner not available' using errcode = 'P0021';
    end if;
    if exists (select 1 from partners where id = p_partner and user_id = p_student) then
      raise exception 'cannot link to yourself' using errcode = 'P0022';
    end if;
    if v_cur = p_partner then raise exception 'same partner' using errcode = 'P0024'; end if;
    if v_cur is null then
      insert into partner_links (student_id, partner_id, source) values (p_student, p_partner, 'admin_manual');
      perform _record_link(p_student, null, p_partner, 'linked', 'admin_manual', auth.uid(), null);
    else
      update partner_links set partner_id = p_partner, source = 'admin_change', linked_at = now()
      where student_id = p_student;
      perform _record_link(p_student, v_cur, p_partner, 'changed', 'admin_change', auth.uid(), null);
    end if;
  end if;
  -- Uma solicitação pendente fica obsoleta quando o administrador decide direto.
  update partner_change_requests set status = 'rejected', reviewed_at = now(), reviewed_by = auth.uid(),
    review_note = 'superseded by administrative change'
  where student_id = p_student and status = 'pending';
  perform audit_event('partner.link', 'user', p_student::text,
    jsonb_build_object('partner_id', v_cur), jsonb_build_object('partner_id', p_partner), p_note);
end $$;

notify pgrst, 'reload schema';
