import 'package:go_router/go_router.dart';
import 'package:aura/features/auth/presentation/pages/login_page.dart';
import 'package:aura/features/splash/presentation/pages/splash_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
  ],
);
