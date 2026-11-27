import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/theme_cubit.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/portal/data/portal_api.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';
import 'package:aura/features/portal/presentation/widgets/portal_widgets.dart';
import 'package:aura/shared/widgets/app_logo.dart';

enum PortalRole { loading, admin, partner, denied, error }

class PortalSessionState {
  const PortalSessionState(this.role, {this.email, this.pending = 0, this.partnerActive = true});
  final PortalRole role;
  final String? email;
  final int pending;

  /// Professor com parceria ativa. Encerrado/suspenso: só Financeiro e Minha parceria.
  final bool partnerActive;
}

/// Papéis do portal, SEMPRE lidos do servidor (get_my_access online). Refaz a
/// leitura periodicamente e quando uma operação volta "sem permissão", para
/// que perder o papel numa sessão aberta feche o portal.
class PortalSession extends Cubit<PortalSessionState> {
  PortalSession(this.api, this._client) : super(const PortalSessionState(PortalRole.loading)) {
    unawaited(refresh());
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => refresh(quiet: true));
  }

  final PortalApi api;
  final SupabaseClient _client;
  Timer? _timer;

  Future<void> refresh({bool quiet = false}) async {
    if (!quiet) emit(PortalSessionState(PortalRole.loading, email: _client.auth.currentUser?.email));
    try {
      final me = await api.me();
      final roles = Map<String, dynamic>.from(me['roles'] as Map);
      final email = _client.auth.currentUser?.email;
      if (roles['admin'] == true) {
        var pending = 0;
        try {
          pending = await api.pendingRequests();
        } catch (_) {}
        emit(PortalSessionState(PortalRole.admin, email: email, pending: pending));
      } else if (roles['partner'] == true) {
        var active = true;
        try {
          active = (await api.partnerMe())['active'] == true;
        } catch (_) {}
        emit(PortalSessionState(PortalRole.partner, email: email, partnerActive: active));
      } else {
        emit(PortalSessionState(PortalRole.denied, email: email));
      }
    } catch (_) {
      if (!quiet || state.role == PortalRole.loading) emit(PortalSessionState(PortalRole.error, email: state.email));
    }
  }

  Future<void> refreshPending() async {
    if (state.role != PortalRole.admin) return;
    try {
      final n = await api.pendingRequests();
      emit(PortalSessionState(PortalRole.admin, email: state.email, pending: n));
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

/// Raiz do portal: monta a API, descobre o papel no servidor e escolhe a interface.
class PortalGate extends StatefulWidget {
  const PortalGate({required this.location, required this.child, super.key});
  final String location;
  final Widget child;

  @override
  State<PortalGate> createState() => _PortalGateState();
}

class _PortalGateState extends State<PortalGate> {
  late final PortalSession _session;
  late final PortalApi _api;

  @override
  void initState() {
    super.initState();
    final client = sl<SupabaseClient>();
    _api = PortalApi(
      client,
      onForbidden: () => unawaited(_session.refresh(quiet: true)),
      onSessionLost: () => unawaited(_signOut()),
    );
    _session = PortalSession(_api, client);
  }

  Future<void> _signOut() async {
    if (sl<AuthRepository>().currentUser == null) return;
    await sl<AuthRepository>().signOut();
    if (mounted) context.go('/login?next=${Uri.encodeComponent(widget.location)}');
  }

  @override
  void dispose() {
    _session.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _api,
      child: BlocProvider.value(
        value: _session,
        child: BlocBuilder<PortalSession, PortalSessionState>(builder: (context, s) {
          switch (s.role) {
            case PortalRole.loading:
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            case PortalRole.error:
              return _Message(
                icon: Icons.cloud_off_rounded,
                title: PortalStrings.watch(context)('Sem conexão', 'No connection', 'Sin conexión'),
                body: PortalStrings.watch(context)(
                  'Não foi possível confirmar suas permissões no servidor.',
                  'Could not confirm your permissions with the server.',
                  'No se pudieron confirmar tus permisos con el servidor.',
                ),
                actionLabel: PortalStrings.watch(context)('Tentar de novo', 'Try again', 'Reintentar'),
                onAction: _session.refresh,
              );
            case PortalRole.denied:
              return _Message(
                icon: Icons.lock_outline_rounded,
                title: PortalStrings.watch(context)('Acesso restrito', 'Restricted access', 'Acceso restringido'),
                body: PortalStrings.watch(context)(
                  'Esta conta não tem permissão para o portal. O aplicativo continua disponível normalmente.',
                  'This account has no portal permission. The app remains available as usual.',
                  'Esta cuenta no tiene permiso para el portal. La aplicación sigue disponible con normalidad.',
                ),
                actionLabel: PortalStrings.watch(context)('Abrir o aplicativo', 'Open the app', 'Abrir la aplicación'),
                onAction: () async => context.go('/home'),
                secondaryLabel: PortalStrings.watch(context)('Sair', 'Sign out', 'Salir'),
                onSecondary: _signOut,
              );
            case PortalRole.partner:
              return PortalShell(
                location: widget.location,
                admin: false,
                signOut: _signOut,
                child: widget.child,
              );
            case PortalRole.admin:
              return PortalShell(location: widget.location, admin: true, signOut: _signOut, child: widget.child);
          }
        }),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });
  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final Future<void> Function() onAction;
  final String? secondaryLabel;
  final Future<void> Function()? onSecondary;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 44, color: c.primary),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(body, textAlign: TextAlign.center, style: TextStyle(color: c.textSecondary)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
              if (secondaryLabel != null)
                TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.path, this.icon, this.label);
  final String path;
  final IconData icon;
  final String label;
}

/// Rótulo de grupo do menu lateral (só administração).
class _NavGroup {
  const _NavGroup(this.label);
  final String label;
}

/// Layout administrativo: barra lateral (gaveta em telas estreitas) + cabeçalho.
class PortalShell extends StatelessWidget {
  const PortalShell({
    required this.location,
    required this.admin,
    required this.signOut,
    required this.child,
    super.key,
  });
  final String location;
  final bool admin;
  final Future<void> Function() signOut;
  final Widget child;

  List<Object> _items(PortalStrings t, bool partnerActive) => admin
      ? [
          _NavGroup(t('Gestão', 'Management', 'Gestión')),
          _NavItem('/partners', Icons.dashboard_outlined, t('Visão geral', 'Overview', 'Resumen')),
          _NavItem('/partners/users', Icons.people_outline_rounded, t('Usuários', 'Users', 'Usuarios')),
          _NavItem('/partners/teachers', Icons.school_outlined, t('Professores', 'Teachers', 'Profesores')),
          _NavItem('/partners/requests', Icons.swap_horiz_rounded, t('Solicitações', 'Requests', 'Solicitudes')),
          _NavGroup(t('Comercial', 'Commercial', 'Comercial')),
          _NavItem('/partners/finance', Icons.account_balance_wallet_outlined, t('Financeiro', 'Finance', 'Finanzas')),
          _NavItem('/partners/subscriptions', Icons.workspace_premium_outlined, t('Assinaturas', 'Subscriptions', 'Suscripciones')),
          _NavItem('/partners/integrations', Icons.hub_outlined, t('Integrações', 'Integrations', 'Integraciones')),
          _NavGroup(t('Sistema', 'System', 'Sistema')),
          _NavItem('/partners/essay-ai', Icons.edit_note_rounded, t('Correção por IA', 'AI feedback', 'Corrección por IA')),
          _NavItem('/partners/audit', Icons.fact_check_outlined, t('Auditoria', 'Audit', 'Auditoría')),
          _NavItem('/partners/settings', Icons.tune_rounded, t('Configurações', 'Settings', 'Configuración')),
        ]
      : [
          if (partnerActive) ...[
            _NavItem('/partners', Icons.dashboard_outlined, t('Visão geral', 'Overview', 'Resumen')),
            _NavItem('/partners/students', Icons.people_outline_rounded, t('Meus alunos', 'My students', 'Mis alumnos')),
            _NavItem('/partners/stats', Icons.insights_outlined, t('Estatísticas', 'Statistics', 'Estadísticas')),
          ],
          _NavItem('/partners/finance', Icons.account_balance_wallet_outlined, t('Financeiro', 'Finance', 'Finanzas')),
          if (partnerActive) _NavItem('/partners/referrals', Icons.share_outlined, t('Minhas indicações', 'My referrals', 'Mis referidos')),
          _NavItem('/partners/me', Icons.badge_outlined, t('Minha parceria', 'My partnership', 'Mi alianza')),
        ];

  bool _active(String path) =>
      path == '/partners' ? location == '/partners' : location == path || location.startsWith('$path/');

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final c = context.colors;
    final wide = MediaQuery.sizeOf(context).width >= kWide;
    final pending = context.select((PortalSession s) => s.state.pending);
    final email = context.select((PortalSession s) => s.state.email);
    final partnerActive = context.select((PortalSession s) => s.state.partnerActive);

    Widget navItem(_NavItem i, {required bool inDrawer}) {
      final active = _active(i.path);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
        child: Material(
          color: active ? c.primary.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            hoverColor: c.primary.withValues(alpha: 0.07),
            onTap: () {
              if (inDrawer) Navigator.pop(context);
              context.go(i.path);
            },
            child: SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(children: [
                  Icon(i.icon, size: 20, color: active ? c.primary : c.textSecondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(i.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? c.primary : c.textPrimary,
                        )),
                  ),
                  if (i.path == '/partners/requests' && pending > 0) StatusBadge('$pending', tone: Tone.warn),
                ]),
              ),
            ),
          ),
        ),
      );
    }

    Widget nav({required bool inDrawer}) => Container(
          width: 252,
          decoration: BoxDecoration(color: c.surface, border: Border(right: BorderSide(color: c.border))),
          child: SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 20, 8),
                child: Row(children: [
                  const AppLogo.mark(size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Aprovaura',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary)),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 20, 12),
                child: StatusBadge(
                  admin ? t('Administração', 'Administration', 'Administración') : t('Professor', 'Teacher', 'Profesor'),
                  tone: Tone.info,
                ),
              ),
              Expanded(
                child: ListView(padding: EdgeInsets.zero, children: [
                  for (final i in _items(t, partnerActive))
                    if (i is _NavGroup)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 14, 20, 6),
                        child: Text(i.label.toUpperCase(),
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: c.textHint)),
                      )
                    else
                      navItem(i as _NavItem, inDrawer: inDrawer),
                ]),
              ),
              Divider(height: 1, color: c.border),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: c.primary.withValues(alpha: 0.16),
                      child: Text((email ?? '?').substring(0, 1).toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.w800, color: c.primary)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                            admin
                                ? t('Administrador', 'Administrator', 'Administrador')
                                : t('Professor', 'Teacher', 'Profesor'),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c.textPrimary)),
                        if (email != null)
                          Text(email, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: c.textSecondary)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.phone_iphone_rounded, size: 18),
                      label: Text(t('Abrir o aplicativo', 'Open the app', 'Abrir la aplicación')),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: signOut,
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: Text(t('Sair', 'Sign out', 'Salir')),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        );

    final themeMode = context.watch<ThemeCubit>().state;
    final language = context.watch<LocaleCubit>().state;
    final header = Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: c.surface, border: Border(bottom: BorderSide(color: c.border))),
      child: Row(children: [
        if (!wide)
          Builder(
            builder: (ctx) => IconButton(
              tooltip: t('Menu', 'Menu', 'Menú'),
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        const Spacer(),
        DropdownButtonHideUnderline(
          child: DropdownButton<AppLanguage>(
            value: language,
            isDense: true,
            items: [for (final l in AppLanguage.values) DropdownMenuItem(value: l, child: Text(l.label))],
            onChanged: (l) {
              if (l != null) context.read<LocaleCubit>().setLanguage(l);
            },
          ),
        ),
        IconButton(
          tooltip: t('Alternar tema', 'Toggle theme', 'Cambiar tema'),
          icon: Icon(Theme.of(context).brightness == Brightness.dark
              ? Icons.light_mode_outlined
              : Icons.dark_mode_outlined),
          onPressed: () => context.read<ThemeCubit>().setMode(
                Theme.of(context).brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
              ),
        ),
        if (themeMode == ThemeMode.system) const SizedBox.shrink(),
      ]),
    );

    return Scaffold(
      backgroundColor: c.background,
      drawer: wide ? null : Drawer(child: nav(inDrawer: true)),
      body: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (wide) nav(inDrawer: false),
        Expanded(
          child: Column(children: [
            header,
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(wide ? 28 : 16),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: kContentMax), child: child),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
