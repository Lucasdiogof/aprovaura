import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/widgets/portal_widgets.dart';

String partnerStatusLabel(PortalStrings t, String s) => switch (s) {
      'active' => t('Ativo', 'Active', 'Activo'),
      'pending' => t('Pendente', 'Pending', 'Pendiente'),
      'suspended' => t('Suspenso', 'Suspended', 'Suspendido'),
      'ended' => t('Encerrado', 'Ended', 'Terminado'),
      _ => s,
    };

Tone partnerTone(String s) => switch (s) {
      'active' => Tone.good,
      'pending' || 'suspended' => Tone.warn,
      _ => Tone.bad,
    };

String referralLink(String code) => 'https://aprovaura.lucksrei.com/?ref=$code';

class TeachersPage extends StatefulWidget {
  const TeachersPage({super.key});
  @override
  State<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  static const _limit = 25;
  String _search = '';
  String _status = '';
  int _offset = 0;
  int _reload = 0;

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(
        title: t('Professores parceiros', 'Partner teachers', 'Profesores asociados'),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              final done = await showDialog<bool>(context: context, builder: (_) => _CreateDialog(api: api));
              if (done == true) setState(() => _reload++);
            },
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: Text(t('Novo professor', 'New teacher', 'Nuevo profesor')),
          ),
        ],
      ),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 10, runSpacing: 10, children: [
            SearchBox(
              hint: t('Nome, e-mail ou código', 'Name, e-mail or code', 'Nombre, correo o código'),
              onChanged: (v) => setState(() {
                _search = v;
                _offset = 0;
              }),
            ),
            Select<String>(
              label: t('Situação', 'Status', 'Estado'),
              value: _status,
              items: {
                '': t('Todos', 'All', 'Todos'),
                'active': t('Ativos', 'Active', 'Activos'),
                'suspended': t('Suspensos', 'Suspended', 'Suspendidos'),
                'ended': t('Encerrados', 'Ended', 'Terminados'),
                'pending': t('Pendentes', 'Pending', 'Pendientes'),
              },
              onChanged: (v) => setState(() {
                _status = v;
                _offset = 0;
              }),
            ),
          ]),
          const SizedBox(height: 12),
          Loader<Map<String, dynamic>>(
            loader: () => api.partners(search: _search.isEmpty ? null : _search, status: _status.isEmpty ? null : _status, limit: _limit, offset: _offset),
            keys: [_search, _status, _offset, _reload],
            builder: (context, d, _) {
              final rows = (d['rows'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
              if (rows.isEmpty) {
                return EmptyState(
                  icon: Icons.school_outlined,
                  message: t('Nenhum professor cadastrado ainda.', 'No teachers registered yet.', 'Aún no hay profesores registrados.'),
                );
              }
              return Column(children: [
                PortalTable(
                  columns: [
                    PortalColumn(t('Professor', 'Teacher', 'Profesor'), flex: 3),
                    PortalColumn(t('Código', 'Code', 'Código')),
                    PortalColumn(t('Situação', 'Status', 'Estado')),
                    PortalColumn(t('Alunos', 'Students', 'Alumnos')),
                    PortalColumn(t('Comissão', 'Commission', 'Comisión')),
                    PortalColumn(t('Saldo pendente', 'Pending balance', 'Saldo pendiente')),
                  ],
                  onTap: (i) => context.go('/partners/teachers/${rows[i]['id']}'),
                  rows: [
                    for (final r in rows)
                      [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${r['display_name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('${r['email']}', style: const TextStyle(fontSize: 12)),
                        ]),
                        Text('${r['referral_code']}'),
                        StatusBadge(partnerStatusLabel(t, '${r['status']}'), tone: partnerTone('${r['status']}')),
                        Text(t.number(r['students'] as num)),
                        Text(t.bps(r['commission_bps'] as num)),
                        Text(t.money(r['balance_cents'] as num)),
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

class _CreateDialog extends StatefulWidget {
  const _CreateDialog({required this.api});
  final PortalApi api;
  @override
  State<_CreateDialog> createState() => _CreateDialogState();
}

class _CreateDialogState extends State<_CreateDialog> {
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _bps = TextEditingController();
  final _pix = TextEditingController();
  String _pixType = '';
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_email, _name, _code, _bps, _pix]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final t = PortalStrings.read(context);
    final email = _email.text.trim().toLowerCase();
    final name = _name.text.trim();
    final pct = _bps.text.trim().isEmpty ? null : double.tryParse(_bps.text.trim().replaceAll(',', '.'));
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email) || name.length < 2 || (_bps.text.trim().isNotEmpty && (pct == null || pct < 0 || pct > 100))) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t('Confira e-mail, nome e percentual.', 'Check e-mail, name and percentage.', 'Revisa correo, nombre y porcentaje.')),
      ));
      return;
    }
    if ((_pixType.isEmpty) != _pix.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t('Informe o tipo e a chave Pix juntos.', 'Provide the Pix type and key together.', 'Indica tipo y clave Pix juntos.')),
      ));
      return;
    }
    final ok = await confirmDialog(
      context,
      title: t('Cadastrar professor?', 'Register teacher?', '¿Registrar profesor?'),
      message: t(
        'Se o e-mail já tem conta, ela será reutilizada sem alterar a senha. Se não tiver, uma conta é criada e o professor define a própria senha pelo e-mail de recuperação.',
        'If the e-mail already has an account it is reused without changing the password. Otherwise an account is created and the teacher sets their own password via the recovery e-mail.',
        'Si el correo ya tiene cuenta, se reutiliza sin cambiar la contraseña. Si no, se crea una cuenta y el profesor define su contraseña con el correo de recuperación.',
      ),
      action: t('Cadastrar', 'Register', 'Registrar'),
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final lang = PortalStrings.read(context).language;
    final done = await runAction(context, () async {
      final r = await widget.api.provisionPartner(
        email: email,
        name: name,
        lang: switch (lang) { AppLanguage.english => 'en', AppLanguage.spanish => 'es', _ => 'pt' },
        code: _code.text.trim().isEmpty ? null : _code.text.trim().toUpperCase(),
        bps: pct == null ? null : (pct * 100).round(),
        pixType: _pixType.isEmpty ? null : _pixType,
        pixKey: _pix.text.trim().isEmpty ? null : _pix.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(r['created_account'] == true
            ? t('Professor cadastrado. Enviamos um e-mail para ele definir a senha.', 'Teacher registered. We e-mailed them to set a password.', 'Profesor registrado. Le enviamos un correo para definir su contraseña.')
            : t('Professor cadastrado com a conta existente.', 'Teacher registered with the existing account.', 'Profesor registrado con la cuenta existente.')),
      ));
    });
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
      title: Text(t('Novo professor parceiro', 'New partner teacher', 'Nuevo profesor asociado')),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Field(label: 'E-mail', controller: _email, keyboard: TextInputType.emailAddress),
            Field(label: t('Nome exibido nas indicações', 'Name shown in referrals', 'Nombre mostrado en referidos'), controller: _name),
            Field(label: t('Código de indicação (opcional)', 'Referral code (optional)', 'Código de referencia (opcional)'), controller: _code, hint: 'AB12CD'),
            Field(label: t('Comissão % (vazio = padrão)', 'Commission % (empty = default)', 'Comisión % (vacío = predeterminada)'), controller: _bps, keyboard: TextInputType.number),
            Align(
              alignment: Alignment.centerLeft,
              child: Select<String>(
                label: t('Tipo de chave Pix', 'Pix key type', 'Tipo de clave Pix'),
                value: _pixType,
                items: {'': '—', 'cpf': 'CPF', 'cnpj': 'CNPJ', 'email': 'E-mail', 'phone': t('Telefone', 'Phone', 'Teléfono'), 'random': t('Aleatória', 'Random', 'Aleatoria')},
                onChanged: (v) => setState(() => _pixType = v),
              ),
            ),
            const SizedBox(height: 8),
            Field(label: t('Chave Pix', 'Pix key', 'Clave Pix'), controller: _pix),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context, false), child: Text(t('Cancelar', 'Cancel', 'Cancelar'))),
        ElevatedButton(onPressed: _busy ? null : _submit, child: Text(t('Cadastrar', 'Register', 'Registrar'))),
      ],
    );
  }
}

