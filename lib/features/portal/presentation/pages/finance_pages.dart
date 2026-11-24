import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/pages/partner_pages.dart';
import 'package:aura/features/portal/presentation/pages/portal_gate.dart';
import 'package:aura/features/portal/presentation/widgets/portal_widgets.dart';

// Financeiro do administrador (Etapa 06). Todos os números vêm do servidor
// (RPCs admin_*): o Flutter só formata e exibe, sem recalcular dinheiro.

num _n(Map? m, String k) => (m?[k] as num?) ?? 0;
Map<String, dynamic> _m(dynamic v) => Map<String, dynamic>.from(v as Map);
List<Map<String, dynamic>> _l(dynamic v) => [for (final e in (v as List? ?? const [])) _m(e)];

/// `/partners/finance`: o mesmo endereço atende admin e professor.
class FinanceHome extends StatelessWidget {
  const FinanceHome({super.key});
  @override
  Widget build(BuildContext context) =>
      context.select((PortalSession s) => s.state.role) == PortalRole.admin ? const AdminFinancePage() : const PartnerFinancePage();
}

/// "1.234,56" / "1234.5" / "12" -> centavos (sem ponto flutuante). null = inválido.
int? parseCents(String raw) {
  var s = raw.replaceAll('R\$', '').replaceAll(' ', '').trim();
  if (s.isEmpty) return null;
  if (s.contains(',')) {
    s = s.replaceAll('.', '').replaceAll(',', '.');
  }
  final parts = s.split('.');
  if (parts.length > 2 || parts.any((p) => p.isNotEmpty && int.tryParse(p) == null)) return null;
  final whole = int.tryParse(parts[0].isEmpty ? '0' : parts[0]);
  var frac = parts.length == 2 ? parts[1] : '';
  if (whole == null || frac.length > 2) return null;
  frac = frac.padRight(2, '0');
  return whole * 100 + int.parse(frac);
}

String centsInput(int cents) => '${cents ~/ 100},${(cents % 100).toString().padLeft(2, '0')}';

String _payStatus(PortalStrings t, String s) => switch (s) {
      'confirmed' => t('Confirmado', 'Confirmed', 'Confirmado'),
      'partially_refunded' => t('Reembolso parcial', 'Partially refunded', 'Reembolso parcial'),
      'refunded' => t('Reembolsado', 'Refunded', 'Reembolsado'),
      'charged_back' => t('Chargeback', 'Chargeback', 'Contracargo'),
      _ => s,
    };

Tone _payTone(String s) => switch (s) {
      'confirmed' => Tone.good,
      'partially_refunded' => Tone.warn,
      _ => Tone.bad,
    };

Widget _recon(PortalStrings t, Map p) => p['reconciliation_status'] == 'pending'
    ? StatusBadge(t('Taxas estimadas', 'Estimated fees', 'Tarifas estimadas'), tone: Tone.warn)
    : StatusBadge(t('Conciliado', 'Reconciled', 'Conciliado'), tone: Tone.good);

String _settle(PortalStrings t, Map p) =>
    p['settlement_status'] == 'settled' ? t('Liquidado', 'Settled', 'Liquidado') : t('Aguardando', 'Awaiting', 'Pendiente');

Widget _section(String title, List<Widget> cards) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
        CardGrid(children: cards),
      ]),
    );

DateTime _month(DateTime d, [int add = 0]) => DateTime(d.year, d.month + add);
String _ym(DateTime d) => '${d.month.toString().padLeft(2, '0')}/${d.year}';

// ───────────────────────── Página com abas ─────────────────────────

class AdminFinancePage extends StatefulWidget {
  const AdminFinancePage({super.key});
  @override
  State<AdminFinancePage> createState() => _AdminFinanceState();
}

class _AdminFinanceState extends State<AdminFinancePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final names = [
      t('Visão geral', 'Overview', 'Resumen'),
      t('Pagamentos', 'Payments', 'Pagos'),
      t('Repasses', 'Payouts', 'Pagos a profesores'),
      t('Despesas', 'Expenses', 'Gastos'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(title: t('Financeiro', 'Finance', 'Finanzas')),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          for (var i = 0; i < names.length; i++)
            ChoiceChip(label: Text(names[i]), selected: _tab == i, onSelected: (_) => setState(() => _tab = i)),
        ]),
      ),
      switch (_tab) {
        0 => const _OverviewTab(),
        1 => const _PaymentsTab(),
        2 => const _PayoutsTab(),
        _ => const _ExpensesTab(),
      },
    ]);
  }
}

// ───────────────────────── Visão geral ─────────────────────────

