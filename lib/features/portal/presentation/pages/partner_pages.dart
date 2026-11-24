import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/pages/portal_gate.dart';
import 'package:aura/features/portal/presentation/widgets/portal_widgets.dart';

// Portal do professor (Etapa 05). Tudo aqui é leitura: o professor é
// identificado no servidor pela sessão; nenhuma tela envia partner_id.

String _avg(Map<dynamic, dynamic> u) => ((u['avg_study_days'] as num?) ?? 0).toStringAsFixed(1);
num _n(Map<dynamic, dynamic>? m, String k) => (m?[k] as num?) ?? 0;
Map<String, dynamic> _m(dynamic v) => Map<String, dynamic>.from(v as Map);
List<Map<String, dynamic>> _l(dynamic v) => [for (final e in (v as List? ?? const [])) _m(e)];

/// Professor encerrado/suspenso só vê Financeiro e Minha parceria.
Widget partnerOnlyActive(Widget page) => Builder(
      builder: (context) => context.select((PortalSession s) => s.state.partnerActive)
          ? page
          : const PartnerFinancePage(),
    );

/// `/partners`: o mesmo endereço atende admin e professor.
class PortalHome extends StatelessWidget {
  const PortalHome({required this.admin, super.key});
  final Widget admin;
  @override
  Widget build(BuildContext context) {
    final role = context.select((PortalSession s) => s.state.role);
    if (role == PortalRole.admin) return admin;
    return partnerOnlyActive(const PartnerOverviewPage());
  }
}

String studentStateLabel(PortalStrings t, String? s) => switch (s) {
      'subscriber' => t('Assinante ativo', 'Active subscriber', 'Suscriptor activo'),
      'trial' => t('Em experiência gratuita', 'In free trial', 'En prueba gratuita'),
      'courtesy' => t('Premium por cortesia', 'Courtesy Premium', 'Premium de cortesía'),
      'sub_expired' => t('Assinatura expirada', 'Subscription expired', 'Suscripción expirada'),
      'trial_expired' => t('Acesso expirado', 'Access expired', 'Acceso expirado'),
      _ => t('Sem acesso Premium', 'No Premium access', 'Sin acceso Premium'),
    };

Tone studentStateTone(String? s) => switch (s) {
      'subscriber' => Tone.good,
      'trial' || 'courtesy' => Tone.info,
      'sub_expired' || 'trial_expired' => Tone.bad,
      _ => Tone.neutral,
    };

String planLabel(PortalStrings t, String? p) => switch (p) {
      'monthly' => t('Mensal', 'Monthly', 'Mensual'),
      'annual' => t('Anual', 'Annual', 'Anual'),
      _ => '—',
    };

Widget _section(String title, List<Widget> cards) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ),
        CardGrid(children: cards),
      ]),
    );

// ───────────────────────── Visão geral ─────────────────────────

class PartnerOverviewPage extends StatefulWidget {
  const PartnerOverviewPage({super.key});
  @override
  State<PartnerOverviewPage> createState() => _OverviewState();
}

