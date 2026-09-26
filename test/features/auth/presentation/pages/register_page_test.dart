import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/auth_state.dart';
import 'package:aura/features/auth/presentation/pages/register_page.dart';

import '../../../../helpers/pump_app.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  group(RegisterPage, () {
    late AuthCubit authCubit;

    setUpAll(() {
      registerFallbackValue(const AuthInitial());
    });

    setUp(() {
      authCubit = _MockAuthCubit();
      when(() => authCubit.state).thenReturn(const AuthInitial());
      when(
        () => authCubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {});
    });

    Future<void> pumpRegisterPage(WidgetTester tester) =>
        tester.pumpAppWithRouter(
          const RegisterPage(),
          providers: [BlocProvider<AuthCubit>.value(value: authCubit)],
        );

    testWidgets('renders name, email, password and confirm password fields', (
      tester,
    ) async {
      await pumpRegisterPage(tester);

      expect(find.byType(TextField), findsNWidgets(5));
    });

    testWidgets(
      'shows validation errors and does not call signUp when the form is '
      'submitted empty',
      (tester) async {
        await pumpRegisterPage(tester);

        await tester.ensureVisible(find.text('Criar conta').last);
        await tester.tap(find.text('Criar conta').last);
        await tester.pump();

        expect(find.text('Informe seu nome.'), findsOneWidget);
        expect(find.text('Informe seu e-mail.'), findsOneWidget);
        expect(find.text('Informe sua senha.'), findsOneWidget);
        expect(find.text('Confirme sua senha.'), findsOneWidget);
        verifyNever(
          () => authCubit.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    testWidgets('shows a mismatch error when the confirmation differs from the '
        'password, and does not call signUp', (tester) async {
      await pumpRegisterPage(tester);
      final fields = find.byType(TextField);

      await tester.enterText(fields.at(0), 'Lucas Diogo');
      await tester.enterText(fields.at(2), 'dash@example.com');
      await tester.enterText(fields.at(3), 'senha123');
      await tester.enterText(fields.at(4), 'senha456');
      await tester.ensureVisible(find.text('Criar conta').last);
      await tester.tap(find.text('Criar conta').last);
      await tester.pump();

      expect(find.text('As senhas não coincidem.'), findsOneWidget);
      verifyNever(
        () => authCubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets(
      'calls signUp with the trimmed email and password when the form is '
      'valid',
      (tester) async {
        await pumpRegisterPage(tester);
        final fields = find.byType(TextField);

        await tester.enterText(fields.at(0), 'Lucas Diogo');
        await tester.enterText(fields.at(2), '  dash@example.com  ');
        await tester.enterText(fields.at(3), 'senha123');
        await tester.enterText(fields.at(4), 'senha123');
        await tester.ensureVisible(find.text('Criar conta').last);
        await tester.tap(find.text('Criar conta').last);
        await tester.pump();

        verify(
          () =>
              authCubit.signUp(email: 'dash@example.com', password: 'senha123'),
        ).called(1);
      },
    );

    testWidgets('shows a real label above every field, not just hints', (
      tester,
    ) async {
      await pumpRegisterPage(tester);

      expect(find.text('Nome completo'), findsOneWidget);
      // The label and the hint are the same text for this one (optional)
      // field, so both the label above it and the hint inside it match.
      expect(find.text('Nome de usuário (opcional)'), findsNWidgets(2));
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      // Same as the username field: "Confirmar senha" is both the label
      // and the hint here, so it matches twice.
      expect(find.text('Confirmar senha'), findsNWidgets(2));
    });

    testWidgets('has a back button and no "already have an account" prompt', (
      tester,
    ) async {
      await pumpRegisterPage(tester);

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.textContaining('Já tem uma conta'), findsNothing);
    });

    testWidgets('no overflow on a very short viewport', (tester) async {
      tester.view.physicalSize = const Size(360, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpRegisterPage(tester);
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