class _OverviewTab extends StatefulWidget {
  const _OverviewTab();
  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> with PeriodState {
  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    final r = range;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
          periodSelect(t),
          Text('${t.date(r.start)} – ${t.date(r.end)}'),
          OutlinedButton.icon(
            onPressed: () => exportCsv(context, () => api.financeExport('summary', from: r.start, to: r.end), 'resumo-financeiro.csv'),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: Text(t('Exportar resumo', 'Export summary', 'Exportar resumen')),
          ),
        ]),
      ),
      Loader<Map<String, dynamic>>(
        loader: () => api.financeDashboard(r.start, r.end),
        keys: [r.start, r.end],
        builder: (context, d, _) {
          final x = _m(d['totals']);
          final series = _l(d['series']);
          final labels = [for (final p in series) t.dateOf(p['date'])];
          final providers = _l(d['by_provider']);
          final plans = _l(d['by_plan']);
          final cats = _l(d['expenses_by_category']);
          final est = _n(x, 'estimated_payments');
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (est > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Panel(
                  child: Text(t(
                    '${est.toInt()} pagamento(s) do período ainda têm taxas ESTIMADAS. Os totais abaixo incluem essas estimativas; as comissões deles só serão liberadas para repasse após a conciliação com o provedor.',
                    '${est.toInt()} payment(s) in the period still have ESTIMATED fees. Totals include those estimates; their commissions are only released for payout after reconciliation with the provider.',
                    '${est.toInt()} pago(s) del periodo aún tienen tarifas ESTIMADAS. Los totales incluyen esas estimaciones; sus comisiones solo se liberan tras conciliar con el proveedor.',
                  )),
                ),
              ),
            _section(t('Receita (por competência)', 'Revenue (accrual)', 'Ingresos (devengado)'), [
              StatCard(icon: Icons.payments_outlined, label: t('Faturamento bruto', 'Gross revenue', 'Facturación bruta'), value: t.money(_n(x, 'gross_cents')), hint: '${t.number(_n(x, 'payments_count'))} ${t('pagamentos confirmados', 'confirmed payments', 'pagos confirmados')}'),
              StatCard(label: t('Reembolsos e estornos', 'Refunds and chargebacks', 'Reembolsos y contracargos'), value: t.money(-_n(x, 'refunds_cents')), hint: '${t.number(_n(x, 'refunds_count'))} ${t('eventos', 'events', 'eventos')}'),
              StatCard(label: t('Taxas das plataformas', 'Platform fees', 'Tarifas de plataformas'), value: t.money(-_n(x, 'fees_cents'))),
              StatCard(label: t('Impostos sobre vendas', 'Sales taxes', 'Impuestos sobre ventas'), value: t.money(-_n(x, 'taxes_cents')), hint: t('Somente os registrados', 'Only those recorded', 'Solo los registrados')),
              StatCard(label: t('Receita líquida', 'Net revenue', 'Ingresos netos'), value: t.money(_n(x, 'net_cents')), hint: t('Após taxas, impostos e reembolsos — não é lucro', 'After fees, taxes and refunds — not profit', 'Tras tarifas, impuestos y reembolsos — no es ganancia')),
            ]),
            _section(t('Comissões de professores', 'Teacher commissions', 'Comisiones de profesores'), [
              StatCard(label: t('Geradas', 'Generated', 'Generadas'), value: t.money(_n(x, 'commissions_generated_cents'))),
              StatCard(label: t('Estornadas', 'Reversed', 'Revertidas'), value: t.money(-_n(x, 'commissions_reversed_cents'))),
              StatCard(label: t('Comissões líquidas', 'Net commissions', 'Comisiones netas'), value: t.money(_n(x, 'commissions_net_cents'))),
              StatCard(label: t('A repassar (saldo atual)', 'To pay out (current balance)', 'Por pagar (saldo actual)'), value: t.money(_n(x, 'commissions_pending_payout_cents')), hint: t('Todos os professores, hoje', 'All teachers, today', 'Todos los profesores, hoy')),
              StatCard(label: t('Repassadas no período', 'Paid out in period', 'Pagadas en el periodo'), value: t.money(_n(x, 'commissions_paid_cents'))),
              StatCard(label: t('Pendentes de conciliação', 'Pending reconciliation', 'Pendientes de conciliación'), value: t.money(_n(x, 'pending_reconciliation_commission_cents')), hint: t('Ainda não liberadas', 'Not yet released', 'Aún no liberadas')),
            ]),
            _section(t('Resultado da Lucksrei', 'Lucksrei result', 'Resultado de Lucksrei'), [
              StatCard(label: t('Receita da Lucksrei', 'Lucksrei revenue', 'Ingresos de Lucksrei'), value: t.money(_n(x, 'lucksrei_cents')), hint: t('Líquida − comissões líquidas', 'Net − net commissions', 'Neta − comisiones netas')),
              StatCard(label: t('Despesas operacionais', 'Operating expenses', 'Gastos operativos'), value: t.money(-_n(x, 'expenses_cents'))),
              StatCard(icon: Icons.account_balance_outlined, label: t('Resultado líquido', 'Net result', 'Resultado neto'), value: t.money(_n(x, 'result_cents')), hint: t('Receita da Lucksrei − despesas', 'Lucksrei revenue − expenses', 'Ingresos de Lucksrei − gastos')),
            ]),
            _section(t('Provedores e caixa', 'Providers and cash', 'Proveedores y caja'), [
              StatCard(label: t('Recebido dos provedores', 'Received from providers', 'Recibido de proveedores'), value: t.money(_n(x, 'received_from_providers_cents')), hint: t('Liquidações informadas no período', 'Settlements reported in the period', 'Liquidaciones informadas en el periodo')),
              StatCard(label: t('Aguardando liquidação', 'Awaiting settlement', 'Pendiente de liquidación'), value: t.money(_n(x, 'awaiting_settlement_cents')), hint: '${t.number(_n(x, 'awaiting_settlement_count'))} ${t('pagamentos (todos os períodos)', 'payments (all periods)', 'pagos (todos los periodos)')}'),
              StatCard(label: t('Fluxo de caixa informado', 'Reported cash flow', 'Flujo de caja informado'), value: t.money(_n(x, 'cash_flow_cents')), hint: t('Recebido − repasses − despesas', 'Received − payouts − expenses', 'Recibido − pagos − gastos')),
            ]),
            Panel(
              title: t('Evolução diária', 'Daily evolution', 'Evolución diaria'),
              child: series.isEmpty
                  ? EmptyState(message: t('Sem dados no período.', 'No data in the period.', 'Sin datos en el periodo.'))
                  : LayoutBuilder(builder: (context, box) {
                      Widget one(String title, String key) => Padding(
                            padding: const EdgeInsets.only(bottom: 16, right: 12),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
                              BarChart(values: [for (final p in series) (p[key] as num)], labels: labels, format: t.money),
                            ]),
                          );
                      final charts = [
                        one(t('Faturamento bruto', 'Gross revenue', 'Facturación bruta'), 'gross_cents'),
                        one(t('Receita líquida', 'Net revenue', 'Ingresos netos'), 'net_cents'),
                        one(t('Comissões', 'Commissions', 'Comisiones'), 'commissions_cents'),
                        one(t('Resultado (antes de reembolsar caixa)', 'Result', 'Resultado'), 'result_cents'),
                      ];
                      return box.maxWidth >= kWide
                          ? Column(children: [
                              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: charts[0]), Expanded(child: charts[1])]),
                              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: charts[2]), Expanded(child: charts[3])]),
                            ])
                          : Column(children: charts);
                    }),
            ),
            const SizedBox(height: 16),
            Panel(
              title: t('Por provedor', 'By provider', 'Por proveedor'),
              child: PortalTable(
                columns: [
                  PortalColumn(t('Provedor', 'Provider', 'Proveedor'), flex: 2),
                  PortalColumn(t('Pagamentos', 'Payments', 'Pagos')),
                  PortalColumn(t('Bruto', 'Gross', 'Bruto')),
                  PortalColumn(t('Taxas', 'Fees', 'Tarifas')),
                  PortalColumn(t('Impostos', 'Taxes', 'Impuestos')),
                  PortalColumn(t('Reembolsos', 'Refunds', 'Reembolsos')),
                ],
                rows: [
                  for (final p in providers)
                    [
                      Text(providerLabel('${p['provider']}')),
                      Text(t.number(_n(p, 'payments'))),
                      Text(t.money(_n(p, 'gross_cents'))),
                      Text(t.money(_n(p, 'fees_cents'))),
                      Text(t.money(_n(p, 'taxes_cents'))),
                      Text(t.money(_n(p, 'refunds_cents'))),
                    ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Panel(
              title: t('Planos e origem', 'Plans and origin', 'Planes y origen'),
              child: plans.isEmpty
                  ? EmptyState(message: t('Sem pagamentos no período.', 'No payments in the period.', 'Sin pagos en el periodo.'))
                  : PortalTable(
                      columns: [
                        PortalColumn(t('Plano', 'Plan', 'Plan'), flex: 2),
                        PortalColumn(t('Origem', 'Origin', 'Origen'), flex: 2),
                        PortalColumn(t('Pagamentos', 'Payments', 'Pagos')),
                        PortalColumn(t('Bruto', 'Gross', 'Bruto')),
                      ],
                      rows: [
                        for (final p in plans)
                          [
                            Text(planLabel(t, p['plan'] as String?)),
                            Text(p['origin'] == 'partner' ? t('Indicado por professor', 'Teacher referral', 'Referido por profesor') : t('Sem indicação', 'No referral', 'Sin referido')),
                            Text(t.number(_n(p, 'payments'))),
                            Text(t.money(_n(p, 'gross_cents'))),
                          ],
                      ],
                    ),
            ),
            if (cats.isNotEmpty) ...[
              const SizedBox(height: 16),
              Panel(
                title: t('Despesas por categoria', 'Expenses by category', 'Gastos por categoría'),
                child: PortalTable(
                  columns: [PortalColumn(t('Categoria', 'Category', 'Categoría'), flex: 3), PortalColumn(t('Valor', 'Amount', 'Valor'))],
                  rows: [for (final c in cats) [Text('${c['category']}'), Text(t.money(_n(c, 'amount_cents')))]],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              t(
                'Fórmulas: líquida = bruto − reembolsos − taxas − impostos. Receita da Lucksrei = líquida − comissões líquidas (comissão gerada − estornada). Resultado = receita da Lucksrei − despesas. A data do repasse não deduz a comissão de novo (ela já foi reconhecida ao ser gerada). Impostos e taxas aparecem só quando registrados; nada é estimado por padrão.',
                'Formulas: net = gross − refunds − fees − taxes. Lucksrei revenue = net − net commissions (generated − reversed). Result = Lucksrei revenue − expenses. The payout date never deducts a commission again (already recognised when generated). Taxes and fees show only when recorded; nothing is estimated by default.',
                'Fórmulas: neta = bruto − reembolsos − tarifas − impuestos. Ingresos de Lucksrei = neta − comisiones netas (generada − revertida). Resultado = ingresos de Lucksrei − gastos. La fecha del pago no deduce otra vez la comisión (ya reconocida al generarse). Impuestos y tarifas solo aparecen si están registrados; nada se estima por defecto.',
              ),
              style: const TextStyle(fontSize: 11),
            ),
          ]);
        },
      ),
    ]);
  }
}

