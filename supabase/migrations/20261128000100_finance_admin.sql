-- Premium/Partners — Etapa 06: financeiro, comissões e repasses.
-- ADITIVA sobre 20261124000400_finance.sql (mesma modelagem; sem segundo
-- sistema). Valores SEMPRE em centavos (bigint); nenhum float em dinheiro.
-- Corrige: percentual/vínculo/status reconstruídos pelo HISTÓRICO no instante
-- do pagamento (eventos atrasados), reembolso parcial/múltiplo, repasse
-- idempotente e limitado ao saldo da competência, comissão só liberada após
-- conciliação das taxas, reversão com motivo obrigatório.
-- Rollback: supabase/rollbacks/20261128000100_finance_admin.down.sql

-- ---------------------------------------------------------------------------
-- 1. Pagamentos: conciliação, liquidação, reembolso parcial
-- ---------------------------------------------------------------------------
alter table payments
  add column if not exists reconciliation_status text not null default 'reconciled'
    check (reconciliation_status in ('reconciled', 'pending')),
  add column if not exists fee_source text not null default 'reported' check (fee_source in ('reported', 'estimated')),
  add column if not exists tax_source text not null default 'reported' check (tax_source in ('reported', 'estimated')),
  add column if not exists settlement_status text not null default 'pending'
    check (settlement_status in ('pending', 'settled')),
  add column if not exists settled_cents bigint check (settled_cents is null or settled_cents >= 0),
  add column if not exists settled_at timestamptz;
alter table payments drop constraint if exists payments_status_check;
alter table payments add constraint payments_status_check
  check (status in ('confirmed', 'partially_refunded', 'refunded', 'charged_back'));

-- Valores/snapshot imutáveis; única exceção: a PRIMEIRA conciliação (pending ->
-- reconciled) pode trocar taxas estimadas pelas reais. Status, estorno e
-- liquidação continuam livres (só por RPC interna).
create or replace function payments_guard() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin
  if tg_op = 'DELETE' then raise exception 'payments are append-only' using errcode = 'P0011'; end if;
  if (new.provider, new.external_id, new.user_id, new.plan, new.gross_cents, new.paid_at, new.competence,
      new.partner_id, new.commission_bps)
     is distinct from
     (old.provider, old.external_id, old.user_id, old.plan, old.gross_cents, old.paid_at, old.competence,
      old.partner_id, old.commission_bps) then
    raise exception 'payment identity is immutable' using errcode = 'P0011';
  end if;
  if (new.fee_cents, new.tax_cents, new.net_cents, new.commission_cents, new.lucksrei_cents)
     is distinct from
     (old.fee_cents, old.tax_cents, old.net_cents, old.commission_cents, old.lucksrei_cents)
     and not (old.reconciliation_status = 'pending' and new.reconciliation_status = 'reconciled') then
    raise exception 'payment amounts are immutable' using errcode = 'P0011';
  end if;
  if old.reconciliation_status = 'reconciled' and new.reconciliation_status = 'pending' then
    raise exception 'payment amounts are immutable' using errcode = 'P0011';
  end if;
  return new;
end $$;

-- Reembolsos/estornos (vários por pagamento; parciais). Mutável só por RPC.
create table if not exists payment_refunds (
  id uuid primary key default gen_random_uuid(),
  payment_id uuid not null references payments (id),
  external_ref text,                         -- id do reembolso no provedor (idempotência)
  kind text not null default 'refund' check (kind in ('refund', 'chargeback')),
  gross_refunded_cents bigint not null check (gross_refunded_cents > 0),
  fee_refunded_cents bigint not null default 0 check (fee_refunded_cents >= 0),
  tax_refunded_cents bigint not null default 0 check (tax_refunded_cents >= 0),
  commission_reversed_cents bigint not null default 0 check (commission_reversed_cents >= 0),
  ledgered boolean not null default false,   -- ajuste já lançado no razão
  refunded_at timestamptz not null,
  created_at timestamptz not null default now()
);
create unique index if not exists payment_refunds_ref_once on payment_refunds (payment_id, external_ref)
  where external_ref is not null;

-- Ajustes posteriores de taxa/imposto informados pelo provedor.
create table if not exists payment_adjustments (
  id uuid primary key default gen_random_uuid(),
  payment_id uuid not null references payments (id),
  external_ref text not null,
  kind text not null check (kind in ('fee', 'tax')),
  delta_cents bigint not null check (delta_cents <> 0),   -- >0 = custo maior
  commission_delta_cents bigint not null default 0,
  note text,
  created_at timestamptz not null default now(),
  unique (payment_id, external_ref)
);

-- Razão: novos tipos e vínculos de idempotência por reembolso/ajuste.
alter table commission_ledger drop constraint if exists commission_ledger_kind_check;
alter table commission_ledger add constraint commission_ledger_kind_check check (kind in
  ('commission', 'refund_adjustment', 'payout', 'payout_reversal', 'manual_adjustment', 'fee_adjustment'));
alter table commission_ledger add column if not exists refund_id uuid references payment_refunds (id);
alter table commission_ledger add column if not exists adjustment_id uuid references payment_adjustments (id);
drop index if exists ledger_refund_once;
create unique index if not exists ledger_refund_once on commission_ledger (refund_id) where kind = 'refund_adjustment';
create unique index if not exists ledger_fee_adj_once on commission_ledger (adjustment_id) where kind = 'fee_adjustment';

-- Repasses: referência do Pix, idempotência, reversão rastreável.
alter table payouts
  add column if not exists reference text check (reference is null or char_length(reference) <= 120),
  add column if not exists idempotency_key text unique,
  add column if not exists reversed_at timestamptz,
  add column if not exists reversed_by uuid,
  add column if not exists reverse_reason text;

-- ---------------------------------------------------------------------------
-- 2. Histórico de parceria (percentual/status) e vínculo no instante
-- ---------------------------------------------------------------------------
create table if not exists partner_commission_history (
  id bigint generated always as identity primary key,
  partner_id uuid not null,
  commission_bps integer not null,
  status text not null,
  effective_from timestamptz not null default now(),
  changed_by uuid
);
create index if not exists pch_idx on partner_commission_history (partner_id, effective_from);
drop trigger if exists pch_immutable on partner_commission_history;
create trigger pch_immutable before update or delete on partner_commission_history
  for each row execute function forbid_mutation();

create or replace function partners_commission_log() returns trigger
language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if tg_op = 'INSERT' or (new.commission_bps, new.status) is distinct from (old.commission_bps, old.status) then
    insert into partner_commission_history (partner_id, commission_bps, status, effective_from, changed_by)
    values (new.id, new.commission_bps, new.status,
            case when tg_op = 'INSERT' then new.started_at else now() end, auth.uid());
  end if;
  return new;
end $$;
drop trigger if exists partners_commission_log_trg on partners;
create trigger partners_commission_log_trg after insert or update on partners
  for each row execute function partners_commission_log();
insert into partner_commission_history (partner_id, commission_bps, status, effective_from)
select p.id, p.commission_bps, p.status, p.started_at from partners p
where not exists (select 1 from partner_commission_history h where h.partner_id = p.id);

-- Professor vinculado ao aluno em p_at (histórico; cai para o vínculo atual
-- só se o aluno nunca teve histórico).
create or replace function _student_partner_at(p_student uuid, p_at timestamptz) returns uuid
language sql stable security definer set search_path = public, pg_temp as $$
  select case when exists (select 1 from partner_link_history where student_id = p_student) then
    (select case when action = 'removed' then null else to_partner_id end
     from partner_link_history where student_id = p_student and occurred_at <= p_at
     order by occurred_at desc, id desc limit 1)
  else (select partner_id from partner_links where student_id = p_student and linked_at <= p_at) end;
$$;

-- Percentual vigente em p_at; null se a parceria não estava ativa então.
create or replace function _partner_bps_at(p_partner uuid, p_at timestamptz) returns integer
language sql stable security definer set search_path = public, pg_temp as $$
  select h.commission_bps from partner_commission_history h
  join partners p on p.id = h.partner_id
  where h.partner_id = p_partner and h.effective_from <= p_at and h.status = 'active'
    and p.started_at <= p_at and (p.ended_at is null or p.ended_at > p_at)
    and h.id = (select max(h2.id) from partner_commission_history h2
                where h2.partner_id = p_partner and h2.effective_from <= p_at);
