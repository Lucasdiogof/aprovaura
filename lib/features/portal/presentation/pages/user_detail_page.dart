import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/pages/portal_gate.dart';
import 'package:aura/features/portal/presentation/pages/users_page.dart';
import 'package:aura/features/portal/presentation/widgets/portal_widgets.dart';

class UserDetailPage extends StatelessWidget {
  const UserDetailPage({required this.userId, super.key});
  final String userId;

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => context.go('/partners/users'),
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: Text(t('Usuários', 'Users', 'Usuarios')),
        ),
      ),
      Loader<Map<String, dynamic>>(
        loader: () => api.user(userId),
        keys: [userId],
        builder: (context, d, reload) => _Detail(data: d, reload: reload),
      ),
    ]);
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.data, required this.reload});
  final Map<String, dynamic> data;
  final Future<void> Function() reload;

  Map<String, dynamic> _m(String k) => Map<String, dynamic>.from(data[k] as Map);
  List<Map<String, dynamic>> _l(dynamic v) =>
      (v as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final acc = _m('account');
    final prem = _m('premium');
    final partner = _m('partner');
    final stats = _m('stats');
    final fin = _m('finance');
    final roles = Map<String, dynamic>.from(acc['roles'] as Map);
    final access = Map<String, dynamic>.from(prem['access'] as Map);
    final id = '${acc['id']}';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(
        title: '${acc['name']}'.isEmpty || acc['name'] == null ? '${acc['email']}' : '${acc['name']}',
        subtitle: '${acc['email']}',
        actions: [
          if (roles['admin'] == true) StatusBadge(t('Administrador', 'Administrator', 'Administrador'), tone: Tone.info),
          if (roles['partner'] == true) StatusBadge(t('Professor', 'Teacher', 'Profesor'), tone: Tone.info),
          if (roles['student'] == true) StatusBadge(t('Aluno', 'Student', 'Alumno')),
        ],
      ),
      _section(t('Dados pessoais', 'Personal data', 'Datos personales'), [
        KeyValue('ID', SelectableText(id)),
        KeyValue('E-mail', Text('${acc['email']}')),
        KeyValue(t('Usuário', 'Username', 'Usuario'), Text(acc['username'] == null ? '—' : '@${acc['username']}')),
        KeyValue(t('Cadastro', 'Signed up', 'Registro'), Text(t.dateTimeOf(acc['created_at']))),
        KeyValue(
          t('E-mail verificado', 'E-mail verified', 'Correo verificado'),
          acc['email_proof'] == null
              ? StatusBadge(t('Sem prova de posse', 'No ownership proof', 'Sin prueba'), tone: Tone.warn)
              : StatusBadge(
                  '${t.dateOf((acc['email_proof'] as Map)['verified_at'])} · ${(acc['email_proof'] as Map)['method']}',
                  tone: Tone.good),
        ),
        KeyValue(t('Último login', 'Last sign-in', 'Último acceso'), Text(t.dateTimeOf(acc['last_sign_in_at']))),
        KeyValue(t('Atividade no app', 'App activity', 'Actividad en la app'),
            Text('${t.dateTimeOf(acc['last_seen_at'])}${acc['last_seen_platform'] == null ? '' : ' · ${acc['last_seen_platform']}'}')),
        KeyValue(t('Último estudo', 'Last study', 'Último estudio'), Text(t.dateTimeOf(acc['last_study_at']))),
        KeyValue(t('Meta, ano da prova', 'Goal, exam year', 'Meta, año del examen'), Text('${acc['goal'] ?? '—'} · ${acc['exam_year'] ?? '—'}')),
      ]),
      _section(
        t('Acesso e assinatura', 'Access and subscription', 'Acceso y suscripción'),
        [
          KeyValue(t('Situação', 'Status', 'Estado'), accessSummary(t, access)),
          KeyValue(t('Vigência', 'Valid until', 'Vigencia'),
              Text(access['indefinite'] == true ? t('Sem data de fim', 'No end date', 'Sin fecha de fin') : t.dateTimeOf(access['access_until']))),
          const SizedBox(height: 8),
          Text(t('Assinaturas e cortesias', 'Subscriptions and courtesies', 'Suscripciones y cortesías'),
              style: const TextStyle(fontWeight: FontWeight.w700)),
          if (_l(prem['entitlements']).isEmpty)
            EmptyState(message: t('Nenhum registro de acesso armazenado.', 'No stored access records.', 'Sin registros de acceso almacenados.'))
          else
            PortalTable(
              columns: [
                PortalColumn(t('Origem', 'Source', 'Origen')),
                PortalColumn(t('Estado', 'State', 'Estado')),
                PortalColumn(t('Início', 'Start', 'Inicio')),
                PortalColumn(t('Fim', 'End', 'Fin')),
                PortalColumn(t('Nota', 'Note', 'Nota'), flex: 2),
                const PortalColumn(''),
              ],
              rows: [
                for (final e in _l(prem['entitlements']))
                  [
                    Text(sourceLabel(t, '${e['source']}')),
                    StatusBadge(stateLabel(t, '${e['effective']}'), tone: stateTone('${e['effective']}')),
                    Text(t.dateOf(e['starts_at'])),
                    Text(e['ends_at'] == null ? t('Sem fim', 'No end', 'Sin fin') : t.dateOf(e['ends_at'])),
                    Text('${e['note'] ?? ''}${e['created_by_name'] == null ? '' : ' (${e['created_by_name']})'}'),
                    if (e['source'] == 'courtesy' && e['effective'] == 'active')
                      TextButton(
                        onPressed: () async {
                          final api = context.read<PortalApi>();
                          final ok = await confirmDialog(context,
                              title: t('Revogar cortesia?', 'Revoke courtesy?', '¿Revocar cortesía?'),
                              message: t(
                                'Somente esta cortesia é encerrada. Outras fontes de acesso continuam valendo.',
                                'Only this courtesy ends. Other access sources stay valid.',
                                'Solo termina esta cortesía. Otras fuentes de acceso siguen vigentes.',
                              ),
                              action: t('Revogar', 'Revoke', 'Revocar'),
                              danger: true);
                          if (!ok || !context.mounted) return;
                          if (await runAction(context, () => api.revokeEntitlement('${e['id']}'),
                              success: t('Cortesia revogada.', 'Courtesy revoked.', 'Cortesía revocada.'))) {
                            await reload();
                          }
                        },
                        child: Text(t('Revogar', 'Revoke', 'Revocar')),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
              ],
            ),
          const SizedBox(height: 8),
          Text(t('Compras Apple, Google e Mercado Pago só mudam pelo provedor; o portal não as altera.',
              'Apple, Google and Mercado Pago purchases only change through the provider; the portal never edits them.',
              'Las compras de Apple, Google y Mercado Pago solo cambian por el proveedor; el portal no las edita.'),
              style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 12),
          Text(t('Histórico de concessões e revogações', 'Grant and revoke history', 'Historial de concesiones y revocaciones'),
              style: const TextStyle(fontWeight: FontWeight.w700)),
          if (_l(prem['audit']).isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(t('Sem registros.', 'No records.', 'Sin registros.')),
            )
          else
            for (final a in _l(prem['audit']))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text('${t.dateTimeOf(a['at'])} · ${a['action']} · ${a['actor_name'] ?? '—'}${a['note'] == null ? '' : ' · ${a['note']}'}',
                    style: const TextStyle(fontSize: 12)),
              ),
        ],
      ),
      _section(t('Indicação', 'Referral', 'Referido'), [
        KeyValue(
          t('Professor atual', 'Current teacher', 'Profesor actual'),
          partner['current'] == null
              ? Text(t('Sem professor', 'No teacher', 'Sin profesor'))
              : Text('${(partner['current'] as Map)['display_name']} · ${t('desde', 'since', 'desde')} ${t.dateOf((partner['current'] as Map)['linked_at'])} · ${(partner['current'] as Map)['source']}'),
        ),
        const SizedBox(height: 8),
        Text(t('Histórico de vinculações', 'Link history', 'Historial de vínculos'), style: const TextStyle(fontWeight: FontWeight.w700)),
        if (_l(partner['history']).isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(t('Sem vínculos.', 'No links.', 'Sin vínculos.')))
        else
          for (final h in _l(partner['history']))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                '${t.dateTimeOf(h['at'])} · ${h['action']} · ${h['from_name'] ?? '—'} → ${h['to_name'] ?? '—'} · ${h['source']}${h['by_name'] == null ? '' : ' · ${h['by_name']}'}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        const SizedBox(height: 8),
        Text(t('Solicitações de alteração', 'Change requests', 'Solicitudes de cambio'), style: const TextStyle(fontWeight: FontWeight.w700)),
        if (_l(partner['requests']).isEmpty)
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(t('Sem solicitações.', 'No requests.', 'Sin solicitudes.')))
        else
          for (final r in _l(partner['requests']))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                '${t.dateOf(r['requested_at'])} · ${r['status']} · ${r['from_name']} → ${r['to_name']}${r['reason'] == null ? '' : ' · "${r['reason']}"'}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
      ]),
      _section(t('Estudo', 'Study', 'Estudio'), [
        CardGrid(minWidth: 150, children: [
          StatCard(label: t('Questões respondidas', 'Questions answered', 'Preguntas respondidas'), value: t.number(stats['answered'] as num)),
          StatCard(
            label: t('Taxa de acertos', 'Accuracy', 'Tasa de aciertos'),
            value: (stats['answered'] as num) == 0 ? '—' : t.percent((stats['correct'] as num) / (stats['answered'] as num)),
          ),
          StatCard(label: 'Aura', value: t.number(stats['aura'] as num), hint: '${t('Nível', 'Level', 'Nivel')} ${stats['level']}'),
          StatCard(
            label: t('Sequência', 'Streak', 'Racha'),
            value: '${(stats['streak'] as Map?)?['current'] ?? 0}',
            hint: '${t('Recorde', 'Best', 'Récord')}: ${(stats['streak'] as Map?)?['longest'] ?? 0}',
          ),
          StatCard(label: t('Hoje (meta diária)', 'Today (daily goal)', 'Hoy (meta diaria)'), value: t.number(stats['answered_today'] as num)),
          StatCard(
            label: t('Simulados', 'Mock exams', 'Simulacros'),
            value: '${(stats['mock_exams'] as Map)['finished']}/${(stats['mock_exams'] as Map)['total']}',
            hint: t.percent((stats['mock_exams'] as Map)['avg_accuracy'] as num?),
          ),
          StatCard(
            label: t('Redações', 'Essays', 'Redacciones'),
            value: '${(stats['essays'] as Map)['evaluated']}/${(stats['essays'] as Map)['submitted']}',
            hint: '${t('Nota média', 'Avg score', 'Nota media')}: ${(stats['essays'] as Map)['avg_score'] ?? '—'}',
          ),
          StatCard(label: t('Regiões (mapas)', 'Regions (maps)', 'Regiones (mapas)'), value: t.number(stats['regions_found'] as num)),
        ]),
        const SizedBox(height: 12),
        Text(t('Desempenho por matéria', 'Performance by subject', 'Rendimiento por materia'), style: const TextStyle(fontWeight: FontWeight.w700)),
        if (_l(stats['by_subject']).isEmpty)
          EmptyState(message: t('Sem respostas ainda.', 'No answers yet.', 'Sin respuestas aún.'))
        else
          PortalTable(
            columns: [
              PortalColumn(t('Matéria', 'Subject', 'Materia'), flex: 2),
              PortalColumn(t('Respondidas', 'Answered', 'Respondidas')),
              PortalColumn(t('Acertos', 'Accuracy', 'Aciertos')),
            ],
            rows: [
              for (final s in _l(stats['by_subject']))
                [
                  Text('${s['subject']}'),
                  Text(t.number(s['answered'] as num)),
                  Text(t.percent((s['correct'] as num) / (s['answered'] as num))),
                ],
            ],
          ),
      ]),
      _section(t('Financeiro', 'Finance', 'Finanzas'), [
        if (_l(fin['payments']).isEmpty)
          EmptyState(
            icon: Icons.receipt_long_outlined,
            message: t('Nenhum pagamento registrado.', 'No payments recorded.', 'Sin pagos registrados.'),
          )
        else
          PortalTable(
            columns: [
              PortalColumn(t('Data', 'Date', 'Fecha')),
              PortalColumn(t('Plano', 'Plan', 'Plan')),
              PortalColumn(t('Provedor', 'Provider', 'Proveedor')),
              PortalColumn(t('Bruto', 'Gross', 'Bruto')),
              PortalColumn(t('Líquido', 'Net', 'Neto')),
              PortalColumn(t('Comissão', 'Commission', 'Comisión')),
              PortalColumn(t('Situação', 'Status', 'Estado')),
            ],
            rows: [
              for (final p in _l(fin['payments']))
                [
                  Text(t.dateOf(p['paid_at'])),
                  Text('${p['plan']}'),
                  Text('${p['provider']}'),
                  Text(t.money(p['gross_cents'] as num)),
                  Text(t.money(p['net_cents'] as num)),
                  Text('${t.money(p['commission_cents'] as num)}${p['partner_name'] == null ? '' : ' (${p['partner_name']})'}'),
                  StatusBadge('${p['status']}', tone: p['status'] == 'confirmed' ? Tone.good : Tone.bad),
                ],
            ],
          ),
      ]),
      _section(t('Ações administrativas', 'Administrative actions', 'Acciones administrativas'), [
        Wrap(spacing: kCardGap, runSpacing: kCardGap, children: [
          ElevatedButton.icon(
            onPressed: () async {
              final done = await showDialog<bool>(context: context, builder: (_) => _GrantDialog(userId: id, api: context.read<PortalApi>()));
              if (done == true) await reload();
            },
            icon: const Icon(Icons.card_giftcard_rounded, size: 18),
            label: Text(t('Conceder Premium (cortesia)', 'Grant Premium (courtesy)', 'Conceder Premium (cortesía)')),
          ),
          OutlinedButton(
            onPressed: () async {
              final done = await showDialog<bool>(
                context: context,
                builder: (_) => _LinkDialog(
                  userId: id,
                  hasCurrent: partner['current'] != null,
                  api: context.read<PortalApi>(),
                  session: context.read<PortalSession>(),
                ),
              );
              if (done == true) await reload();
            },
            child: Text(partner['current'] == null
                ? t('Vincular a um professor', 'Link to a teacher', 'Vincular a un profesor')
                : t('Alterar / remover vínculo', 'Change / remove link', 'Cambiar / quitar vínculo')),
          ),
        ]),
      ]),
    ]);
  }

  Widget _section(String title, List<Widget> children) => Padding(
        padding: const EdgeInsets.only(bottom: kCardGap),
        child: Panel(title: title, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)),
      );
}

