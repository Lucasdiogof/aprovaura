import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/router/app_route_observer.dart';
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
import 'package:aura/features/portal/presentation/pages/partner_pages.dart';
import 'package:aura/features/portal/presentation/pages/portal_gate.dart';
import 'package:aura/features/portal/presentation/pages/teachers_pages.dart';
import 'package:aura/features/portal/presentation/pages/user_detail_page.dart';
import 'package:aura/features/portal/presentation/pages/users_page.dart';

/// Rotas que só existem com sessão: sem ela, `/home` quebraria em
/// `currentUser!` e `/onboarding` gravaria perfil sem dono. Importa também
/// na web, onde qualquer URL pode ser aberta direto.
const _authenticatedRoutes = {'/home', '/onboarding'};

/// [introSeen]: the animated presentation was already shown (or skipped) on
/// this install. [setupPending]: the signed-in account still has to finish
/// the personal setup. Both default to the "nothing special" value, so a
/// caller that doesn't know about them keeps the old behaviour.
/// O portal vive em /partners (mesmo domínio, mesma conta). [next] é o destino
/// pedido antes do login (só aceito se for do portal: nunca redireciona para fora).
bool isPortalPath(String? p) => p != null && (p == '/partners' || p.startsWith('/partners/'));

String? authRedirect({
  required bool hasSession,
  required String location,
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
  initialLocation: _initialLocation(),
  observers: [appRouteObserver],
  redirect: (context, state) {
    final user = sl<AuthRepository>().currentUser;
    final store = IntroStore(sl<SharedPreferences>());
    return authRedirect(
      hasSession: user != null,
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
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          PortalGate(location: state.matchedLocation, child: child),
      routes: [
        GoRoute(path: '/partners', builder: (_, __) => const PortalHome(admin: DashboardPage())),
        GoRoute(path: '/partners/students', builder: (_, __) => partnerOnlyActive(const PartnerStudentsPage())),
        GoRoute(
          path: '/partners/students/:id',
          builder: (_, state) => partnerOnlyActive(PartnerStudentDetailPage(id: state.pathParameters['id']!)),
        ),
        GoRoute(path: '/partners/stats', builder: (_, __) => partnerOnlyActive(const PartnerStatsPage())),
        GoRoute(path: '/partners/finance', builder: (_, __) => const PartnerFinancePage()),
        GoRoute(path: '/partners/referrals', builder: (_, __) => partnerOnlyActive(const PartnerReferralsPage())),
        GoRoute(path: '/partners/me', builder: (_, __) => const PartnerProfilePage()),
        GoRoute(path: '/partners/users', builder: (_, __) => const UsersPage()),
        GoRoute(
          path: '/partners/users/:id',
          builder: (_, state) => UserDetailPage(userId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/partners/teachers', builder: (_, __) => const TeachersPage()),
        GoRoute(
          path: '/partners/teachers/:id',
          builder: (_, state) => TeacherDetailPage(partnerId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/partners/requests', builder: (_, __) => const RequestsPage()),
        GoRoute(path: '/partners/subscriptions', builder: (_, __) => const SubscriptionsPage()),
        GoRoute(path: '/partners/audit', builder: (_, __) => const AuditPage()),
        GoRoute(path: '/partners/settings', builder: (_, __) => const SettingsPage()),
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
