import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/router/app_route_observer.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/auth/presentation/pages/login_page.dart';
import 'package:aura/features/auth/presentation/pages/register_page.dart';
import 'package:aura/features/home/presentation/pages/home_shell_page.dart';
import 'package:aura/features/onboarding/presentation/pages/onboarding_page.dart';

/// Rotas que só existem com sessão: sem ela, `/home` quebraria em
/// `currentUser!` e `/onboarding` gravaria perfil sem dono. Importa também
/// na web, onde qualquer URL pode ser aberta direto.
const _authenticatedRoutes = {'/home', '/onboarding'};

String? authRedirect({required bool hasSession, required String location}) {
  if (!hasSession && _authenticatedRoutes.contains(location)) return '/login';
  if (hasSession && location == '/login') return '/home';
  return null;
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  observers: [appRouteObserver],
  redirect: (context, state) => authRedirect(
    hasSession: sl<AuthRepository>().currentUser != null,
    location: state.matchedLocation,
  ),
  routes: [
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
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
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