$$;

-- ---------------------------------------------------------------------------
-- 3. Visão de valores efetivos (base + ajustes + reembolsos)
-- ---------------------------------------------------------------------------
create or replace view payments_eff as
select p.*,
  (p.fee_cents + coalesce(a.fee_adj, 0))::bigint as fee_eff,
  (p.tax_cents + coalesce(a.tax_adj, 0))::bigint as tax_eff,
  (p.net_cents - coalesce(a.fee_adj, 0) - coalesce(a.tax_adj, 0))::bigint as net_eff,
  (p.commission_cents + coalesce(a.com_adj, 0))::bigint as commission_eff,
  coalesce(r.gross_ref, 0)::bigint as refunded_gross, coalesce(r.fee_ref, 0)::bigint as refunded_fee,
  coalesce(r.tax_ref, 0)::bigint as refunded_tax, coalesce(r.com_ref, 0)::bigint as refunded_commission
from payments p
left join (select payment_id,
    sum(delta_cents) filter (where kind = 'fee') fee_adj, sum(delta_cents) filter (where kind = 'tax') tax_adj,
    sum(commission_delta_cents) com_adj from payment_adjustments group by payment_id) a on a.payment_id = p.id
left join (select payment_id, sum(gross_refunded_cents) gross_ref, sum(fee_refunded_cents) fee_ref,
    sum(tax_refunded_cents) tax_ref, sum(commission_reversed_cents) com_ref
    from payment_refunds group by payment_id) r on r.payment_id = p.id;

-- ---------------------------------------------------------------------------
-- 4. Contratos para os provedores (Etapa 07) — só service_role/definer
-- ---------------------------------------------------------------------------
drop function if exists record_confirmed_payment(text, text, uuid, text, bigint, bigint, bigint, timestamptz, jsonb);
create or replace function record_confirmed_payment(
  p_provider text, p_external_id text, p_user_id uuid, p_plan text,
  p_gross_cents bigint, p_fee_cents bigint, p_tax_cents bigint, p_paid_at timestamptz,
  p_raw jsonb default null, p_fee_source text default 'reported', p_tax_source text default 'reported'
) returns jsonb language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_id uuid; v_partner uuid; v_bps integer; v_net bigint; v_commission bigint := 0; v_recon text;
begin
  if p_fee_source not in ('reported', 'estimated') or p_tax_source not in ('reported', 'estimated')
     or p_gross_cents is null or p_gross_cents <= 0 or coalesce(p_fee_cents, 0) < 0 or coalesce(p_tax_cents, 0) < 0
     or coalesce(p_fee_cents, 0) + coalesce(p_tax_cents, 0) > p_gross_cents then
    raise exception 'invalid payment' using errcode = 'P0050';
  end if;
  perform pg_advisory_xact_lock(hashtextextended('pay:' || p_provider || ':' || p_external_id, 0));
  select id into v_id from payments where provider = p_provider and external_id = p_external_id;
  if v_id is not null then return jsonb_build_object('payment_id', v_id, 'created', false); end if;
  v_net := p_gross_cents - coalesce(p_fee_cents, 0) - coalesce(p_tax_cents, 0);
  v_partner := _student_partner_at(p_user_id, p_paid_at);
  v_bps := case when v_partner is null then null else _partner_bps_at(v_partner, p_paid_at) end;
  if v_bps is null then v_partner := null; else v_commission := floor(v_net * v_bps / 10000.0)::bigint; end if;
  v_recon := case when p_fee_source = 'reported' and p_tax_source = 'reported' then 'reconciled' else 'pending' end;
  insert into payments (provider, external_id, user_id, plan, gross_cents, fee_cents, tax_cents, net_cents,
    paid_at, competence, partner_id, commission_bps, commission_cents, lucksrei_cents, raw,
    reconciliation_status, fee_source, tax_source)
  values (p_provider, p_external_id, p_user_id, p_plan, p_gross_cents, coalesce(p_fee_cents, 0),
    coalesce(p_tax_cents, 0), v_net, p_paid_at, _competence(p_paid_at), v_partner, v_bps, v_commission,
    v_net - v_commission, p_raw, v_recon, p_fee_source, p_tax_source)
  returning id into v_id;
  -- Comissão sobre valores estimados NÃO entra no razão (não é liberável).
  if v_commission > 0 and v_recon = 'reconciled' then
    insert into commission_ledger (partner_id, kind, amount_cents, competence, payment_id)
    values (v_partner, 'commission', v_commission, _competence(p_paid_at), v_id);
  end if;
  return jsonb_build_object('payment_id', v_id, 'created', true, 'commission_cents', v_commission,
    'reconciliation_status', v_recon);
end $$;

-- Posta reembolsos ainda não lançados (pagamento recém-conciliado).
create or replace function _ledger_pending_refunds(p_payment uuid) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare pe payments_eff%rowtype; r payment_refunds%rowtype; v_cum bigint := 0; v_prev bigint := 0; v_target bigint; v_rev bigint;
begin
  select * into pe from payments_eff where id = p_payment;
  for r in select * from payment_refunds where payment_id = p_payment order by refunded_at, created_at loop
    v_cum := v_cum + r.gross_refunded_cents;
    v_target := case when v_cum >= pe.gross_cents then pe.commission_eff
                     else floor(pe.commission_eff * v_cum / pe.gross_cents::numeric)::bigint end;
    v_rev := v_target - v_prev; v_prev := v_target;
    if not r.ledgered then
      update payment_refunds set commission_reversed_cents = v_rev, ledgered = true where id = r.id;
      if v_rev > 0 then
        insert into commission_ledger (partner_id, kind, amount_cents, competence, payment_id, refund_id, note)
        values (pe.partner_id, 'refund_adjustment', -v_rev, _competence(r.refunded_at), p_payment, r.id, r.kind);
      end if;
    end if;
  end loop;
end $$;

-- Conciliação: troca estimativas pelos valores oficiais do provedor (uma vez).
create or replace function record_payment_reconciliation(
  p_provider text, p_external_id text, p_fee_cents bigint, p_tax_cents bigint,
  p_settled_cents bigint default null, p_settled_at timestamptz default null
) returns jsonb language plpgsql security definer set search_path = public, pg_temp as $$
declare p payments%rowtype; v_net bigint; v_com bigint := 0;
begin
  select * into p from payments where provider = p_provider and external_id = p_external_id for update;
  if not found then raise exception 'payment not found' using errcode = 'P0040'; end if;
  if p.reconciliation_status = 'reconciled' then return jsonb_build_object('payment_id', p.id, 'changed', false); end if;
  if p_fee_cents < 0 or p_tax_cents < 0 or p_fee_cents + p_tax_cents > p.gross_cents then
    raise exception 'invalid payment' using errcode = 'P0050';
  end if;
  v_net := p.gross_cents - p_fee_cents - p_tax_cents;
  if p.partner_id is not null then v_com := floor(v_net * p.commission_bps / 10000.0)::bigint; end if;
  update payments set fee_cents = p_fee_cents, tax_cents = p_tax_cents, net_cents = v_net,
    commission_cents = v_com, lucksrei_cents = v_net - v_com, reconciliation_status = 'reconciled',
    fee_source = 'reported', tax_source = 'reported',
    settlement_status = case when p_settled_cents is null then settlement_status else 'settled' end,
    settled_cents = coalesce(p_settled_cents, settled_cents), settled_at = coalesce(p_settled_at, settled_at)
  where id = p.id;
  if v_com > 0 then
    insert into commission_ledger (partner_id, kind, amount_cents, competence, payment_id)
    values (p.partner_id, 'commission', v_com, p.competence, p.id);
  end if;
  perform _ledger_pending_refunds(p.id);
  return jsonb_build_object('payment_id', p.id, 'changed', true, 'commission_cents', v_com);
end $$;

