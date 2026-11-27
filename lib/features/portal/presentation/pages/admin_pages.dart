import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/pages/portal_gate.dart';
import 'package:aura/features/portal/presentation/widgets/portal_widgets.dart';

List<Map<String, dynamic>> _rows(dynamic v) => (v as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

const double _kSmallText = 12;
const double _kHintText = 11;
const int _kPageSize = 25;

TextStyle _small(BuildContext context, {bool bold = false}) => TextStyle(
      fontSize: _kSmallText,
      fontWeight: bold ? FontWeight.w700 : null,
      color: context.colors.textSecondary,
    );

// ---------------------------------------------------------------------------
// Solicitações de troca de professor
// ---------------------------------------------------------------------------
class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});
  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  String _status = 'pending';
  int _offset = 0;
  int _reload = 0;

  Future<void> _review(Map<String, dynamic> r, bool approve) async {
    final t = PortalStrings.read(context);
    final api = context.read<PortalApi>();
    final session = context.read<PortalSession>();
    final note = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(approve ? t('Aprovar troca?', 'Approve change?', '¿Aprobar cambio?') : t('Recusar solicitação?', 'Decline request?', '¿Rechazar solicitud?')),
        content: SizedBox(
          width: 420,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${r['student_name']}: ${r['from_name']} → ${r['to_name']}'),
            const SizedBox(height: 8),
            Text(
              approve
                  ? t('O vínculo muda agora e só afeta pagamentos futuros.', 'The link changes now and only affects future payments.', 'El vínculo cambia ahora y solo afecta pagos futuros.')
                  : t('O aluno continua com o professor atual.', 'The student stays with the current teacher.', 'El alumno sigue con el profesor actual.'),
              style: _small(ctx),
            ),
            const SizedBox(height: 12),
            Field(label: t('Nota (opcional)', 'Note (optional)', 'Nota (opcional)'), controller: note, maxLines: 2),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t('Cancelar', 'Cancel', 'Cancelar'))),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(approve ? t('Aprovar', 'Approve', 'Aprobar') : t('Recusar', 'Decline', 'Rechazar'))),
        ],
      ),
    );
    final text = note.text.trim();
    note.dispose();
    if (ok != true || !mounted) return;
    try {
      final res = await api.reviewRequest('${r['id']}', approve, note: text.isEmpty ? null : text);
      if (!mounted) return;
      final msg = switch (res['result']) {
        'already_processed' => t('Esta solicitação já foi processada por outro administrador.', 'This request was already handled by another administrator.', 'Esta solicitud ya fue procesada por otro administrador.'),
        'obsolete' => t('O vínculo do aluno mudou desde o pedido; a solicitação foi encerrada como obsoleta.', 'The student link changed since the request; it was closed as obsolete.', 'El vínculo del alumno cambió desde la solicitud; se cerró como obsoleta.'),
        _ => approve ? t('Troca aprovada.', 'Change approved.', 'Cambio aprobado.') : t('Solicitação recusada.', 'Request declined.', 'Solicitud rechazada.'),
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorText(t, e))));
    }
    await session.refreshPending();
    if (mounted) setState(() => _reload++);
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(
        title: t('Solicitações de troca de professor', 'Teacher change requests', 'Solicitudes de cambio de profesor'),
        subtitle: t(
          'Aprovar muda o vínculo na hora e só afeta pagamentos futuros. Toda decisão fica na auditoria.',
          'Approving changes the link immediately and only affects future payments. Every decision is audited.',
          'Aprobar cambia el vínculo al instante y solo afecta pagos futuros. Toda decisión queda en la auditoría.',
        ),
      ),
      FilterBar(children: [
        Select<String>(
          label: t('Situação', 'Status', 'Estado'),
          value: _status,
          items: {
            'pending': t('Pendentes', 'Pending', 'Pendientes'),
            'approved': t('Aprovadas', 'Approved', 'Aprobadas'),
            'rejected': t('Recusadas', 'Declined', 'Rechazadas'),
            '': t('Todas', 'All', 'Todas'),
          },
          onChanged: (v) => setState(() {
            _status = v;
            _offset = 0;
          }),
        ),
      ]),
      Panel(
        child: Loader<Map<String, dynamic>>(
          loader: () => api.changeRequests(status: _status.isEmpty ? null : _status, limit: _kPageSize, offset: _offset),
          keys: [_status, _offset, _reload],
          builder: (context, d, _) {
            final rows = _rows(d['rows']);
            if (rows.isEmpty) {
              return EmptyState(
                icon: LucideIcons.clipboardList,
                message: t('Nenhuma solicitação nesta situação.', 'No requests in this status.', 'Sin solicitudes en este estado.'),
              );
            }
            return Column(children: [
              PortalTable(
                columns: [
                  PortalColumn(t('Situação', 'Status', 'Estado')),
                  PortalColumn(t('Aluno', 'Student', 'Alumno'), flex: 2),
                  PortalColumn(t('Troca solicitada', 'Requested change', 'Cambio solicitado'), flex: 3),
                  PortalColumn(t('Motivo', 'Reason', 'Motivo'), flex: 2),
                  PortalColumn(t('Data', 'Date', 'Fecha')),
                  PortalColumn(t('Ações / decisão', 'Actions / decision', 'Acciones / decisión'), flex: 3),
                ],
                rows: [
                  for (final r in rows)
                    [
                      switch ('${r['status']}') {
                        'pending' => StatusBadge(t('Pendente', 'Pending', 'Pendiente'), tone: Tone.warn),
                        'approved' => StatusBadge(t('Aprovada', 'Approved', 'Aprobada'), tone: Tone.good),
                        _ => StatusBadge(t('Recusada', 'Declined', 'Rechazada'), tone: Tone.bad),
                      },
                      TextButton(
                        onPressed: () => context.go('/partners/users/${r['student_id']}'),
                        child: Text('${r['student_name'] ?? '—'}'),
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${r['from_name'] ?? '—'}  →  ${r['to_name'] ?? '—'}'),
                        if (r['to_active'] != true)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: StatusBadge(t('Destino inativo', 'Target inactive', 'Destino inactivo'), tone: Tone.bad),
                          ),
                      ]),
                      Text('${r['reason'] ?? '—'}'),
                      Text(t.dateOf(r['requested_at'])),
                      r['status'] == 'pending'
                          ? Wrap(spacing: 8, runSpacing: 6, children: [
                              ElevatedButton(
                                onPressed: r['to_active'] == true ? () => _review(r, true) : null,
                                child: Text(t('Aprovar', 'Approve', 'Aprobar')),
                              ),
                              OutlinedButton(onPressed: () => _review(r, false), child: Text(t('Recusar', 'Decline', 'Rechazar'))),
                            ])
                          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${t.dateOf(r['reviewed_at'])} · ${r['reviewer_name'] ?? '—'}', style: _small(context)),
                              if (r['review_note'] != null)
                                Text('${r['review_note']}', style: TextStyle(fontSize: _kSmallText, color: c.muted)),
                            ]),
                    ],
                ],
              ),
              Pager(total: (d['total'] as num).toInt(), offset: _offset, limit: _kPageSize, onPage: (o) => setState(() => _offset = o)),
            ]);
          },
        ),
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Assinaturas
// ---------------------------------------------------------------------------
class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});
  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  String _source = '';
  String _state = '';
  String _search = '';
  int _offset = 0;

  /// Origens com cobrança real; as demais são acesso gratuito (não entram como receita).
  static const _paidSources = {'apple', 'google', 'web'};

  void _set(VoidCallback f) => setState(() {
        f();
        _offset = 0;
      });

  String _stateText(PortalStrings t, Map<String, dynamic> r) {
    final s = '${r['state']}';
    if (s == 'grace') return t('Em tolerância', 'In grace period', 'En tolerancia');
    final end = t.parse(r['ends_at']);
    if (s == 'canceled' && end != null && end.isAfter(DateTime.now())) {
      return t('Cancelada, com acesso', 'Canceled, still has access', 'Cancelada, con acceso');
    }
    return stateLabel(t, s);
  }

  String _sourceText(PortalStrings t, String s) => switch (s) {
        'trial' => t('Teste gratuito', 'Free trial', 'Prueba gratuita'),
        'partner' => t('Parceria (professor)', 'Partnership (teacher)', 'Alianza (profesor)'),
        _ => sourceLabel(t, s),
      };

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(
        title: t('Assinaturas e acessos', 'Subscriptions and access', 'Suscripciones y accesos'),
        subtitle: t(
          'Dados reais do servidor. As integrações de cobrança (Apple, Google, Mercado Pago) ainda não estão ativas.',
          'Real server data. Billing integrations (Apple, Google, Mercado Pago) are not live yet.',
          'Datos reales del servidor. Las integraciones de cobro (Apple, Google, Mercado Pago) aún no están activas.',
        ),
      ),
      FilterBar(children: [
        SearchBox(hint: t('Nome ou e-mail', 'Name or e-mail', 'Nombre o correo'), onChanged: (v) => _set(() => _search = v)),
        Select<String>(
          label: t('Origem', 'Source', 'Origen'),
          value: _source,
          items: {
            '': t('Todas', 'All', 'Todas'),
            for (final s in ['apple', 'google', 'web', 'trial', 'courtesy', 'partner', 'admin']) s: _sourceText(t, s),
          },
          onChanged: (v) => _set(() => _source = v),
        ),
        Select<String>(
          label: t('Estado', 'State', 'Estado'),
          value: _state,
          items: {
            '': t('Todos', 'All', 'Todos'),
            for (final s in ['active', 'grace', 'canceled', 'expired', 'refunded', 'revoked', 'pending'])
              s: s == 'grace' ? t('Em tolerância', 'In grace period', 'En tolerancia') : stateLabel(t, s),
          },
          onChanged: (v) => _set(() => _state = v),
        ),
      ]),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            t(
              'Pago = compra em Apple, Google Play ou Web (receita). Sem receita = teste, cortesia, parceria ou administrador: acesso gratuito.',
              'Paid = purchase on Apple, Google Play or Web (revenue). No revenue = trial, courtesy, partnership or administrator: free access.',
              'Pago = compra en Apple, Google Play o Web (ingreso). Sin ingreso = prueba, cortesía, alianza o administrador: acceso gratuito.',
            ),
            style: _small(context),
          ),
          const SizedBox(height: 12),
          Loader<Map<String, dynamic>>(
            loader: () => api.subscriptions(
              source: _source.isEmpty ? null : _source,
              state: _state.isEmpty ? null : _state,
              search: _search.isEmpty ? null : _search,
              limit: _kPageSize,
              offset: _offset,
            ),
            keys: [_source, _state, _search, _offset],
            builder: (context, d, _) {
              final rows = _rows(d['rows']);
              if (rows.isEmpty) {
                return EmptyState(
                  icon: LucideIcons.creditCard,
                  message: t('Nenhum registro para estes filtros.', 'No records for these filters.', 'Sin registros para estos filtros.'),
                );
              }
              return Column(children: [
                PortalTable(
                  columns: [
                    PortalColumn(t('Usuário', 'User', 'Usuario'), flex: 3),
                    PortalColumn(t('Origem', 'Source', 'Origen'), flex: 2),
                    PortalColumn(t('Tipo', 'Type', 'Tipo')),
                    PortalColumn(t('Plano', 'Plan', 'Plan')),
                    PortalColumn(t('Estado', 'State', 'Estado'), flex: 2),
                    PortalColumn(t('Início', 'Start', 'Inicio')),
                    PortalColumn(t('Acesso até', 'Access until', 'Acceso hasta')),
                    PortalColumn(t('Renovação', 'Renewal', 'Renovación')),
                  ],
                  onTap: (i) => context.go('/partners/users/${rows[i]['user_id']}'),
                  rows: [
                    for (final r in rows)
                      [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${r['name'] ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('${r['email']}', style: _small(context)),
                        ]),
                        Text(_sourceText(t, '${r['source']}')),
                        _paidSources.contains(r['source'])
                            ? StatusBadge(t('Pago', 'Paid', 'Pago'), tone: Tone.info)
                            : StatusBadge(t('Sem receita', 'No revenue', 'Sin ingreso')),
                        Text('${r['plan'] ?? '—'}'),
                        StatusBadge(_stateText(t, r), tone: stateTone('${r['state']}')),
                        Text(t.dateOf(r['starts_at'])),
                        Text(r['ends_at'] == null ? t('Sem fim', 'No end', 'Sin fin') : t.dateOf(r['ends_at'])),
                        Text(r['auto_renew'] == null ? '—' : (r['auto_renew'] == true ? t('Automática', 'Auto', 'Automática') : t('Não', 'No', 'No'))),
                      ],
                  ],
                ),
                Pager(total: (d['total'] as num).toInt(), offset: _offset, limit: _kPageSize, onPage: (o) => setState(() => _offset = o)),
              ]);
            },
          ),
        ]),
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Configurações comerciais
// ---------------------------------------------------------------------------
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(
        title: t('Configurações comerciais', 'Commercial settings', 'Configuración comercial'),
        subtitle: t(
          'Valem para todos os usuários e ficam registradas na auditoria.',
          'Apply to all users and are recorded in the audit log.',
          'Valen para todos los usuarios y quedan en la auditoría.',
        ),
      ),
      Loader<Map<String, dynamic>>(
        loader: api.config,
        builder: (context, c, reload) => _SettingsBody(api: api, config: c, reload: reload),
      ),
    ]);
  }
}

