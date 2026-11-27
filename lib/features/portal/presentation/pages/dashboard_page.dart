import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/widgets/portal_widgets.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with PeriodState {
  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final range = this.range;
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(
        title: t('Visão geral', 'Overview', 'Resumen'),
        subtitle: '${t.date(range.start)} – ${t.date(range.end)}',
        actions: [
          periodSelect(t),
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

  num _n(Map<dynamic, dynamic> m, String k) => (m[k] as num?) ?? 0;

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
    final inPeriod = t('no período', 'in period', 'en el periodo');

    String new1(num n) => plural(t, n, one: 'novo', many: 'novos', oneEn: 'new', manyEn: 'new', oneEs: 'nuevo', manyEs: 'nuevos');
    List<String> labels() => [for (final p in series) t.dateOf(p['date'])];
    final pctStudents = totalUsers == 0 ? null : _n(u, 'students_with_referral') / totalUsers;

    Widget twoCols(Widget a, Widget b) => LayoutBuilder(
          builder: (context, box) => box.maxWidth >= kWide
              ? IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Expanded(child: a),
                    const SizedBox(width: kCardGap),
                    Expanded(child: b),
                  ]),
                )
              : Column(children: [a, const SizedBox(height: kCardGap), b]),
        );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CardGrid(minWidth: 260, maxColumns: 4, children: [
        HeroStat(
          icon: LucideIcons.users,
          label: t('Total de usuários', 'Total users', 'Total de usuarios'),
          value: t.number(totalUsers),
          hint: '${new1(_n(u, 'new_in_period'))} $inPeriod',
        ),
        HeroStat(
          icon: LucideIcons.creditCard,
          tone: Tone.good,
          label: t('Assinantes Premium pagos', 'Paid Premium subscribers', 'Suscriptores Premium de pago'),
          value: t.number(_n(u, 'paid_active')),
          hint: t('Compra real em Apple, Google ou Web', 'Real purchase on Apple, Google or Web', 'Compra real en Apple, Google o Web'),
        ),
        HeroStat(
          icon: LucideIcons.graduationCap,
          label: t('Professores parceiros ativos', 'Active partner teachers', 'Profesores socios activos'),
          value: t.number(_n(u, 'partners_active')),
          hint: plural(t, _n(u, 'partners_inactive'), one: 'inativo', many: 'inativos', oneEn: 'inactive', manyEn: 'inactive', oneEs: 'inactivo', manyEs: 'inactivos'),
        ),
        HeroStat(
          icon: LucideIcons.wallet,
          label: t('Receita da Lucksrei', 'Lucksrei revenue', 'Ingresos de Lucksrei'),
          value: t.money(_n(f, 'lucksrei_cents')),
          hint: t('Período; antes das despesas, não é lucro.', 'Period; before expenses, not profit.', 'Periodo; antes de gastos, no es ganancia.'),
        ),
      ]),
      SectionHeader(t('Usuários e crescimento', 'Users and growth', 'Usuarios y crecimiento')),
      MetricPanel(
        icon: LucideIcons.userPlus,
        title: t('Base de usuários', 'User base', 'Base de usuarios'),
        subtitle: t('Atividade e origem dos cadastros no período.', 'Activity and sign-up origin in the period.', 'Actividad y origen de los registros en el periodo.'),
        columns: 4,
        metrics: [
          Metric(t('Novos no período', 'New in period', 'Nuevos en el periodo'), t.number(_n(u, 'new_in_period'))),
          Metric(t('Ativos no período', 'Active in period', 'Activos en el periodo'), t.number(_n(u, 'active_in_period')),
              hint: t('Estudo ou uso do app', 'Studying or app use', 'Estudio o uso de la app')),
          Metric(t('Alunos com indicação', 'Students with referral', 'Alumnos con referido'), t.number(_n(u, 'students_with_referral')),
              hint: pctStudents == null ? null : '${t.percent(pctStudents)} ${t('da base', 'of the base', 'de la base')}'),
          Metric(t('E-mails verificados', 'Verified e-mails', 'Correos verificados'), t.number(_n(u, 'verified_emails')),
              hint: t('Prova real de posse do e-mail', 'Proven mailbox ownership', 'Prueba real del correo')),
        ],
        footer: DistributionBar(segments: [
          (label: t('Com indicação', 'With referral', 'Con referido'), value: _n(u, 'students_with_referral'), tone: Tone.info),
          (label: t('Sem indicação', 'Without referral', 'Sin referido'), value: _n(u, 'students_without_referral'), tone: Tone.neutral),
        ]),
      ),
      SectionHeader(t('Assinaturas', 'Subscriptions', 'Suscripciones'),
          subtitle: t('Acesso gratuito nunca entra na receita.', 'Free access never counts as revenue.', 'El acceso gratuito nunca cuenta como ingreso.')),
      MetricPanel(
        icon: LucideIcons.creditCard,
        title: t('Situação dos acessos Premium', 'Premium access status', 'Estado de los accesos Premium'),
        columns: 6,
        metrics: [
          Metric(t('Assinantes pagos', 'Paid subscribers', 'Suscriptores de pago'), t.number(_n(u, 'paid_active')), tone: Tone.good),
          Metric(t('Em período de teste', 'In trial', 'En prueba'), t.number(_n(u, 'trial_active'))),
          Metric(t('Premium por cortesia', 'Courtesy Premium', 'Premium de cortesía'), t.number(_n(u, 'courtesy_active'))),
          Metric(t('Conversão em assinatura', 'Subscription conversion', 'Conversión a suscripción'), t.percent(conv),
              hint: t('Assinantes ÷ quem teve teste', 'Subscribers ÷ trial users', 'Suscriptores ÷ con prueba')),
          Metric(t('Testes expirados', 'Expired trials', 'Pruebas expiradas'), t.number(_n(u, 'trials_expired'))),
          Metric(t('Assinaturas expiradas', 'Expired subscriptions', 'Suscripciones expiradas'), t.number(_n(u, 'subscriptions_expired'))),
        ],
        footer: DistributionBar(segments: [
          (label: t('Pagos', 'Paid', 'De pago'), value: _n(u, 'paid_active'), tone: Tone.good),
          (label: t('Em teste', 'Trial', 'Prueba'), value: _n(u, 'trial_active'), tone: Tone.warn),
          (label: t('Cortesia', 'Courtesy', 'Cortesía'), value: _n(u, 'courtesy_active'), tone: Tone.info),
          (
            label: t('Professores e administradores', 'Teachers and admins', 'Profesores y administradores'),
            value: (_n(u, 'premium_active') - _n(u, 'paid_active') - _n(u, 'trial_active') - _n(u, 'courtesy_active')).clamp(0, 1 << 30),
            tone: Tone.neutral,
          ),
        ]),
      ),
      SectionHeader(t('Engajamento e finanças', 'Engagement and finance', 'Participación y finanzas')),
      twoCols(
        MetricPanel(
          icon: LucideIcons.chartLine,
          title: t('Estudo', 'Study', 'Estudio'),
          columns: 2,
          metrics: [
            Metric(t('Questões respondidas', 'Questions answered', 'Preguntas respondidas'), t.number(_n(s, 'questions_total')),
                hint: '${t.number(_n(s, 'questions_in_period'))} $inPeriod'),
            Metric(t('Média de acertos', 'Average accuracy', 'Promedio de aciertos'), t.percent(s['accuracy_total'] as num?),
                hint: '${t.percent(s['accuracy_in_period'] as num?)} $inPeriod'),
            Metric(t('Simulados realizados', 'Mock exams taken', 'Simulacros realizados'), t.number(_n(s, 'mock_exams_finished_total')),
                hint: '${t.number(_n(s, 'mock_exams_finished_in_period'))} $inPeriod'),
            Metric(t('Redações corrigidas', 'Essays graded', 'Redacciones corregidas'), t.number(_n(s, 'essays_evaluated_total')),
                hint: '${t.number(_n(s, 'essays_evaluated_in_period'))} $inPeriod'),
          ],
        ),
        MetricPanel(
          icon: LucideIcons.landmark,
          title: t('Financeiro do período', 'Period finance', 'Finanzas del periodo'),
          subtitle: t('A receita da Lucksrei está no topo da página.', 'Lucksrei revenue is at the top of the page.', 'Los ingresos de Lucksrei están al inicio de la página.'),
          columns: 3,
          metrics: [
            Metric(t('Faturamento bruto', 'Gross revenue', 'Facturación bruta'), t.money(_n(f, 'gross_cents')),
                hint: plural(t, _n(f, 'payments_count'), one: 'pagamento', many: 'pagamentos', oneEn: 'payment', manyEn: 'payments', oneEs: 'pago', manyEs: 'pagos')),
            Metric(t('Receita líquida', 'Net revenue', 'Ingresos netos'), t.money(_n(f, 'net_cents'))),
            Metric(t('Comissões de professores', 'Teacher commissions', 'Comisiones de profesores'), t.money(_n(f, 'commission_cents'))),
            Metric(t('Taxas e impostos', 'Fees and taxes', 'Tarifas e impuestos'), t.money(_n(f, 'fee_cents') + _n(f, 'tax_cents')),
                hint: t('Taxas das plataformas + impostos registrados', 'Platform fees + recorded taxes', 'Tarifas de plataformas + impuestos registrados')),
            Metric(t('Repasses pendentes', 'Pending payouts', 'Pagos pendientes'), t.money(_n(f, 'pending_payouts_cents')),
                hint: t('Saldo atual, todos os professores', 'Current balance, all teachers', 'Saldo actual, todos los profesores')),
            Metric(t('Repasses realizados', 'Payouts made', 'Pagos realizados'), t.money(_n(f, 'paid_payouts_cents'))),
          ],
        ),
      ),
      SectionHeader(t('Evolução diária', 'Daily evolution', 'Evolución diaria')),
      Panel(
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
                      padding: const EdgeInsets.only(bottom: kCardGap, right: kCardGap),
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