-- Liquidação: valor efetivamente recebido do provedor (idempotente).
create or replace function record_payment_settlement(
  p_provider text, p_external_id text, p_settled_cents bigint, p_settled_at timestamptz
) returns jsonb language plpgsql security definer set search_path = public, pg_temp as $$
declare p payments%rowtype;
begin
  if p_settled_cents is null or p_settled_cents < 0 then raise exception 'invalid payment' using errcode = 'P0050'; end if;
  select * into p from payments where provider = p_provider and external_id = p_external_id for update;
  if not found then raise exception 'payment not found' using errcode = 'P0040'; end if;
  if p.settlement_status = 'settled' then return jsonb_build_object('payment_id', p.id, 'changed', false); end if;
  update payments set settlement_status = 'settled', settled_cents = p_settled_cents, settled_at = p_settled_at where id = p.id;
  return jsonb_build_object('payment_id', p.id, 'changed', true);
end $$;

-- Ajuste posterior de taxa/imposto (delta de custo, idempotente por external_ref).
create or replace function record_payment_adjustment(
  p_provider text, p_external_id text, p_kind text, p_delta_cents bigint, p_external_ref text, p_note text default null
) returns jsonb language plpgsql security definer set search_path = public, pg_temp as $$
declare pe payments_eff%rowtype; v_id uuid; v_new_net bigint; v_new_com bigint; v_delta bigint := 0;
begin
  if p_kind not in ('fee', 'tax') or p_delta_cents is null or p_delta_cents = 0 or coalesce(p_external_ref, '') = ''
     then raise exception 'invalid payment' using errcode = 'P0050'; end if;
  select * into pe from payments_eff where provider = p_provider and external_id = p_external_id;
  if not found then raise exception 'payment not found' using errcode = 'P0040'; end if;
  perform pg_advisory_xact_lock(hashtextextended('pay:' || p_provider || ':' || p_external_id, 0));
  if exists (select 1 from payment_adjustments where payment_id = pe.id and external_ref = p_external_ref) then
    return jsonb_build_object('payment_id', pe.id, 'changed', false);
  end if;
  v_new_net := greatest(pe.net_eff - p_delta_cents, 0);
  if pe.partner_id is not null and pe.reconciliation_status = 'reconciled' then
    v_new_com := floor(v_new_net * pe.commission_bps / 10000.0)::bigint;
    v_delta := v_new_com - pe.commission_eff;
  end if;
  insert into payment_adjustments (payment_id, external_ref, kind, delta_cents, commission_delta_cents, note)
  values (pe.id, p_external_ref, p_kind, p_delta_cents, v_delta, p_note) returning id into v_id;
  if v_delta <> 0 then
    insert into commission_ledger (partner_id, kind, amount_cents, competence, payment_id, adjustment_id, note)
    values (pe.partner_id, 'fee_adjustment', v_delta, _competence(now()), pe.id, v_id, p_note);
  end if;
  return jsonb_build_object('payment_id', pe.id, 'changed', true, 'commission_delta_cents', v_delta);
end $$;

-- Reembolso/estorno (total, parcial, vários). Idempotente por external_ref;
-- sem referência, só o reembolso integral restante é idempotente (status).
-- Evento fora de ordem (pagamento ainda não registrado) => P0040 (reenfileirar).
drop function if exists record_payment_refund(text, text, timestamptz, boolean);
create or replace function record_payment_refund(
  p_provider text, p_external_id text, p_refunded_at timestamptz, p_charged_back boolean default false,
  p_refund_cents bigint default null, p_fee_refund_cents bigint default 0, p_tax_refund_cents bigint default 0,
  p_external_ref text default null
) returns jsonb language plpgsql security definer set search_path = public, pg_temp as $$
declare
  pe payments_eff%rowtype; v_rid uuid; v_amount bigint; v_cum bigint; v_target bigint; v_rev bigint;
  v_status text; v_led boolean;
begin
  select * into pe from payments_eff where provider = p_provider and external_id = p_external_id;
  if not found then raise exception 'payment not found' using errcode = 'P0040'; end if;
  perform pg_advisory_xact_lock(hashtextextended('pay:' || p_provider || ':' || p_external_id, 0));
  select * into pe from payments_eff where id = pe.id;
  if p_external_ref is not null and exists (select 1 from payment_refunds where payment_id = pe.id and external_ref = p_external_ref) then
    return jsonb_build_object('payment_id', pe.id, 'changed', false);
  end if;
  v_amount := coalesce(p_refund_cents, pe.gross_cents - pe.refunded_gross);
  if v_amount <= 0 then return jsonb_build_object('payment_id', pe.id, 'changed', false); end if;
  if v_amount > pe.gross_cents - pe.refunded_gross or coalesce(p_fee_refund_cents, 0) < 0 or coalesce(p_tax_refund_cents, 0) < 0 then
    raise exception 'invalid refund' using errcode = 'P0043';
  end if;
  v_cum := pe.refunded_gross + v_amount;
  v_led := pe.reconciliation_status = 'reconciled';
  v_target := case when v_cum >= pe.gross_cents then pe.commission_eff
                   else floor(pe.commission_eff * v_cum / pe.gross_cents::numeric)::bigint end;
  v_rev := case when v_led then v_target - pe.refunded_commission else 0 end;
  insert into payment_refunds (payment_id, external_ref, kind, gross_refunded_cents, fee_refunded_cents,
    tax_refunded_cents, commission_reversed_cents, ledgered, refunded_at)
  values (pe.id, p_external_ref, case when p_charged_back then 'chargeback' else 'refund' end, v_amount,
    coalesce(p_fee_refund_cents, 0), coalesce(p_tax_refund_cents, 0), v_rev, v_led, p_refunded_at)
  returning id into v_rid;
  if v_rev > 0 then
    insert into commission_ledger (partner_id, kind, amount_cents, competence, payment_id, refund_id, note)
    values (pe.partner_id, 'refund_adjustment', -v_rev, _competence(p_refunded_at), pe.id, v_rid,
            case when p_charged_back then 'chargeback' else 'refund' end);
  end if;
  v_status := case when v_cum >= pe.gross_cents then (case when p_charged_back then 'charged_back' else 'refunded' end)
                   else 'partially_refunded' end;
  update payments set status = v_status, refunded_at = p_refunded_at where id = pe.id;
  return jsonb_build_object('payment_id', pe.id, 'changed', true, 'commission_reversed_cents', v_rev);
end $$;

-- ---------------------------------------------------------------------------
-- 5. Repasses (Pix manual): idempotente, limitado ao saldo da competência
-- ---------------------------------------------------------------------------
create or replace function _mask_pix(p_key text) returns text
language sql immutable set search_path = public, pg_temp as $$
  select case when p_key is null then null else repeat('•', 6) || right(p_key, least(4, char_length(p_key))) end;
$$;

-- Saldo disponível até a competência (inclui competências anteriores).
create or replace function _partner_available(p_partner uuid, p_competence date) returns bigint
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce(sum(amount_cents), 0)::bigint from commission_ledger
  where partner_id = p_partner and competence <= date_trunc('month', p_competence)::date;
$$;

drop function if exists admin_register_payout(uuid, bigint, date, timestamptz, text);
create or replace function admin_register_payout(
  p_partner uuid, p_amount_cents bigint, p_competence date, p_paid_at timestamptz default now(),
  p_note text default null, p_reference text default null, p_idempotency_key text default null
) returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare v_id uuid; v_pix_type text; v_pix text; v_avail bigint; v_comp date;
begin
  perform require_admin();
  if p_competence is null or p_amount_cents is null or p_amount_cents <= 0
     or char_length(coalesce(p_note, '')) > 500 or char_length(coalesce(p_reference, '')) > 120
     or p_paid_at is null or p_paid_at > now() + interval '1 day' then
    raise exception 'invalid payout' using errcode = 'P0050';
  end if;
  v_comp := date_trunc('month', p_competence)::date;
  perform pg_advisory_xact_lock(hashtextextended('payout:' || p_partner::text, 0));
  if p_idempotency_key is not null then
    select id into v_id from payouts where idempotency_key = p_idempotency_key and partner_id = p_partner;
    if v_id is not null then return v_id; end if;
  end if;
  select pix_key_type, pix_key into v_pix_type, v_pix from partners where id = p_partner;
  if not found then raise exception 'partner not found' using errcode = 'P0013'; end if;
  v_avail := _partner_available(p_partner, v_comp);
  if p_amount_cents > v_avail then
    raise exception 'amount exceeds available balance (%)', v_avail using errcode = 'P0041';
  end if;
  insert into payouts (partner_id, competence, amount_cents, pix_key_type, pix_key, paid_at, note,
    registered_by, reference, idempotency_key)
  values (p_partner, v_comp, p_amount_cents, v_pix_type, v_pix, p_paid_at, p_note, auth.uid(),
    nullif(btrim(p_reference), ''), p_idempotency_key) returning id into v_id;
  insert into commission_ledger (partner_id, kind, amount_cents, competence, payout_id, note, created_by)
  values (p_partner, 'payout', -p_amount_cents, v_comp, v_id, p_note, auth.uid());
  perform audit_event('payout.register', 'payout', v_id::text, null,
    jsonb_build_object('partner_id', p_partner, 'amount_cents', p_amount_cents, 'competence', v_comp,
      'reference', p_reference), p_note);
  return v_id;