class _OverviewState extends State<PartnerOverviewPage> with PeriodState {
  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    final r = range;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(
        title: t('Visão geral', 'Overview', 'Resumen'),
        subtitle: '${t.date(r.start)} – ${t.date(r.end)}',
        actions: [periodSelect(t)],
      ),
      Loader<Map<String, dynamic>>(
        loader: () async {
          final d = await api.partnerDashboard(r.start, r.end);
          final u = await api.partnerUsage(r.start, r.end);
          return {...d, 'usage': u};
        },
        keys: [r.start, r.end],
        builder: (context, d, _) {
          final c = _m(d['commercial']);
          final f = _m(d['finance']);
          final u = _m(d['usage']);
          final series = _l(d['series']);
          final students = _n(c, 'students');
          final paid = _n(c, 'paid_ever');
          String inPeriod(num v) => '${t.number(v)} ${t('no período', 'in period', 'en el periodo')}';
          final shared = u['suppressed'] != true;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _section(t('Indicações e assinaturas', 'Referrals and subscriptions', 'Referidos y suscripciones'), [
              StatCard(icon: Icons.people_outline_rounded, label: t('Alunos indicados', 'Referred students', 'Alumnos referidos'), value: t.number(students)),
              StatCard(icon: Icons.person_add_alt_rounded, label: t('Novos no período', 'New in period', 'Nuevos en el periodo'), value: t.number(_n(c, 'new_in_period'))),
              StatCard(icon: Icons.mark_email_read_outlined, label: t('E-mails verificados', 'Verified e-mails', 'Correos verificados'), value: t.number(_n(c, 'verified_emails'))),
              StatCard(icon: Icons.workspace_premium_outlined, label: t('Assinantes ativos', 'Active subscribers', 'Suscriptores activos'), value: t.number(_n(c, 'subscribers')), hint: '${t.number(_n(c, 'monthly'))} ${t('mensal', 'monthly', 'mensual')} · ${t.number(_n(c, 'annual'))} ${t('anual', 'annual', 'anual')}'),
              StatCard(label: t('Em experiência gratuita', 'In free trial', 'En prueba gratuita'), value: t.number(_n(c, 'trial'))),
              StatCard(label: t('Experiência encerrada', 'Trial ended', 'Prueba terminada'), value: t.number(_n(c, 'trial_expired'))),
              StatCard(label: t('Assinatura expirada', 'Subscription expired', 'Suscripción expirada'), value: t.number(_n(c, 'subscription_expired'))),
              StatCard(label: t('Premium por cortesia', 'Courtesy Premium', 'Premium de cortesía'), value: t.number(_n(c, 'courtesy'))),
              StatCard(
                label: t('Conversão em assinatura', 'Subscription conversion', 'Conversión a suscripción'),
                value: t.percent(students == 0 ? null : paid / students),
                hint: t('Alunos que já assinaram ÷ alunos indicados', 'Students who ever subscribed ÷ referred students', 'Alumnos que alguna vez suscribieron ÷ alumnos referidos'),
              ),
            ]),
            _section(t('Estudo (alunos que compartilham)', 'Study (sharing students)', 'Estudio (alumnos que comparten)'), shared
                ? [
                    StatCard(label: t('Alunos ativos', 'Active students', 'Alumnos activos'), value: t.number(_n(u, 'active_students')), hint: t('com estudo no período', 'studying in period', 'estudiaron en el periodo')),
                    StatCard(label: t('Questões respondidas', 'Questions answered', 'Preguntas respondidas'), value: t.number(_n(u, 'questions_total')), hint: inPeriod(_n(u, 'questions_in_period'))),
                    StatCard(label: t('Taxa de acerto', 'Accuracy', 'Tasa de aciertos'), value: t.percent(u['accuracy_total'] as num?), hint: '${t.percent(u['accuracy_in_period'] as num?)} ${t('no período', 'in period', 'en el periodo')}'),
                    StatCard(label: t('Simulados', 'Mock exams', 'Simulacros'), value: t.number(_n(u, 'mock_exams_total')), hint: inPeriod(_n(u, 'mock_exams_in_period'))),
                    StatCard(label: t('Redações corrigidas', 'Essays graded', 'Redacciones corregidas'), value: t.number(_n(u, 'essays_total')), hint: inPeriod(_n(u, 'essays_in_period'))),
                  ]
                : [_SuppressedCard(u: u)]),
            _section(t('Financeiro', 'Finance', 'Finanzas'), [
              StatCard(icon: Icons.percent_rounded, label: t('Sua comissão', 'Your commission', 'Tu comisión'), value: t.bps(_n(f, 'commission_bps'))),
              StatCard(label: t('Saldo a receber', 'Balance to receive', 'Saldo a recibir'), value: t.money(_n(f, 'balance_cents'))),
              StatCard(label: t('Comissões no período', 'Commissions in period', 'Comisiones en el periodo'), value: t.money(_n(f, 'commissions_period_cents'))),
              StatCard(label: t('Total já recebido', 'Total received', 'Total recibido'), value: t.money(_n(f, 'received_cents'))),
              StatCard(
                label: t('Último repasse', 'Last payout', 'Último pago'),
                value: f['last_payout'] == null ? '—' : t.money(_n(_m(f['last_payout']), 'amount_cents')),
                hint: f['last_payout'] == null ? null : t.dateOf(_m(f['last_payout'])['paid_at']),
              ),
              StatCard(label: t('Próximo repasse', 'Next payout', 'Próximo pago'), value: t.dateOf(f['next_payout_date'])),
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
                              BarChart(values: [for (final p in series) (p[key] as num)], labels: [for (final p in series) t.dateOf(p['date'])]),
                            ]),
                          );
                      final a = one(t('Indicações', 'Referrals', 'Referidos'), 'referrals');
                      final b = one(t('Novas assinaturas', 'New subscriptions', 'Nuevas suscripciones'), 'subscriptions');
                      return box.maxWidth >= kWide
                          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: a), Expanded(child: b)])
                          : Column(children: [a, b]);
                    }),
            ),
          ]);
        },
      ),
    ]);
  }
}

class _SuppressedCard extends StatelessWidget {
  const _SuppressedCard({required this.u});
  final Map<String, dynamic> u;
  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final min = _n(u, 'min_cohort').toInt();
    return Panel(
      child: EmptyState(
        icon: Icons.lock_outline_rounded,
        message: t(
          'As estatísticas de estudo só aparecem quando pelo menos $min alunos vinculados compartilham seus dados (hoje: ${_n(u, 'consented').toInt()} de ${_n(u, 'total').toInt()}). Isso protege a privacidade de cada aluno.',
          'Study statistics only appear when at least $min linked students share their data (today: ${_n(u, 'consented').toInt()} of ${_n(u, 'total').toInt()}). This protects each student\'s privacy.',
          'Las estadísticas de estudio solo aparecen cuando al menos $min alumnos vinculados comparten sus datos (hoy: ${_n(u, 'consented').toInt()} de ${_n(u, 'total').toInt()}). Esto protege la privacidad de cada alumno.',
        ),
      ),
    );
  }
}

