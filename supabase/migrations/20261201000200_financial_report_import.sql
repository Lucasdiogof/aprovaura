-- Premium/Partners — Etapa 09 (parte 2): importação e conciliação de relatórios
-- financeiros oficiais (Apple, Google Play, Mercado Pago). ADITIVA e inerte.
-- Metodologia (ver docs/finance/RECONCILIATION.md):
--  * IMPORTAR só guarda e CONFERE (nunca altera pagamentos). Nada é inventado.
--  * Apple: relatórios agregados (sem id de transação) => só conferência de totais.
--  * Google (pedido) e Mercado Pago (SOURCE_ID): conferência individual por id exato.
--  * APLICAR é um ato do admin, auditado, e só atinge linhas 'matched' (valor bruto
--    idêntico ao pagamento registrado). Divergência/sem par nunca é aplicada.
--  * Formatos NÃO foram validados com amostra real: a UI avisa; validar na Etapa 10.
-- Rollback: supabase/rollbacks/20261201000200_financial_report_import.down.sql

create table if not exists financial_report_imports (
  id uuid primary key default gen_random_uuid(),
  provider text not null check (provider in ('apple', 'google', 'mercadopago')),
  kind text not null check (kind in ('apple_sales', 'apple_financial', 'google_sales', 'google_earnings', 'mp_release', 'mp_settlement')),
  competence date not null,                       -- 1º dia do mês
  file_name text,
  file_sha256 text not null,
  line_count integer not null default 0,
  matched integer not null default 0,
  divergent integer not null default 0,
  unmatched integer not null default 0,
  status text not null default 'staged' check (status in ('staged', 'applied')),
  totals jsonb not null default '{}'::jsonb,
  created_by uuid, created_at timestamptz not null default now(),
  applied_by uuid, applied_at timestamptz,
  unique (provider, file_sha256)                  -- o mesmo arquivo não entra duas vezes
);

create table if not exists financial_report_lines (
  id bigint generated always as identity primary key,
  import_id uuid not null references financial_report_imports (id),
  line_no integer not null,
  ref text,                                       -- id individual do provedor (pedido / SOURCE_ID)
  sku text, country text, currency text,
  quantity integer,
  gross_cents bigint, tax_cents bigint, fee_cents bigint, net_cents bigint,
  occurred_at timestamptz,
  status text not null default 'aggregate' check (status in ('aggregate', 'matched', 'divergent', 'unmatched', 'applied', 'already')),
  note text,
  payment_id uuid references payments (id)
);
create index if not exists financial_report_lines_import_idx on financial_report_lines (import_id, status);
-- Linha repetida em arquivos sobrepostos é inofensiva: record_payment_reconciliation é idempotente
-- (pagamento já conciliado vira 'already').

create or replace function admin_import_report(
  p_provider text, p_kind text, p_competence date, p_file_name text, p_sha256 text, p_lines jsonb
) returns jsonb language plpgsql security definer set search_path = public, pg_temp as $$
declare
  v_id uuid; l jsonb; i integer := 0; v_pay payments%rowtype; v_status text; v_note text;
  v_ref text; v_gross bigint; v_individual boolean; m integer := 0; d integer := 0; u integer := 0;
begin
  perform require_admin();
  if p_provider not in ('apple', 'google', 'mercadopago') then raise exception 'invalid provider' using errcode = 'P0060'; end if;
  if jsonb_typeof(p_lines) <> 'array' or jsonb_array_length(p_lines) = 0 or jsonb_array_length(p_lines) > 20000 then
    raise exception 'invalid lines' using errcode = 'P0060';
  end if;
  if p_sha256 !~ '^[0-9a-f]{64}$' then raise exception 'invalid hash' using errcode = 'P0060'; end if;
  if (p_provider = 'apple') <> (p_kind like 'apple\_%') or (p_provider = 'google') <> (p_kind like 'google\_%')
     or (p_provider = 'mercadopago') <> (p_kind like 'mp\_%') then
    raise exception 'kind does not match provider' using errcode = 'P0060';
  end if;
  if exists (select 1 from financial_report_imports where provider = p_provider and file_sha256 = p_sha256) then
    raise exception 'file already imported' using errcode = 'P0061';
  end if;
  v_individual := p_kind in ('google_sales', 'google_earnings', 'mp_release', 'mp_settlement');
  insert into financial_report_imports (provider, kind, competence, file_name, file_sha256, created_by)
  values (p_provider, p_kind, date_trunc('month', p_competence)::date, left(p_file_name, 200), p_sha256, auth.uid())
  returning id into v_id;

  for l in select * from jsonb_array_elements(p_lines) loop
    i := i + 1; v_note := null; v_status := 'aggregate'; v_ref := nullif(btrim(l->>'ref'), ''); v_pay := null;
    v_gross := nullif(l->>'gross_cents', '')::bigint;
    if v_individual then
      if v_ref is null then v_status := 'unmatched'; v_note := 'sem id individual';
      else
        select * into v_pay from payments where provider = p_provider and external_id = v_ref;
        if not found then v_status := 'unmatched'; v_note := 'pagamento não encontrado';
        elsif v_gross is distinct from v_pay.gross_cents then
          v_status := 'divergent'; v_note := 'valor bruto difere: relatório ' || coalesce(v_gross::text, '?') || ' x sistema ' || v_pay.gross_cents;
        elsif p_kind = 'google_sales' then
          v_status := 'already'; v_note := 'confere o valor bruto; taxa só vem no relatório de ganhos';
        elsif v_pay.reconciliation_status = 'reconciled' then v_status := 'already'; v_note := 'já conciliado';
        elsif nullif(l->>'fee_cents', '') is null or nullif(l->>'tax_cents', '') is null then
          v_status := 'unmatched'; v_note := 'taxa/imposto ausentes na linha';
        elsif (l->>'fee_cents')::bigint < 0 or (l->>'tax_cents')::bigint < 0
              or (l->>'fee_cents')::bigint + (l->>'tax_cents')::bigint > v_pay.gross_cents then
          v_status := 'divergent'; v_note := 'taxa+imposto inválidos';
        else v_status := 'matched'; end if;
      end if;
      if v_status = 'matched' then m := m + 1; elsif v_status = 'divergent' then d := d + 1;
      elsif v_status = 'unmatched' then u := u + 1; end if;
    end if;
    insert into financial_report_lines (import_id, line_no, ref, sku, country, currency, quantity, gross_cents,
      tax_cents, fee_cents, net_cents, occurred_at, status, note, payment_id)
    values (v_id, i, v_ref, left(l->>'sku', 100), left(l->>'country', 8), left(l->>'currency', 8),
      nullif(l->>'qty', '')::integer, v_gross, nullif(l->>'tax_cents', '')::bigint,
      nullif(l->>'fee_cents', '')::bigint, nullif(l->>'net_cents', '')::bigint,
      nullif(l->>'at', '')::timestamptz, v_status, v_note, v_pay.id);
  end loop;

  update financial_report_imports set line_count = i, matched = m, divergent = d, unmatched = u where id = v_id;
  perform audit_event('finance.report_import', 'report', v_id::text, null,
    jsonb_build_object('provider', p_provider, 'kind', p_kind, 'lines', i, 'matched', m, 'divergent', d, 'unmatched', u), p_file_name);
  return jsonb_build_object('import_id', v_id, 'lines', i, 'matched', m, 'divergent', d, 'unmatched', u);