end $$;

drop function if exists admin_reverse_payout(uuid, text);
create or replace function admin_reverse_payout(p_payout uuid, p_reason text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare o payouts%rowtype;
begin
  perform require_admin();
  if char_length(btrim(coalesce(p_reason, ''))) < 5 or char_length(p_reason) > 500 then
    raise exception 'reason required' using errcode = 'P0050';
  end if;
  select * into o from payouts where id = p_payout for update;
  if not found or o.status <> 'paid' then raise exception 'payout not reversible' using errcode = 'P0042'; end if;
  update payouts set status = 'reversed', reversed_at = now(), reversed_by = auth.uid(), reverse_reason = btrim(p_reason)
  where id = p_payout;
  insert into commission_ledger (partner_id, kind, amount_cents, competence, payout_id, note, created_by)
  values (o.partner_id, 'payout_reversal', o.amount_cents, o.competence, p_payout, btrim(p_reason), auth.uid());
  perform audit_event('payout.reverse', 'payout', p_payout::text, jsonb_build_object('amount_cents', o.amount_cents,
    'partner_id', o.partner_id, 'competence', o.competence), null, btrim(p_reason));
end $$;

-- Chave Pix completa só por ação explícita e auditada.
create or replace function admin_get_partner_pix(p_partner uuid) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare p partners%rowtype;
begin
  perform require_admin();
  select * into p from partners where id = p_partner;
  if not found then raise exception 'partner not found' using errcode = 'P0013'; end if;
  perform audit_event('partner.pix_view', 'partner', p_partner::text, null, null, null);
  return jsonb_build_object('type', p.pix_key_type, 'key', p.pix_key);
end $$;

-- ---------------------------------------------------------------------------
-- 6. Despesas operacionais
-- ---------------------------------------------------------------------------
create table if not exists expense_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique check (char_length(btrim(name)) between 2 and 60),
  builtin boolean not null default false,
  active boolean not null default true,
  created_at timestamptz not null default now()
);
insert into expense_categories (name, builtin) values ('Supabase', true), ('Cloudflare', true),
  ('Inteligência artificial', true), ('Apple Developer', true), ('Google Play', true),
  ('Serviços de e-mail', true), ('Marketing', true), ('Outros', true) on conflict (name) do nothing;

