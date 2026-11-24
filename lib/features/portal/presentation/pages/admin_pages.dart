import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/pages/portal_gate.dart';
import 'package:aura/features/portal/presentation/widgets/portal_widgets.dart';

List<Map<String, dynamic>> _rows(dynamic v) => (v as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

// ---------------------------------------------------------------------------
// Solicitações de troca de professor
// ---------------------------------------------------------------------------
class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});
  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  static const _limit = 25;
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
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(
        title: t('Solicitações de troca de professor', 'Teacher change requests', 'Solicitudes de cambio de profesor'),
        actions: [
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
        ],
      ),
      Panel(
        child: Loader<Map<String, dynamic>>(
          loader: () => api.changeRequests(status: _status.isEmpty ? null : _status, limit: _limit, offset: _offset),
          keys: [_status, _offset, _reload],
          builder: (context, d, _) {
            final rows = _rows(d['rows']);
            if (rows.isEmpty) {
              return EmptyState(
                icon: Icons.swap_horiz_rounded,
                message: t('Nenhuma solicitação nesta situação.', 'No requests in this status.', 'Sin solicitudes en este estado.'),
              );
            }
            return Column(children: [
              PortalTable(
                columns: [
                  PortalColumn(t('Aluno', 'Student', 'Alumno'), flex: 2),
                  PortalColumn(t('Professor atual', 'Current teacher', 'Profesor actual'), flex: 2),
                  PortalColumn(t('Solicitado', 'Requested', 'Solicitado'), flex: 2),
                  PortalColumn(t('Motivo', 'Reason', 'Motivo'), flex: 2),
                  PortalColumn(t('Data', 'Date', 'Fecha')),
                  PortalColumn(t('Decisão', 'Decision', 'Decisión'), flex: 2),
                ],
                rows: [
                  for (final r in rows)
                    [
                      TextButton(
                        onPressed: () => context.go('/partners/users/${r['student_id']}'),
                        child: Text('${r['student_name'] ?? '—'}'),
                      ),
                      Text('${r['from_name'] ?? '—'}'),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${r['to_name'] ?? '—'}'),
                        if (r['to_active'] != true) StatusBadge(t('Inativo', 'Inactive', 'Inactivo'), tone: Tone.bad),
                      ]),
                      Text('${r['reason'] ?? '—'}'),
                      Text(t.dateOf(r['requested_at'])),
                      r['status'] == 'pending'
                          ? Wrap(spacing: 6, children: [
                              ElevatedButton(
                                onPressed: r['to_active'] == true ? () => _review(r, true) : null,
                                child: Text(t('Aprovar', 'Approve', 'Aprobar')),
                              ),
                              OutlinedButton(onPressed: () => _review(r, false), child: Text(t('Recusar', 'Decline', 'Rechazar'))),
                            ])
                          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              StatusBadge(r['status'] == 'approved' ? t('Aprovada', 'Approved', 'Aprobada') : t('Recusada', 'Declined', 'Rechazada'),
                                  tone: r['status'] == 'approved' ? Tone.good : Tone.bad),
                              Text('${t.dateOf(r['reviewed_at'])} · ${r['reviewer_name'] ?? '—'}', style: const TextStyle(fontSize: 11)),
                              if (r['review_note'] != null) Text('${r['review_note']}', style: const TextStyle(fontSize: 11)),
                            ]),
                    ],
                ],
              ),
              Pager(total: (d['total'] as num).toInt(), offset: _offset, limit: _limit, onPage: (o) => setState(() => _offset = o)),
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
  static const _limit = 25;
  String _source = '';
  String _state = '';
  String _search = '';
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
        title: t('Assinaturas e acessos', 'Subscriptions and access', 'Suscripciones y accesos'),
        subtitle: t(
          'Dados reais do servidor. As integrações de cobrança (Apple, Google, Mercado Pago) ainda não estão ativas.',
          'Real server data. Billing integrations (Apple, Google, Mercado Pago) are not live yet.',
          'Datos reales del servidor. Las integraciones de cobro (Apple, Google, Mercado Pago) aún no están activas.',
        ),
      ),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 10, runSpacing: 10, children: [
            SearchBox(hint: t('Nome ou e-mail', 'Name or e-mail', 'Nombre o correo'), onChanged: (v) => _set(() => _search = v)),
            Select<String>(
              label: t('Origem', 'Source', 'Origen'),
              value: _source,
              items: {
                '': t('Todas', 'All', 'Todas'),
                'apple': 'Apple',
                'google': 'Google Play',
                'web': 'Web',
                'trial': t('Teste', 'Trial', 'Prueba'),
                'courtesy': t('Cortesia', 'Courtesy', 'Cortesía'),
                'partner': t('Professor', 'Teacher', 'Profesor'),
                'admin': t('Administrador', 'Administrator', 'Administrador'),
              },
              onChanged: (v) => _set(() => _source = v),
            ),
            Select<String>(
              label: t('Estado', 'State', 'Estado'),
              value: _state,
              items: {
                '': t('Todos', 'All', 'Todos'),
                for (final s in ['active', 'expired', 'canceled', 'refunded', 'revoked', 'pending']) s: stateLabel(t, s),
              },
              onChanged: (v) => _set(() => _state = v),
            ),
          ]),
          const SizedBox(height: 12),
          Loader<Map<String, dynamic>>(
            loader: () => api.subscriptions(
              source: _source.isEmpty ? null : _source,
              state: _state.isEmpty ? null : _state,
              search: _search.isEmpty ? null : _search,
              limit: _limit,
              offset: _offset,
            ),
            keys: [_source, _state, _search, _offset],
            builder: (context, d, _) {
              final rows = _rows(d['rows']);
              if (rows.isEmpty) {
                return EmptyState(
                  icon: Icons.workspace_premium_outlined,
                  message: t('Nenhum registro para estes filtros.', 'No records for these filters.', 'Sin registros para estos filtros.'),
                );
              }
              return Column(children: [
                PortalTable(
                  columns: [
                    PortalColumn(t('Usuário', 'User', 'Usuario'), flex: 3),
                    PortalColumn(t('Origem', 'Source', 'Origen')),
                    PortalColumn(t('Plano', 'Plan', 'Plan')),
                    PortalColumn(t('Estado', 'State', 'Estado')),
                    PortalColumn(t('Início', 'Start', 'Inicio')),
                    PortalColumn(t('Fim', 'End', 'Fin')),
                    PortalColumn(t('Renovação', 'Renewal', 'Renovación')),
                  ],
                  onTap: (i) => context.go('/partners/users/${rows[i]['user_id']}'),
                  rows: [
                    for (final r in rows)
                      [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${r['name'] ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('${r['email']}', style: const TextStyle(fontSize: 12)),
                        ]),
                        Text(sourceLabel(t, '${r['source']}')),
                        Text('${r['plan'] ?? '—'}'),
                        StatusBadge(stateLabel(t, '${r['state']}'), tone: stateTone('${r['state']}')),
                        Text(t.dateOf(r['starts_at'])),
                        Text(r['ends_at'] == null ? t('Sem fim', 'No end', 'Sin fin') : t.dateOf(r['ends_at'])),
                        Text(r['auto_renew'] == null ? '—' : (r['auto_renew'] == true ? t('Automática', 'Auto', 'Automática') : t('Não', 'No', 'No'))),
                      ],
                  ],
                ),
                Pager(total: (d['total'] as num).toInt(), offset: _offset, limit: _limit, onPage: (o) => setState(() => _offset = o)),
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
      PageHeader(title: t('Configurações comerciais', 'Commercial settings', 'Configuración comercial')),
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
  late final _trial = TextEditingController(text: '${widget.config['trial_hours']}');
  late final _essay = TextEditingController(text: '${widget.config['essay_daily_limit']}');
  late final _ttlUser = TextEditingController(text: '${widget.config['offline_ttl_hours_user']}');
  late final _ttlStaff = TextEditingController(text: '${widget.config['offline_ttl_hours_staff']}');
  late final _commission = TextEditingController(text: '${(widget.config['default_commission_bps'] as num) / 100}');
  late final _vAndroid = TextEditingController(text: '${widget.config['min_version_android'] ?? ''}');
  late final _vIos = TextEditingController(text: '${widget.config['min_version_ios'] ?? ''}');
  late final _vWeb = TextEditingController(text: '${widget.config['min_version_web'] ?? ''}');
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_trial, _essay, _ttlUser, _ttlStaff, _commission, _vAndroid, _vIos, _vWeb]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final t = PortalStrings.read(context);
    final trial = int.tryParse(_trial.text.trim());
    final essay = int.tryParse(_essay.text.trim());
    final ttlU = int.tryParse(_ttlUser.text.trim());
    final ttlS = int.tryParse(_ttlStaff.text.trim());
    final pct = double.tryParse(_commission.text.trim().replaceAll(',', '.'));
    bool ver(String v) => v.isEmpty || RegExp(r'^\d+(\.\d+){0,2}$').hasMatch(v);
    final bad = trial == null || trial < 1 || trial > 720 ||
        essay == null || essay < 0 || essay > 50 ||
        ttlU == null || ttlU < 1 || ttlU > 720 ||
        ttlS == null || ttlS < 1 || ttlS > 168 ||
        pct == null || pct < 0 || pct > 100 ||
        !ver(_vAndroid.text.trim()) || !ver(_vIos.text.trim()) || !ver(_vWeb.text.trim());
    if (bad) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t('Há valores fora do permitido. Confira os campos.', 'Some values are out of range. Check the fields.', 'Hay valores fuera de rango. Revisa los campos.')),
      ));
      return;
    }
    final ok = await confirmDialog(
      context,
      title: t('Salvar configurações?', 'Save settings?', '¿Guardar configuración?'),
      message: t(
        'As mudanças valem para todos os usuários e ficam registradas na auditoria. O percentual padrão só vale para novos professores.',
        'Changes apply to all users and are recorded in the audit log. The default percentage only applies to new teachers.',
        'Los cambios valen para todos los usuarios y quedan en la auditoría. El porcentaje predeterminado solo vale para nuevos profesores.',
      ),
      action: t('Salvar', 'Save', 'Guardar'),
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
    setState(() => _busy = false);
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

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final c = widget.config;
    final prices = Map<String, dynamic>.from(c['prices'] as Map);
    Widget flag(String label, bool on, {String? onLabel, String? offLabel}) => KeyValue(
          label,
          StatusBadge(on ? (onLabel ?? t('Ligado', 'On', 'Activo')) : (offLabel ?? t('Desligado', 'Off', 'Apagado')), tone: on ? Tone.good : Tone.neutral),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Panel(
        title: t('Estado do modelo comercial', 'Commercial model state', 'Estado del modelo comercial'),
        child: Column(children: [
          flag(t('Cobrança (modelo comercial)', 'Billing (commercial model)', 'Cobro (modelo comercial)'), c['enforcement_enabled'] == true),
          KeyValue(t('Marco de lançamento', 'Launch marker', 'Hito de lanzamiento'), Text(c['launch_marker'] == null ? t('Não definido (antes do lançamento)', 'Not set (pre-launch)', 'Sin definir (antes del lanzamiento)') : t.dateTimeOf(c['launch_marker']))),
          flag(t('Confirmação obrigatória de e-mail', 'Required e-mail confirmation', 'Confirmación de correo obligatoria'), c['email_verification_required'] == true),
          KeyValue(
            t('Bloqueio emergencial', 'Emergency disable', 'Desactivación de emergencia'),
            Row(children: [
              Switch(value: c['emergency_disable'] == true, onChanged: _toggleEmergency),
              Flexible(child: Text(c['emergency_disable'] == true ? t('Ativo', 'Active', 'Activo') : t('Inativo', 'Inactive', 'Inactivo'), overflow: TextOverflow.ellipsis)),
            ]),
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.lock_outline_rounded, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t(
                  'A ativação da cobrança está bloqueada neste portal até a etapa de lançamento. Ela exige checklist operacional e ação deliberada fora desta tela.',
                  'Enabling billing is locked in this portal until the launch stage. It requires the operational checklist and a deliberate action outside this screen.',
                  'La activación del cobro está bloqueada en este portal hasta la etapa de lanzamiento. Requiere checklist operativo y una acción deliberada fuera de esta pantalla.',
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      Panel(
        title: t('Preços de referência', 'Reference prices', 'Precios de referencia'),
        child: Column(children: [
          KeyValue(t('Mensal', 'Monthly', 'Mensual'), Text(t.money(prices['monthly_cents'] as num))),
          KeyValue(t('Anual', 'Annual', 'Anual'), Text(t.money(prices['annual_cents'] as num))),
          KeyValue(t('Repasse a professores', 'Teacher payouts', 'Pago a profesores'), Text(t('Manual, dia 01 de cada mês, sem valor mínimo', 'Manual, on the 1st of each month, no minimum', 'Manual, el día 1 de cada mes, sin mínimo'))),
          Text(
            t(
              'Os valores cobrados de fato são definidos nas lojas/provedores; este portal não os altera.',
              'Amounts actually charged are set in the stores/providers; this portal does not change them.',
              'Los importes cobrados se definen en las tiendas/proveedores; este portal no los cambia.',
            ),
            style: const TextStyle(fontSize: 11),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      Panel(
        title: t('Parâmetros', 'Parameters', 'Parámetros'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          LayoutBuilder(builder: (context, box) {
            final w = box.maxWidth >= 700 ? (box.maxWidth - 12) / 2 : box.maxWidth;
            Widget f(String label, TextEditingController ctrl, {String? hint}) => SizedBox(
                  width: w,
                  child: Field(label: label, controller: ctrl, hint: hint, keyboard: TextInputType.number),
                );
            return Wrap(spacing: 12, children: [
              f(t('Percentual padrão de comissão (%)', 'Default commission (%)', 'Comisión predeterminada (%)'), _commission),
              f(t('Duração do teste (horas)', 'Trial length (hours)', 'Duración de la prueba (horas)'), _trial),
              f(t('Limite diário de redações', 'Daily essay limit', 'Límite diario de redacciones'), _essay),
              f(t('Autorização offline — usuários (horas)', 'Offline authorization — users (hours)', 'Autorización offline — usuarios (horas)'), _ttlUser),
              f(t('Autorização offline — equipe (horas)', 'Offline authorization — staff (hours)', 'Autorización offline — equipo (horas)'), _ttlStaff),
              SizedBox(width: w, child: Field(label: t('Versão mínima Android', 'Minimum Android version', 'Versión mínima Android'), controller: _vAndroid, hint: '1.2.3')),
              SizedBox(width: w, child: Field(label: t('Versão mínima iOS', 'Minimum iOS version', 'Versión mínima iOS'), controller: _vIos, hint: '1.2.3')),
              SizedBox(width: w, child: Field(label: t('Versão mínima Web', 'Minimum Web version', 'Versión mínima Web'), controller: _vWeb, hint: '1.2.3')),
            ]);
          }),
          Text(
            t('A versão mínima só orienta a tela "atualize o app"; a autorização é sempre do servidor.', 'The minimum version only drives the "update the app" screen; authorization is always server-side.', 'La versión mínima solo orienta la pantalla "actualiza la app"; la autorización siempre es del servidor.'),
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _busy ? null : _save, child: Text(t('Salvar parâmetros', 'Save parameters', 'Guardar parámetros'))),
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
  static const _limit = 25;
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
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
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
            OutlinedButton.icon(
              onPressed: () async {
                final r = await showDateRangePicker(context: context, firstDate: DateTime(2025), lastDate: DateTime.now());
                if (r == null) return;
    _set(() {
                  _from = r.start;
                  _to = r.end;
                });
              },
              icon: const Icon(Icons.date_range_rounded, size: 18),
              label: Text(_from == null ? t('Período', 'Period', 'Periodo') : '${t.date(_from)} – ${t.date(_to)}'),
            ),
            if (_from != null)
              IconButton(onPressed: () => _set(() {
                    _from = null;
                    _to = null;
                  }), icon: const Icon(Icons.close_rounded)),
          ]),
          const SizedBox(height: 12),
          Loader<Map<String, dynamic>>(
            loader: () => api.audit(
              actor: RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(_actor) ? _actor : null,
              action: _action.isEmpty ? null : _action,
              target: _target.isEmpty ? null : _target,
              from: _from,
              to: _to,
              limit: _limit,
              offset: _offset,
            ),
            keys: [_action, _target, _actor, _from, _to, _offset],
            builder: (context, d, _) {
              final rows = _rows(d['rows']);
              if (rows.isEmpty) {
                return EmptyState(icon: Icons.fact_check_outlined, message: t('Nenhum registro encontrado.', 'No records found.', 'No se encontraron registros.'));
              }
              return Column(children: [
                PortalTable(
                  columns: [
                    PortalColumn(t('Quando', 'When', 'Cuándo'), flex: 2),
                    PortalColumn(t('Administrador', 'Administrator', 'Administrador'), flex: 2),
                    PortalColumn(t('Ação', 'Action', 'Acción'), flex: 2),
                    PortalColumn(t('Alvo', 'Target', 'Objetivo'), flex: 2),
                    PortalColumn(t('Nota', 'Note', 'Nota'), flex: 2),
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
                        Text('${r['target_name'] ?? r['target_id'] ?? '—'}'),
                        Text('${r['note'] ?? ''}'),
                      ],
                  ],
                ),
                Pager(total: (d['total'] as num).toInt(), offset: _offset, limit: _limit, onPage: (o) => setState(() => _offset = o)),
              ]);
            },
          ),
        ]),
      ),
    ]);
  }
}

String _pretty(dynamic v) {
  if (v == null) return '—';
  if (v is Map) return v.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  return '$v';
}

class _AuditDialog extends StatelessWidget {
  const _AuditDialog({required this.api, required this.row});
  final PortalApi api;
  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    Widget block(String title, dynamic v) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            SelectableText(_pretty(v), style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
          ]),
        );
    return AlertDialog(
      title: Text('${row['action']}'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${t.dateTimeOf(row['at'])} · ${row['actor_name'] ?? '—'} · ${row['target_type'] ?? ''} ${row['target_id'] ?? ''}',
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            block(t('Antes', 'Before', 'Antes'), row['before']),
            block(t('Depois', 'After', 'Después'), row['after']),
            if (row['note'] != null) block(t('Nota', 'Note', 'Nota'), row['note']),
            Loader<Map<String, dynamic>>(
              loader: () => api.auditNeighbors((row['id'] as num).toInt()),
              builder: (context, n, _) {
                final before = _rows(n['before']);
                final after = _rows(n['after']);
                String line(Map<String, dynamic> r) => '${t.dateTimeOf(r['at'])} · ${r['action']} · ${r['actor_name'] ?? '—'}';
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t('Registros anteriores do mesmo alvo', 'Earlier entries for the same target', 'Registros anteriores del mismo objetivo'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  if (before.isEmpty) const Text('—') else for (final r in before) Text(line(r), style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(t('Registros posteriores', 'Later entries', 'Registros posteriores'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  if (after.isEmpty) const Text('—') else for (final r in after) Text(line(r), style: const TextStyle(fontSize: 12)),
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