// ───────────────────────── Pagamentos ─────────────────────────

class _PaymentsTab extends StatefulWidget {
  const _PaymentsTab();
  @override
  State<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<_PaymentsTab> {
  static const _limit = 25;
  String _search = '', _provider = '', _status = '', _plan = '', _partner = '', _recon = '', _sort = 'paid_at', _dir = 'desc';
  DateTime? _from, _to;
  int _offset = 0;

  void _set(VoidCallback f) => setState(() {
        f();
        _offset = 0;
      });

  Future<void> _pickRange() async {
    final r = await showDateRangePicker(context: context, firstDate: DateTime(2025), lastDate: DateTime.now());
    if (r != null) _set(() {
      _from = r.start;
      _to = r.end;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    String? n(String v) => v.isEmpty ? null : v;
    return Panel(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
          SearchBox(hint: t('ID externo, nome ou e-mail', 'External ID, name or e-mail', 'ID externo, nombre o correo'), onChanged: (v) => _set(() => _search = v)),
          Select<String>(label: t('Provedor', 'Provider', 'Proveedor'), value: _provider, items: {
            '': t('Todos', 'All', 'Todos'), 'apple': 'Apple', 'google': 'Google Play', 'mercadopago': 'Mercado Pago'}, onChanged: (v) => _set(() => _provider = v)),
          Select<String>(label: t('Situação', 'Status', 'Estado'), value: _status, items: {
            '': t('Todas', 'All', 'Todos'),
            'confirmed': _payStatus(t, 'confirmed'), 'partially_refunded': _payStatus(t, 'partially_refunded'),
            'refunded': _payStatus(t, 'refunded'), 'charged_back': _payStatus(t, 'charged_back')}, onChanged: (v) => _set(() => _status = v)),
          Select<String>(label: t('Plano', 'Plan', 'Plan'), value: _plan, items: {
            '': t('Todos', 'All', 'Todos'), 'monthly': planLabel(t, 'monthly'), 'annual': planLabel(t, 'annual')}, onChanged: (v) => _set(() => _plan = v)),
          Select<String>(label: t('Conciliação', 'Reconciliation', 'Conciliación'), value: _recon, items: {
            '': t('Todas', 'All', 'Todas'), 'pending': t('Taxas estimadas', 'Estimated fees', 'Tarifas estimadas'),
            'reconciled': t('Conciliado', 'Reconciled', 'Conciliado')}, onChanged: (v) => _set(() => _recon = v)),
          Loader<Map<String, dynamic>>(
            loader: () => api.partners(limit: 200),
            builder: (context, d, _) => Select<String>(
              label: t('Professor', 'Teacher', 'Profesor'),
              value: _partner,
              items: {'': t('Todos', 'All', 'Todos'), 'none': t('Sem indicação', 'No referral', 'Sin referido'),
                for (final p in (d['rows'] as List)) '${(p as Map)['id']}': '${p['display_name']}'},
              onChanged: (v) => _set(() => _partner = v),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _pickRange,
            icon: const Icon(Icons.date_range_rounded, size: 18),
            label: Text(_from == null ? t('Período', 'Period', 'Periodo') : '${t.date(_from)} – ${t.date(_to)}'),
          ),
          if (_from != null)
            IconButton(tooltip: t('Limpar', 'Clear', 'Limpiar'), onPressed: () => _set(() { _from = null; _to = null; }), icon: const Icon(Icons.close_rounded)),
          Select<String>(label: t('Ordenar', 'Sort', 'Ordenar'), value: _sort, items: {
            'paid_at': t('Data', 'Date', 'Fecha'), 'gross': t('Bruto', 'Gross', 'Bruto'), 'net': t('Líquido', 'Net', 'Neto'),
            'commission': t('Comissão', 'Commission', 'Comisión')}, onChanged: (v) => _set(() => _sort = v)),
          IconButton(
            tooltip: t('Inverter ordem', 'Reverse order', 'Invertir orden'),
            onPressed: () => _set(() => _dir = _dir == 'desc' ? 'asc' : 'desc'),
            icon: Icon(_dir == 'desc' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
          ),
          OutlinedButton.icon(
            onPressed: () => exportCsv(context, () => api.financeExport('payments', from: _from, to: _to, provider: n(_provider),
                partner: _partner.length == 36 ? _partner : null), 'pagamentos.csv'),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('CSV'),
          ),
        ]),
        const SizedBox(height: 12),
        Loader<Map<String, dynamic>>(
          loader: () => api.payments(search: n(_search), provider: n(_provider), status: n(_status), plan: n(_plan),
              partner: n(_partner), recon: n(_recon), from: _from, to: _to, sort: _sort, dir: _dir, limit: _limit, offset: _offset),
          keys: [_search, _provider, _status, _plan, _partner, _recon, _from, _to, _sort, _dir, _offset],
          builder: (context, d, _) {
            final rows = _l(d['rows']);
            if (rows.isEmpty) {
              return EmptyState(message: t('Nenhum pagamento encontrado.', 'No payments found.', 'No se encontraron pagos.'));
            }
            return Column(children: [
              PortalTable(
                columns: [
                  PortalColumn(t('Data', 'Date', 'Fecha')),
                  PortalColumn(t('Usuário', 'User', 'Usuario'), flex: 3),
                  PortalColumn(t('Provedor / plano', 'Provider / plan', 'Proveedor / plan'), flex: 2),
                  PortalColumn(t('Bruto', 'Gross', 'Bruto')),
                  PortalColumn(t('Taxas + imp.', 'Fees + tax', 'Tarifas + imp.')),
                  PortalColumn(t('Líquido', 'Net', 'Neto')),
                  PortalColumn(t('Professor / comissão', 'Teacher / commission', 'Profesor / comisión'), flex: 2),
                  PortalColumn(t('Lucksrei', 'Lucksrei', 'Lucksrei')),
                  PortalColumn(t('Situação', 'Status', 'Estado'), flex: 2),
                ],
                onTap: (i) => context.go('/partners/finance/payments/${rows[i]['id']}'),
                rows: [
                  for (final r in rows)
                    [
                      Text(t.dateOf(r['paid_at'])),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${r['user_name'] ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('${r['user_email'] ?? ''}', style: const TextStyle(fontSize: 12)),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(providerLabel('${r['provider']}')),
                        Text('${planLabel(t, r['plan'] as String?)} · ${r['external_id']}', style: const TextStyle(fontSize: 11)),
                      ]),
                      Text(t.money(_n(r, 'gross_cents'))),
                      Text(t.money(_n(r, 'fee_cents') + _n(r, 'tax_cents'))),
                      Text(t.money(_n(r, 'net_cents'))),
                      r['partner_id'] == null
                          ? const Text('—')
                          : Text('${r['partner_name']} · ${t.bps(_n(r, 'commission_bps'))}\n${t.money(_n(r, 'commission_cents'))}'),
                      Text(t.money(_n(r, 'lucksrei_cents'))),
                      Wrap(spacing: 4, runSpacing: 4, children: [
                        StatusBadge(_payStatus(t, '${r['status']}'), tone: _payTone('${r['status']}')),
                        _recon(t, r),
                        Text(_settle(t, r), style: const TextStyle(fontSize: 11)),
                      ]),
                    ],
                ],
              ),
              Pager(total: (d['total'] as num).toInt(), offset: _offset, limit: _limit, onPage: (o) => setState(() => _offset = o)),
            ]);
          },
        ),
      ]),
    );
  }
}

