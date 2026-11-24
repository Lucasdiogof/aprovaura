-- Premium/Partners — 0400: fundação financeira (pagamentos, comissões,
-- repasses). Valores SEMPRE em centavos inteiros (bigint). Aditiva; depende
-- de 0200. Sem FK para auth.users nem para parceiros apagáveis: o histórico
-- financeiro sobrevive à exclusão de contas.
-- Rollback: supabase/rollbacks/20261124000400_finance.down.sql

create table if not exists payments (
  id uuid primary key default gen_random_uuid(),
  provider text not null check (provider in ('apple', 'google', 'mercadopago')),
  external_id text not null,               -- id único do pagamento no provedor
  user_id uuid not null,
  plan text not null check (plan in ('monthly', 'annual')),
  currency text not null default 'BRL' check (currency = 'BRL'),
  gross_cents bigint not null check (gross_cents > 0),
  fee_cents bigint not null default 0 check (fee_cents >= 0),
  tax_cents bigint not null default 0 check (tax_cents >= 0),
  net_cents bigint not null,
  status text not null default 'confirmed' check (status in ('confirmed', 'refunded', 'charged_back')),
  paid_at timestamptz not null,
  competence date not null,                -- 1º dia do mês (America/Sao_Paulo)
  -- Snapshot do momento do pagamento: mudanças futuras NÃO o alteram.
  partner_id uuid references partners (id),
  commission_bps integer check (commission_bps between 0 and 10000),
  commission_cents bigint not null default 0 check (commission_cents >= 0),
  lucksrei_cents bigint not null,
  refunded_at timestamptz,
  raw jsonb,
  created_at timestamptz not null default now(),
  constraint payments_net_ok check (net_cents = gross_cents - fee_cents - tax_cents and net_cents >= 0),
  constraint payments_split_ok check (commission_cents + lucksrei_cents = net_cents),
  unique (provider, external_id)
);
create index if not exists payments_partner_idx on payments (partner_id, competence);
create index if not exists payments_user_idx on payments (user_id);

-- Só status/estorno podem mudar; valores e snapshot são imutáveis.
create or replace function payments_guard() returns trigger
language plpgsql set search_path = public, pg_temp as $$
begin
  if tg_op = 'DELETE' then raise exception 'payments are append-only' using errcode = 'P0011'; end if;
  if (new.provider, new.external_id, new.user_id, new.plan, new.gross_cents, new.fee_cents,
      new.tax_cents, new.net_cents, new.paid_at, new.competence, new.partner_id,
      new.commission_bps, new.commission_cents, new.lucksrei_cents)
     is distinct from
     (old.provider, old.external_id, old.user_id, old.plan, old.gross_cents, old.fee_cents,
      old.tax_cents, old.net_cents, old.paid_at, old.competence, old.partner_id,
      old.commission_bps, old.commission_cents, old.lucksrei_cents) then
    raise exception 'payment amounts are immutable' using errcode = 'P0011';
  end if;
  return new;
end $$;
drop trigger if exists payments_guard_trg on payments;
create trigger payments_guard_trg before update or delete on payments
  for each row execute function payments_guard();

-- Razão (ledger) append-only por parceiro. Saldo pendente = soma dos lançamentos.
-- Repasse e estorno são lançamentos NEGATIVOS; nada é apagado nem editado.
create table if not exists commission_ledger (
  id bigint generated always as identity primary key,
  partner_id uuid not null references partners (id),
  kind text not null check (kind in
    ('commission', 'refund_adjustment', 'payout', 'payout_reversal', 'manual_adjustment')),
  amount_cents bigint not null check (amount_cents <> 0),
  competence date not null,
  payment_id uuid references payments (id),
  payout_id uuid,
  note text,
  created_by uuid,
  created_at timestamptz not null default now()
);
create index if not exists commission_ledger_partner_idx on commission_ledger (partner_id, competence);
-- Idempotência: uma comissão e um estorno por pagamento.
create unique index if not exists ledger_commission_once
  on commission_ledger (payment_id) where kind = 'commission';
create unique index if not exists ledger_refund_once
  on commission_ledger (payment_id) where kind = 'refund_adjustment';
create unique index if not exists ledger_payout_once
  on commission_ledger (payout_id) where kind = 'payout';
create unique index if not exists ledger_payout_reversal_once
  on commission_ledger (payout_id) where kind = 'payout_reversal';