// ───────────────────────── Meus alunos ─────────────────────────

class PartnerStudentsPage extends StatefulWidget {
  const PartnerStudentsPage({super.key});
  @override
  State<PartnerStudentsPage> createState() => _StudentsState();
}

class _StudentsState extends State<PartnerStudentsPage> {
  static const _limit = 25;
  String _search = '';
  String _filter = '';
  String _sort = 'linked';
  String _dir = 'desc';
  int _offset = 0;

  void _set(VoidCallback f) => setState(() {
        f();
        _offset = 0;
      });

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(title: t('Meus alunos', 'My students', 'Mis alumnos')),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
            SearchBox(hint: t('Nome ou usuário', 'Name or username', 'Nombre o usuario'), onChanged: (v) => _set(() => _search = v)),
            Select<String>(
              label: t('Filtro', 'Filter', 'Filtro'),
              value: _filter,
              items: {
                '': t('Todos', 'All', 'Todos'),
                'subscribers': t('Assinantes ativos', 'Active subscribers', 'Suscriptores activos'),
                'trial': t('Em experiência gratuita', 'In free trial', 'En prueba gratuita'),
                'expired': t('Com acesso expirado', 'With expired access', 'Con acceso expirado'),
                'courtesy': t('Premium por cortesia', 'Courtesy Premium', 'Premium de cortesía'),
                'recent': t('Com atividade recente', 'Recently active', 'Con actividad reciente'),
                'inactive': t('Sem atividade recente', 'Not recently active', 'Sin actividad reciente'),
              },
              onChanged: (v) => _set(() => _filter = v),
            ),
            Select<String>(
              label: t('Ordenar', 'Sort', 'Ordenar'),
              value: _sort,
              items: {
                'linked': t('Data do vínculo', 'Link date', 'Fecha del vínculo'),
                'created': t('Cadastro', 'Sign-up', 'Registro'),
                'name': t('Nome', 'Name', 'Nombre'),
                'activity': t('Última atividade', 'Last activity', 'Última actividad'),
                'answered': t('Questões', 'Questions', 'Preguntas'),
              },
              onChanged: (v) => _set(() => _sort = v),
            ),
            IconButton(
              tooltip: t('Inverter ordem', 'Reverse order', 'Invertir orden'),
              onPressed: () => _set(() => _dir = _dir == 'desc' ? 'asc' : 'desc'),
              icon: Icon(_dir == 'desc' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded),
            ),
          ]),
          const SizedBox(height: 12),
          Loader<Map<String, dynamic>>(
            loader: () => api.partnerStudents(
              search: _search.isEmpty ? null : _search,
              filter: _filter.isEmpty ? null : _filter,
              sort: _sort,
              dir: _dir,
              limit: _limit,
              offset: _offset,
            ),
            keys: [_search, _filter, _sort, _dir, _offset],
            builder: (context, d, _) {
              final rows = _l(d['rows']);
              if (rows.isEmpty) {
                return EmptyState(message: t('Nenhum aluno encontrado.', 'No students found.', 'No se encontraron alumnos.'));
              }
              const dash = '—';
              return Column(children: [
                PortalTable(
                  columns: [
                    PortalColumn(t('Aluno', 'Student', 'Alumno'), flex: 3),
                    PortalColumn(t('Cadastro', 'Signed up', 'Registro')),
                    PortalColumn(t('Vínculo', 'Linked', 'Vínculo')),
                    PortalColumn(t('Acesso', 'Access', 'Acceso'), flex: 2),
                    PortalColumn(t('Plano', 'Plan', 'Plan')),
                    PortalColumn(t('Última atividade', 'Last activity', 'Última actividad')),
                    PortalColumn(t('Questões', 'Questions', 'Preguntas')),
                    PortalColumn(t('Acertos', 'Accuracy', 'Aciertos')),
                  ],
                  onTap: (i) => context.go('/partners/students/${rows[i]['id']}'),
                  rows: [
                    for (final r in rows)
                      [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${r['name']}'.isEmpty ? dash : '${r['name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          if (r['username'] != null) Text('@${r['username']}', style: const TextStyle(fontSize: 12)),
                        ]),
                        Text(t.dateOf(r['created_at'])),
                        Text(t.dateOf(r['linked_at'])),
                        StatusBadge(studentStateLabel(t, r['state'] as String?), tone: studentStateTone(r['state'] as String?)),
                        Text(planLabel(t, r['plan'] as String?)),
                        r['shared'] == true ? Text(t.dateTimeOf(r['last_activity'])) : _noShare(t),
                        Text(r['shared'] == true ? t.number(_n(r, 'answered')) : dash),
                        Text(r['shared'] == true ? t.percent(r['accuracy'] as num?) : dash),
                      ],
                  ],
                ),
                Pager(total: (d['total'] as num).toInt(), offset: _offset, limit: _limit, onPage: (o) => setState(() => _offset = o)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t(
                      'Dados de estudo só aparecem para alunos que autorizaram o compartilhamento. "Atividade recente" = estudo ou uso do app nos últimos 14 dias.',
                      'Study data only shows for students who allowed sharing. "Recent activity" = study or app use in the last 14 days.',
                      'Los datos de estudio solo aparecen para alumnos que autorizaron compartir. "Actividad reciente" = estudio o uso de la app en los últimos 14 días.',
                    ),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ]);
            },
          ),
        ]),
      ),
    ]);
  }
}