class _GrantDialog extends StatefulWidget {
  const _GrantDialog({required this.userId, required this.api});
  final String userId;
  final PortalApi api;
  @override
  State<_GrantDialog> createState() => _GrantDialogState();
}

class _GrantDialogState extends State<_GrantDialog> {
  String _mode = '30';
  final _days = TextEditingController();
  final _note = TextEditingController();
  DateTime? _date;
  bool _busy = false;

  @override
  void dispose() {
    _days.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final presets = ['3', '7', '30', '90', '180', '365'];
    return AlertDialog(
      title: Text(t('Conceder Premium', 'Grant Premium', 'Conceder Premium')),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final p in presets)
                ChoiceChip(label: Text('$p ${t('dias', 'days', 'días')}'), selected: _mode == p, onSelected: (_) => setState(() => _mode = p)),
              ChoiceChip(label: Text(t('Outro (dias)', 'Other (days)', 'Otro (días)')), selected: _mode == 'days', onSelected: (_) => setState(() => _mode = 'days')),
              ChoiceChip(label: Text(t('Até uma data', 'Until a date', 'Hasta una fecha')), selected: _mode == 'date', onSelected: (_) => setState(() => _mode = 'date')),
              ChoiceChip(label: Text(t('Sem expiração', 'No expiry', 'Sin vencimiento')), selected: _mode == 'forever', onSelected: (_) => setState(() => _mode = 'forever')),
            ]),
            const SizedBox(height: 12),
            if (_mode == 'days') Field(label: t('Quantidade de dias', 'Number of days', 'Cantidad de días'), controller: _days, keyboard: TextInputType.number),
            if (_mode == 'date')
              OutlinedButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final d = await showDatePicker(
                    context: context,
                    initialDate: now.add(const Duration(days: 30)),
                    firstDate: now.add(const Duration(days: 1)),
                    lastDate: DateTime(now.year + 10),
                  );
                  if (d != null) setState(() => _date = DateTime(d.year, d.month, d.day, 23, 59));
                },
                child: Text(_date == null ? t('Escolher data', 'Pick a date', 'Elegir fecha') : t.date(_date)),
              ),
            if (_mode == 'forever')
              Text(t('O Premium só termina se você revogar.', 'Premium only ends if you revoke it.', 'Premium solo termina si lo revocas.'),
                  style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Field(label: t('Motivo (opcional)', 'Reason (optional)', 'Motivo (opcional)'), controller: _note, maxLines: 2),
            Text(t('Cortesia administrativa não gera comissão para professores.',
                'Administrative courtesy never generates teacher commission.',
                'La cortesía administrativa no genera comisión para profesores.'),
                style: const TextStyle(fontSize: 11)),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context, false), child: Text(t('Cancelar', 'Cancel', 'Cancelar'))),
        ElevatedButton(
          onPressed: _busy ? null : _submit,
          child: Text(t('Conceder', 'Grant', 'Conceder')),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final t = PortalStrings.read(context);
    int? days;
    DateTime? endsAt;
    var forever = false;
    switch (_mode) {
      case 'days':
        days = int.tryParse(_days.text.trim());
        if (days == null || days < 1 || days > 3650) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Informe de 1 a 3650 dias.', 'Enter 1 to 3650 days.', 'Indica de 1 a 3650 días.'))));
          return;
        }
      case 'date':
        endsAt = _date;
        if (endsAt == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Escolha a data.', 'Pick the date.', 'Elige la fecha.'))));
          return;
        }
      case 'forever':
        forever = true;
      default:
        days = int.parse(_mode);
    }
    final ok = await confirmDialog(
      context,
      title: t('Confirmar concessão', 'Confirm grant', 'Confirmar concesión'),
      message: t('Conceder Premium de cortesia a este usuário?', 'Grant courtesy Premium to this user?', '¿Conceder Premium de cortesía a este usuario?'),
      action: t('Conceder', 'Grant', 'Conceder'),
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final api = widget.api;
    final done = await runAction(
      context,
      () => api.grantPremium(widget.userId, days: days, endsAt: endsAt, indefinite: forever, note: _note.text.trim().isEmpty ? null : _note.text.trim()),
      success: t('Premium concedido.', 'Premium granted.', 'Premium concedido.'),
    );
    if (!mounted) return;
    if (done) {
      Navigator.pop(context, true);
    } else {
      setState(() => _busy = false);
    }
  }
}