create table if not exists expenses (
  id uuid primary key default gen_random_uuid(),
  description text not null check (char_length(btrim(description)) between 2 and 160),
  category_id uuid not null references expense_categories (id),
  amount_cents bigint not null check (amount_cents > 0),
  expense_date date not null,
  competence date not null,
  note text check (note is null or char_length(note) <= 500),
  voided_at timestamptz,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists expenses_date_idx on expenses (expense_date);
create table if not exists expense_history (
  id bigint generated always as identity primary key,
  expense_id uuid not null,
  action text not null,
  snapshot jsonb not null,
  changed_by uuid,
  note text,
  at timestamptz not null default now()
);
drop trigger if exists expense_history_immutable on expense_history;
create trigger expense_history_immutable before update or delete on expense_history
  for each row execute function forbid_mutation();

create or replace function _expense_valid(p_desc text, p_amount bigint, p_date date, p_note text) returns void
language plpgsql immutable set search_path = public, pg_temp as $$
begin
  if char_length(btrim(coalesce(p_desc, ''))) not between 2 and 160 or p_amount is null or p_amount <= 0
     or p_amount > 100000000000 or p_date is null or p_date > current_date + 1 or p_date < date '2020-01-01'
     or char_length(coalesce(p_note, '')) > 500 then
    raise exception 'invalid expense' using errcode = 'P0050';
  end if;
end $$;

create or replace function admin_create_expense(p_description text, p_category uuid, p_amount_cents bigint,
  p_date date, p_note text default null, p_competence date default null) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_id uuid; e expenses%rowtype;
begin
  perform require_admin();
  perform _expense_valid(p_description, p_amount_cents, p_date, p_note);
  if not exists (select 1 from expense_categories where id = p_category and active) then
    raise exception 'invalid expense' using errcode = 'P0050';
  end if;
  insert into expenses (description, category_id, amount_cents, expense_date, competence, note, created_by)
  values (btrim(p_description), p_category, p_amount_cents, p_date,
    date_trunc('month', coalesce(p_competence, p_date))::date, p_note, auth.uid()) returning * into e;
  insert into expense_history (expense_id, action, snapshot, changed_by) values (e.id, 'create', to_jsonb(e), auth.uid());
  perform audit_event('expense.create', 'expense', e.id::text, null, to_jsonb(e), null);
  return e.id;
end $$;

create or replace function admin_update_expense(p_id uuid, p_description text, p_category uuid, p_amount_cents bigint,
  p_date date, p_note text default null, p_competence date default null) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare o expenses%rowtype; e expenses%rowtype;
begin
  perform require_admin();
  perform _expense_valid(p_description, p_amount_cents, p_date, p_note);
  select * into o from expenses where id = p_id for update;
  if not found or o.voided_at is not null then raise exception 'expense not found' using errcode = 'P0013'; end if;
  if not exists (select 1 from expense_categories where id = p_category) then
    raise exception 'invalid expense' using errcode = 'P0050';
  end if;
  update expenses set description = btrim(p_description), category_id = p_category, amount_cents = p_amount_cents,
    expense_date = p_date, competence = date_trunc('month', coalesce(p_competence, p_date))::date,
    note = p_note, updated_at = now() where id = p_id returning * into e;
  insert into expense_history (expense_id, action, snapshot, changed_by) values (p_id, 'update', to_jsonb(o), auth.uid());
  perform audit_event('expense.update', 'expense', p_id::text, to_jsonb(o), to_jsonb(e), null);
end $$;

create or replace function admin_void_expense(p_id uuid, p_reason text) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare o expenses%rowtype;
begin
  perform require_admin();
  if char_length(btrim(coalesce(p_reason, ''))) < 3 then raise exception 'reason required' using errcode = 'P0050'; end if;
  select * into o from expenses where id = p_id for update;
  if not found or o.voided_at is not null then raise exception 'expense not found' using errcode = 'P0013'; end if;
  update expenses set voided_at = now(), updated_at = now() where id = p_id;
  insert into expense_history (expense_id, action, snapshot, changed_by, note)
  values (p_id, 'void', to_jsonb(o), auth.uid(), btrim(p_reason));
  perform audit_event('expense.void', 'expense', p_id::text, to_jsonb(o), null, btrim(p_reason));
end $$;

create or replace function admin_add_expense_category(p_name text) returns uuid
language plpgsql security definer set search_path = public, pg_temp as $$
declare v_id uuid;
begin
  perform require_admin();
  if char_length(btrim(coalesce(p_name, ''))) not between 2 and 60 then raise exception 'invalid expense' using errcode = 'P0050'; end if;
  insert into expense_categories (name) values (btrim(p_name))
  on conflict (name) do update set active = true returning id into v_id;
  perform audit_event('expense.category', 'expense_category', v_id::text, null, jsonb_build_object('name', btrim(p_name)), null);
  return v_id;
end $$;

create or replace function admin_list_expenses(p_from date default null, p_to date default null, p_category uuid default null,
  p_limit integer default 25, p_offset integer default 0) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_pg integer[] := _page(p_limit, p_offset);
begin
  perform require_admin();
  return jsonb_build_object(
    'categories', (select coalesce(jsonb_agg(jsonb_build_object('id', id, 'name', name, 'builtin', builtin) order by builtin desc, name), '[]'::jsonb)
                   from expense_categories where active),
    'total', (select count(*) from expenses e where e.voided_at is null and (p_from is null or e.expense_date >= p_from)
              and (p_to is null or e.expense_date <= p_to) and (p_category is null or e.category_id = p_category)),
    'sum_cents', (select coalesce(sum(amount_cents), 0) from expenses e where e.voided_at is null
              and (p_from is null or e.expense_date >= p_from) and (p_to is null or e.expense_date <= p_to)
              and (p_category is null or e.category_id = p_category)),
    'rows', coalesce((select jsonb_agg(to_jsonb(x) order by x.expense_date desc, x.created_at desc) from (
        select e.id, e.description, e.category_id, c.name as category, e.amount_cents, e.expense_date, e.competence, e.note, e.created_at
        from expenses e join expense_categories c on c.id = e.category_id
        where e.voided_at is null and (p_from is null or e.expense_date >= p_from) and (p_to is null or e.expense_date <= p_to)
          and (p_category is null or e.category_id = p_category)
        order by e.expense_date desc, e.created_at desc limit v_pg[1] offset v_pg[2]) x), '[]'::jsonb));
end $$;

-- ---------------------------------------------------------------------------
-- 7. Painel financeiro do administrador
-- ---------------------------------------------------------------------------
create or replace function admin_finance_dashboard(p_from date, p_to date) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare
  v_from timestamptz; v_to timestamptz; v_tot jsonb; v_prov jsonb; v_plan jsonb; v_series jsonb; v_exp jsonb;
begin
  perform require_admin();
  if p_from is null or p_to is null or p_from > p_to or p_to - p_from > 1100 then
    raise exception 'invalid period' using errcode = 'P0060';
  end if;
  v_from := _tz_day_start(p_from); v_to := _tz_day_start(p_to + 1);

  with pay as (select * from payments_eff where paid_at >= v_from and paid_at < v_to),
  ref as (select r.* from payment_refunds r where r.refunded_at >= v_from and r.refunded_at < v_to),
  pa as (select
      coalesce(sum(gross_cents), 0) gross, coalesce(sum(fee_eff), 0) fee, coalesce(sum(tax_eff), 0) tax,
      coalesce(sum(commission_eff), 0) com, count(*) n,
      count(*) filter (where reconciliation_status = 'pending') n_pending,
      coalesce(sum(net_eff) filter (where reconciliation_status = 'pending'), 0) pending_net,
      coalesce(sum(commission_eff) filter (where reconciliation_status = 'pending'), 0) pending_com
    from pay),
  re as (select coalesce(sum(gross_refunded_cents), 0) gross, coalesce(sum(fee_refunded_cents), 0) fee,
      coalesce(sum(tax_refunded_cents), 0) tax, coalesce(sum(commission_reversed_cents), 0) com, count(*) n from ref),
  ex as (select coalesce(sum(amount_cents), 0) total from expenses where voided_at is null
         and expense_date >= p_from and expense_date <= p_to),
  led as (select
      coalesce(sum(amount_cents), 0) balance_all,
      coalesce(sum(-amount_cents) filter (where kind = 'payout' and created_at >= v_from and created_at < v_to), 0)
        - coalesce(sum(amount_cents) filter (where kind = 'payout_reversal' and created_at >= v_from and created_at < v_to), 0) paid_period
    from commission_ledger),
  pend as (select coalesce(sum(commission_cents), 0) c from payments where reconciliation_status = 'pending'
           and status in ('confirmed', 'partially_refunded')),
  st as (select coalesce(sum(settled_cents) filter (where settled_at >= v_from and settled_at < v_to), 0) received,
      coalesce(sum(net_eff) filter (where settlement_status = 'pending' and status in ('confirmed', 'partially_refunded')), 0) awaiting,
      count(*) filter (where settlement_status = 'pending' and status in ('confirmed', 'partially_refunded')) n_awaiting
      from payments_eff)
  select jsonb_build_object(
    'gross_cents', pa.gross, 'payments_count', pa.n,
    'refunds_cents', re.gross, 'refunds_count', re.n,
    'fees_cents', pa.fee - re.fee, 'taxes_cents', pa.tax - re.tax,
    'net_cents', pa.gross - re.gross - (pa.fee - re.fee) - (pa.tax - re.tax),
    'commissions_generated_cents', pa.com, 'commissions_reversed_cents', re.com,
    'commissions_net_cents', pa.com - re.com,
    'commissions_pending_payout_cents', led.balance_all,
    'commissions_paid_cents', led.paid_period,
    'pending_reconciliation_commission_cents', pend.c,
    'lucksrei_cents', (pa.gross - re.gross - (pa.fee - re.fee) - (pa.tax - re.tax)) - (pa.com - re.com),
    'expenses_cents', ex.total,
    'result_cents', (pa.gross - re.gross - (pa.fee - re.fee) - (pa.tax - re.tax)) - (pa.com - re.com) - ex.total,
    'estimated_payments', pa.n_pending, 'estimated_net_cents', pa.pending_net,
    'received_from_providers_cents', st.received, 'awaiting_settlement_cents', st.awaiting,
    'awaiting_settlement_count', st.n_awaiting,
    'cash_flow_cents', st.received - led.paid_period - ex.total)
  into v_tot from pa, re, ex, led, pend, st;

  select coalesce(jsonb_agg(jsonb_build_object('provider', pv.provider, 'gross_cents', coalesce(g.gross, 0),
      'fees_cents', coalesce(g.fee, 0) - coalesce(r.fee, 0), 'taxes_cents', coalesce(g.tax, 0) - coalesce(r.tax, 0),
      'refunds_cents', coalesce(r.gross, 0), 'payments', coalesce(g.n, 0)) order by pv.provider), '[]'::jsonb)
  into v_prov
  from (values ('apple'), ('google'), ('mercadopago')) pv(provider)
  left join (select provider, sum(gross_cents) gross, sum(fee_eff) fee, sum(tax_eff) tax, count(*) n
             from payments_eff where paid_at >= v_from and paid_at < v_to group by provider) g on g.provider = pv.provider
  left join (select p.provider, sum(r.gross_refunded_cents) gross, sum(r.fee_refunded_cents) fee, sum(r.tax_refunded_cents) tax
             from payment_refunds r join payments p on p.id = r.payment_id
             where r.refunded_at >= v_from and r.refunded_at < v_to group by p.provider) r on r.provider = pv.provider;

  select coalesce(jsonb_agg(jsonb_build_object('plan', t.plan, 'gross_cents', t.gross, 'payments', t.n, 'origin', t.origin)), '[]'::jsonb)
  into v_plan
  from (select plan, case when partner_id is null then 'none' else 'partner' end origin,
          sum(gross_cents) gross, count(*) n
        from payments where paid_at >= v_from and paid_at < v_to group by 1, 2) t;

  select coalesce(jsonb_agg(jsonb_build_object('date', g.d, 'gross_cents', coalesce(a.gross, 0) , 'net_cents', coalesce(a.net, 0),
      'commissions_cents', coalesce(a.com, 0), 'expenses_cents', coalesce(e.amt, 0),
      'result_cents', coalesce(a.net, 0) - coalesce(a.com, 0) - coalesce(e.amt, 0)) order by g.d), '[]'::jsonb)
  into v_series
  from (select d::date from generate_series(p_from::timestamp, p_to::timestamp, interval '1 day') d) g
  left join (
    select d, sum(gross) gross, sum(net) net, sum(com) com from (
      select (paid_at at time zone 'America/Sao_Paulo')::date d, gross_cents gross, net_eff net, commission_eff com
        from payments_eff where paid_at >= v_from and paid_at < v_to
      union all
      select (r.refunded_at at time zone 'America/Sao_Paulo')::date, -r.gross_refunded_cents,
        -(r.gross_refunded_cents - r.fee_refunded_cents - r.tax_refunded_cents), -r.commission_reversed_cents
        from payment_refunds r where r.refunded_at >= v_from and r.refunded_at < v_to) u group by d) a on a.d = g.d
  left join (select expense_date d, sum(amount_cents) amt from expenses where voided_at is null
             and expense_date between p_from and p_to group by 1) e on e.d = g.d;

  select coalesce(jsonb_agg(jsonb_build_object('category', c.name, 'amount_cents', s.amt) order by s.amt desc), '[]'::jsonb)
  into v_exp from (select category_id, sum(amount_cents) amt from expenses where voided_at is null
        and expense_date between p_from and p_to group by 1) s join expense_categories c on c.id = s.category_id;

  return jsonb_build_object('totals', v_tot, 'by_provider', v_prov, 'by_plan', v_plan, 'series', v_series,
    'expenses_by_category', v_exp);
end $$;

-- ---------------------------------------------------------------------------
-- 8. Pagamentos
-- ---------------------------------------------------------------------------
create or replace function _payment_json(pe payments_eff, p_name text, p_email text, p_partner text) returns jsonb
language sql immutable set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'id', pe.id, 'provider', pe.provider, 'external_id', pe.external_id, 'plan', pe.plan, 'paid_at', pe.paid_at,
    'user_id', pe.user_id, 'user_name', p_name, 'user_email', p_email,
    'gross_cents', pe.gross_cents, 'fee_cents', pe.fee_eff, 'tax_cents', pe.tax_eff, 'net_cents', pe.net_eff,
    'partner_id', pe.partner_id, 'partner_name', p_partner, 'commission_bps', pe.commission_bps,
    'commission_cents', pe.commission_eff, 'lucksrei_cents', pe.net_eff - pe.commission_eff,
    'status', pe.status, 'reconciliation_status', pe.reconciliation_status, 'fee_source', pe.fee_source,
    'tax_source', pe.tax_source, 'settlement_status', pe.settlement_status, 'settled_cents', pe.settled_cents,
    'settled_at', pe.settled_at, 'refunded_cents', pe.refunded_gross, 'adjustments_cents',
    (pe.fee_eff - pe.fee_cents) + (pe.tax_eff - pe.tax_cents), 'competence', pe.competence);