class PaymentDetailPage extends StatelessWidget {
  const PaymentDetailPage({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextButton.icon(onPressed: () => context.go('/partners/finance'), icon: const Icon(Icons.arrow_back_rounded, size: 18), label: Text(t('Financeiro', 'Finance', 'Finanzas'))),
      Loader<Map<String, dynamic>>(
        loader: () => api.payment(id),
        keys: [id],
        builder: (context, d, _) {
          final p = _m(d['payment']);
          final b = _m(d['base']);
          final refunds = _l(d['refunds']);
          final adjs = _l(d['adjustments']);
          final ledger = _l(d['ledger']);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PageHeader(title: '${providerLabel('${p['provider']}')} · ${p['external_id']}', subtitle: t('Registro do provedor: somente leitura', 'Provider record: read only', 'Registro del proveedor: solo lectura')),
            Panel(
              child: Column(children: [
                KeyValue(t('Usuário', 'User', 'Usuario'), Text('${p['user_name'] ?? '—'} · ${p['user_email'] ?? ''}')),
                KeyValue(t('Data', 'Date', 'Fecha'), Text(t.dateTimeOf(p['paid_at']))),
                KeyValue(t('Plano', 'Plan', 'Plan'), Text(planLabel(t, p['plan'] as String?))),
                KeyValue(t('Situação', 'Status', 'Estado'), Wrap(spacing: 6, children: [StatusBadge(_payStatus(t, '${p['status']}'), tone: _payTone('${p['status']}')), _recon(t, p)])),
                KeyValue(t('Liquidação', 'Settlement', 'Liquidación'), Text(p['settlement_status'] == 'settled' ? '${t('Liquidado', 'Settled', 'Liquidado')}: ${t.money(_n(p, 'settled_cents'))} · ${t.dateOf(p['settled_at'])}' : _settle(t, p))),
                KeyValue(t('Bruto', 'Gross', 'Bruto'), Text(t.money(_n(p, 'gross_cents')))),
                KeyValue(t('Taxas', 'Fees', 'Tarifas'), Text('${t.money(_n(p, 'fee_cents'))} (${p['fee_source'] == 'estimated' ? t('estimada', 'estimated', 'estimada') : t('informada', 'reported', 'informada')})')),
                KeyValue(t('Impostos', 'Taxes', 'Impuestos'), Text('${t.money(_n(p, 'tax_cents'))} (${p['tax_source'] == 'estimated' ? t('estimado', 'estimated', 'estimado') : t('registrado', 'recorded', 'registrado')})')),
                KeyValue(t('Líquido', 'Net', 'Neto'), Text(t.money(_n(p, 'net_cents')))),
                KeyValue(t('Professor', 'Teacher', 'Profesor'), Text(p['partner_id'] == null ? t('Sem indicação', 'No referral', 'Sin referido') : '${p['partner_name']} · ${t.bps(_n(p, 'commission_bps'))} ${t('(vigente na data do pagamento)', '(in force on the payment date)', '(vigente en la fecha del pago)')}')),
                KeyValue(t('Comissão', 'Commission', 'Comisión'), Text(t.money(_n(p, 'commission_cents')))),
                KeyValue(t('Receita da Lucksrei', 'Lucksrei revenue', 'Ingresos de Lucksrei'), Text(t.money(_n(p, 'lucksrei_cents')))),
                KeyValue(t('Valores originais', 'Original amounts', 'Valores originales'), Text('${t('taxas', 'fees', 'tarifas')} ${t.money(_n(b, 'fee_cents'))} · ${t('imp.', 'tax', 'imp.')} ${t.money(_n(b, 'tax_cents'))} · ${t('comissão', 'commission', 'comisión')} ${t.money(_n(b, 'commission_cents'))}')),
              ]),
            ),
            const SizedBox(height: 16),
            Panel(
              title: t('Reembolsos e estornos', 'Refunds and chargebacks', 'Reembolsos y contracargos'),
              child: refunds.isEmpty
                  ? EmptyState(message: t('Nenhum reembolso.', 'No refunds.', 'Sin reembolsos.'))
                  : PortalTable(
                      columns: [PortalColumn(t('Data', 'Date', 'Fecha')), PortalColumn(t('Tipo', 'Type', 'Tipo')), PortalColumn(t('Valor', 'Amount', 'Valor')), PortalColumn(t('Comissão revertida', 'Commission reversed', 'Comisión revertida')), PortalColumn(t('Lançado', 'Posted', 'Registrado'))],
                      rows: [for (final r in refunds) [Text(t.dateOf(r['at'])), Text(r['kind'] == 'chargeback' ? 'Chargeback' : t('Reembolso', 'Refund', 'Reembolso')), Text(t.money(_n(r, 'gross_cents'))), Text(t.money(_n(r, 'commission_reversed_cents'))), Text(r['ledgered'] == true ? t('Sim', 'Yes', 'Sí') : t('Aguarda conciliação', 'Awaits reconciliation', 'Espera conciliación'))]],
                    ),
            ),
            const SizedBox(height: 16),
            Panel(
              title: t('Ajustes de taxas/impostos', 'Fee/tax adjustments', 'Ajustes de tarifas/impuestos'),
              child: adjs.isEmpty
                  ? EmptyState(message: t('Nenhum ajuste.', 'No adjustments.', 'Sin ajustes.'))
                  : PortalTable(
                      columns: [PortalColumn(t('Data', 'Date', 'Fecha')), PortalColumn(t('Tipo', 'Type', 'Tipo')), PortalColumn(t('Custo', 'Cost', 'Costo')), PortalColumn(t('Efeito na comissão', 'Commission effect', 'Efecto en la comisión'))],
                      rows: [for (final r in adjs) [Text(t.dateOf(r['at'])), Text(r['kind'] == 'tax' ? t('Imposto', 'Tax', 'Impuesto') : t('Taxa', 'Fee', 'Tarifa')), Text(t.money(_n(r, 'delta_cents'))), Text(t.money(_n(r, 'commission_delta_cents')))]],
                    ),
            ),
            const SizedBox(height: 16),
            Panel(
              title: t('Razão do professor (este pagamento)', 'Teacher ledger (this payment)', 'Libro del profesor (este pago)'),
              child: ledger.isEmpty
                  ? EmptyState(message: t('Sem lançamentos.', 'No entries.', 'Sin asientos.'))
                  : PortalTable(
                      columns: [PortalColumn(t('Data', 'Date', 'Fecha')), PortalColumn(t('Tipo', 'Type', 'Tipo'), flex: 2), PortalColumn(t('Competência', 'Competence', 'Competencia')), PortalColumn(t('Valor', 'Amount', 'Valor'))],
                      rows: [for (final r in ledger) [Text(t.dateOf(r['at'])), Text(ledgerKindLabel(t, '${r['kind']}')), Text('${r['competence']}'.substring(0, 7)), Text(t.money(_n(r, 'amount_cents')))]],
                    ),
            ),
          ]);
        },
      ),
    ]);
  }
}