class _LinkDialog extends StatefulWidget {
  const _LinkDialog({required this.userId, required this.hasCurrent, required this.api, required this.session});
  final String userId;
  final bool hasCurrent;
  final PortalApi api;
  final PortalSession session;
  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  String _partner = '';
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _apply(bool remove) async {
    final t = PortalStrings.read(context);
    if (!remove && _partner.isEmpty) return;
    final ok = await confirmDialog(
      context,
      title: remove ? t('Remover vínculo?', 'Remove link?', '¿Quitar vínculo?') : t('Confirmar vínculo', 'Confirm link', 'Confirmar vínculo'),
      message: t(
        'Só pagamentos futuros são afetados; comissões já registradas não mudam.',
        'Only future payments are affected; recorded commissions do not change.',
        'Solo afecta pagos futuros; las comisiones ya registradas no cambian.',
      ),
      action: remove ? t('Remover', 'Remove', 'Quitar') : t('Confirmar', 'Confirm', 'Confirmar'),
      danger: remove,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final api = widget.api;
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    final done = await runAction(
      context,
      () => api.setStudentPartner(widget.userId, remove ? null : _partner, note: note),
      success: t('Vínculo atualizado.', 'Link updated.', 'Vínculo actualizado.'),
    );
    if (!mounted) return;
    if (done) {
      unawaited(widget.session.refreshPending());
      Navigator.pop(context, true);
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = widget.api;
    return AlertDialog(
      title: Text(t('Vínculo com professor', 'Teacher link', 'Vínculo con profesor')),
      content: SizedBox(
        width: 420,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Loader<Map<String, dynamic>>(
            loader: () => api.partners(status: 'active', limit: 200),
            builder: (context, d, _) => Select<String>(
              label: t('Professor', 'Teacher', 'Profesor'),
              value: _partner,
              items: {
                '': t('Escolher…', 'Choose…', 'Elegir…'),
                for (final p in (d['rows'] as List)) '${(p as Map)['id']}': '${p['display_name']}',
              },
              onChanged: (v) => setState(() => _partner = v),
            ),
          ),
          const SizedBox(height: 12),
          Field(label: t('Motivo (opcional)', 'Reason (optional)', 'Motivo (opcional)'), controller: _note, maxLines: 2),
        ]),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context, false), child: Text(t('Cancelar', 'Cancel', 'Cancelar'))),
        if (widget.hasCurrent)
          TextButton(onPressed: _busy ? null : () => _apply(true), child: Text(t('Remover vínculo', 'Remove link', 'Quitar vínculo'))),
        ElevatedButton(onPressed: _busy || _partner.isEmpty ? null : () => _apply(false), child: Text(t('Salvar', 'Save', 'Guardar'))),
      ],
    );
  }
}
