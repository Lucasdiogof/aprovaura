import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';

// LocaleCubit's real starting state depends on the device locale, which is
// unpredictable in a test environment (often en_US, not pt_BR). Pages
// assert on Portuguese copy, so tests force a deterministic starting
// language: mock prefs empty (so the cubit's own async load never
// overrides it with something else) and emit portuguese immediately after
// construction.
class _TestLocaleCubit extends LocaleCubit {
  _TestLocaleCubit() {
    emit(AppLanguage.portuguese);
  }
}

LocaleCubit _testLocaleCubit() {
  SharedPreferences.setMockInitialValues({});
  return _TestLocaleCubit();
}

extension PumpApp on WidgetTester {
  // Wraps [child] with the providers/theme every page needs to render on
  // its own in a widget test, without booting the real app/router.
  Future<void> pumpApp(
    Widget child, {
    List<BlocProvider<dynamic>> providers = const [],
  }) {
    return pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<LocaleCubit>(create: (_) => _testLocaleCubit()),
          ...providers,
        ],
        child: MaterialApp(theme: AppTheme.light, home: child),
      ),
    );
  }

  // Same as pumpApp, but hosts [child] behind a real GoRouter so
  // context.go/context.push calls (navigation) don't throw.
  Future<void> pumpAppWithRouter(
    Widget child, {
    List<BlocProvider<dynamic>> providers = const [],
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => child),
        GoRoute(path: '/cadastro', builder: (_, _) => const SizedBox.shrink()),
        GoRoute(path: '/home', builder: (_, _) => const SizedBox.shrink()),
        GoRoute(
          path: '/onboarding',
          builder: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
    return pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<LocaleCubit>(create: (_) => _testLocaleCubit()),
          ...providers,
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
  }
}