Widget _noShare(PortalStrings t) => Text(
      t('Não compartilhado', 'Not shared', 'No compartido'),
      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
    );

// ───────────────────────── Detalhe do aluno ─────────────────────────

class PartnerStudentDetailPage extends StatelessWidget {
  const PartnerStudentDetailPage({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextButton.icon(
        onPressed: () => context.go('/partners/students'),
        icon: const Icon(Icons.arrow_back_rounded, size: 18),
        label: Text(t('Meus alunos', 'My students', 'Mis alumnos')),
      ),
      Loader<Map<String, dynamic>>(
        loader: () => api.partnerStudent(id),
        keys: [id],
        builder: (context, d, _) {
          final s = _m(d['student']);
          final com = _m(s['commercial']);
          final st = d['stats'] == null ? null : _m(d['stats']);
          final name = '${s['name'] ?? ''}'.isEmpty ? '—' : '${s['name']}';
          final streak = st?['streak'] == null ? null : _m(st!['streak']);
          final answered = _n(st, 'answered');
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PageHeader(title: name, subtitle: t('Somente leitura', 'Read only', 'Solo lectura')),
            Panel(
              title: t('Acesso', 'Access', 'Acceso'),
              child: Column(children: [
                KeyValue(t('Situação', 'Status', 'Situación'), StatusBadge(studentStateLabel(t, com['state'] as String?), tone: studentStateTone(com['state'] as String?))),
                KeyValue(t('Plano', 'Plan', 'Plan'), Text(planLabel(t, com['plan'] as String?))),
                KeyValue(t('Cadastro', 'Signed up', 'Registro'), Text(t.dateOf(s['created_at']))),
                KeyValue(t('Vínculo com você', 'Linked to you', 'Vínculo contigo'), Text(t.dateOf(s['linked_at']))),
                if (st != null) KeyValue(t('Última atividade', 'Last activity', 'Última actividad'), Text(t.dateTimeOf(st['last_activity']))),
              ]),
            ),
            const SizedBox(height: 16),
            if (st == null)
              Panel(
                child: EmptyState(
                  icon: Icons.lock_outline_rounded,
                  message: t(
                    'Este aluno não autorizou o compartilhamento de estatísticas de estudo (ou revogou a autorização). Os dados individuais ficam ocultos.',
                    'This student has not allowed (or has revoked) sharing study statistics. Individual data stays hidden.',
                    'Este alumno no autorizó (o revocó) compartir estadísticas de estudio. Los datos individuales permanecen ocultos.',
                  ),
                ),
              )
            else ...[
              _section(t('Estudo', 'Study', 'Estudio'), [
                StatCard(label: t('Questões respondidas', 'Questions answered', 'Preguntas respondidas'), value: t.number(answered), hint: '${t.number(_n(st, 'answered_today'))} ${t('hoje', 'today', 'hoy')}'),
                StatCard(label: t('Acertos', 'Correct', 'Aciertos'), value: t.number(_n(st, 'correct'))),
                StatCard(label: t('Taxa de acerto', 'Accuracy', 'Tasa de aciertos'), value: t.percent(answered == 0 ? null : _n(st, 'correct') / answered)),
                StatCard(label: t('Simulados concluídos', 'Mock exams finished', 'Simulacros terminados'), value: t.number(_n(st, 'mock_exams_finished'))),
                StatCard(label: t('Redações corrigidas', 'Essays graded', 'Redacciones corregidas'), value: t.number(_n(st, 'essays_evaluated'))),
              ]),
              _section(t('Engajamento', 'Engagement', 'Compromiso'), [
                StatCard(label: 'Aura', value: t.number(_n(st, 'aura')), hint: '${t('Nível', 'Level', 'Nivel')} ${t.number(_n(st, 'level'))}'),
                StatCard(label: t('Sequência atual', 'Current streak', 'Racha actual'), value: streak == null ? '—' : '${t.number(_n(streak, 'current'))} ${t('dias', 'days', 'días')}', hint: streak == null ? null : '${t('Recorde', 'Record', 'Récord')}: ${t.number(_n(streak, 'longest'))}'),
              ]),
              Panel(
                title: t('Desempenho por matéria', 'Performance by subject', 'Rendimiento por materia'),
                child: _SubjectTable(rows: _l(st['by_subject'])),
              ),
              const SizedBox(height: 16),
              Panel(
                title: t('Questões respondidas (30 dias)', 'Questions answered (30 days)', 'Preguntas respondidas (30 días)'),
                child: BarChart(
                  values: [for (final p in _l(st['series'])) (p['answered'] as num)],
                  labels: [for (final p in _l(st['series'])) t.dateOf(p['date'])],
                ),
              ),
            ],
          ]);
        },
      ),
    ]);
  }
}