// ───────────────────────── Repasses ─────────────────────────

class _PayoutsTab extends StatefulWidget {
  const _PayoutsTab();
  @override
  State<_PayoutsTab> createState() => _PayoutsTabState();
}

class _PayoutsTabState extends State<_PayoutsTab> {
  late DateTime _comp = _month(DateTime.now(), -1); // no dia 01: mês anterior
  String _search = '';
  int _reload = 0, _histOffset = 0;

  Future<void> _copyPix(PortalApi api, Map<String, dynamic> r) async {
    final t = PortalStrings.read(context);
    final ok = await confirmDialog(context,
        title: t('Copiar chave Pix?', 'Copy Pix key?', '¿Copiar clave Pix?'),
        message: t('A chave completa de ${r['name']} será copiada e o acesso fica registrado na auditoria.',
            'The full Pix key of ${r['name']} will be copied and the access is logged in the audit trail.',
            'La clave Pix completa de ${r['name']} se copiará y el acceso queda registrado en la auditoría.'),
        action: t('Copiar', 'Copy', 'Copiar'));
    if (!ok || !mounted) return;
    try {
      final k = await api.partnerPix('${r['id']}');
      await Clipboard.setData(ClipboardData(text: '${k['key']}'));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Chave Pix copiada.', 'Pix key copied.', 'Clave Pix copiada.'))));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorText(t, e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    final months = [for (var i = 0; i < 18; i++) _month(DateTime.now(), -i)];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Panel(
        title: t('Fechamento mensal', 'Monthly closing', 'Cierre mensual'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Select<String>(
              label: t('Competência', 'Competence', 'Competencia'),
              value: _ym(_comp),
              items: {for (final m in months) _ym(m): _ym(m)},
              onChanged: (v) => setState(() => _comp = months.firstWhere((m) => _ym(m) == v)),
            ),
            SearchBox(hint: t('Professor', 'Teacher', 'Profesor'), onChanged: (v) => setState(() => _search = v)),
            OutlinedButton.icon(
              onPressed: () => exportCsv(context, () => api.financeExport('commissions'), 'comissoes.csv'),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(t('Comissões CSV', 'Commissions CSV', 'Comisiones CSV')),
            ),
            OutlinedButton.icon(
              onPressed: () => exportCsv(context, () => api.financeExport('payouts'), 'repasses.csv'),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(t('Repasses CSV', 'Payouts CSV', 'Pagos CSV')),
            ),
          ]),
          const SizedBox(height: 12),
          Loader<Map<String, dynamic>>(
            loader: () => api.closing(_comp, search: _search.isEmpty ? null : _search, limit: 100),
            keys: [_comp, _search, _reload],
            builder: (context, d, reload) {
              final rows = _l(d['rows']);
              if (rows.isEmpty) {
                return EmptyState(message: t('Nenhum professor com lançamentos até esta competência.', 'No teacher has entries up to this competence.', 'Ningún profesor con asientos hasta esta competencia.'));
              }
              String state(Map r) {
                final av = _n(r, 'available'), paid = _n(r, 'paid_cents');
                if (av <= 0 && paid > 0) return t('Pago', 'Paid', 'Pagado');
                if (av > 0 && paid > 0) return t('Parcial', 'Partial', 'Parcial');
                if (av > 0) return t('Pendente', 'Pending', 'Pendiente');
                return av < 0 ? t('Saldo negativo', 'Negative balance', 'Saldo negativo') : '—';
              }
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('${t('Total disponível', 'Total available', 'Total disponible')}: ${t.money(_n(d, 'sum_available_cents'))}',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
                PortalTable(
                  columns: [
                    PortalColumn(t('Professor', 'Teacher', 'Profesor'), flex: 3),
                    PortalColumn(t('Acumulado anterior', 'Carried over', 'Acumulado anterior'), flex: 2),
                    PortalColumn(t('Comissão do mês', 'Month commission', 'Comisión del mes'), flex: 2),
                    PortalColumn(t('Ajustes', 'Adjustments', 'Ajustes')),
                    PortalColumn(t('Já repassado', 'Already paid', 'Ya pagado')),
                    PortalColumn(t('Disponível', 'Available', 'Disponible')),
                    PortalColumn(t('Situação', 'Status', 'Estado')),
                    PortalColumn(t('Ações', 'Actions', 'Acciones'), flex: 3),
                  ],
                  rows: [
                    for (final r in rows)
                      [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${r['name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(r['has_pix'] == true ? 'Pix ${r['pix_masked']}' : t('Sem chave Pix', 'No Pix key', 'Sin clave Pix'), style: const TextStyle(fontSize: 11)),
                          if (_n(r, 'pending_reconciliation_cents') > 0)
                            StatusBadge('${t('A conciliar', 'To reconcile', 'Por conciliar')}: ${t.money(_n(r, 'pending_reconciliation_cents'))}', tone: Tone.warn),
                        ]),
                        Text(t.money(_n(r, 'carry_cents'))),
                        Text(t.money(_n(r, 'commissions_cents'))),
                        Text(t.money(_n(r, 'adjustments_cents'))),
                        Text(t.money(_n(r, 'paid_cents'))),
                        Text(t.money(_n(r, 'available')), style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(state(r)),
                        Wrap(spacing: 4, runSpacing: 4, children: [
                          if (r['has_pix'] == true)
                            IconButton(tooltip: t('Copiar chave Pix', 'Copy Pix key', 'Copiar clave Pix'), onPressed: () => _copyPix(api, r), icon: const Icon(Icons.copy_rounded, size: 18)),
                          if (_n(r, 'available') > 0)
                            ElevatedButton(
                              onPressed: () async {
                                final done = await showDialog<bool>(context: context, builder: (_) => _PayoutDialog(api: api, row: r, competence: _comp));
                                if (done == true) setState(() => _reload++);
                              },
                              child: Text(t('Registrar repasse', 'Register payout', 'Registrar pago')),
                            ),
                          TextButton(onPressed: () => context.go('/partners/finance/teachers/${r['id']}'), child: Text(t('Extrato', 'Statement', 'Extracto'))),
                        ]),
                      ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  t(
                    'Disponível = tudo o que foi conquistado até esta competência menos repasses já registrados. O portal só REGISTRA o Pix que você fez no banco; nada é enviado automaticamente. Saldos antigos nunca são apagados ao virar o mês.',
                    'Available = everything earned up to this competence minus payouts already registered. The portal only RECORDS the Pix you made at your bank; nothing is sent automatically. Old balances are never erased when the month turns.',
                    'Disponible = todo lo ganado hasta esta competencia menos los pagos ya registrados. El portal solo REGISTRA el Pix que hiciste en el banco; nada se envía automáticamente. Los saldos antiguos nunca se borran al cambiar de mes.',
                  ),
                  style: const TextStyle(fontSize: 11),
                ),
              ]);
            },
          ),
        ]),
      ),
      const SizedBox(height: 16),
      Panel(
        title: t('Histórico de repasses', 'Payout history', 'Historial de pagos'),
        child: Loader<Map<String, dynamic>>(
          loader: () => api.payouts(limit: 25, offset: _histOffset),
          keys: [_reload, _histOffset],
          builder: (context, d, reload) {
            final rows = _l(d['rows']);
            if (rows.isEmpty) return EmptyState(message: t('Nenhum repasse registrado.', 'No payouts recorded.', 'Ningún pago registrado.'));
            return Column(children: [
              PortalTable(
                columns: [
                  PortalColumn(t('Data do Pix', 'Pix date', 'Fecha del Pix')),
                  PortalColumn(t('Professor', 'Teacher', 'Profesor'), flex: 2),
                  PortalColumn(t('Competência', 'Competence', 'Competencia')),
                  PortalColumn(t('Valor', 'Amount', 'Valor')),
                  PortalColumn(t('Referência / obs.', 'Reference / note', 'Referencia / obs.'), flex: 3),
                  PortalColumn(t('Situação', 'Status', 'Estado')),
                  PortalColumn(''),
                ],
                rows: [
                  for (final r in rows)
                    [
                      Text(t.dateOf(r['paid_at'])),
                      Text('${r['partner_name']}'),
                      Text('${r['competence']}'.substring(0, 7)),
                      Text(t.money(_n(r, 'amount_cents'))),
                      Text([if (r['reference'] != null) '${r['reference']}', if (r['note'] != null) '${r['note']}', if (r['reverse_reason'] != null) '↩ ${r['reverse_reason']}'].join(' · ')),
                      StatusBadge(r['status'] == 'paid' ? t('Pago', 'Paid', 'Pagado') : t('Revertido', 'Reversed', 'Revertido'), tone: r['status'] == 'paid' ? Tone.good : Tone.bad),
                      r['status'] == 'paid'
                          ? TextButton(
                              onPressed: () async {
                                final done = await showDialog<bool>(context: context, builder: (_) => _ReverseDialog(api: api, payout: r));
                                if (done == true) setState(() => _reload++);
                              },
                              child: Text(t('Reverter', 'Reverse', 'Revertir')),
                            )
                          : const SizedBox.shrink(),
                    ],
                ],
              ),
              Pager(total: (d['total'] as num).toInt(), offset: _histOffset, limit: 25, onPage: (o) => setState(() => _histOffset = o)),
            ]);
          },
        ),
      ),
    ]);
  }
}

