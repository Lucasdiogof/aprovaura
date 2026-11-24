import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/widgets/portal_widgets.dart';

enum _Preset { today, d7, d30, month, lastMonth, custom }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  _Preset _preset = _Preset.d30;
  DateTimeRange? _custom;

  DateTimeRange _range() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_preset) {
      case _Preset.today:
        return DateTimeRange(start: today, end: today);
      case _Preset.d7:
        return DateTimeRange(start: today.subtract(const Duration(days: 6)), end: today);
      case _Preset.d30:
        return DateTimeRange(start: today.subtract(const Duration(days: 29)), end: today);
      case _Preset.month:
        return DateTimeRange(start: DateTime(now.year, now.month), end: today);
      case _Preset.lastMonth:
        return DateTimeRange(start: DateTime(now.year, now.month - 1), end: DateTime(now.year, now.month, 0));
      case _Preset.custom:
        return _custom ?? DateTimeRange(start: today.subtract(const Duration(days: 29)), end: today);
    }
  }

  Future<void> _pick(Object? v) async {
    final p = v as _Preset;
    if (p == _Preset.custom) {
      final now = DateTime.now();
      final r = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2025),
        lastDate: now,
        initialDateRange: _range(),
      );
      if (r == null) return;
      setState(() {
        _custom = r;
        _preset = p;
      });
      return;
    }
    setState(() => _preset = p);
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final range = _range();
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(
        title: t('Visão geral', 'Overview', 'Resumen'),
        subtitle: '${t.date(range.start)} – ${t.date(range.end)}',
        actions: [
          Select<_Preset>(
            label: t('Período', 'Period', 'Periodo'),
            value: _preset,
            items: {
              _Preset.today: t('Hoje', 'Today', 'Hoy'),
              _Preset.d7: t('Últimos 7 dias', 'Last 7 days', 'Últimos 7 días'),
              _Preset.d30: t('Últimos 30 dias', 'Last 30 days', 'Últimos 30 días'),
              _Preset.month: t('Mês atual', 'This month', 'Mes actual'),
              _Preset.lastMonth: t('Mês anterior', 'Last month', 'Mes anterior'),
              _Preset.custom: t('Personalizado…', 'Custom…', 'Personalizado…'),
            },
            onChanged: _pick,
          ),
        ],
      ),
      Loader<Map<String, dynamic>>(
        loader: () => api.dashboard(range.start, range.end),
        keys: [range.start, range.end],
        builder: (context, d, reload) => _Body(data: d),
      ),
    ]);
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data});
  final Map<String, dynamic> data;

  num _n(Map m, String k) => (m[k] as num?) ?? 0;

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final u = Map<String, dynamic>.from(data['users'] as Map);
    final s = Map<String, dynamic>.from(data['study'] as Map);
    final f = Map<String, dynamic>.from(data['finance'] as Map);
    final series = (data['series'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final trials = _n(u, 'trials_total');
    final conv = trials == 0 ? null : _n(u, 'paid_users_ever') / trials;
    final totalUsers = _n(u, 'total');

    Widget section(String title, List<Widget> cards) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
            CardGrid(children: cards),
          ]),
        );

    List<String> labels() => [for (final p in series) t.dateOf(p['date'])];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      section(t('Usuários', 'Users', 'Usuarios'), [
        StatCard(icon: Icons.people_outline_rounded, label: t('Total de usuários', 'Total users', 'Total de usuarios'), value: t.number(totalUsers)),
        StatCard(icon: Icons.person_add_alt_rounded, label: t('Novos no período', 'New in period', 'Nuevos en el periodo'), value: t.number(_n(u, 'new_in_period'))),
        StatCard(icon: Icons.mark_email_read_outlined, label: t('E-mails verificados', 'Verified e-mails', 'Correos verificados'), value: t.number(_n(u, 'verified_emails')), hint: t('Prova real de posse do e-mail', 'Proven mailbox ownership', 'Prueba real del correo')),
        StatCard(icon: Icons.bolt_rounded, label: t('Ativos no período', 'Active in period', 'Activos en el periodo'), value: t.number(_n(u, 'active_in_period')), hint: t('Estudo ou uso do app', 'Studying or app use', 'Estudio o uso de la app')),
        StatCard(icon: Icons.person_outline_rounded, label: t('Alunos com indicação', 'Students with referral', 'Alumnos con referido'), value: t.number(_n(u, 'students_with_referral'))),
        StatCard(icon: Icons.person_off_outlined, label: t('Sem indicação', 'Without referral', 'Sin referido'), value: t.number(_n(u, 'students_without_referral'))),
      ]),
      section(t('Acesso Premium', 'Premium access', 'Acceso Premium'), [
        StatCard(icon: Icons.workspace_premium_outlined, label: t('Premium ativo', 'Active Premium', 'Premium activo'), value: t.number(_n(u, 'premium_active')), hint: t('Inclui administradores e professores', 'Includes admins and teachers', 'Incluye administradores y profesores')),
        StatCard(label: t('Assinantes pagos', 'Paid subscribers', 'Suscriptores de pago'), value: t.number(_n(u, 'paid_active'))),
        StatCard(label: t('Em período de teste', 'In trial', 'En prueba'), value: t.number(_n(u, 'trial_active'))),
        StatCard(label: t('Testes expirados', 'Expired trials', 'Pruebas expiradas'), value: t.number(_n(u, 'trials_expired'))),
        StatCard(label: t('Assinaturas expiradas', 'Expired subscriptions', 'Suscripciones expiradas'), value: t.number(_n(u, 'subscriptions_expired'))),
        StatCard(label: t('Premium por cortesia', 'Courtesy Premium', 'Premium de cortesía'), value: t.number(_n(u, 'courtesy_active'))),
        StatCard(label: t('Professores ativos', 'Active teachers', 'Profesores activos'), value: t.number(_n(u, 'partners_active'))),
        StatCard(label: t('Professores inativos', 'Inactive teachers', 'Profesores inactivos'), value: t.number(_n(u, 'partners_inactive'))),
        StatCard(label: t('Conversão em assinatura', 'Subscription conversion', 'Conversión a suscripción'), value: t.percent(conv), hint: t('Assinantes ÷ quem teve teste', 'Subscribers ÷ trial users', 'Suscriptores ÷ con prueba')),
      ]),
      section(t('Estudo', 'Study', 'Estudio'), [
        StatCard(label: t('Questões respondidas', 'Questions answered', 'Preguntas respondidas'), value: t.number(_n(s, 'questions_total')), hint: '${t.number(_n(s, 'questions_in_period'))} ${t('no período', 'in period', 'en el periodo')}'),
        StatCard(label: t('Média de acertos', 'Average accuracy', 'Promedio de aciertos'), value: t.percent(s['accuracy_total'] as num?), hint: '${t.percent(s['accuracy_in_period'] as num?)} ${t('no período', 'in period', 'en el periodo')}'),
        StatCard(label: t('Redações corrigidas', 'Essays graded', 'Redacciones corregidas'), value: t.number(_n(s, 'essays_evaluated_total')), hint: '${t.number(_n(s, 'essays_evaluated_in_period'))} ${t('no período', 'in period', 'en el periodo')}'),
        StatCard(label: t('Simulados realizados', 'Mock exams taken', 'Simulacros realizados'), value: t.number(_n(s, 'mock_exams_finished_total')), hint: '${t.number(_n(s, 'mock_exams_finished_in_period'))} ${t('no período', 'in period', 'en el periodo')}'),
      ]),
      section(t('Financeiro (período)', 'Finance (period)', 'Finanzas (periodo)'), [
        StatCard(label: t('Faturamento bruto', 'Gross revenue', 'Facturación bruta'), value: t.money(_n(f, 'gross_cents')), hint: '${t.number(_n(f, 'payments_count'))} ${t('pagamentos', 'payments', 'pagos')}'),
        StatCard(label: t('Taxas', 'Fees', 'Tarifas'), value: t.money(_n(f, 'fee_cents'))),
        StatCard(label: t('Impostos registrados', 'Recorded taxes', 'Impuestos registrados'), value: t.money(_n(f, 'tax_cents'))),
        StatCard(label: t('Receita líquida', 'Net revenue', 'Ingresos netos'), value: t.money(_n(f, 'net_cents'))),
        StatCard(label: t('Comissões de professores', 'Teacher commissions', 'Comisiones de profesores'), value: t.money(_n(f, 'commission_cents'))),
        StatCard(label: t('Receita da Lucksrei', 'Lucksrei revenue', 'Ingresos de Lucksrei'), value: t.money(_n(f, 'lucksrei_cents')), hint: t('Antes de despesas operacionais; não é lucro.', 'Before operating expenses; not profit.', 'Antes de gastos operativos; no es ganancia.')),
        StatCard(label: t('Repasses pendentes', 'Pending payouts', 'Pagos pendientes'), value: t.money(_n(f, 'pending_payouts_cents')), hint: t('Saldo atual de todos os professores', 'Current balance, all teachers', 'Saldo actual de todos los profesores')),
        StatCard(label: t('Repasses realizados', 'Payouts made', 'Pagos realizados'), value: t.money(_n(f, 'paid_payouts_cents'))),
      ]),
      Panel(
        title: t('Evolução diária', 'Daily evolution', 'Evolución diaria'),
        child: series.isEmpty
            ? EmptyState(message: t('Sem dados no período.', 'No data in the period.', 'Sin datos en el periodo.'))
            : LayoutBuilder(builder: (context, box) {
                final List<(String, List<num>, String Function(num)?)> chart = [
                  (t('Cadastros', 'Sign-ups', 'Registros'), [for (final p in series) (p['signups'] as num)], null),
                  (t('Questões respondidas', 'Questions answered', 'Preguntas respondidas'), [for (final p in series) (p['answers'] as num)], null),
                  (t('Faturamento bruto', 'Gross revenue', 'Facturación bruta'), [for (final p in series) (p['gross_cents'] as num)], t.money),
                ];
                final wide = box.maxWidth >= kWide;
                Widget one(int i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16, right: 12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(chart[i].$1, style: const TextStyle(fontWeight: FontWeight.w600))),
                        BarChart(values: chart[i].$2, labels: labels(), format: chart[i].$3),
                      ]),
                    );
                return wide
                    ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [for (var i = 0; i < 3; i++) Expanded(child: one(i))])
                    : Column(children: [for (var i = 0; i < 3; i++) one(i)]);
              }),
      ),
    ]);
  }
}