class _SubjectTable extends StatelessWidget {
  const _SubjectTable({required this.rows});
  final List<Map<String, dynamic>> rows;
  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    if (rows.isEmpty) return EmptyState(message: t('Sem questões respondidas.', 'No questions answered.', 'Sin preguntas respondidas.'));
    return PortalTable(
      columns: [
        PortalColumn(t('Matéria', 'Subject', 'Materia'), flex: 3),
        PortalColumn(t('Respondidas', 'Answered', 'Respondidas')),
        PortalColumn(t('Acertos', 'Correct', 'Aciertos')),
        PortalColumn(t('Taxa', 'Rate', 'Tasa')),
      ],
      rows: [
        for (final r in rows)
          [
            Text('${r['subject'] ?? '—'}'),
            Text(t.number(_n(r, 'answered'))),
            Text(t.number(_n(r, 'correct'))),
            Text(t.percent(_n(r, 'answered') == 0 ? null : _n(r, 'correct') / _n(r, 'answered'))),
          ],
      ],
    );
  }
}

// ───────────────────────── Estatísticas ─────────────────────────

class PartnerStatsPage extends StatefulWidget {
  const PartnerStatsPage({super.key});
  @override
  State<PartnerStatsPage> createState() => _StatsState();
}

class _StatsState extends State<PartnerStatsPage> with PeriodState {
  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    final r = range;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(
        title: t('Estatísticas', 'Statistics', 'Estadísticas'),
        subtitle: '${t.date(r.start)} – ${t.date(r.end)}',
        actions: [periodSelect(t)],
      ),
      Loader<Map<String, dynamic>>(
        loader: () => api.partnerUsage(r.start, r.end),
        keys: [r.start, r.end],
        builder: (context, u, _) {
          if (u['suppressed'] == true) return _SuppressedCard(u: u);
          final consented = _n(u, 'consented');
          final lv = _m(u['aura_levels']);
          final series = _l(u['series']);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _section(t('Resumo', 'Summary', 'Resumen'), [
              StatCard(label: t('Alunos na amostra', 'Students in sample', 'Alumnos en la muestra'), value: '${t.number(consented)} / ${t.number(_n(u, 'total'))}', hint: t('Só entram alunos que autorizaram o compartilhamento', 'Only students who allowed sharing are counted', 'Solo entran alumnos que autorizaron compartir')),
              StatCard(label: t('Alunos ativos', 'Active students', 'Alumnos activos'), value: t.number(_n(u, 'active_students')), hint: t('Estudaram no período', 'Studied in the period', 'Estudiaron en el periodo')),
              StatCard(label: t('Dias de estudo por aluno', 'Study days per student', 'Días de estudio por alumno'), value: t(_avg(u).replaceAll('.', ','), _avg(u), _avg(u).replaceAll('.', ',')), hint: t('Média no período, sobre toda a amostra', 'Period average over the whole sample', 'Promedio del periodo sobre toda la muestra')),
              StatCard(label: t('Questões respondidas', 'Questions answered', 'Preguntas respondidas'), value: t.number(_n(u, 'questions_total')), hint: '${t.number(_n(u, 'questions_in_period'))} ${t('no período', 'in period', 'en el periodo')}'),
              StatCard(label: t('Taxa de acerto', 'Accuracy', 'Tasa de aciertos'), value: t.percent(u['accuracy_total'] as num?), hint: '${t.percent(u['accuracy_in_period'] as num?)} ${t('no período', 'in period', 'en el periodo')}'),
              StatCard(label: t('Simulados concluídos', 'Mock exams finished', 'Simulacros terminados'), value: t.number(_n(u, 'mock_exams_total')), hint: '${t.number(_n(u, 'mock_exams_in_period'))} ${t('no período', 'in period', 'en el periodo')}'),
              StatCard(label: t('Redações corrigidas', 'Essays graded', 'Redacciones corregidas'), value: t.number(_n(u, 'essays_total')), hint: '${t.number(_n(u, 'essays_in_period'))} ${t('no período', 'in period', 'en el periodo')}'),
            ]),
            Panel(title: t('Matérias com mais respostas', 'Most answered subjects', 'Materias con más respuestas'), child: _SubjectTable(rows: _l(u['by_subject']))),
            const SizedBox(height: 16),
            Panel(
              title: t('Nível de Aura (alunos)', 'Aura level (students)', 'Nivel de Aura (alumnos)'),
              child: Column(children: [
                KeyValue(t('Níveis 1–2', 'Levels 1–2', 'Niveles 1–2'), Text(t.number(_n(lv, 'l1_2')))),
                KeyValue(t('Níveis 3–5', 'Levels 3–5', 'Niveles 3–5'), Text(t.number(_n(lv, 'l3_5')))),
                KeyValue(t('Níveis 6–10', 'Levels 6–10', 'Niveles 6–10'), Text(t.number(_n(lv, 'l6_10')))),
                KeyValue(t('Nível 11 ou mais', 'Level 11 or more', 'Nivel 11 o más'), Text(t.number(_n(lv, 'l11_plus')))),
              ]),
            ),
            const SizedBox(height: 16),
            Panel(
              title: t('Alunos ativos por dia', 'Active students per day', 'Alumnos activos por día'),
              child: BarChart(values: [for (final p in series) (p['active'] as num)], labels: [for (final p in series) t.dateOf(p['date'])]),
            ),
            const SizedBox(height: 12),
            Text(
              t(
                'Como ler: as questões guardam a última resposta de cada aluno por questão (não o histórico de tentativas), então os totais são consolidados. "Ativo" = respondeu questão, fez simulado, enviou redação ou ganhou Aura no período. Sem rankings nem estimativas.',
                'How to read: questions keep each student\'s latest answer per question (not the attempt history), so totals are consolidated. "Active" = answered a question, took a mock exam, submitted an essay or earned Aura in the period. No rankings or estimates.',
                'Cómo leer: las preguntas guardan la última respuesta de cada alumno (no el historial de intentos), por eso los totales son consolidados. "Activo" = respondió, hizo simulacro, envió redacción o ganó Aura en el periodo. Sin rankings ni estimaciones.',
              ),
              style: const TextStyle(fontSize: 11),
            ),
          ]);
        },
      ),
    ]);
  }
}