class _SettingsBody extends StatefulWidget {
  const _SettingsBody({required this.api, required this.config, required this.reload});
  final PortalApi api;
  final Map<String, dynamic> config;
  final Future<void> Function() reload;
  @override
  State<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<_SettingsBody> {
  // Limites aceitos (os mesmos de antes; o servidor revalida).
  static const _trialMax = 720;
  static const _essayMax = 50;
  static const _ttlUserMax = 720;
  static const _ttlStaffMax = 168;
  static const _pctMax = 100;
  static const _hoursPerDay = 24;
  static const _formGap = 12.0;
  static const _twoColumnsFrom = 700.0;
  static final _versionRe = RegExp(r'^\d+(\.\d+){0,2}$');

  late final _trial = TextEditingController(text: '${widget.config['trial_hours']}');
  late final _essay = TextEditingController(text: '${widget.config['essay_daily_limit']}');
  late final _ttlUser = TextEditingController(text: '${widget.config['offline_ttl_hours_user']}');
  late final _ttlStaff = TextEditingController(text: '${widget.config['offline_ttl_hours_staff']}');
  late final _commission = TextEditingController(text: '${(widget.config['default_commission_bps'] as num) / 100}');
  late final _vAndroid = TextEditingController(text: '${widget.config['min_version_android'] ?? ''}');
  late final _vIos = TextEditingController(text: '${widget.config['min_version_ios'] ?? ''}');
  late final _vWeb = TextEditingController(text: '${widget.config['min_version_web'] ?? ''}');
  late final List<TextEditingController> _all = [_commission, _trial, _essay, _ttlUser, _ttlStaff, _vAndroid, _vIos, _vWeb];
  late List<String> _base = _snapshot();
  bool _busy = false;

  List<String> _snapshot() => [for (final c in _all) c.text.trim()];

  @override
  void initState() {
    super.initState();
    for (final c in _all) {
      c.addListener(_refresh);
    }
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _dirty {
    final now = _snapshot();
    for (var i = 0; i < now.length; i++) {
      if (now[i] != _base[i]) return true;
    }
    return false;
  }

  bool _intOk(TextEditingController c, int min, int max) {
    final v = int.tryParse(c.text.trim());
    return v != null && v >= min && v <= max;
  }

  bool _pctOk() {
    final v = double.tryParse(_commission.text.trim().replaceAll(',', '.'));
    return v != null && v >= 0 && v <= _pctMax;
  }

  bool _verOk(TextEditingController c) => c.text.trim().isEmpty || _versionRe.hasMatch(c.text.trim());

  bool get _valid =>
      _intOk(_trial, 1, _trialMax) &&
      _intOk(_essay, 0, _essayMax) &&
      _intOk(_ttlUser, 1, _ttlUserMax) &&
      _intOk(_ttlStaff, 1, _ttlStaffMax) &&
      _pctOk() &&
      _verOk(_vAndroid) &&
      _verOk(_vIos) &&
      _verOk(_vWeb);

  String _hoursText(PortalStrings t, TextEditingController c) {
    final h = int.tryParse(c.text.trim());
    if (h == null) return '';
    final unit = t('horas', 'hours', 'horas');
    if (h >= _hoursPerDay && h % _hoursPerDay == 0) {
      final d = h ~/ _hoursPerDay;
      return '$h $unit ($d ${d == 1 ? t('dia', 'day', 'día') : t('dias', 'days', 'días')})';
    }
    return '$h $unit';
  }

  void _discard() {
    for (var i = 0; i < _all.length; i++) {
      _all[i].text = _base[i];
    }
  }

  Future<void> _save() async {
    final t = PortalStrings.read(context);
    if (!_valid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t('Há valores fora do permitido. Confira os campos.', 'Some values are out of range. Check the fields.', 'Hay valores fuera de rango. Revisa los campos.')),
      ));
      return;
    }
    final trial = int.parse(_trial.text.trim());
    final essay = int.parse(_essay.text.trim());
    final ttlU = int.parse(_ttlUser.text.trim());
    final ttlS = int.parse(_ttlStaff.text.trim());
    final pct = double.parse(_commission.text.trim().replaceAll(',', '.'));
    final labels = [
      t('Comissão padrão', 'Default commission', 'Comisión predeterminada'),
      t('Duração do teste', 'Trial length', 'Duración de la prueba'),
      t('Limite diário de redações', 'Daily essay limit', 'Límite diario de redacciones'),
      t('Offline (usuários)', 'Offline (users)', 'Offline (usuarios)'),
      t('Offline (equipe)', 'Offline (staff)', 'Offline (equipo)'),
      t('Versão mínima Android', 'Minimum Android version', 'Versión mínima Android'),
      t('Versão mínima iOS', 'Minimum iOS version', 'Versión mínima iOS'),
      t('Versão mínima Web', 'Minimum Web version', 'Versión mínima Web'),
    ];
    final now = _snapshot();
    final changed = [for (var i = 0; i < now.length; i++) if (now[i] != _base[i]) i];
    final versionChanged = changed.any((i) => i >= 5);
    final ok = await confirmDialog(
      context,
      title: t('Salvar configurações?', 'Save settings?', '¿Guardar configuración?'),
      message: '${t('Alterações', 'Changes', 'Cambios')}: ${[for (final i in changed) labels[i]].join(', ')}.\n\n'
          '${t(
        'As mudanças valem para todos os usuários e ficam registradas na auditoria. O percentual padrão só vale para novos professores.',
        'Changes apply to all users and are recorded in the audit log. The default percentage only applies to new teachers.',
        'Los cambios valen para todos los usuarios y quedan en la auditoría. El porcentaje predeterminado solo vale para nuevos profesores.',
      )}'
          '${versionChanged ? '\n\n${t(
              'Atenção: versão mínima pode levar usuários de versões antigas à tela "atualize o app".',
              'Warning: a minimum version can send users on older versions to the "update the app" screen.',
              'Atención: la versión mínima puede llevar a usuarios de versiones antiguas a la pantalla "actualiza la app".',
            )}' : ''}',
      action: t('Salvar', 'Save', 'Guardar'),
      danger: versionChanged,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final done = await runAction(
      context,
      () => widget.api.updateConfig({
        'trial_hours': trial,
        'essay_daily_limit': essay,
        'offline_ttl_hours_user': ttlU,
        'offline_ttl_hours_staff': ttlS,
        'default_commission_bps': (pct * 100).round(),
        'min_version_android': _vAndroid.text.trim(),
        'min_version_ios': _vIos.text.trim(),
        'min_version_web': _vWeb.text.trim(),
      }),
      success: t('Configurações salvas.', 'Settings saved.', 'Configuración guardada.'),
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (done) _base = _snapshot();
    });
    if (done) await widget.reload();
  }

  Future<void> _toggleEmergency(bool value) async {
    final t = PortalStrings.read(context);
    final ok = await confirmDialog(
      context,
      title: value ? t('Ativar bloqueio emergencial?', 'Enable emergency disable?', '¿Activar desactivación de emergencia?') : t('Desativar bloqueio emergencial?', 'Disable emergency disable?', '¿Quitar desactivación de emergencia?'),
      message: value
          ? t('Suspende imediatamente a cobrança/gate: todos voltam a ter acesso liberado.', 'Immediately suspends the paywall/gate: everyone gets open access again.', 'Suspende de inmediato el cobro/gate: todos vuelven a tener acceso libre.')
          : t('O modelo comercial volta a valer, se estiver ligado.', 'The commercial model applies again, if enabled.', 'El modelo comercial vuelve a regir, si está activo.'),
      action: t('Confirmar', 'Confirm', 'Confirmar'),
      danger: value,
    );
    if (!ok || !mounted) return;
    final done = await runAction(context, () => widget.api.updateConfig({'emergency_disable': value}),
        success: t('Atualizado.', 'Updated.', 'Actualizado.'));
    if (done) await widget.reload();
  }

  /// Linha de estado: rótulo + descrição à esquerda, controle compacto à direita.
  Widget _row(BuildContext context, String label, Widget trailing, {String? desc, bool locked = false}) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        if (locked) ...[Icon(LucideIcons.lock, size: 16, color: c.muted), const SizedBox(width: 8)],
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: locked ? c.textSecondary : c.textPrimary)),
            if (desc != null) Text(desc, style: TextStyle(fontSize: _kSmallText, color: c.muted)),
          ]),
        ),
        const SizedBox(width: 12),
        trailing,
      ]),
    );
  }

  Widget _note(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(text, style: TextStyle(fontSize: _kHintText, color: context.colors.muted)),
      );

  Widget _grid(List<Widget> children) => LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth >= _twoColumnsFrom ? (box.maxWidth - _formGap) / 2 : box.maxWidth;
        return Wrap(spacing: _formGap, runSpacing: _formGap, children: [for (final f in children) SizedBox(width: w, child: f)]);
      });

  Widget _num(String label, TextEditingController ctrl, {required bool ok, String? helper, String? suffix, String? hint, bool decimal = false, String? error}) =>
      TextField(
        controller: ctrl,
        keyboardType: decimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
        enabled: !_busy,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          helperText: ok ? helper : null,
          errorText: ok ? null : error,
          isDense: true,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final c = widget.config;
    final colors = context.colors;
    final prices = Map<String, dynamic>.from(c['prices'] as Map);
    final dirty = _dirty;
    final emergency = c['emergency_disable'] == true;
    final range = t('Valor fora do permitido.', 'Value out of range.', 'Valor fuera de rango.');
    final badVer = t('Use o formato 1.2.3.', 'Use the format 1.2.3.', 'Usa el formato 1.2.3.');
    final verHelp = t('Vazio = sem exigência.', 'Empty = no requirement.', 'Vacío = sin exigencia.');

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Panel(
        title: t('Estado comercial', 'Commercial state', 'Estado comercial'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _row(
            context,
            t('Cobrança (modelo comercial)', 'Billing (commercial model)', 'Cobro (modelo comercial)'),
            StatusBadge(c['enforcement_enabled'] == true ? t('Ligada', 'On', 'Activa') : t('Desligada', 'Off', 'Apagada'),
                tone: c['enforcement_enabled'] == true ? Tone.good : Tone.neutral),
            desc: t('Somente informativo.', 'Informational only.', 'Solo informativo.'),
            locked: true,
          ),
          const Divider(height: 1),
          _row(
            context,
            t('Marco de lançamento', 'Launch marker', 'Hito de lanzamiento'),
            c['launch_marker'] == null
                ? StatusBadge(t('Não definido (pré-lançamento)', 'Not set (pre-launch)', 'Sin definir (prelanzamiento)'))
                : Text(t.dateTimeOf(c['launch_marker']), style: const TextStyle(fontSize: 13)),
            desc: t('Somente informativo.', 'Informational only.', 'Solo informativo.'),
            locked: true,
          ),
          const Divider(height: 1),
          _row(
            context,
            t('Confirmação obrigatória de e-mail', 'Required e-mail confirmation', 'Confirmación de correo obligatoria'),
            StatusBadge(c['email_verification_required'] == true ? t('Ligada', 'On', 'Activa') : t('Desligada', 'Off', 'Apagada'),
                tone: c['email_verification_required'] == true ? Tone.good : Tone.neutral),
            desc: t('Somente informativo.', 'Informational only.', 'Solo informativo.'),
            locked: true,
          ),
          const Divider(height: 1),
          _row(
            context,
            t('Bloqueio emergencial', 'Emergency disable', 'Desactivación de emergencia'),
            Row(mainAxisSize: MainAxisSize.min, children: [
              StatusBadge(emergency ? t('Ativo', 'Active', 'Activo') : t('Inativo', 'Inactive', 'Inactivo'), tone: emergency ? Tone.bad : Tone.neutral),
              const SizedBox(width: 8),
              Switch(value: emergency, onChanged: _toggleEmergency),
            ]),
            desc: t('Editável: suspende a cobrança e libera o acesso a todos.', 'Editable: suspends billing and opens access for everyone.', 'Editable: suspende el cobro y libera el acceso a todos.'),
          ),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(LucideIcons.lock, size: 16, color: colors.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t(
                  'A ativação da cobrança está bloqueada neste portal até a etapa de lançamento. Ela exige checklist operacional e ação deliberada fora desta tela.',
                  'Enabling billing is locked in this portal until the launch stage. It requires the operational checklist and a deliberate action outside this screen.',
                  'La activación del cobro está bloqueada en este portal hasta la etapa de lanzamiento. Requiere checklist operativo y una acción deliberada fuera de esta pantalla.',
                ),
                style: TextStyle(fontSize: _kSmallText, color: colors.textSecondary),
              ),
            ),
          ]),
        ]),
      ),
      const SizedBox(height: kCardGap),
      Panel(
        title: t('Preços de referência', 'Reference prices', 'Precios de referencia'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          KeyValue(t('Mensal', 'Monthly', 'Mensual'), Text(t.money(prices['monthly_cents'] as num))),
          KeyValue(t('Anual', 'Annual', 'Anual'), Text(t.money(prices['annual_cents'] as num))),
          _note(
            context,
            t(
              'Referência única do servidor, somente leitura. O preço realmente cobrado é definido nas lojas/provedores (Apple, Google Play, Mercado Pago); este portal não o altera.',
              'Single server reference, read only. The price actually charged is set in the stores/providers (Apple, Google Play, Mercado Pago); this portal does not change it.',
              'Referencia única del servidor, solo lectura. El precio realmente cobrado se define en las tiendas/proveedores (Apple, Google Play, Mercado Pago); este portal no lo cambia.',
            ),
          ),
        ]),
      ),
      const SizedBox(height: kCardGap),
      Panel(
        title: t('Programa de professores', 'Teacher program', 'Programa de profesores'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _grid([
            _num(t('Comissão padrão', 'Default commission', 'Comisión predeterminada'), _commission,
                ok: _pctOk(), suffix: '%', decimal: true, error: range, helper: t('Só vale para novos professores.', 'Only applies to new teachers.', 'Solo vale para nuevos profesores.')),
          ]),
          const SizedBox(height: kCardGap),
          KeyValue(
            t('Repasse', 'Payout', 'Pago'),
            Text(t('Manual, dia ${c['payout_day'] ?? 1} de cada mês, sem valor mínimo', 'Manual, on day ${c['payout_day'] ?? 1} of each month, no minimum', 'Manual, el día ${c['payout_day'] ?? 1} de cada mes, sin mínimo')),
          ),
        ]),
      ),
      const SizedBox(height: kCardGap),
      Panel(
        title: t('Experiência e acesso', 'Experience and access', 'Experiencia y acceso'),
        child: _grid([
          _num(t('Duração do teste', 'Trial length', 'Duración de la prueba'), _trial,
              ok: _intOk(_trial, 1, _trialMax), suffix: t('horas', 'hours', 'horas'), error: range, helper: _hoursText(t, _trial)),
          _num(t('Limite diário de redações', 'Daily essay limit', 'Límite diario de redacciones'), _essay,
              ok: _intOk(_essay, 0, _essayMax), suffix: t('por dia', 'per day', 'por día'), error: range, helper: t('0 = sem redações.', '0 = no essays.', '0 = sin redacciones.')),
          _num(t('Autorização offline: usuários', 'Offline authorization: users', 'Autorización offline: usuarios'), _ttlUser,
              ok: _intOk(_ttlUser, 1, _ttlUserMax), suffix: t('horas', 'hours', 'horas'), error: range, helper: _hoursText(t, _ttlUser)),
          _num(t('Autorização offline: equipe', 'Offline authorization: staff', 'Autorización offline: equipo'), _ttlStaff,
              ok: _intOk(_ttlStaff, 1, _ttlStaffMax), suffix: t('horas', 'hours', 'horas'), error: range, helper: _hoursText(t, _ttlStaff)),
        ]),
      ),
      const SizedBox(height: kCardGap),
      Panel(
        title: t('Versões mínimas', 'Minimum versions', 'Versiones mínimas'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _grid([
            _num(t('Android', 'Android', 'Android'), _vAndroid, ok: _verOk(_vAndroid), hint: '1.2.3', error: badVer, helper: verHelp),
            _num(t('iOS', 'iOS', 'iOS'), _vIos, ok: _verOk(_vIos), hint: '1.2.3', error: badVer, helper: verHelp),
            _num(t('Web', 'Web', 'Web'), _vWeb, ok: _verOk(_vWeb), hint: '1.2.3', error: badVer, helper: verHelp),
          ]),
          _note(
            context,
            t(
              'Quem estiver numa versão menor vê a tela "atualize o app". A versão só orienta essa tela; a autorização é sempre do servidor.',
              'Anyone on a lower version sees the "update the app" screen. The version only drives that screen; authorization is always server-side.',
              'Quien tenga una versión menor ve la pantalla "actualiza la app". La versión solo orienta esa pantalla; la autorización siempre es del servidor.',
            ),
          ),
        ]),
      ),
      const SizedBox(height: kCardGap),
      Panel(
        child: Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.spaceBetween, crossAxisAlignment: WrapCrossAlignment.center, children: [
          dirty
              ? StatusBadge(t('Alterações não salvas', 'Unsaved changes', 'Cambios sin guardar'), tone: Tone.warn)
              : Text(t('Tudo salvo.', 'All saved.', 'Todo guardado.'), style: TextStyle(fontSize: 13, color: colors.textSecondary)),
          Row(mainAxisSize: MainAxisSize.min, children: [
            OutlinedButton(
              onPressed: dirty && !_busy ? _discard : null,
              child: Text(t('Descartar', 'Discard', 'Descartar')),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: dirty && !_busy && _valid ? _save : null,
              child: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(t('Salvar alterações', 'Save changes', 'Guardar cambios')),
            ),
          ]),
        ]),
      ),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Auditoria (somente leitura)