/// Registrar repasse: valor padrão = disponível; chave de idempotência gerada
/// ao abrir o diálogo (clique duplo / reenvio não duplica).
class _PayoutDialog extends StatefulWidget {
  const _PayoutDialog({required this.api, required this.row, required this.competence});
  final PortalApi api;
  final Map<String, dynamic> row;
  final DateTime competence;
  @override
  State<_PayoutDialog> createState() => _PayoutDialogState();
}

class _PayoutDialogState extends State<_PayoutDialog> {
  late final TextEditingController _amount = TextEditingController(text: centsInput(_n(widget.row, 'available').toInt()));
  final _ref = TextEditingController();
  final _note = TextEditingController();
  late final String _key = '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
  DateTime _date = DateTime.now();
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _ref.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = PortalStrings.read(context);
    final cents = parseCents(_amount.text);
    final avail = _n(widget.row, 'available').toInt();
    if (cents == null || cents <= 0 || cents > avail) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Informe um valor entre R\$ 0,01 e o disponível.', 'Enter an amount between R\$ 0.01 and the available balance.', 'Indica un valor entre R\$ 0,01 y el disponible.'))));
      return;
    }
    final ok = await confirmDialog(context,
        title: t('Registrar repasse?', 'Register payout?', '¿Registrar pago?'),
        message: t(
          'Confirma que você JÁ fez um Pix de ${PortalStrings.read(context).money(cents)} para ${widget.row['name']}? O portal apenas registra; não envia dinheiro.',
          'Do you confirm you ALREADY sent a Pix of ${PortalStrings.read(context).money(cents)} to ${widget.row['name']}? The portal only records it; it does not send money.',
          '¿Confirmas que YA hiciste un Pix de ${PortalStrings.read(context).money(cents)} a ${widget.row['name']}? El portal solo lo registra; no envía dinero.',
        ),
        action: t('Registrar', 'Register', 'Registrar'));
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final done = await runAction(
      context,
      () => widget.api.registerPayout(
        partner: '${widget.row['id']}', cents: cents, competence: widget.competence, paidAt: _date,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        reference: _ref.text.trim().isEmpty ? null : _ref.text.trim(), key: _key),
      success: t('Repasse registrado.', 'Payout registered.', 'Pago registrado.'),
    );
    if (!mounted) return;
    if (done) {
      Navigator.pop(context, true);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    return AlertDialog(
      title: Text('${t('Registrar repasse', 'Register payout', 'Registrar pago')} · ${widget.row['name']}'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${t('Disponível', 'Available', 'Disponible')}: ${t.money(_n(widget.row, 'available'))} · ${t('competência', 'competence', 'competencia')} ${_ym(widget.competence)}'),
            const SizedBox(height: 10),
            Field(label: t('Valor pago (R\$)', 'Amount paid (R\$)', 'Valor pagado (R\$)'), controller: _amount, keyboard: const TextInputType.numberWithOptions(decimal: true)),
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2025), lastDate: DateTime.now());
                if (d != null) setState(() => _date = d);
              },
              icon: const Icon(Icons.event_rounded, size: 18),
              label: Text('${t('Data do Pix', 'Pix date', 'Fecha del Pix')}: ${t.date(_date)}'),
            ),
            const SizedBox(height: 10),
            Field(label: t('Referência do Pix (opcional)', 'Pix reference (optional)', 'Referencia del Pix (opcional)'), controller: _ref),
            Field(label: t('Observação (opcional)', 'Note (optional)', 'Observación (opcional)'), controller: _note, maxLines: 2),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context, false), child: Text(t('Cancelar', 'Cancel', 'Cancelar'))),
        ElevatedButton(onPressed: _busy ? null : _submit, child: Text(t('Continuar', 'Continue', 'Continuar'))),
      ],
    );
  }
}

class _ReverseDialog extends StatefulWidget {
  const _ReverseDialog({required this.api, required this.payout});
  final PortalApi api;
  final Map<String, dynamic> payout;
  @override
  State<_ReverseDialog> createState() => _ReverseDialogState();
}