end $$;

-- Aplicar: só linhas 'matched' viram conciliação oficial (taxa/imposto do provedor).
create or replace function admin_apply_report(p_import uuid) returns jsonb
language plpgsql security definer set search_path = public, pg_temp as $$
declare imp financial_report_imports%rowtype; l record; v_res jsonb; n integer := 0;
begin
  perform require_admin();
  select * into imp from financial_report_imports where id = p_import for update;
  if not found then raise exception 'import not found' using errcode = 'P0062'; end if;
  if imp.status = 'applied' then return jsonb_build_object('applied', 0, 'already', true); end if;
  for l in select * from financial_report_lines where import_id = p_import and status = 'matched' order by id loop
    v_res := record_payment_reconciliation(imp.provider, l.ref, l.fee_cents, l.tax_cents, l.net_cents, l.occurred_at);
    update financial_report_lines set status = case when (v_res->>'changed')::boolean then 'applied' else 'already' end
      where id = l.id;
    if (v_res->>'changed')::boolean then n := n + 1; end if;
  end loop;
  update financial_report_imports set status = 'applied', applied_by = auth.uid(), applied_at = now() where id = p_import;
  perform audit_event('finance.report_apply', 'report', p_import::text, null, jsonb_build_object('applied', n), null);
  return jsonb_build_object('applied', n);
end $$;

create or replace function admin_list_report_imports() returns jsonb
language plpgsql stable security definer set search_path = public, pg_temp as $$
begin
  perform require_admin();
  return coalesce((select jsonb_agg(to_jsonb(i) - 'file_sha256' order by i.created_at desc)
    from (select * from financial_report_imports order by created_at desc limit 100) i), '[]'::jsonb);
end $$;

-- Detalhe: linhas problemáticas (divergentes/sem par) e, para relatórios agregados,
-- a CONFERÊNCIA de totais do mês contra os pagamentos registrados (sem atribuir nada).
create or replace function admin_get_report_import(p_import uuid, p_only_issues boolean default true)
returns jsonb language plpgsql stable security definer set search_path = public, pg_temp as $$
declare imp financial_report_imports%rowtype; v_check jsonb;
begin
  perform require_admin();
  select * into imp from financial_report_imports where id = p_import;
  if not found then raise exception 'import not found' using errcode = 'P0062'; end if;
  if imp.provider = 'apple' then
    v_check := jsonb_build_object(
      'report_quantity', (select coalesce(sum(quantity), 0) from financial_report_lines where import_id = p_import),
      'report_customer_price_cents', (select coalesce(sum(gross_cents), 0) from financial_report_lines where import_id = p_import),
      'report_partner_share_cents', (select coalesce(sum(net_cents), 0) from financial_report_lines where import_id = p_import),
      'system_payments', (select count(*) from payments where provider = 'apple' and competence = imp.competence),
      'system_gross_cents', (select coalesce(sum(gross_cents), 0) from payments where provider = 'apple' and competence = imp.competence),
      'note', 'Conferência agregada: o relatório da Apple não traz id de transação; nenhum pagamento é conciliado individualmente.');
  end if;
  return jsonb_build_object('import', to_jsonb(imp) - 'file_sha256', 'check', v_check,
    'lines', coalesce((select jsonb_agg(to_jsonb(x) order by x.line_no) from (
        select line_no, ref, sku, country, currency, quantity, gross_cents, tax_cents, fee_cents, net_cents, status, note
        from financial_report_lines where import_id = p_import
          and (not p_only_issues or status in ('divergent', 'unmatched')) order by line_no limit 500) x), '[]'::jsonb));
end $$;

select app_lock_tables(array['financial_report_imports', 'financial_report_lines']);
select app_grant_functions(array['admin_import_report', 'admin_apply_report', 'admin_list_report_imports',
  'admin_get_report_import'], array['authenticated']);
notify pgrst, 'reload schema';