// ---------------------------------------------------------------------------
class AuditPage extends StatefulWidget {
  const AuditPage({super.key});
  @override
  State<AuditPage> createState() => _AuditPageState();
}

class _AuditPageState extends State<AuditPage> {
  static final _uuidRe = RegExp(r'^[0-9a-fA-F-]{36}$');
  String _action = '';
  String _target = '';
  String _actor = '';
  DateTime? _from;
  DateTime? _to;
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
      PageHeader(
        title: t('Auditoria administrativa', 'Administrative audit', 'Auditoría administrativa'),
        subtitle: t('Registro imutável; somente consulta. Segredos e chaves Pix não aparecem.', 'Immutable log; read only. Secrets and Pix keys are hidden.', 'Registro inmutable; solo lectura. Secretos y claves Pix no aparecen.'),
      ),
      FilterBar(
        children: [
          Loader<List<String>>(
            loader: api.auditActions,
            builder: (context, actions, _) => Select<String>(
              label: t('Ação', 'Action', 'Acción'),
              value: _action,
              items: {'': t('Todas', 'All', 'Todas'), for (final a in actions) a: a},
              onChanged: (v) => _set(() => _action = v),
            ),
          ),
          SearchBox(
            hint: t('ID do usuário/professor', 'User/teacher ID', 'ID de usuario/profesor'),
            onChanged: (v) => _set(() => _target = v),
          ),
          SearchBox(
            hint: t('ID do administrador', 'Administrator ID', 'ID del administrador'),
            onChanged: (v) => _set(() => _actor = v),
          ),
          SizedBox(
            height: kControlH,
            child: OutlinedButton.icon(
              onPressed: () async {
                final r = await showDateRangePicker(context: context, firstDate: DateTime(2025), lastDate: DateTime.now());
                if (r == null) return;
                _set(() {
                  _from = r.start;
                  _to = r.end;
                });
              },
              icon: const Icon(LucideIcons.calendarRange, size: 18),
              label: Text(_from == null ? t('Período', 'Period', 'Periodo') : '${t.date(_from)} – ${t.date(_to)}'),
            ),
          ),
          if (_from != null)
            IconButton(
              tooltip: t('Limpar período', 'Clear period', 'Limpiar periodo'),
              onPressed: () => _set(() {
                _from = null;
                _to = null;
              }),
              icon: const Icon(LucideIcons.x),
            ),
        ],
      ),
      Panel(
        child: Loader<Map<String, dynamic>>(
          loader: () => api.audit(
            actor: _uuidRe.hasMatch(_actor) ? _actor : null,
            action: _action.isEmpty ? null : _action,
            target: _target.isEmpty ? null : _target,
            from: _from,
            to: _to,
            limit: _kPageSize,
            offset: _offset,
          ),
          keys: [_action, _target, _actor, _from, _to, _offset],
          builder: (context, d, _) {
            final rows = _rows(d['rows']);
            if (rows.isEmpty) {
              return EmptyState(icon: LucideIcons.shieldCheck, message: t('Nenhum registro encontrado.', 'No records found.', 'No se encontraron registros.'));
            }
            return Column(children: [
              PortalTable(
                columns: [
                  PortalColumn(t('Data/hora', 'Date/time', 'Fecha/hora'), flex: 2),
                  PortalColumn(t('Administrador', 'Administrator', 'Administrador'), flex: 2),
                  PortalColumn(t('Ação', 'Action', 'Acción'), flex: 2),
                  PortalColumn(t('Entidade', 'Entity', 'Entidad'), flex: 2),
                  PortalColumn(t('Resultado', 'Result', 'Resultado')),
                  PortalColumn(t('Detalhes', 'Details', 'Detalles'), flex: 3),
                ],
                onTap: (i) => showDialog<void>(
                  context: context,
                  builder: (_) => _AuditDialog(api: api, row: rows[i]),
                ),
                rows: [
                  for (final r in rows)
                    [
                      Text(t.dateTimeOf(r['at'])),
                      Text('${r['actor_name'] ?? (r['actor_id'] == null ? t('Sistema', 'System', 'Sistema') : '—')}'),
                      Text('${r['action']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${r['target_name'] ?? r['target_id'] ?? '—'}${r['target_type'] == null ? '' : ' (${r['target_type']})'}'),
                      // O log só grava operações concluídas.
                      StatusBadge(t('Registrada', 'Recorded', 'Registrada'), tone: Tone.good),
                      Row(children: [
                        Expanded(child: Text('${r['note'] ?? t('Ver detalhes', 'View details', 'Ver detalles')}', maxLines: 2, overflow: TextOverflow.ellipsis)),
                        const Icon(LucideIcons.chevronRight, size: 18),
                      ]),
                    ],
                ],
              ),
              Pager(total: (d['total'] as num).toInt(), offset: _offset, limit: _kPageSize, onPage: (o) => setState(() => _offset = o)),
            ]);
          },
        ),
      ),
    ]);
  }
}