$$;

create or replace function admin_list_payments(
  p_search text default null, p_provider text default null, p_status text default null, p_plan text default null,
  p_partner text default null, p_recon text default null, p_from date default null, p_to date default null,
  p_sort text default 'paid_at', p_dir text default 'desc', p_limit integer default 25, p_offset integer default 0
) returns jsonb language plpgsql stable security definer set search_path = public, pg_temp as $$
declare
  v_pg integer[] := _page(p_limit, p_offset); v_dir text := case when lower(p_dir) = 'asc' then 'asc' else 'desc' end;
  v_order text; v_res jsonb; v_q text := case when p_search is null or btrim(p_search) = '' then null else _like_escape(lower(btrim(p_search))) end;
begin
  perform require_admin();
  if (p_provider is not null and p_provider not in ('apple', 'google', 'mercadopago'))
     or (p_status is not null and p_status not in ('confirmed', 'partially_refunded', 'refunded', 'charged_back'))
     or (p_plan is not null and p_plan not in ('monthly', 'annual'))
     or (p_recon is not null and p_recon not in ('pending', 'reconciled'))
     or (p_partner is not null and p_partner <> 'none' and p_partner !~ '^[0-9a-f-]{36}$') then
    raise exception 'invalid filter' using errcode = 'P0060';
  end if;
  v_order := case p_sort when 'gross' then 'pe.gross_cents' when 'net' then 'pe.net_eff'
    when 'commission' then 'pe.commission_eff' else 'pe.paid_at' end;
  execute format($q$
    with f as (
      select pe, pr.name, au.email::text, pa.display_name, count(*) over () total
      from payments_eff pe
      left join profiles pr on pr.id = pe.user_id left join auth.users au on au.id = pe.user_id
      left join partners pa on pa.id = pe.partner_id
      where ($1::text is null or lower(pe.external_id) like '%%' || $1 || '%%' escape '\'
             or lower(coalesce(pr.name, '')) like '%%' || $1 || '%%' escape '\'
             or lower(coalesce(au.email, '')) like '%%' || $1 || '%%' escape '\')
        and ($2::text is null or pe.provider = $2) and ($3::text is null or pe.status = $3)
        and ($4::text is null or pe.plan = $4)
        and ($5::text is null or ($5 = 'none' and pe.partner_id is null) or pe.partner_id::text = $5)
        and ($6::text is null or pe.reconciliation_status = $6)
        and ($7::date is null or pe.paid_at >= _tz_day_start($7)) and ($8::date is null or pe.paid_at < _tz_day_start($8 + 1))
      order by %s %s, pe.id limit $9 offset $10)
    select jsonb_build_object('total', coalesce(max(f.total), 0),
      'rows', coalesce(jsonb_agg(_payment_json(f.pe, f.name, f.email, f.display_name)), '[]'::jsonb)) from f
  $q$, v_order, v_dir)
  into v_res using v_q, p_provider, p_status, p_plan, p_partner, p_recon, p_from, p_to, v_pg[1], v_pg[2];
  return v_res;
end $$;

create or replace function admin_get_payment(p_id uuid) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare pe payments_eff%rowtype;
begin
  perform require_admin();
  select * into pe from payments_eff where id = p_id;
  if not found then raise exception 'payment not found' using errcode = 'P0040'; end if;
  return jsonb_build_object(
    'payment', _payment_json(pe, (select name from profiles where id = pe.user_id),
      (select email::text from auth.users where id = pe.user_id), (select display_name from partners where id = pe.partner_id)),
    'base', jsonb_build_object('fee_cents', pe.fee_cents, 'tax_cents', pe.tax_cents, 'net_cents', pe.net_cents,
      'commission_cents', pe.commission_cents),
    'refunds', coalesce((select jsonb_agg(jsonb_build_object('kind', kind, 'gross_cents', gross_refunded_cents,
        'fee_cents', fee_refunded_cents, 'tax_cents', tax_refunded_cents, 'commission_reversed_cents', commission_reversed_cents,
        'ledgered', ledgered, 'at', refunded_at, 'ref', external_ref) order by refunded_at) from payment_refunds where payment_id = p_id), '[]'::jsonb),
    'adjustments', coalesce((select jsonb_agg(jsonb_build_object('kind', kind, 'delta_cents', delta_cents,
        'commission_delta_cents', commission_delta_cents, 'ref', external_ref, 'note', note, 'at', created_at) order by created_at)
        from payment_adjustments where payment_id = p_id), '[]'::jsonb),
    'ledger', coalesce((select jsonb_agg(jsonb_build_object('kind', kind, 'amount_cents', amount_cents, 'competence', competence,
        'at', created_at, 'note', note) order by id) from commission_ledger where payment_id = p_id), '[]'::jsonb));
end $$;

-- ---------------------------------------------------------------------------
-- 9. Comissões por professor, fechamento e repasses
-- ---------------------------------------------------------------------------
create or replace function admin_partner_closing(p_competence date, p_search text default null,
  p_limit integer default 50, p_offset integer default 0) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_pg integer[] := _page(p_limit, p_offset); v_c date; v_q text;
begin
  perform require_admin();
  if p_competence is null then raise exception 'invalid period' using errcode = 'P0060'; end if;
  v_c := date_trunc('month', p_competence)::date;
  v_q := case when p_search is null or btrim(p_search) = '' then null else _like_escape(lower(btrim(p_search))) end;
  return (select jsonb_build_object('competence', v_c, 'total', coalesce(max(t.total), 0),
    'sum_available_cents', coalesce(sum(t.available) filter (where t.available > 0), 0),
    'rows', coalesce(jsonb_agg(to_jsonb(t) - 'total' order by t.available desc, t.name), '[]'::jsonb))
  from (
    select p.id, p.display_name as name, p.status, p.commission_bps, p.pix_key_type, (p.pix_key is not null) as has_pix,
      _mask_pix(p.pix_key) as pix_masked,
      coalesce(sum(l.amount_cents) filter (where l.competence < v_c), 0) as carry_cents,
      coalesce(sum(l.amount_cents) filter (where l.kind = 'commission' and l.competence = v_c), 0) as commissions_cents,
      coalesce(sum(l.amount_cents) filter (where l.kind in ('refund_adjustment', 'manual_adjustment', 'fee_adjustment') and l.competence = v_c), 0) as adjustments_cents,
      -coalesce(sum(l.amount_cents) filter (where l.kind in ('payout', 'payout_reversal') and l.competence = v_c), 0) as paid_cents,
      coalesce(sum(l.amount_cents) filter (where l.competence <= v_c), 0) as available,
      coalesce((select sum(pm.commission_cents) from payments pm where pm.partner_id = p.id
        and pm.reconciliation_status = 'pending' and pm.competence <= v_c and pm.status in ('confirmed', 'partially_refunded')), 0) as pending_reconciliation_cents,
      count(*) over () as total
    from partners p join commission_ledger l on l.partner_id = p.id
    where (v_q is null or lower(p.display_name) like '%' || v_q || '%' escape '\')
    group by p.id order by 1 limit v_pg[1] offset v_pg[2]) t
  ) || '{}'::jsonb;
end $$;

create or replace function admin_partner_commissions(p_partner uuid, p_limit integer default 25, p_offset integer default 0) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_pg integer[] := _page(p_limit, p_offset); p partners%rowtype;
begin
  perform require_admin();
  select * into p from partners where id = p_partner;
  if not found then raise exception 'partner not found' using errcode = 'P0013'; end if;
  return jsonb_build_object(
    'partner', jsonb_build_object('id', p.id, 'name', p.display_name, 'status', p.status, 'commission_bps', p.commission_bps,
      'pix_type', p.pix_key_type, 'pix_masked', _mask_pix(p.pix_key)),
    'summary', _partner_finance_summary(p_partner) || jsonb_build_object(
      'pending_reconciliation_cents', coalesce((select sum(commission_cents) from payments where partner_id = p_partner
        and reconciliation_status = 'pending' and status in ('confirmed', 'partially_refunded')), 0),
      'payments_count', (select count(*) from payments where partner_id = p_partner)),
    'bps_history', coalesce((select jsonb_agg(jsonb_build_object('commission_bps', commission_bps, 'status', status,
        'from', effective_from) order by id desc) from partner_commission_history where partner_id = p_partner), '[]'::jsonb),
    'by_competence', coalesce((select jsonb_agg(jsonb_build_object('competence', t.c, 'commissions_cents', t.com,
        'adjustments_cents', t.adj, 'payouts_cents', t.pay, 'balance_cents', t.com + t.adj + t.pay) order by t.c desc)
        from (select competence c,
          coalesce(sum(amount_cents) filter (where kind = 'commission'), 0) com,
          coalesce(sum(amount_cents) filter (where kind in ('refund_adjustment', 'manual_adjustment', 'fee_adjustment')), 0) adj,
          coalesce(sum(amount_cents) filter (where kind in ('payout', 'payout_reversal')), 0) pay
          from commission_ledger where partner_id = p_partner group by competence order by competence desc limit 60) t), '[]'::jsonb),
    'ledger_total', (select count(*) from commission_ledger where partner_id = p_partner),
    'ledger', coalesce((select jsonb_agg(jsonb_build_object('id', y.id, 'kind', y.kind, 'amount_cents', y.amount_cents,
        'competence', y.competence, 'at', y.created_at, 'payment_id', y.payment_id, 'note', y.note) order by y.id desc)
        from (select * from commission_ledger where partner_id = p_partner order by id desc limit v_pg[1] offset v_pg[2]) y), '[]'::jsonb));
end $$;

create or replace function admin_list_payouts(p_partner uuid default null, p_status text default null,
  p_limit integer default 25, p_offset integer default 0) returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_pg integer[] := _page(p_limit, p_offset);
begin
  perform require_admin();
  if p_status is not null and p_status not in ('paid', 'reversed') then raise exception 'invalid filter' using errcode = 'P0060'; end if;
  return jsonb_build_object(
    'total', (select count(*) from payouts where (p_partner is null or partner_id = p_partner) and (p_status is null or status = p_status)),
    'rows', coalesce((select jsonb_agg(to_jsonb(x) order by x.paid_at desc) from (
      select o.id, o.partner_id, pa.display_name as partner_name, o.competence, o.amount_cents, o.status, o.paid_at,
        o.note, o.reference, o.created_at, o.reversed_at, o.reverse_reason,
        (select email::text from auth.users where id = o.registered_by) as registered_by
      from payouts o join partners pa on pa.id = o.partner_id
      where (p_partner is null or o.partner_id = p_partner) and (p_status is null or o.status = p_status)
      order by o.paid_at desc, o.created_at desc limit v_pg[1] offset v_pg[2]) x), '[]'::jsonb));
end $$;

-- ---------------------------------------------------------------------------
-- 10. Portal do professor: mesma fonte de dados (substitui a da Etapa 05)
-- ---------------------------------------------------------------------------
create or replace function _partner_finance_summary(p_partner uuid) returns jsonb
language sql stable security definer set search_path = public, pg_temp as $$
  select jsonb_build_object(
    'balance_cents', partner_balance_cents(p_partner),
    'commissions_cents', coalesce((select sum(amount_cents) from commission_ledger
        where partner_id = p_partner and kind = 'commission'), 0),
    'month_commissions_cents', coalesce((select sum(amount_cents) from commission_ledger
        where partner_id = p_partner and kind = 'commission' and competence = _competence(now())), 0),
    'adjustments_cents', coalesce((select sum(amount_cents) from commission_ledger
        where partner_id = p_partner and kind in ('refund_adjustment', 'manual_adjustment', 'fee_adjustment')), 0),
    'received_cents', coalesce((select sum(amount_cents) from payouts where partner_id = p_partner and status = 'paid'), 0),
    'pending_reconciliation_cents', coalesce((select sum(commission_cents) from payments where partner_id = p_partner
        and reconciliation_status = 'pending' and status in ('confirmed', 'partially_refunded')), 0),
    'last_payout', (select jsonb_build_object('amount_cents', amount_cents, 'paid_at', paid_at, 'competence', competence)
        from payouts where partner_id = p_partner and status = 'paid' order by paid_at desc limit 1),
    'next_payout_date', _next_payout_date());
$$;

create or replace function partner_finance(p_limit integer default 25, p_offset integer default 0)
returns jsonb language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_pid uuid := _my_partner_id(); v_pg integer[] := _page(p_limit, p_offset); p partners%rowtype;
begin
  if v_pid is null then raise exception 'forbidden' using errcode = '42501'; end if;
  select * into p from partners where id = v_pid;
  return jsonb_build_object(
    'partner', jsonb_build_object('status', p.status, 'active', partner_active_at(v_pid, now()), 'commission_bps', p.commission_bps),
    'summary', _partner_finance_summary(v_pid),
    'by_competence', coalesce((select jsonb_agg(jsonb_build_object('competence', t.c, 'commissions_cents', t.com,
        'adjustments_cents', t.adj, 'payouts_cents', t.pay, 'balance_cents', t.com + t.adj + t.pay) order by t.c desc)
        from (select competence c,
          coalesce(sum(amount_cents) filter (where kind = 'commission'), 0)::bigint com,
          coalesce(sum(amount_cents) filter (where kind in ('refund_adjustment', 'manual_adjustment', 'fee_adjustment')), 0)::bigint adj,
          coalesce(sum(amount_cents) filter (where kind in ('payout', 'payout_reversal')), 0)::bigint pay
          from commission_ledger where partner_id = v_pid group by competence order by competence desc limit 60) t), '[]'::jsonb),
    'payouts', coalesce((select jsonb_agg(jsonb_build_object('competence', x.competence, 'amount_cents', x.amount_cents,
        'status', x.status, 'paid_at', x.paid_at, 'reference', x.reference) order by x.paid_at desc)
        from (select * from payouts where partner_id = v_pid order by paid_at desc limit 36) x), '[]'::jsonb),
    'ledger_total', (select count(*) from commission_ledger where partner_id = v_pid),
    'ledger', coalesce((select jsonb_agg(jsonb_build_object('id', y.id, 'kind', y.kind, 'amount_cents', y.amount_cents,
        'competence', y.competence, 'at', y.created_at, 'plan', pay.plan, 'paid_at', pay.paid_at, 'payment_status', pay.status)
        order by y.id desc)
        from (select * from commission_ledger where partner_id = v_pid order by id desc limit v_pg[1] offset v_pg[2]) y
        left join payments pay on pay.id = y.payment_id), '[]'::jsonb));
end $$;

-- ---------------------------------------------------------------------------
-- 11. Exportações CSV (texto livre protegido contra injeção de fórmula)
-- ---------------------------------------------------------------------------
create or replace function _csv(p_text text) returns text
language sql immutable set search_path = public, pg_temp as $$
  select case when p_text is null then '' else
    '"' || replace(case when p_text ~ '^[=+\-@\t\r]' then '''' || p_text else p_text end, '"', '""') || '"' end;
$$;
create or replace function _money_txt(p_cents bigint) returns text
language sql immutable set search_path = public, pg_temp as $$
  select case when p_cents is null then '' else
    (case when p_cents < 0 then '-' else '' end) || (abs(p_cents) / 100)::text || '.' || lpad((abs(p_cents) % 100)::text, 2, '0') end;
$$;

create or replace function _csv_ledger(p_partner uuid, p_from date, p_to date, p_admin boolean) returns text
language sql stable security definer set search_path = public, pg_temp as $$
  select 'data,competencia,tipo,valor_brl' || case when p_admin then ',professor' else '' end || E'\n' ||
    coalesce(string_agg(to_char(l.created_at at time zone 'America/Sao_Paulo', 'YYYY-MM-DD') || ',' ||
      to_char(l.competence, 'YYYY-MM') || ',' || l.kind || ',' || _money_txt(l.amount_cents) ||
      case when p_admin then ',' || _csv(pa.display_name) else '' end, E'\n' order by l.id), '')
  from (select * from commission_ledger where (p_partner is null or partner_id = p_partner)
        and (p_from is null or created_at >= _tz_day_start(p_from)) and (p_to is null or created_at < _tz_day_start(p_to + 1))
        order by id limit 20000) l join partners pa on pa.id = l.partner_id;
$$;

create or replace function _csv_payouts(p_partner uuid, p_from date, p_to date, p_admin boolean) returns text
language sql stable security definer set search_path = public, pg_temp as $$
  select 'data_pix,competencia,valor_brl,situacao,referencia' || case when p_admin then ',professor' else '' end || E'\n' ||
    coalesce(string_agg(to_char(o.paid_at at time zone 'America/Sao_Paulo', 'YYYY-MM-DD') || ',' ||
      to_char(o.competence, 'YYYY-MM') || ',' || _money_txt(o.amount_cents) || ',' || o.status || ',' || _csv(o.reference) ||
      case when p_admin then ',' || _csv(pa.display_name) else '' end, E'\n' order by o.paid_at), '')
  from (select * from payouts where (p_partner is null or partner_id = p_partner)
        and (p_from is null or paid_at >= _tz_day_start(p_from)) and (p_to is null or paid_at < _tz_day_start(p_to + 1))
        order by paid_at limit 20000) o join partners pa on pa.id = o.partner_id;
$$;

create or replace function admin_finance_export(p_kind text, p_from date default null, p_to date default null,
  p_partner uuid default null, p_provider text default null) returns text
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_out text;
begin
  perform require_admin();
  if p_kind = 'commissions' then return _csv_ledger(p_partner, p_from, p_to, true);
  elsif p_kind = 'payouts' then return _csv_payouts(p_partner, p_from, p_to, true);
  elsif p_kind = 'payments' then
    select 'data,provedor,plano,id_externo,bruto_brl,taxas_brl,impostos_brl,liquido_brl,professor,percentual_bps,comissao_brl,receita_lucksrei_brl,situacao,conciliacao,liquidacao,reembolsado_brl' || E'\n' ||
      coalesce(string_agg(to_char(pe.paid_at at time zone 'America/Sao_Paulo', 'YYYY-MM-DD') || ',' || pe.provider || ',' || pe.plan || ',' ||
        _csv(pe.external_id) || ',' || _money_txt(pe.gross_cents) || ',' || _money_txt(pe.fee_eff) || ',' || _money_txt(pe.tax_eff) || ',' ||
        _money_txt(pe.net_eff) || ',' || _csv(pa.display_name) || ',' || coalesce(pe.commission_bps::text, '') || ',' ||
        _money_txt(pe.commission_eff) || ',' || _money_txt(pe.net_eff - pe.commission_eff) || ',' || pe.status || ',' ||
        pe.reconciliation_status || ',' || pe.settlement_status || ',' || _money_txt(pe.refunded_gross), E'\n' order by pe.paid_at), '')
    into v_out from (select * from payments_eff where (p_provider is null or provider = p_provider)
        and (p_partner is null or partner_id = p_partner)
        and (p_from is null or paid_at >= _tz_day_start(p_from)) and (p_to is null or paid_at < _tz_day_start(p_to + 1))
        order by paid_at limit 20000) pe left join partners pa on pa.id = pe.partner_id;
    return v_out;
  elsif p_kind = 'expenses' then
    select 'data,competencia,categoria,descricao,valor_brl,observacao' || E'\n' ||
      coalesce(string_agg(to_char(e.expense_date, 'YYYY-MM-DD') || ',' || to_char(e.competence, 'YYYY-MM') || ',' || _csv(c.name) || ',' ||
        _csv(e.description) || ',' || _money_txt(e.amount_cents) || ',' || _csv(e.note), E'\n' order by e.expense_date), '')
    into v_out from (select * from expenses where voided_at is null and (p_from is null or expense_date >= p_from)
        and (p_to is null or expense_date <= p_to) order by expense_date limit 20000) e join expense_categories c on c.id = e.category_id;
    return v_out;
  elsif p_kind = 'summary' then
    if p_from is null or p_to is null then raise exception 'invalid period' using errcode = 'P0060'; end if;
    select 'indicador,valor' || E'\n' || string_agg(k || ',' || case when k like '%cents' then _money_txt(v::bigint) else v end, E'\n' order by k)
    into v_out from jsonb_each_text(admin_finance_dashboard(p_from, p_to)->'totals') t(k, v);
    return v_out;
  end if;
  raise exception 'invalid filter' using errcode = 'P0060';
end $$;

create or replace function partner_finance_export(p_kind text, p_from date default null, p_to date default null) returns text
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_pid uuid := _my_partner_id();
begin
  if v_pid is null then raise exception 'forbidden' using errcode = '42501'; end if;
  if p_kind = 'commissions' then return _csv_ledger(v_pid, p_from, p_to, false);
  elsif p_kind = 'payouts' then return _csv_payouts(v_pid, p_from, p_to, false); end if;
  raise exception 'invalid filter' using errcode = 'P0060';
end $$;

-- ---------------------------------------------------------------------------
-- 12. Permissões
-- ---------------------------------------------------------------------------
select app_lock_tables(array['payment_refunds', 'payment_adjustments', 'partner_commission_history',
  'expense_categories', 'expenses', 'expense_history']);
revoke all on payments_eff from public, anon, authenticated;
select app_grant_functions(array['partners_commission_log', '_student_partner_at', '_partner_bps_at', '_ledger_pending_refunds',
  'record_confirmed_payment', 'record_payment_reconciliation', 'record_payment_settlement', 'record_payment_adjustment',
  'record_payment_refund', '_mask_pix', '_partner_available', '_expense_valid', '_payment_json', '_csv', '_money_txt',
  '_csv_ledger', '_csv_payouts', '_partner_finance_summary'], array[]::text[]);
select app_grant_functions(array['admin_register_payout', 'admin_reverse_payout', 'admin_get_partner_pix', 'admin_create_expense',
  'admin_update_expense', 'admin_void_expense', 'admin_add_expense_category', 'admin_list_expenses', 'admin_finance_dashboard',
  'admin_list_payments', 'admin_get_payment', 'admin_partner_closing', 'admin_partner_commissions', 'admin_list_payouts',
  'admin_finance_export', 'partner_finance', 'partner_finance_export'], array['authenticated']);
notify pgrst, 'reload schema';
