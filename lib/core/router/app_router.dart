import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/router/app_route_observer.dart';
import 'package:aura/features/access/domain/entities/access_status.dart';
import 'package:aura/features/access/presentation/cubit/access_cubit.dart';
import 'package:aura/features/paywall/presentation/pages/access_gate_pages.dart';
import 'package:aura/features/legal/presentation/pages/legal_acceptance_page.dart';
import 'package:aura/features/paywall/presentation/pages/my_subscription_page.dart';
import 'package:aura/features/paywall/presentation/pages/paywall_page.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/auth/presentation/pages/email_verification_page.dart';
import 'package:aura/features/auth/presentation/pages/login_page.dart';
import 'package:aura/features/auth/presentation/pages/register_page.dart';
import 'package:aura/features/home/presentation/pages/home_shell_page.dart';
import 'package:aura/features/intro/data/intro_store.dart';
import 'package:aura/features/intro/presentation/pages/intro_page.dart';
import 'package:aura/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:aura/features/portal/presentation/pages/admin_pages.dart';
import 'package:aura/features/portal/presentation/pages/dashboard_page.dart';
import 'package:aura/features/portal/presentation/pages/finance_pages.dart';
import 'package:aura/features/portal/presentation/pages/integrations_page.dart';
import 'package:aura/features/portal/presentation/pages/partner_pages.dart';
import 'package:aura/features/portal/presentation/pages/portal_gate.dart';
import 'package:aura/features/legal/presentation/pages/privacy_page.dart';
import 'package:aura/features/portal/presentation/pages/teachers_pages.dart';
import 'package:aura/features/portal/presentation/pages/user_detail_page.dart';
import 'package:aura/features/portal/presentation/pages/users_page.dart';

