import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/auth/presentation/pages/login_page.dart';
import 'package:aura/features/auth/presentation/pages/register_page.dart';
import 'package:aura/features/home/presentation/pages/home_shell_page.dart';
import 'package:aura/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:aura/features/splash/presentation/pages/splash_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
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
      builder: (context, state) =>
          OnboardingPage(user: state.extra! as AppUser),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AuthCubit>(),
        child: HomeShellPage(user: state.extra! as AppUser),
      ),
    ),
  ],
);