/// Defesa extra no cliente: o servidor já remove segredos (`_scrub`), mas nunca exibimos
/// senha/token/chave mesmo que algum chegue.
final _sensitiveKey = RegExp(r'pass|senha|token|secret|api_?key|pix|authorization', caseSensitive: false);
const _kMasked = '••••••';

dynamic _redact(dynamic v) {
  if (v is Map) {
    return {for (final e in v.entries) '${e.key}': _sensitiveKey.hasMatch('${e.key}') ? _kMasked : _redact(e.value)};
  }
  if (v is List) return v.map(_redact).toList();
  return v;
}

String _fmt(dynamic v) {
  if (v == null) return '—';
  if (v is Map || v is List) return jsonEncode(v);
  return '$v';
}

class _AuditDialog extends StatelessWidget {
  const _AuditDialog({required this.api, required this.row});
  final PortalApi api;
  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final c = context.colors;
    final before = _redact(row['before']);
    final after = _redact(row['after']);

    Widget title(String s) => Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(s, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c.textPrimary)),
        );

    Widget kv(String k, String v, {Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 160, child: Text(k, style: TextStyle(fontSize: _kSmallText, color: c.textSecondary))),
            Expanded(child: SelectableText(v, style: TextStyle(fontSize: _kSmallText, color: color ?? c.textPrimary))),
          ]),
        );

    // Só os campos que mudaram (antes → depois); sem JSON bruto na tela.
    Widget changes() {
      final b = before is Map ? before : const <String, dynamic>{};
      final a = after is Map ? after : const <String, dynamic>{};
      if (before is! Map && after is! Map) {
        return kv(t('Valor', 'Value', 'Valor'), '${_fmt(before)} → ${_fmt(after)}');
      }
      final keys = ({...b.keys, ...a.keys}.map((k) => '$k').toList()..sort());
      final diff = [for (final k in keys) if (_fmt(b[k]) != _fmt(a[k])) k];
      if (diff.isEmpty) return Text('—', style: _small(context));
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final k in diff) kv(k, '${_fmt(b[k])}  →  ${_fmt(a[k])}'),
      ]);
    }

    final raw = const JsonEncoder.withIndent('  ').convert({'before': before, 'after': after});

    return AlertDialog(
      title: Text('${row['action']}'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            kv(t('Data/hora', 'Date/time', 'Fecha/hora'), t.dateTimeOf(row['at'])),
            kv(t('Administrador', 'Administrator', 'Administrador'), '${row['actor_name'] ?? (row['actor_id'] == null ? t('Sistema', 'System', 'Sistema') : '—')}'),
            kv(t('Entidade', 'Entity', 'Entidad'), '${row['target_name'] ?? ''} ${row['target_type'] ?? ''} ${row['target_id'] ?? ''}'.trim()),
            if (row['note'] != null) kv(t('Nota', 'Note', 'Nota'), '${row['note']}'),
            title(t('O que mudou', 'What changed', 'Qué cambió')),
            changes(),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(t('Dados brutos (JSON)', 'Raw data (JSON)', 'Datos brutos (JSON)'), style: _small(context, bold: true)),
                children: [Align(alignment: Alignment.centerLeft, child: SelectableText(raw, style: const TextStyle(fontSize: _kHintText, fontFamily: 'monospace')))],
              ),
            ),
            Loader<Map<String, dynamic>>(
              loader: () => api.auditNeighbors((row['id'] as num).toInt()),
              builder: (context, n, _) {
                final prev = _rows(n['before']);
                final next = _rows(n['after']);
                String line(Map<String, dynamic> r) => '${t.dateTimeOf(r['at'])} · ${r['action']} · ${r['actor_name'] ?? '—'}';
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  title(t('Registros anteriores do mesmo alvo', 'Earlier entries for the same target', 'Registros anteriores del mismo objetivo')),
                  if (prev.isEmpty) const Text('—') else for (final r in prev) Text(line(r), style: _small(context)),
                  title(t('Registros posteriores', 'Later entries', 'Registros posteriores')),
                  if (next.isEmpty) const Text('—') else for (final r in next) Text(line(r), style: _small(context)),
                ]);
              },
            ),
          ]),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t('Fechar', 'Close', 'Cerrar')))],
    );
  }
}
