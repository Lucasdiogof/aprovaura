import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/widgets/portal_widgets.dart';

/// Resumo de acesso (origem + validade) usado em listas.
Widget accessSummary(PortalStrings t, Map access) {
  final has = access['has_access'] == true;
  final sources = ((access['sources'] as List?) ?? const []).map((e) => '${(e as Map)['source']}').toSet();
  if (!has) return StatusBadge(t('Sem Premium', 'No Premium', 'Sin Premium'), tone: Tone.bad);
  return Wrap(spacing: 4, runSpacing: 4, children: [
    for (final s in sources) StatusBadge(sourceLabel(t, s), tone: s == 'admin' || s == 'partner' ? Tone.info : Tone.good),
  ]);
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  static const _limit = 25;
  String _search = '';
  String _access = '';
  String _partner = '';
  String _referral = '';
  String _email = '';
  String _sort = 'created';
  String _dir = 'desc';
  DateTime? _from;
  DateTime? _to;
  int _offset = 0;

  void _set(VoidCallback f) => setState(() {
        f();
        _offset = 0;
      });

  Future<void> _pickRange() async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      initialDateRange: _from == null || _to == null ? null : DateTimeRange(start: _from!, end: _to!),
    );
    if (r != null) _set(() {
      _from = r.start;
      _to = r.end;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final api = context.read<PortalApi>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PageHeader(title: t('Usuários', 'Users', 'Usuarios')),
      Panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
            SearchBox(
              hint: t('Nome, usuário ou e-mail', 'Name, username or e-mail', 'Nombre, usuario o correo'),
              onChanged: (v) => _set(() => _search = v),
            ),
            Select<String>(
              label: t('Acesso', 'Access', 'Acceso'),
              value: _access,
              items: {
                '': t('Todos', 'All', 'Todos'),
                'premium': 'Premium',
                'none': t('Sem Premium', 'No Premium', 'Sin Premium'),
                'paid': t('Assinante', 'Subscriber', 'Suscriptor'),
                'trial': t('Teste', 'Trial', 'Prueba'),
                'courtesy': t('Cortesia', 'Courtesy', 'Cortesía'),
                'partner': t('Professor', 'Teacher', 'Profesor'),
                'admin': t('Administrador', 'Administrator', 'Administrador'),
              },
              onChanged: (v) => _set(() => _access = v),
            ),
            Select<String>(
              label: t('Indicação', 'Referral', 'Referido'),
              value: _referral,
              items: {
                '': t('Todas', 'Any', 'Todas'),
                'with': t('Com indicação', 'With referral', 'Con referido'),
                'without': t('Sem indicação', 'Without referral', 'Sin referido'),
              },
              onChanged: (v) => _set(() => _referral = v),
            ),
            Select<String>(
              label: t('E-mail', 'E-mail', 'Correo'),
              value: _email,
              items: {
                '': t('Todos', 'All', 'Todos'),
                'verified': t('Verificado', 'Verified', 'Verificado'),
                'unverified': t('Não verificado', 'Unverified', 'No verificado'),
              },
              onChanged: (v) => _set(() => _email = v),
            ),
            Loader<Map<String, dynamic>>(
              loader: () => api.partners(limit: 200),
              builder: (context, d, _) => Select<String>(
                label: t('Professor', 'Teacher', 'Profesor'),
                value: _partner,
                items: {
                  '': t('Todos', 'All', 'Todos'),
                  for (final p in (d['rows'] as List)) '${(p as Map)['id']}': '${p['display_name']}',
                },
                onChanged: (v) => _set(() => _partner = v),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _pickRange,
              icon: const Icon(Icons.date_range_rounded, size: 18),
              label: Text(_from == null
                  ? t('Data de cadastro', 'Sign-up date', 'Fecha de registro')
                  : '${t.date(_from)} – ${t.date(_to)}'),
            ),
            if (_from != null)
              IconButton(
                tooltip: t('Limpar datas', 'Clear dates', 'Limpiar fechas'),
                onPressed: () => _set(() {
                  _from = null;
                  _to = null;
                }),
                icon: const Icon(Icons.close_rounded),
              ),
            Select<String>(
              label: t('Ordenar', 'Sort', 'Ordenar'),
              value: _sort,
              items: {
                'created': t('Cadastro', 'Sign-up', 'Registro'),
                'activity': t('Atividade no app', 'App activity', 'Actividad en la app'),
                'login': t('Último login', 'Last login', 'Último acceso'),
                'name': t('Nome', 'Name', 'Nombre'),
                'email': 'E-mail',
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
            loader: () => api.users(
              search: _search.isEmpty ? null : _search,
              access: _access.isEmpty ? null : _access,
              partner: _partner.isEmpty ? null : _partner,
              referral: _referral.isEmpty ? null : _referral,
              email: _email.isEmpty ? null : _email,
              from: _from,
              to: _to,
              sort: _sort,
              dir: _dir,
              limit: _limit,
              offset: _offset,
            ),
            keys: [_search, _access, _partner, _referral, _email, _from, _to, _sort, _dir, _offset],
            builder: (context, d, _) {
              final rows = (d['rows'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
              if (rows.isEmpty) {
                return EmptyState(message: t('Nenhum usuário encontrado.', 'No users found.', 'No se encontraron usuarios.'));
              }
              return Column(children: [
                PortalTable(
                  columns: [
                    PortalColumn(t('Usuário', 'User', 'Usuario'), flex: 3),
                    PortalColumn(t('Cadastro', 'Signed up', 'Registro')),
                    PortalColumn(t('Professor', 'Teacher', 'Profesor'), flex: 2),
                    PortalColumn('Premium', flex: 2),
                    PortalColumn(t('Expira', 'Expires', 'Expira')),
                    PortalColumn(t('Atividade no app', 'App activity', 'Actividad en la app')),
                    PortalColumn(t('Último estudo', 'Last study', 'Último estudio')),
                  ],
                  onTap: (i) => context.go('/partners/users/${rows[i]['id']}'),
                  rows: [
                    for (final r in rows)
                      [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${r['name']}'.isEmpty ? '—' : '${r['name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('${r['email']}${r['username'] == null ? '' : ' · @${r['username']}'}',
                              style: const TextStyle(fontSize: 12)),
                          if (r['email_verified'] != true)
                            StatusBadge(t('E-mail não verificado', 'E-mail unverified', 'Correo sin verificar'), tone: Tone.warn),
                        ]),
                        Text(t.dateOf(r['created_at'])),
                        Text('${r['partner_name'] ?? '—'}'),
                        accessSummary(t, Map<String, dynamic>.from(r['access'] as Map)),
                        Text(((r['access'] as Map)['indefinite'] == true)
                            ? t('Sem fim', 'No end', 'Sin fin')
                            : t.dateOf((r['access'] as Map)['access_until'])),
                        Text(t.dateTimeOf(r['last_seen_at'])),
                        Text(t.dateTimeOf(r['last_study_at'])),
                      ],
                  ],
                ),
                Pager(
                  total: (d['total'] as num).toInt(),
                  offset: _offset,
                  limit: _limit,
                  onPage: (o) => setState(() => _offset = o),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t(
                      'Atividade no app = última abertura conhecida (≠ último login, ≠ estudo). Aparece após a próxima abertura do app atualizado.',
                      'App activity = last known app open (≠ last sign-in, ≠ study). Shows after the next open of the updated app.',
                      'Actividad en la app = última apertura conocida (≠ último acceso, ≠ estudio). Aparece tras la próxima apertura de la app actualizada.',
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