// ───────────────────────── Financeiro ─────────────────────────

String ledgerKindLabel(PortalStrings t, String k) => switch (k) {
      'commission' => t('Comissão', 'Commission', 'Comisión'),
      'refund_adjustment' => t('Estorno', 'Refund adjustment', 'Reembolso'),
      'fee_adjustment' => t('Ajuste de taxa', 'Fee adjustment', 'Ajuste de tarifa'),
      'manual_adjustment' => t('Ajuste manual', 'Manual adjustment', 'Ajuste manual'),
      'payout' => t('Repasse', 'Payout', 'Pago'),
      'payout_reversal' => t('Repasse revertido', 'Payout reversed', 'Pago revertido'),
      _ => k,
    };

class PartnerFinancePage extends StatefulWidget {
  const PartnerFinancePage({super.key});
  @override
  State<PartnerFinancePage> createState() => _FinanceState();
}

class _FinanceState extends State<PartnerFinancePage> {
  static const _limit = 25;
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(
        title: t('Financeiro', 'Finance', 'Finanzas'),
        subtitle: t('Somente leitura', 'Read only', 'Solo lectura'),
        actions: [
          OutlinedButton.icon(
            onPressed: () => exportCsv(context, () => api.partnerExport('commissions'), 'minhas-comissoes.csv'),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: Text(t('Comissões CSV', 'Commissions CSV', 'Comisiones CSV')),
          ),
          OutlinedButton.icon(
            onPressed: () => exportCsv(context, () => api.partnerExport('payouts'), 'meus-repasses.csv'),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: Text(t('Repasses CSV', 'Payouts CSV', 'Pagos CSV')),
          ),
        ],
      ),
      Loader<Map<String, dynamic>>(
        loader: () => api.partnerFinance(limit: _limit, offset: _offset),
        keys: [_offset],
        builder: (context, d, _) {
          final p = _m(d['partner']);
          final s = _m(d['summary']);
          final comp = _l(d['by_competence']);
          final payouts = _l(d['payouts']);
          final ledger = _l(d['ledger']);
          final last = s['last_payout'] == null ? null : _m(s['last_payout']);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (p['active'] != true)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Panel(
                  child: Text(t(
                    'Sua parceria não está ativa. Você mantém acesso ao histórico financeiro e aos valores pendentes.',
                    'Your partnership is not active. You keep access to your financial history and pending amounts.',
                    'Tu alianza no está activa. Mantienes acceso a tu historial financiero y a los valores pendientes.',
                  )),
                ),
              ),
            _section(t('Resumo', 'Summary', 'Resumen'), [
              StatCard(label: t('Saldo a receber', 'Balance to receive', 'Saldo a recibir'), value: t.money(_n(s, 'balance_cents')), hint: t('Comissões + ajustes − repasses', 'Commissions + adjustments − payouts', 'Comisiones + ajustes − pagos')),
              StatCard(label: t('Sua comissão', 'Your commission', 'Tu comisión'), value: t.bps(_n(p, 'commission_bps')), hint: t('Vale para pagamentos futuros', 'Applies to future payments', 'Vale para pagos futuros')),
              StatCard(label: t('Comissões do mês', 'This month commissions', 'Comisiones del mes'), value: t.money(_n(s, 'month_commissions_cents'))),
              StatCard(label: t('Pendente de conciliação', 'Pending reconciliation', 'Pendiente de conciliación'), value: t.money(_n(s, 'pending_reconciliation_cents')), hint: t('Libera após o provedor confirmar as taxas', 'Released once the provider confirms fees', 'Se libera cuando el proveedor confirma las tarifas')),
              StatCard(label: t('Comissões confirmadas (total)', 'Confirmed commissions (total)', 'Comisiones confirmadas (total)'), value: t.money(_n(s, 'commissions_cents')), hint: t('Só de pagamentos confirmados', 'From confirmed payments only', 'Solo de pagos confirmados')),
              StatCard(label: t('Estornos e ajustes', 'Refunds and adjustments', 'Reembolsos y ajustes'), value: t.money(_n(s, 'adjustments_cents'))),
              StatCard(label: t('Total já recebido', 'Total received', 'Total recibido'), value: t.money(_n(s, 'received_cents'))),
              StatCard(label: t('Último repasse', 'Last payout', 'Último pago'), value: last == null ? '—' : t.money(_n(last, 'amount_cents')), hint: last == null ? null : t.dateOf(last['paid_at'])),
              StatCard(label: t('Próximo repasse', 'Next payout', 'Próximo pago'), value: t.dateOf(s['next_payout_date']), hint: t('Repasses são manuais, todo dia 1º', 'Payouts are manual, on the 1st of each month', 'Los pagos son manuales, el día 1 de cada mes')),
            ]),
            Panel(
              title: t('Por competência (mês)', 'By competence (month)', 'Por competencia (mes)'),
              child: comp.isEmpty
                  ? EmptyState(message: t('Sem movimentações ainda.', 'No movements yet.', 'Aún sin movimientos.'))
                  : PortalTable(
                      columns: [
                        PortalColumn(t('Competência', 'Competence', 'Competencia')),
                        PortalColumn(t('Comissões', 'Commissions', 'Comisiones')),
                        PortalColumn(t('Ajustes', 'Adjustments', 'Ajustes')),
                        PortalColumn(t('Repasses', 'Payouts', 'Pagos')),
                        PortalColumn(t('Saldo', 'Balance', 'Saldo')),
                      ],
                      rows: [
                        for (final r in comp)
                          [
                            Text('${r['competence']}'.substring(0, 7)),
                            Text(t.money(_n(r, 'commissions_cents'))),
                            Text(t.money(_n(r, 'adjustments_cents'))),
                            Text(t.money(_n(r, 'payouts_cents'))),
                            Text(t.money(_n(r, 'balance_cents')), style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            Panel(
              title: t('Repasses', 'Payouts', 'Pagos'),
              child: payouts.isEmpty
                  ? EmptyState(message: t('Nenhum repasse registrado.', 'No payouts recorded.', 'Ningún pago registrado.'))
                  : PortalTable(
                      columns: [
                        PortalColumn(t('Competência', 'Competence', 'Competencia')),
                        PortalColumn(t('Valor', 'Amount', 'Valor')),
                        PortalColumn(t('Situação', 'Status', 'Estado')),
                        PortalColumn(t('Data do Pix', 'Pix date', 'Fecha del Pix')),
                        PortalColumn(t('Referência', 'Reference', 'Referencia'), flex: 2),
                      ],
                      rows: [
                        for (final r in payouts)
                          [
                            Text('${r['competence']}'.substring(0, 7)),
                            Text(t.money(_n(r, 'amount_cents'))),
                            StatusBadge(r['status'] == 'paid' ? t('Pago', 'Paid', 'Pagado') : t('Revertido', 'Reversed', 'Revertido'), tone: r['status'] == 'paid' ? Tone.good : Tone.bad),
                            Text(t.dateOf(r['paid_at'])),
                            Text('${r['reference'] ?? '—'}'),
                          ],
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            Panel(
              title: t('Movimentações', 'Movements', 'Movimientos'),
              child: ledger.isEmpty
                  ? EmptyState(message: t('Sem movimentações ainda.', 'No movements yet.', 'Aún sin movimientos.'))
                  : Column(children: [
                      PortalTable(
                        columns: [
                          PortalColumn(t('Data', 'Date', 'Fecha')),
                          PortalColumn(t('Tipo', 'Type', 'Tipo')),
                          PortalColumn(t('Plano', 'Plan', 'Plan')),
                          PortalColumn(t('Valor', 'Amount', 'Valor')),
                        ],
                        rows: [
                          for (final r in ledger)
                            [
                              Text(t.dateOf(r['at'])),
                              Text(ledgerKindLabel(t, '${r['kind']}')),
                              Text(planLabel(t, r['plan'] as String?)),
                              Text(t.money(_n(r, 'amount_cents'))),
                            ],
                        ],
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

// ───────────────────────── Minhas indicações ─────────────────────────

class PartnerReferralsPage extends StatelessWidget {
  const PartnerReferralsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(title: t('Minhas indicações', 'My referrals', 'Mis referidos')),
      Loader<Map<String, dynamic>>(
        loader: () async {
          final me = await api.partnerMe();
          final now = DateTime.now();
          final d = await api.partnerDashboard(DateTime(now.year, now.month), now);
          return {'me': me, 'dash': d};
        },
        builder: (context, d, _) {
          final me = _m(d['me']);
          final c = _m(_m(d['dash'])['commercial']);
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ReferralCard(code: '${me['referral_code']}', link: '${me['link']}', active: me['active'] == true),
            const SizedBox(height: 16),
            _section(t('Resultado', 'Results', 'Resultados'), [
              StatCard(label: t('Alunos indicados', 'Referred students', 'Alumnos referidos'), value: t.number(_n(c, 'students'))),
              StatCard(label: t('Novos no mês', 'New this month', 'Nuevos en el mes'), value: t.number(_n(c, 'new_in_period'))),
              StatCard(label: t('Assinantes ativos', 'Active subscribers', 'Suscriptores activos'), value: t.number(_n(c, 'subscribers'))),
            ]),
            Text(
              t(
                'O aluno que abre o link já encontra você pré-selecionado no cadastro, mas pode trocar. O vínculo não muda sozinho depois de criado.',
                'A student who opens the link finds you pre-selected at sign-up, but can change it. The link never changes by itself once created.',
                'El alumno que abre el enlace te encuentra preseleccionado en el registro, pero puede cambiarlo. El vínculo no cambia solo una vez creado.',
              ),
              style: const TextStyle(fontSize: 11),
            ),
          ]);
        },
      ),
    ]);
  }
}

/// Código + link com copiar e compartilhar (share nativo; cai para copiar).
class ReferralCard extends StatelessWidget {
  const ReferralCard({required this.code, required this.link, required this.active, super.key});
  final String code;
  final String link;
  final bool active;

  Future<void> _copy(BuildContext context, String text, String msg) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _share(BuildContext context, PortalStrings t) async {
    try {
      await SharePlus.instance.share(ShareParams(text: link));
    } catch (_) {
      if (context.mounted) await _copy(context, link, t('Link copiado.', 'Link copied.', 'Enlace copiado.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    return Panel(
      title: t('Seu link de indicação', 'Your referral link', 'Tu enlace de referencia'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (!active)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: StatusBadge(t('Parceria inativa: o link não vincula novos alunos', 'Inactive partnership: the link does not link new students', 'Alianza inactiva: el enlace no vincula nuevos alumnos'), tone: Tone.warn),
          ),
        KeyValue(t('Código', 'Code', 'Código'), SelectableText(code, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5))),
        KeyValue(t('Link', 'Link', 'Enlace'), SelectableText(link)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(
            onPressed: () => _copy(context, code, t('Código copiado.', 'Code copied.', 'Código copiado.')),
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(t('Copiar código', 'Copy code', 'Copiar código')),
          ),
          OutlinedButton.icon(
            onPressed: () => _copy(context, link, t('Link copiado.', 'Link copied.', 'Enlace copiado.')),
            icon: const Icon(Icons.link_rounded, size: 18),
            label: Text(t('Copiar link', 'Copy link', 'Copiar enlace')),
          ),
          ElevatedButton.icon(
            onPressed: () => _share(context, t),
            icon: const Icon(Icons.share_rounded, size: 18),
            label: Text(t('Compartilhar', 'Share', 'Compartir')),
          ),
        ]),
      ]),
    );
  }
}

// ───────────────────────── Minha parceria ─────────────────────────

class PartnerProfilePage extends StatelessWidget {
  const PartnerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(title: t('Minha parceria', 'My partnership', 'Mi alianza'), subtitle: t('Somente leitura', 'Read only', 'Solo lectura')),
      Loader<Map<String, dynamic>>(
        loader: api.partnerMe,
        builder: (context, me, _) {
          final status = '${me['status']}';
          final label = switch (status) {
            'active' => t('Ativa', 'Active', 'Activa'),
            'suspended' => t('Suspensa', 'Suspended', 'Suspendida'),
            'ended' => t('Encerrada', 'Ended', 'Terminada'),
            _ => t('Pendente', 'Pending', 'Pendiente'),
          };
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Panel(
              child: Column(children: [
                KeyValue(t('Nome de divulgação', 'Display name', 'Nombre público'), Text('${me['display_name']}')),
                KeyValue(t('Situação', 'Status', 'Estado'), StatusBadge(label, tone: me['active'] == true ? Tone.good : Tone.bad)),
                KeyValue(t('Início', 'Start', 'Inicio'), Text(t.dateOf(me['started_at']))),
                if (me['ended_at'] != null) KeyValue(t('Encerramento', 'Ended on', 'Terminó el'), Text(t.dateOf(me['ended_at']))),
                KeyValue(t('Comissão', 'Commission', 'Comisión'), Text(t.bps(_n(me, 'commission_bps')))),
                KeyValue(t('Próximo repasse', 'Next payout', 'Próximo pago'), Text(t.dateOf(me['next_payout_date']))),
                KeyValue(
                  t('Chave Pix', 'Pix key', 'Clave Pix'),
                  Text(me['pix_key_masked'] == null ? t('Não informada', 'Not provided', 'No informada') : '${me['pix_key_masked']}'),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            ReferralCard(code: '${me['referral_code']}', link: '${me['link']}', active: me['active'] == true),
            const SizedBox(height: 12),
            Text(
              t(
                'Para alterar nome, comissão, código ou chave Pix, fale com a equipe Lucksrei.',
                'To change name, commission, code or Pix key, contact the Lucksrei team.',
                'Para cambiar nombre, comisión, código o clave Pix, habla con el equipo de Lucksrei.',
              ),
              style: const TextStyle(fontSize: 11),
            ),
          ]);
        },
      ),
    ]);
  }
}