/// Rotas que só existem com sessão: sem ela, `/home` quebraria em
/// `currentUser!` e `/onboarding` gravaria perfil sem dono. Importa também
/// na web, onde qualquer URL pode ser aberta direto.
const _authenticatedRoutes = {'/home', '/onboarding'};
const _sessionOnlyRoutes = {'/aceite-legal', '/assinatura', '/minha-assinatura', '/privacidade', '/verificando', '/conectar', '/atualizar'};

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Faz o roteador reavaliar o redirect quando o PORTÃO de acesso muda (acesso
/// vence, 402, pagamento confirmado, volta a conexão...). Ao entrar num
/// bloqueio, também fecha o que foi empilhado por cima (telas de estudo,
/// diálogos, folhas): voltar nunca reabre conteúdo bloqueado.
class _AccessGateRefresh extends ChangeNotifier {
  _AccessGateRefresh(AccessCubit cubit) : _cubit = cubit, _last = cubit.gate {
    _sub = cubit.stream.listen((_) {
      final g = _cubit.gate;
      if (g == _last) return;
      _last = g;
      if (g == AccessGate.paywall ||
          g == AccessGate.connectionRequired ||
          g == AccessGate.updateRequired) {
        rootNavigatorKey.currentState?.popUntil((r) => r.settings is Page<dynamic>);
      }
      notifyListeners();
    });
  }
  final AccessCubit _cubit;
  AccessGate _last;
  late final StreamSubscription<AccessState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// [introSeen]: the animated presentation was already shown (or skipped) on
/// this install. [setupPending]: the signed-in account still has to finish
/// the personal setup. Both default to the "nothing special" value, so a
/// caller that doesn't know about them keeps the old behaviour.
/// O portal vive em /partners (mesmo domínio, mesma conta). [next] é o destino
/// pedido antes do login (só aceito se for do portal: nunca redireciona para fora).
bool isPortalPath(String? p) => p != null && (p == '/partners' || p.startsWith('/partners/'));

/// Decisão ÚNICA de acesso para quem tem sessão. O portal (/partners) tem o
/// próprio gate por papel e nunca é barrado pelo paywall. Com bloqueio só
/// ficam acessíveis o destino do bloqueio e "Minha assinatura".
String? gateRedirect({
  required AccessGate gate,
  required String location,
  String? fullLocation,
  String? to,
}) {
  if (isPortalPath(location)) return null;
  switch (gate) {
    case AccessGate.resolving:
      if (location == '/verificando') return null;
      final dest = Uri.encodeComponent(fullLocation ?? location);
      return '/verificando?to=$dest';
    case AccessGate.open:
      if (location == '/verificando') {
        return to != null && to.startsWith('/') && !to.startsWith('//') ? to : '/home';
      }
      return location == '/conectar' || location == '/atualizar' || location == '/aceite-legal' ? '/home' : null;
    case AccessGate.paywall:
      return location == '/assinatura' || location == '/minha-assinatura' || location == '/privacidade' ? null : '/assinatura';
    case AccessGate.connectionRequired:
      return location == '/conectar' ? null : '/conectar';
    case AccessGate.updateRequired:
      return location == '/atualizar' ? null : '/atualizar';
    case AccessGate.legalRequired:
      // Ler documentos, sair e excluir a conta (rodapé da própria tela) nunca são barrados.
      return location == '/aceite-legal' || location == '/privacidade' ? null : '/aceite-legal';
  }
}

String? authRedirect({
  required bool hasSession,
  required String location,
  AccessGate gate = AccessGate.open,
  String? to,
  bool introSeen = true,
  bool setupPending = false,
  bool hasPendingSignup = false,
  String? next,
  String? fullLocation,
}) {
  if (!hasSession && isPortalPath(location)) {
    return '/login?next=${Uri.encodeComponent(fullLocation ?? location)}';
  }
  if (hasSession && location == '/login' && isPortalPath(next)) return next;
  if (!hasSession && _authenticatedRoutes.contains(location)) return '/login';
  if (!hasSession && _sessionOnlyRoutes.contains(location)) return '/login';
  if (hasSession) {
    final g = gateRedirect(gate: gate, location: location, fullLocation: fullLocation, to: to);
    if (g != null) return g;
  }
  // First run, signed out: the presentation comes before the login.
  if (!hasSession &&
      !introSeen &&
      !hasPendingSignup &&
      next == null &&
      location == '/login') {
    return '/apresentacao';
  }
  if (hasSession && (location == '/login' || location == '/apresentacao')) {
    return setupPending ? '/onboarding' : '/home';
  }
  if (hasSession && setupPending && location == '/home') return '/onboarding';
  return null;
}

/// Com URL sem '#': abre direto /partners/... (ou um antigo link '#/rota').
String _initialLocation() {
  if (!kIsWeb) return '/login';
  final u = Uri.base;
  if (u.fragment.startsWith('/')) return u.fragment;
  if (isPortalPath(u.path)) return '${u.path}${u.hasQuery ? '?${u.query}' : ''}';
  return '/login';
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  refreshListenable: _AccessGateRefresh(sl<AccessCubit>()),
  initialLocation: _initialLocation(),
  observers: [appRouteObserver],
  redirect: (context, state) {
    final user = sl<AuthRepository>().currentUser;
    final store = IntroStore(sl<SharedPreferences>());
    return authRedirect(
      hasSession: user != null,
      gate: sl<AccessCubit>().gate,
      to: state.uri.queryParameters['to'],
      location: state.matchedLocation,
      next: state.uri.queryParameters['next'],
      fullLocation: state.uri.toString(),
      introSeen: store.introSeen,
      hasPendingSignup: store.hasPendingSignup,
      setupPending: user != null && store.setupPendingFor == user.id,
    );
  },
  routes: [
    GoRoute(
      path: '/apresentacao',
      builder: (context, state) => const IntroPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthCubit>(),
        child: const LoginPage(),
      ),
    ),
    GoRoute(
      path: '/cadastro',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthCubit>(),
        child: const RegisterPage(),
      ),
    ),
    GoRoute(
      path: '/confirmar-email',
      builder: (context, state) {
        // (e-mail, veio do cadastro). Sem o extra (web recarregada) a
        // página do login retoma pelo cadastro pendente guardado.
        final extra = state.extra;
        if (extra is (String, bool)) {
          return EmailVerificationPage(email: extra.$1, fromSignUp: extra.$2);
        }
        return BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const LoginPage(),
        );
      },
    ),
    GoRoute(path: '/verificando', builder: (_, _) => const AccessResolvingPage()),
    GoRoute(path: '/conectar', builder: (_, _) => const ConnectionRequiredPage()),
    GoRoute(path: '/aceite-legal', builder: (_, _) => const LegalAcceptancePage()),
    GoRoute(path: '/atualizar', builder: (_, _) => const UpdateRequiredPage()),
    GoRoute(path: '/assinatura', builder: (_, _) => const PaywallPage()),
    GoRoute(path: '/minha-assinatura', builder: (_, _) => const MySubscriptionPage()),
    GoRoute(path: '/privacidade', builder: (_, _) => const PrivacyPage()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          PortalGate(location: state.matchedLocation, child: child),
      routes: [
        GoRoute(path: '/partners', builder: (_, _) => const PortalHome(admin: DashboardPage())),
        GoRoute(path: '/partners/students', builder: (_, _) => partnerOnlyActive(const PartnerStudentsPage())),
        GoRoute(
          path: '/partners/students/:id',
          builder: (_, state) => partnerOnlyActive(PartnerStudentDetailPage(id: state.pathParameters['id']!)),
        ),
        GoRoute(path: '/partners/stats', builder: (_, _) => partnerOnlyActive(const PartnerStatsPage())),
        GoRoute(path: '/partners/finance', builder: (_, _) => const FinanceHome()),
        GoRoute(path: '/partners/integrations', builder: (_, _) => const IntegrationsPage()),
        GoRoute(path: '/partners/finance/payments/:id', builder: (_, state) => PaymentDetailPage(id: state.pathParameters['id']!)),
        GoRoute(path: '/partners/finance/teachers/:id', builder: (_, state) => PartnerCommissionsPage(id: state.pathParameters['id']!)),
        GoRoute(path: '/partners/referrals', builder: (_, _) => partnerOnlyActive(const PartnerReferralsPage())),
        GoRoute(path: '/partners/me', builder: (_, _) => const PartnerProfilePage()),
        GoRoute(path: '/partners/users', builder: (_, _) => const UsersPage()),
        GoRoute(
          path: '/partners/users/:id',
          builder: (_, state) => UserDetailPage(userId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/partners/teachers', builder: (_, _) => const TeachersPage()),
        GoRoute(
          path: '/partners/teachers/:id',
          builder: (_, state) => TeacherDetailPage(partnerId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/partners/requests', builder: (_, _) => const RequestsPage()),
        GoRoute(path: '/partners/subscriptions', builder: (_, _) => const SubscriptionsPage()),
        GoRoute(path: '/partners/audit', builder: (_, _) => const AuditPage()),
        GoRoute(path: '/partners/settings', builder: (_, _) => const SettingsPage()),
      ],
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthCubit>(),
        child: HomeShellPage(user: sl<AuthRepository>().currentUser!),
      ),
    ),
  ],
);