class TeacherDetailPage extends StatefulWidget {
  const TeacherDetailPage({required this.partnerId, super.key});
  final String partnerId;
  @override
  State<TeacherDetailPage> createState() => _TeacherDetailPageState();
}

class _TeacherDetailPageState extends State<TeacherDetailPage> {
  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => context.go('/partners/teachers'),
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: Text(t('Professores', 'Teachers', 'Profesores')),
        ),
      ),
      Loader<Map<String, dynamic>>(
        loader: () => api.partner(widget.partnerId),
        keys: [widget.partnerId],
        builder: (context, d, reload) => _TeacherBody(api: api, data: d, reload: reload),
      ),
    ]);
  }
}

class _TeacherBody extends StatelessWidget {
  const _TeacherBody({required this.api, required this.data, required this.reload});
  final PortalApi api;
  final Map<String, dynamic> data;
  final Future<void> Function() reload;

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final p = Map<String, dynamic>.from(data['partner'] as Map);
    final st = Map<String, dynamic>.from(data['stats'] as Map);
    final students = (data['students'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final history = (data['history'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final status = '${p['status']}';
    final link = referralLink('${p['referral_code']}');

    Future<void> setStatus(String s, String title, String msg) async {
      final ok = await confirmDialog(context, title: title, message: msg, action: t('Confirmar', 'Confirm', 'Confirmar'), danger: s != 'active');
      if (!ok || !context.mounted) return;
      if (await runAction(context, () => api.updatePartner('${p['id']}', {'status': s}), success: t('Situação atualizada.', 'Status updated.', 'Estado actualizado.'))) {
        await reload();
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(
        title: '${p['display_name']}',
        subtitle: '${p['email']}',
        actions: [
          StatusBadge(partnerStatusLabel(t, status), tone: partnerTone(status)),
          OutlinedButton(
            onPressed: () async {
              final done = await showDialog<bool>(context: context, builder: (_) => _EditDialog(api: api, partner: p));
              if (done == true) await reload();
            },
            child: Text(t('Editar', 'Edit', 'Editar')),
          ),
          if (status == 'active')
            OutlinedButton(
              onPressed: () => setStatus(
                'ended',
                t('Encerrar parceria?', 'End partnership?', '¿Terminar alianza?'),
                t(
                  'O professor sai da lista de indicações, perde o Premium de professor e não gera novas comissões. Comissões, repasses, conta e histórico são preservados.',
                  'The teacher leaves the referral list, loses teacher Premium and earns no new commissions. Commissions, payouts, account and history are preserved.',
                  'El profesor sale de la lista de referidos, pierde el Premium de profesor y no genera nuevas comisiones. Comisiones, pagos, cuenta e historial se conservan.',
                ),
              ),
              child: Text(t('Encerrar parceria', 'End partnership', 'Terminar alianza')),
            )
          else
            ElevatedButton(
              onPressed: () => setStatus(
                'active',
                t('Reativar parceria?', 'Reactivate partnership?', '¿Reactivar alianza?'),
                t('O professor volta à lista de indicações e recebe Premium de professor.', 'The teacher returns to the referral list and gets teacher Premium.', 'El profesor vuelve a la lista de referidos y recibe Premium de profesor.'),
              ),
              child: Text(t('Reativar', 'Reactivate', 'Reactivar')),
            ),
        ],
      ),
      Panel(
        title: t('Dados da parceria', 'Partnership details', 'Datos de la alianza'),
        child: Column(children: [
          KeyValue(t('Código de indicação', 'Referral code', 'Código de referencia'), Text('${p['referral_code']}')),
          KeyValue(
            t('Link de indicação', 'Referral link', 'Enlace de referencia'),
            Row(children: [
              Expanded(child: SelectableText(link)),
              IconButton(
                tooltip: t('Copiar', 'Copy', 'Copiar'),
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: link));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Link copiado.', 'Link copied.', 'Enlace copiado.'))));
                  }
                },
              ),
            ]),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              t(
                'Quem abre este link e se cadastra já vê o professor pré-selecionado e pode trocá-lo.',
                'Whoever opens this link and signs up sees the teacher pre-selected and can change it.',
                'Quien abre este enlace y se registra ve al profesor preseleccionado y puede cambiarlo.',
              ),
              style: const TextStyle(fontSize: 11),
            ),
          ),
          KeyValue(t('Comissão individual', 'Individual commission', 'Comisión individual'), Text(t.bps(p['commission_bps'] as num))),
          KeyValue(
            t('Chave Pix', 'Pix key', 'Clave Pix'),
            Text(p['pix_key'] == null ? t('Não cadastrada', 'Not registered', 'No registrada') : '${p['pix_key_type']} · ${p['pix_key']}'),
          ),
          KeyValue(t('Início', 'Started', 'Inicio'), Text(t.dateOf(p['started_at']))),
          if (p['ended_at'] != null) KeyValue(t('Encerramento', 'Ended', 'Terminada'), Text(t.dateOf(p['ended_at']))),
          KeyValue(t('Conta (usuário)', 'Account (user)', 'Cuenta (usuario)'),
              TextButton(onPressed: () => context.go('/partners/users/${p['user_id']}'), child: Text(t('Abrir conta', 'Open account', 'Abrir cuenta')))),
        ]),
      ),
      const SizedBox(height: 16),
      CardGrid(minWidth: 170, children: [
        StatCard(label: t('Alunos vinculados', 'Linked students', 'Alumnos vinculados'), value: t.number(st['students'] as num)),
        StatCard(label: t('Alunos pagantes', 'Paying students', 'Alumnos de pago'), value: t.number(st['paying_students'] as num)),
        StatCard(label: t('Faturamento gerado', 'Revenue generated', 'Facturación generada'), value: t.money(st['gross_cents'] as num)),
        StatCard(label: t('Comissões', 'Commissions', 'Comisiones'), value: t.money(st['commission_cents'] as num)),
        StatCard(label: t('Saldo pendente', 'Pending balance', 'Saldo pendiente'), value: t.money(st['balance_cents'] as num)),
        StatCard(label: t('Repassado', 'Paid out', 'Pagado'), value: t.money(st['paid_out_cents'] as num)),
      ]),
      const SizedBox(height: 16),
      Panel(
        title: t('Alunos vinculados', 'Linked students', 'Alumnos vinculados'),
        child: students.isEmpty
            ? EmptyState(message: t('Nenhum aluno vinculado.', 'No linked students.', 'Sin alumnos vinculados.'))
            : PortalTable(
                columns: [
                  PortalColumn(t('Aluno', 'Student', 'Alumno'), flex: 2),
                  PortalColumn(t('Vinculado em', 'Linked on', 'Vinculado el')),
                  PortalColumn(t('Origem', 'Source', 'Origen')),
                ],
                onTap: (i) => context.go('/partners/users/${students[i]['id']}'),
                rows: [
                  for (final s in students)
                    [
                      Text('${s['name'] ?? '—'}${s['username'] == null ? '' : ' · @${s['username']}'}'),
                      Text(t.dateOf(s['linked_at'])),
                      Text('${s['source']}'),
                    ],
                ],
              ),
      ),
      const SizedBox(height: 16),
      Panel(
        title: t('Histórico da parceria', 'Partnership history', 'Historial de la alianza'),
        child: history.isEmpty
            ? EmptyState(message: t('Sem registros.', 'No records.', 'Sin registros.'))
            : Column(children: [
                for (final h in history)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text('${t.dateTimeOf(h['at'])} · ${h['action']} · ${h['actor_name'] ?? '—'}', style: const TextStyle(fontSize: 12)),
                    ),
                  ),
              ]),
      ),
    ]);
  }
}

