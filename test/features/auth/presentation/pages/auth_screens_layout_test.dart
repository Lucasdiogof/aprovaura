import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/auth_state.dart';
import 'package:aura/features/auth/presentation/pages/login_page.dart';
import 'package:aura/features/auth/presentation/pages/register_page.dart';
import 'package:aura/features/auth/presentation/widgets/auth_card.dart';
import 'package:aura/features/auth/presentation/widgets/auth_header.dart';
import 'package:aura/features/auth/presentation/widgets/auth_layout.dart';
import 'package:aura/features/auth/presentation/widgets/auth_palette.dart';
import 'package:aura/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:aura/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:aura/shared/widgets/app_aura_loader.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _PortugueseLocale extends LocaleCubit {
  _PortugueseLocale() {
    emit(AppLanguage.portuguese);
  }
}

enum _Screen { login, register }

void main() {
  late AuthCubit auth;

  setUpAll(() => registerFallbackValue(const AuthInitial()));

  setUp(() {
    auth = _MockAuthCubit();
    when(() => auth.state).thenReturn(const AuthInitial());
    when(
      () => auth.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => auth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
        username: any(named: 'username'),
      ),
    ).thenAnswer((_) async {});
  });

  void useSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  /// Login at the root, like the app; sign-up pushed on top of it. As in
  /// the app's router, each screen has its own AuthCubit: [auth] belongs to
  /// the screen under test, the other one gets an idle one.
  Future<GoRouter> pump(
    WidgetTester tester,
    _Screen screen, {
    bool dark = false,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final idle = _MockAuthCubit();
    when(() => idle.state).thenReturn(const AuthInitial());
    Widget withAuth(AuthCubit cubit, Widget page) =>
        BlocProvider<AuthCubit>.value(value: cubit, child: page);
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, _) => withAuth(
            screen == _Screen.login ? auth : idle,
            const LoginPage(),
          ),
        ),
        GoRoute(
          path: '/cadastro',
          builder: (_, _) => withAuth(
            screen == _Screen.register ? auth : idle,
            const RegisterPage(),
          ),
        ),
        GoRoute(path: '/home', builder: (_, _) => const SizedBox()),
        GoRoute(path: '/onboarding', builder: (_, _) => const SizedBox()),
      ],
    );
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<LocaleCubit>(create: (_) => _PortugueseLocale()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          routerConfig: router,
        ),
      ),
    );
    if (screen == _Screen.register) {
      unawaited(router.push('/cadastro'));
      // Not pumpAndSettle: a loading button's loader never settles.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }
    return router;
  }

  Finder field(int i) => find.byType(TextField).at(i);

  bool obscured(WidgetTester tester, int i) => tester
      .widget<EditableText>(
        find.descendant(of: field(i), matching: find.byType(EditableText)),
      )
      .obscureText;

  Future<void> tapSubmit(WidgetTester tester) async {
    await tester.ensureVisible(find.byType(AuthSubmitButton));
    await tester.tap(find.byType(AuthSubmitButton));
    await tester.pump();
  }

  group('light and dark', () {
    for (final screen in _Screen.values) {
      for (final dark in [false, true]) {
        final theme = dark ? 'dark' : 'light';
        testWidgets('${screen.name} renders in $theme with its own tokens', (
          tester,
        ) async {
          useSize(tester, const Size(390, 844));
          await pump(tester, screen, dark: dark);

          expect(tester.takeException(), isNull);
          expect(find.byType(AuthHeader), findsOneWidget);
          expect(find.byType(AuthCard), findsOneWidget);
          expect(find.byType(AuthSubmitButton), findsOneWidget);
          final scaffold = tester.widget<Scaffold>(
            find.descendant(
              of: find.byType(AuthScaffold),
              matching: find.byType(Scaffold),
            ),
          );
          expect(
            scaffold.backgroundColor,
            dark ? AuthPalette.dark.background : AuthPalette.light.background,
          );
        });
      }

      testWidgets('${screen.name}: the same geometry in both themes', (
        tester,
      ) async {
        useSize(tester, const Size(390, 844));
        Future<List<Rect>> rects(bool dark) async {
          await pump(tester, screen, dark: dark);
          return [
            tester.getRect(find.byType(AuthHeader)),
            tester.getRect(find.byType(AuthCard)),
            for (var i = 0; i < find.byType(TextField).evaluate().length; i++)
              tester.getRect(field(i)),
            tester.getRect(find.byType(AuthSubmitButton)),
          ];
        }

        final light = await rects(false);
        final dark = await rects(true);
        expect(dark, light);
      });
    }
  });

  group('login', () {
    testWidgets('the front door has no back button; its row keeps the '
        'layout in place', (tester) async {
      useSize(tester, const Size(390, 844));
      await pump(tester, _Screen.login);
      expect(find.byIcon(AuthScaffold.backIcon), findsNothing);
      // The header starts under the (empty) back-button row, like on
      // sign-up.
      expect(
        tester.getTopLeft(find.byType(AuthHeader)).dy,
        greaterThanOrEqualTo(AuthLayout.backButtonSize),
      );
    });

    testWidgets('the eye shows and hides the password', (tester) async {
      await pump(tester, _Screen.login);
      expect(obscured(tester, 1), isTrue);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(obscured(tester, 1), isFalse);
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      expect(obscured(tester, 1), isTrue);
    });

    testWidgets('while signing in: the Aura loader, and a second tap does '
        'nothing', (tester) async {
      when(() => auth.state).thenReturn(const AuthLoading());
      await pump(tester, _Screen.login);
      await tester.enterText(field(0), 'dash@example.com');
      await tester.enterText(field(1), 'senha123');
      await tapSubmit(tester);
      await tapSubmit(tester);

      expect(find.byType(AppAuraLoader), findsOneWidget);
      verifyNever(
        () => auth.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('keyboard "done" on the password signs in', (tester) async {
      await pump(tester, _Screen.login);
      await tester.enterText(field(0), 'dash@example.com');
      await tester.enterText(field(1), 'senha123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      verify(
        () => auth.signIn(email: 'dash@example.com', password: 'senha123'),
      ).called(1);
    });
  });

  group('sign-up', () {
    testWidgets('each eye toggles only its own field', (tester) async {
      useSize(tester, const Size(390, 844));
      await pump(tester, _Screen.register);
      expect(obscured(tester, 3), isTrue);
      expect(obscured(tester, 4), isTrue);

      Future<void> tapEye(int i) async {
        final eye = find.byIcon(Icons.visibility_outlined).at(i);
        await tester.ensureVisible(eye);
        await tester.tap(eye);
        await tester.pump();
      }

      await tapEye(0);
      expect(obscured(tester, 3), isFalse);
      expect(obscured(tester, 4), isTrue);

      // The password's eye now shows "hide"; the only "show" left is the
      // confirmation's.
      await tapEye(0);
      expect(obscured(tester, 3), isFalse);
      expect(obscured(tester, 4), isFalse);
    });

    testWidgets('while signing up a second tap does nothing', (tester) async {
      when(() => auth.state).thenReturn(const AuthLoading());
      await pump(tester, _Screen.register);
      await tester.enterText(field(0), 'Lucas');
      await tester.enterText(field(2), 'dash@example.com');
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha123');
      await tapSubmit(tester);
      await tapSubmit(tester);

      expect(find.byType(AppAuraLoader), findsOneWidget);
      verifyNever(
        () => auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
          username: any(named: 'username'),
        ),
      );
    });

    testWidgets('an email that already has an account: the error, no '
        'navigation, and the form usable again', (tester) async {
      final states = StreamController<AuthState>();
      addTearDown(states.close);
      whenListen(auth, states.stream, initialState: const AuthInitial());
      await pump(tester, _Screen.register);
      states
        ..add(const AuthLoading())
        ..add(
          const AuthError(
            'Já existe uma conta com este e-mail.',
            isEmailTaken: true,
          ),
        );
      await tester.pumpAndSettle();

      expect(find.text('Esse e-mail já tem conta'), findsOneWidget);
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(RegisterPage), findsOneWidget);
      // Back to normal: the label, not the loader.
      expect(
        find.descendant(
          of: find.byType(AuthSubmitButton),
          matching: find.byType(AppAuraLoader),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(AuthSubmitButton),
          matching: find.text('Criar conta'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the back button returns to login', (tester) async {
      await pump(tester, _Screen.register);
      await tester.tap(find.byIcon(AuthScaffold.backIcon));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(RegisterPage), findsNothing);
    });
  });

  group('sizes and keyboard', () {
    for (final screen in _Screen.values) {
      for (final (name, size) in [
        ('360', const Size(360, 740)),
        ('430', const Size(430, 932)),
        ('tablet', const Size(1024, 1366)),
      ]) {
        testWidgets('${screen.name} at $name: no overflow, width capped', (
          tester,
        ) async {
          useSize(tester, size);
          await pump(tester, screen);
          expect(tester.takeException(), isNull);
          expect(
            tester.getSize(find.byType(AuthCard)).width,
            lessThanOrEqualTo(AuthLayout.maxContentWidth),
          );
        });
      }

      testWidgets('${screen.name} with the keyboard open and every error '
          'showing: no overflow, the button still reachable', (tester) async {
        useSize(tester, const Size(360, 740));
        tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 3);
        await pump(tester, screen);

        // The button is disabled on an empty form; "done" on the keyboard is
        // what reveals every error at once.
        await tester.showKeyboard(find.byType(TextField).last);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('Informe seu e-mail.'), findsOneWidget);
        await tester.ensureVisible(find.byType(AuthSubmitButton));
        expect(
          tester.getBottomLeft(find.byType(AuthSubmitButton)).dy,
          lessThanOrEqualTo(740 - 300),
        );
      });
    }
  });
}