drop trigger if exists commission_ledger_immutable on commission_ledger;
create trigger commission_ledger_immutable before update or delete on commission_ledger
  for each row execute function forbid_mutation();

create table if not exists payouts (
  id uuid primary key default gen_random_uuid(),
  partner_id uuid not null references partners (id),
  competence date not null,                -- mês que está sendo repassado (1º dia)
  amount_cents bigint not null check (amount_cents > 0),
  status text not null default 'paid' check (status in ('paid', 'reversed')),
  pix_key_type text,
  pix_key text,                            -- snapshot da chave usada
  paid_at timestamptz not null,
  note text,
  registered_by uuid,
  created_at timestamptz not null default now()
);
create index if not exists payouts_partner_idx on payouts (partner_id, competence);

create or replace function partner_balance_cents(p_partner uuid) returns bigint
language sql stable security definer set search_path = public, pg_temp as $$
  select coalesce(sum(amount_cents), 0)::bigint from commission_ledger where partner_id = p_partner;
$$;

create or replace function _competence(p_at timestamptz) returns date
language sql immutable set search_path = public, pg_temp as $$
  select date_trunc('month', p_at at time zone 'America/Sao_Paulo')::date;
$$;

-- Pagamento CONFIRMADO. Idempotente por (provider, external_id): reentrega de
-- webhook devolve o mesmo resultado e não duplica pagamento nem comissão.
-- Professor e percentual do MOMENTO ficam gravados; só gera comissão se a
-- parceria estava ativa em paid_at e o vínculo já existia.
create or replace function record_confirmed_payment(
  p_provider text, p_external_id text, p_user_id uuid, p_plan text,
  p_gross_cents bigint, p_fee_cents bigint, p_tax_cents bigint,
  p_paid_at timestamptz, p_raw jsonb default null
) returns jsonb language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_id uuid; v_partner uuid; v_bps integer; v_net bigint; v_commission bigint := 0; v_created boolean := true;
begin
  perform pg_advisory_xact_lock(hashtextextended('pay:' || p_provider || ':' || p_external_id, 0));
  select id into v_id from payments where provider = p_provider and external_id = p_external_id;
  if v_id is not null then
    return jsonb_build_object('payment_id', v_id, 'created', false);
  end if;
  v_net := p_gross_cents - coalesce(p_fee_cents, 0) - coalesce(p_tax_cents, 0);
  select l.partner_id, p.commission_bps into v_partner, v_bps
  from partner_links l join partners p on p.id = l.partner_id
  where l.student_id = p_user_id and l.linked_at <= p_paid_at and partner_active_at(p.id, p_paid_at);
  if v_partner is not null then
    v_commission := floor(v_net * v_bps / 10000.0)::bigint;     -- arredonda para baixo
  end if;
  insert into payments (provider, external_id, user_id, plan, gross_cents, fee_cents, tax_cents,
    net_cents, paid_at, competence, partner_id, commission_bps, commission_cents, lucksrei_cents, raw)
  values (p_provider, p_external_id, p_user_id, p_plan, p_gross_cents, coalesce(p_fee_cents, 0),
    coalesce(p_tax_cents, 0), v_net, p_paid_at, _competence(p_paid_at), v_partner, v_bps,
    v_commission, v_net - v_commission, p_raw)
  returning id into v_id;
  if v_commission > 0 then
    insert into commission_ledger (partner_id, kind, amount_cents, competence, payment_id)
    values (v_partner, 'commission', v_commission, _competence(p_paid_at), v_id);
  end if;
  return jsonb_build_object('payment_id', v_id, 'created', true, 'commission_cents', v_commission);
end $$;

-- Reembolso/estorno: gera ajuste NEGATIVO rastreável (mesmo que a comissão já
-- tenha sido repassada: o saldo do parceiro pode ficar negativo e compensa
-- nos próximos meses). Idempotente. O Premium é revogado pela integração.
create or replace function record_payment_refund(
  p_provider text, p_external_id text, p_refunded_at timestamptz, p_charged_back boolean default false
) returns jsonb language plpgsql security definer set search_path = public, pg_temp as $$
declare p payments%rowtype;
begin
  select * into p from payments where provider = p_provider and external_id = p_external_id for update;
  if not found then raise exception 'payment not found' using errcode = 'P0040'; end if;
  if p.status <> 'confirmed' then
    return jsonb_build_object('payment_id', p.id, 'changed', false);
  end if;
  update payments set status = case when p_charged_back then 'charged_back' else 'refunded' end,
    refunded_at = p_refunded_at where id = p.id;
  if p.commission_cents > 0 then
    insert into commission_ledger (partner_id, kind, amount_cents, competence, payment_id, note)
    values (p.partner_id, 'refund_adjustment', -p.commission_cents, _competence(p_refunded_at), p.id,
            case when p_charged_back then 'chargeback' else 'refund' end)
    on conflict do nothing;
  end if;
  return jsonb_build_object('payment_id', p.id, 'changed', true);
