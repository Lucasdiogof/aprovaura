import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

    testWidgets(
      'shows validation errors and does not call signIn when the form is '
      'submitted empty',
      (tester) async {
        await pumpLoginPage(tester);

        await tester.ensureVisible(find.text('Entrar').last);
        await tester.tap(find.text('Entrar').last);
        await tester.pump();

        expect(find.text('Informe seu e-mail.'), findsOneWidget);
        expect(find.text('Informe sua senha.'), findsOneWidget);
        verifyNever(
          () => authCubit.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    testWidgets('shows an invalid-email error for a malformed address', (
      tester,
    ) async {
      await pumpLoginPage(tester);

      await tester.enterText(find.byType(TextField).first, 'not-an-email');
      await tester.tap(find.text('Entrar').last);
      await tester.pump();

      expect(find.text('Informe um e-mail válido.'), findsOneWidget);
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

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