class _ReverseDialogState extends State<_ReverseDialog> {
  final _reason = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = PortalStrings.read(context);
    if (_reason.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Informe o motivo (mín. 5 caracteres).', 'Enter the reason (min. 5 characters).', 'Indica el motivo (mín. 5 caracteres).'))));
      return;
    }
    final ok = await confirmDialog(context,
        title: t('Reverter este repasse?', 'Reverse this payout?', '¿Revertir este pago?'),
        message: t('O saldo do professor volta a incluir ${PortalStrings.read(context).money(_n(widget.payout, 'amount_cents'))}. Isto NÃO desfaz um Pix já realizado no banco, e o registro original é preservado.',
            'The teacher balance includes ${PortalStrings.read(context).money(_n(widget.payout, 'amount_cents'))} again. This does NOT undo a Pix already made at the bank, and the original record is kept.',
            'El saldo del profesor vuelve a incluir ${PortalStrings.read(context).money(_n(widget.payout, 'amount_cents'))}. Esto NO deshace un Pix ya hecho en el banco y el registro original se conserva.'),
        action: t('Reverter', 'Reverse', 'Revertir'),
        danger: true);
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final done = await runAction(context, () => widget.api.reversePayout('${widget.payout['id']}', _reason.text.trim()),
        success: t('Repasse revertido.', 'Payout reversed.', 'Pago revertido.'));
    if (!mounted) return;
    if (done) {
      Navigator.pop(context, true);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    return AlertDialog(
      title: Text(t('Reverter repasse', 'Reverse payout', 'Revertir pago')),
      content: SizedBox(width: 420, child: Field(label: t('Motivo', 'Reason', 'Motivo'), controller: _reason, maxLines: 3)),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context, false), child: Text(t('Cancelar', 'Cancel', 'Cancelar'))),
        TextButton(onPressed: _busy ? null : _submit, child: Text(t('Continuar', 'Continue', 'Continuar'))),
      ],
    );
  }
}

// ───────────────────────── Extrato de um professor ─────────────────────────

class PartnerCommissionsPage extends StatefulWidget {
  const PartnerCommissionsPage({required this.id, super.key});
  final String id;
  @override
  State<PartnerCommissionsPage> createState() => _PartnerCommissionsState();
}

class _PartnerCommissionsState extends State<PartnerCommissionsPage> {
  static const _limit = 25;
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextButton.icon(onPressed: () => context.go('/partners/finance'), icon: const Icon(Icons.arrow_back_rounded, size: 18), label: Text(t('Financeiro', 'Finance', 'Finanzas'))),
      Loader<Map<String, dynamic>>(
        loader: () => api.partnerCommissions(widget.id, limit: _limit, offset: _offset),
        keys: [widget.id, _offset],
        builder: (context, d, _) {
          final p = _m(d['partner']);
          final s = _m(d['summary']);
          final hist = _l(d['bps_history']);
          final comp = _l(d['by_competence']);
          final ledger = _l(d['ledger']);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PageHeader(
              title: '${p['name']}',
              subtitle: '${t('Percentual atual', 'Current rate', 'Porcentaje actual')}: ${t.bps(_n(p, 'commission_bps'))} · ${p['pix_masked'] == null ? t('sem Pix', 'no Pix', 'sin Pix') : 'Pix ${p['pix_masked']}'}',
              actions: [
                OutlinedButton.icon(
                  onPressed: () => exportCsv(context, () => api.financeExport('commissions', partner: widget.id), 'comissoes-professor.csv'),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('CSV'),
                ),
              ],
            ),
            _section(t('Resumo', 'Summary', 'Resumen'), [
              StatCard(label: t('Saldo disponível', 'Available balance', 'Saldo disponible'), value: t.money(_n(s, 'balance_cents'))),
              StatCard(label: t('Comissões geradas', 'Commissions generated', 'Comisiones generadas'), value: t.money(_n(s, 'commissions_cents')), hint: '${t.number(_n(s, 'payments_count'))} ${t('pagamentos originados', 'payments originated', 'pagos originados')}'),
              StatCard(label: t('Ajustes (+/−)', 'Adjustments (+/−)', 'Ajustes (+/−)'), value: t.money(_n(s, 'adjustments_cents'))),
              StatCard(label: t('Total repassado', 'Total paid out', 'Total pagado'), value: t.money(_n(s, 'received_cents'))),
              StatCard(label: t('Pendente de conciliação', 'Pending reconciliation', 'Pendiente de conciliación'), value: t.money(_n(s, 'pending_reconciliation_cents'))),
            ]),
            Panel(
              title: t('Histórico de percentual', 'Rate history', 'Historial de porcentaje'),
              child: PortalTable(
                columns: [PortalColumn(t('Vigente desde', 'In force since', 'Vigente desde')), PortalColumn(t('Percentual', 'Rate', 'Porcentaje')), PortalColumn(t('Situação', 'Status', 'Estado'))],
                rows: [for (final h in hist) [Text(t.dateTimeOf(h['from'])), Text(t.bps(_n(h, 'commission_bps'))), Text('${h['status']}')]],
              ),
            ),
            const SizedBox(height: 16),
            Panel(
              title: t('Por competência', 'By competence', 'Por competencia'),
              child: comp.isEmpty
                  ? EmptyState(message: t('Sem movimentações.', 'No movements.', 'Sin movimientos.'))
                  : PortalTable(
                      columns: [PortalColumn(t('Competência', 'Competence', 'Competencia')), PortalColumn(t('Comissões', 'Commissions', 'Comisiones')), PortalColumn(t('Ajustes', 'Adjustments', 'Ajustes')), PortalColumn(t('Repasses', 'Payouts', 'Pagos')), PortalColumn(t('Saldo', 'Balance', 'Saldo'))],
                      rows: [for (final r in comp) [Text('${r['competence']}'.substring(0, 7)), Text(t.money(_n(r, 'commissions_cents'))), Text(t.money(_n(r, 'adjustments_cents'))), Text(t.money(_n(r, 'payouts_cents'))), Text(t.money(_n(r, 'balance_cents')))]],
                    ),
            ),
            const SizedBox(height: 16),
            Panel(
              title: t('Razão (imutável)', 'Ledger (immutable)', 'Libro (inmutable)'),
              child: ledger.isEmpty
                  ? EmptyState(message: t('Sem lançamentos.', 'No entries.', 'Sin asientos.'))
                  : Column(children: [
                      PortalTable(
                        columns: [PortalColumn(t('Data', 'Date', 'Fecha')), PortalColumn(t('Tipo', 'Type', 'Tipo'), flex: 2), PortalColumn(t('Competência', 'Competence', 'Competencia')), PortalColumn(t('Valor', 'Amount', 'Valor')), PortalColumn(t('Obs.', 'Note', 'Obs.'), flex: 2)],
                        onTap: (i) {
                          final id = ledger[i]['payment_id'];
                          if (id != null) context.go('/partners/finance/payments/$id');
                        },
                        rows: [for (final r in ledger) [Text(t.dateOf(r['at'])), Text(ledgerKindLabel(t, '${r['kind']}')), Text('${r['competence']}'.substring(0, 7)), Text(t.money(_n(r, 'amount_cents'))), Text('${r['note'] ?? ''}')]],
                      ),
                      Pager(total: (d['ledger_total'] as num).toInt(), offset: _offset, limit: _limit, onPage: (o) => setState(() => _offset = o)),
                    ]),
            ),
          ]);
        },
      ),
    ]);
  }
}

// ───────────────────────── Despesas ─────────────────────────