end $$;

-- Repasse manual via Pix (dia 01 de cada mês, sem mínimo). Reduz o saldo
-- pendente com um lançamento negativo; não apaga nenhum lançamento anterior.
create or replace function admin_register_payout(
  p_partner uuid, p_amount_cents bigint, p_competence date, p_paid_at timestamptz default now(),
  p_note text default null
) returns uuid language plpgsql security definer set search_path = public, pg_temp as $$
declare v_id uuid; v_pix_type text; v_pix text; v_balance bigint;
begin
  perform require_admin();
  perform pg_advisory_xact_lock(hashtextextended('payout:' || p_partner::text, 0));
  select pix_key_type, pix_key into v_pix_type, v_pix from partners where id = p_partner;
  if not found then raise exception 'partner not found' using errcode = 'P0013'; end if;
  v_balance := partner_balance_cents(p_partner);
  if p_amount_cents <= 0 or p_amount_cents > v_balance then
    raise exception 'amount exceeds pending balance (%)', v_balance using errcode = 'P0041';
  end if;
  insert into payouts (partner_id, competence, amount_cents, pix_key_type, pix_key, paid_at, note, registered_by)
  values (p_partner, date_trunc('month', p_competence)::date, p_amount_cents, v_pix_type, v_pix,
          p_paid_at, p_note, auth.uid()) returning id into v_id;
  insert into commission_ledger (partner_id, kind, amount_cents, competence, payout_id, note, created_by)
  values (p_partner, 'payout', -p_amount_cents, date_trunc('month', p_competence)::date, v_id, p_note, auth.uid());
  perform audit_event('payout.register', 'payout', v_id::text, null,
    jsonb_build_object('partner_id', p_partner, 'amount_cents', p_amount_cents, 'competence', p_competence), p_note);
  return v_id;
end $$;

-- Desfaz um repasse registrado por engano: lançamento positivo, nada é apagado.
create or replace function admin_reverse_payout(p_payout uuid, p_note text default null) returns void
language plpgsql security definer set search_path = public, pg_temp as $$
declare o payouts%rowtype;
begin
  perform require_admin();
  select * into o from payouts where id = p_payout for update;
  if not found or o.status <> 'paid' then raise exception 'payout not reversible' using errcode = 'P0042'; end if;
  update payouts set status = 'reversed' where id = p_payout;
  insert into commission_ledger (partner_id, kind, amount_cents, competence, payout_id, note, created_by)
  values (o.partner_id, 'payout_reversal', o.amount_cents, o.competence, p_payout, p_note, auth.uid());
  perform audit_event('payout.reverse', 'payout', p_payout::text, to_jsonb(o), null, p_note);
end $$;

-- Resumo do PRÓPRIO parceiro: agregados, sem dados pessoais de alunos
-- (isolamento entre professores).
create or replace function partner_my_summary() returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
declare v_partner uuid;
begin
  select id into v_partner from partners where user_id = auth.uid();
  if v_partner is null then raise exception 'not a partner' using errcode = '42501'; end if;
  return jsonb_build_object(
    'pending_balance_cents', partner_balance_cents(v_partner),
    'students', (select count(*) from partner_links where partner_id = v_partner),
    'by_competence', coalesce((select jsonb_agg(jsonb_build_object('competence', competence,
        'amount_cents', amt) order by competence desc)
      from (select competence, sum(amount_cents) amt from commission_ledger
            where partner_id = v_partner group by competence) c), '[]'::jsonb));
end $$;

select app_lock_tables(array['payments', 'commission_ledger', 'payouts']);
select app_grant_functions(array['payments_guard', 'partner_balance_cents', '_competence',
  'record_confirmed_payment', 'record_payment_refund'], array[]::text[]);
select app_grant_functions(array['admin_register_payout', 'admin_reverse_payout', 'partner_my_summary'],
  array['authenticated']);