class _EditDialog extends StatefulWidget {
  const _EditDialog({required this.api, required this.partner});
  final PortalApi api;
  final Map<String, dynamic> partner;
  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final _name = TextEditingController(text: '${widget.partner['display_name']}');
  late final _code = TextEditingController(text: '${widget.partner['referral_code']}');
  late final _bps = TextEditingController(text: ((widget.partner['commission_bps'] as num) / 100).toString());
  late final _pix = TextEditingController(text: '${widget.partner['pix_key'] ?? ''}');
  late String _pixType = '${widget.partner['pix_key_type'] ?? ''}';
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_name, _code, _bps, _pix]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final t = PortalStrings.read(context);
    final pct = double.tryParse(_bps.text.trim().replaceAll(',', '.'));
    if (pct == null || pct < 0 || pct > 100 || (_pixType.isEmpty) != _pix.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t('Confira o percentual e a chave Pix.', 'Check the percentage and Pix key.', 'Revisa el porcentaje y la clave Pix.')),
      ));
      return;
    }
    final ok = await confirmDialog(
      context,
      title: t('Salvar alterações?', 'Save changes?', '¿Guardar cambios?'),
      message: t('Mudanças de comissão e código só valem para pagamentos futuros.', 'Commission and code changes only apply to future payments.', 'Los cambios de comisión y código solo valen para pagos futuros.'),
      action: t('Salvar', 'Save', 'Guardar'),
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    final done = await runAction(
      context,
      () => widget.api.updatePartner('${widget.partner['id']}', {
        'display_name': _name.text.trim(),
        'referral_code': _code.text.trim().toUpperCase(),
        'commission_bps': (pct * 100).round(),
        'pix_key_type': _pixType,
        'pix_key': _pix.text.trim(),
      }),
      success: t('Dados salvos.', 'Saved.', 'Datos guardados.'),
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
      title: Text(t('Editar professor', 'Edit teacher', 'Editar profesor')),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Field(label: t('Nome exibido nas indicações', 'Name shown in referrals', 'Nombre mostrado en referidos'), controller: _name),
            Field(label: t('Código de indicação', 'Referral code', 'Código de referencia'), controller: _code),
            Field(label: t('Comissão %', 'Commission %', 'Comisión %'), controller: _bps, keyboard: TextInputType.number),
            Align(
              alignment: Alignment.centerLeft,
              child: Select<String>(
                label: t('Tipo de chave Pix', 'Pix key type', 'Tipo de clave Pix'),
                value: _pixType,
                items: {'': '—', 'cpf': 'CPF', 'cnpj': 'CNPJ', 'email': 'E-mail', 'phone': t('Telefone', 'Phone', 'Teléfono'), 'random': t('Aleatória', 'Random', 'Aleatoria')},
                onChanged: (v) => setState(() => _pixType = v),
              ),
            ),
            const SizedBox(height: 8),
            Field(label: t('Chave Pix', 'Pix key', 'Clave Pix'), controller: _pix),
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