class _ExpensesTab extends StatefulWidget {
  const _ExpensesTab();
  @override
  State<_ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<_ExpensesTab> with PeriodState {
  int _reload = 0, _offset = 0;
  String _cat = '';

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    final r = range;
    return Panel(
      child: Loader<Map<String, dynamic>>(
        loader: () => api.expenses(from: r.start, to: r.end, category: _cat.isEmpty ? null : _cat, limit: 25, offset: _offset),
        keys: [r.start, r.end, _cat, _reload, _offset],
        builder: (context, d, _) {
          final rows = _l(d['rows']);
          final cats = _l(d['categories']);
          Future<void> edit([Map<String, dynamic>? e]) async {
            final done = await showDialog<bool>(context: context, builder: (_) => _ExpenseDialog(api: api, categories: cats, expense: e));
            if (done == true) setState(() => _reload++);
          }
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
              periodSelect(t),
              Select<String>(label: t('Categoria', 'Category', 'Categoría'), value: _cat, items: {'': t('Todas', 'All', 'Todas'), for (final c in cats) '${c['id']}': '${c['name']}'}, onChanged: (v) => setState(() { _cat = v; _offset = 0; })),
              ElevatedButton.icon(onPressed: () => edit(), icon: const Icon(Icons.add_rounded, size: 18), label: Text(t('Nova despesa', 'New expense', 'Nuevo gasto'))),
              OutlinedButton.icon(
                onPressed: () async {
                  final c = TextEditingController();
                  final name = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(t('Nova categoria', 'New category', 'Nueva categoría')),
                      content: Field(label: t('Nome', 'Name', 'Nombre'), controller: c),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t('Cancelar', 'Cancel', 'Cancelar'))),
                        TextButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: Text(t('Salvar', 'Save', 'Guardar'))),
                      ],
                    ),
                  );
                  if (name != null && name.isNotEmpty && context.mounted && await runAction(context, () => api.addExpenseCategory(name))) {
                    setState(() => _reload++);
                  }
                },
                icon: const Icon(Icons.label_outline_rounded, size: 18),
                label: Text(t('Categoria', 'Category', 'Categoría')),
              ),
              OutlinedButton.icon(
                onPressed: () => exportCsv(context, () => api.financeExport('expenses', from: r.start, to: r.end), 'despesas.csv'),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('CSV'),
              ),
            ]),
            const SizedBox(height: 8),
            Text('${t('Total no período', 'Total in period', 'Total en el periodo')}: ${t.money(_n(d, 'sum_cents'))}', style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if (rows.isEmpty)
              EmptyState(message: t('Nenhuma despesa no período.', 'No expenses in the period.', 'Sin gastos en el periodo.'))
            else ...[
              PortalTable(
                columns: [
                  PortalColumn(t('Data', 'Date', 'Fecha')),
                  PortalColumn(t('Categoria', 'Category', 'Categoría'), flex: 2),
                  PortalColumn(t('Descrição', 'Description', 'Descripción'), flex: 3),
                  PortalColumn(t('Valor', 'Amount', 'Valor')),
                  PortalColumn(''),
                ],
                rows: [
                  for (final e in rows)
                    [
                      Text(t.dateOf(e['expense_date'])),
                      Text('${e['category']}'),
                      Text('${e['description']}${e['note'] == null ? '' : '\n${e['note']}'}'),
                      Text(t.money(_n(e, 'amount_cents'))),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(tooltip: t('Editar', 'Edit', 'Editar'), onPressed: () => edit(e), icon: const Icon(Icons.edit_outlined, size: 18)),
                        IconButton(
                          tooltip: t('Excluir', 'Delete', 'Eliminar'),
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          onPressed: () async {
                            final ok = await confirmDialog(context,
                                title: t('Excluir despesa?', 'Delete expense?', '¿Eliminar gasto?'),
                                message: t('A despesa sai dos totais; o histórico de alterações é preservado.', 'The expense leaves the totals; the change history is preserved.', 'El gasto sale de los totales; el historial de cambios se conserva.'),
                                action: t('Excluir', 'Delete', 'Eliminar'), danger: true);
                            if (ok && context.mounted && await runAction(context, () => api.voidExpense('${e['id']}', 'excluída pelo administrador'))) {
                              setState(() => _reload++);
                            }
                          },
                        ),
                      ]),
                    ],
                ],
              ),
              Pager(total: (d['total'] as num).toInt(), offset: _offset, limit: 25, onPage: (o) => setState(() => _offset = o)),
            ],
            const SizedBox(height: 8),
            Text(
              t('Despesas reduzem o lucro da Lucksrei; nunca alteram comissões de professores.',
                  'Expenses reduce Lucksrei profit; they never change teacher commissions.',
                  'Los gastos reducen la ganancia de Lucksrei; nunca alteran las comisiones de profesores.'),
              style: const TextStyle(fontSize: 11),
            ),
          ]);
        },
      ),
    );
  }
}

class _ExpenseDialog extends StatefulWidget {
  const _ExpenseDialog({required this.api, required this.categories, this.expense});
  final PortalApi api;
  final List<Map<String, dynamic>> categories;
  final Map<String, dynamic>? expense;
  @override
  State<_ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<_ExpenseDialog> {
  late final _desc = TextEditingController(text: '${widget.expense?['description'] ?? ''}');
  late final _amount = TextEditingController(text: widget.expense == null ? '' : centsInput(_n(widget.expense, 'amount_cents').toInt()));
  late final _note = TextEditingController(text: '${widget.expense?['note'] ?? ''}');
  late String _cat = '${widget.expense?['category_id'] ?? widget.categories.first['id']}';
  late DateTime _date = DateTime.tryParse('${widget.expense?['expense_date']}') ?? DateTime.now();
  bool _busy = false;

  @override
  void dispose() {
    _desc.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = PortalStrings.read(context);
    final cents = parseCents(_amount.text);
    if (cents == null || cents <= 0 || _desc.text.trim().length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Preencha descrição e valor válidos.', 'Fill in a valid description and amount.', 'Completa descripción y valor válidos.'))));
      return;
    }
    setState(() => _busy = true);
    final done = await runAction(
      context,
      () => widget.api.saveExpense(id: widget.expense?['id'] as String?, description: _desc.text.trim(), category: _cat, cents: cents, date: _date, note: _note.text.trim().isEmpty ? null : _note.text.trim()),
      success: t('Despesa salva.', 'Expense saved.', 'Gasto guardado.'),
    );
    if (!mounted) return;
    if (done) {
      Navigator.pop(context, true);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    return AlertDialog(
      title: Text(widget.expense == null ? t('Nova despesa', 'New expense', 'Nuevo gasto') : t('Editar despesa', 'Edit expense', 'Editar gasto')),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Field(label: t('Descrição', 'Description', 'Descripción'), controller: _desc),
            Select<String>(label: t('Categoria', 'Category', 'Categoría'), value: _cat, items: {for (final c in widget.categories) '${c['id']}': '${c['name']}'}, onChanged: (v) => setState(() => _cat = v)),
            const SizedBox(height: 10),
            Field(label: t('Valor (R\$)', 'Amount (R\$)', 'Valor (R\$)'), controller: _amount, keyboard: const TextInputType.numberWithOptions(decimal: true)),
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1)));
                if (d != null) setState(() => _date = d);
              },
              icon: const Icon(Icons.event_rounded, size: 18),
              label: Text('${t('Data', 'Date', 'Fecha')}: ${t.date(_date)}'),
            ),
            const SizedBox(height: 10),
            Field(label: t('Observação (opcional)', 'Note (optional)', 'Observación (opcional)'), controller: _note, maxLines: 2),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context, false), child: Text(t('Cancelar', 'Cancel', 'Cancelar'))),
        ElevatedButton(onPressed: _busy ? null : _save, child: Text(t('Salvar', 'Save', 'Guardar'))),
      ],
    );
  }
}
