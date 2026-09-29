import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/shared/widgets/app_aura_loader.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/auth_state.dart';
import 'package:aura/features/auth/presentation/pages/login_page.dart';

import '../../../../helpers/pump_app.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  group(LoginPage, () {
    late AuthCubit authCubit;

    setUpAll(() {
      registerFallbackValue(const AuthInitial());
    });

    setUp(() {
      authCubit = _MockAuthCubit();
      when(() => authCubit.state).thenReturn(const AuthInitial());
      when(
        () => authCubit.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});
    });

    Future<void> pumpLoginPage(WidgetTester tester) => tester.pumpAppWithRouter(
      const LoginPage(),
      providers: [BlocProvider<AuthCubit>.value(value: authCubit)],
    );

    testWidgets('renders an email field and a password field', (tester) async {
      await pumpLoginPage(tester);

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Entrar'), findsWidgets);
    });

    testWidgets('empty: no errors, and the disabled button does nothing', (
      tester,
    ) async {
      await pumpLoginPage(tester);

      await tester.ensureVisible(find.text('Entrar').last);
      await tester.tap(find.text('Entrar').last);
      await tester.pump();

      expect(find.text('Informe seu e-mail.'), findsNothing);
      expect(find.text('Informe sua senha.'), findsNothing);
      verifyNever(
        () => authCubit.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('"done" on the keyboard with the form empty shows what is '
        'missing', (tester) async {
      await pumpLoginPage(tester);

      await tester.showKeyboard(find.byType(TextField).last);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('Informe seu e-mail.'), findsOneWidget);
      expect(find.text('Informe sua senha.'), findsOneWidget);
    });

    testWidgets('a malformed e-mail is flagged while typing, and the flag '
        'goes once it is fixed or erased', (tester) async {
      await pumpLoginPage(tester);
      final email = find.byType(TextField).first;

      await tester.enterText(email, 'not-an-email');
      await tester.pump();
      expect(find.text('Informe um e-mail válido.'), findsOneWidget);

      await tester.enterText(email, 'dash@example.com');
      await tester.pump();
      expect(find.text('Informe um e-mail válido.'), findsNothing);

      await tester.enterText(email, 'x');
      await tester.pump();
      await tester.enterText(email, '');
      await tester.pump();
      expect(find.text('Informe um e-mail válido.'), findsNothing);
      expect(find.text('Informe seu e-mail.'), findsNothing);
    });

    testWidgets(
      'calls signIn with the trimmed email and password when the form is '
      'valid',
      (tester) async {
        await pumpLoginPage(tester);

        await tester.enterText(
          find.byType(TextField).first,
          '  dash@example.com  ',
        );
        await tester.enterText(find.byType(TextField).last, 'senha123');
        await tester.pump();
        await tester.ensureVisible(find.text('Entrar').last);
        await tester.tap(find.text('Entrar').last);
        await tester.pump();

        verify(
          () =>
              authCubit.signIn(email: 'dash@example.com', password: 'senha123'),
        ).called(1);
      },
    );

    testWidgets('shows a loading indicator while signing in', (tester) async {
      when(() => authCubit.state).thenReturn(const AuthLoading());
      await pumpLoginPage(tester);

      expect(find.byType(AppAuraLoader), findsOneWidget);
    });

    testWidgets('shows real labels above the fields, not just hints', (
      tester,
    ) async {
      await pumpLoginPage(tester);

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
    });

    testWidgets('no overflow on a very short viewport', (tester) async {
      tester.view.physicalSize = const Size(360, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpLoginPage(tester);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
