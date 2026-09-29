import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/auth_state.dart';
import 'package:aura/features/auth/presentation/pages/register_page.dart';
import 'package:aura/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';

import '../../../../helpers/pump_app.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  group(RegisterPage, () {
    late AuthCubit authCubit;
    late ProfileRepository profiles;

    setUpAll(() {
      registerFallbackValue(const AuthInitial());
    });

    setUp(() async {
      await sl.reset();
      profiles = _MockProfileRepository();
      // "lucks" is taken; every other well-formed name is free.
      when(() => profiles.isUsernameAvailable(any())).thenAnswer(
        (call) async =>
            Success(call.positionalArguments.first as String != 'lucks'),
      );
      sl.registerSingleton<ProfileRepository>(profiles);
      authCubit = _MockAuthCubit();
      when(() => authCubit.state).thenReturn(const AuthInitial());
      when(
        () => authCubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
          username: any(named: 'username'),
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

    Finder field(int i) => find.byType(TextField).at(i);

    /// Types a free username and lets the (debounced) database check land.
    Future<void> typeUsername(WidgetTester tester, String value) async {
      await tester.enterText(field(1), value);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
    }

    Future<void> fillValid(
      WidgetTester tester, {
      String email = 'dash@example.com',
    }) async {
      await tester.enterText(field(0), 'Lucas Diogo');
      await typeUsername(tester, 'lucas_diogo');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha123');
      await tester.pump();
    }

    testWidgets('empty: no errors, and the disabled button does nothing', (
      tester,
    ) async {
      await pumpRegisterPage(tester);

      await tester.ensureVisible(find.text('Criar conta').last);
      await tester.tap(find.text('Criar conta').last);
      await tester.pump();

      expect(find.text('Informe seu nome.'), findsNothing);
      expect(find.text('Informe seu e-mail.'), findsNothing);
      verifyNever(
        () => authCubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
          username: any(named: 'username'),
        ),
      );
    });

    testWidgets('"done" on the keyboard with the form empty shows what is '
        'missing, the username included', (tester) async {
      await pumpRegisterPage(tester);

      await tester.showKeyboard(field(4));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('Informe seu nome.'), findsOneWidget);
      expect(find.text('Escolha um nome de usuário.'), findsOneWidget);
      expect(find.text('Informe seu e-mail.'), findsOneWidget);
      expect(find.text('Informe sua senha.'), findsOneWidget);
      expect(find.text('Confirme sua senha.'), findsOneWidget);
    });

    testWidgets('a different confirmation is flagged while typing, and the '
        'button stays disabled', (tester) async {
      await pumpRegisterPage(tester);
      await fillValid(tester);
      await tester.enterText(field(4), 'senha456');
      await tester.pump();

      expect(find.text('As senhas não coincidem.'), findsOneWidget);
      await tester.ensureVisible(find.text('Criar conta').last);
      await tester.tap(find.text('Criar conta').last);
      await tester.pump();
      verifyNever(
        () => authCubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
          username: any(named: 'username'),
        ),
      );
    });

    testWidgets('a password under 6 characters is flagged while typing', (
      tester,
    ) async {
      await pumpRegisterPage(tester);
      await tester.enterText(field(3), 'abc');
      await tester.pump();
      expect(find.text('Use pelo menos 6 caracteres.'), findsOneWidget);
      await tester.enterText(field(3), 'abcdef');
      await tester.pump();
      expect(find.text('Use pelo menos 6 caracteres.'), findsNothing);
    });

    group('username', () {
      testWidgets('too short, bad characters: flagged while typing, no '
          'database call', (tester) async {
        await pumpRegisterPage(tester);

        await typeUsername(tester, 'lu');
        expect(find.text('Use de 3 a 20 caracteres.'), findsOneWidget);

        await typeUsername(tester, 'lucas diogo');
        expect(
          find.text('Use só letras, números, ponto e _ (sem espaços).'),
          findsOneWidget,
        );
        verifyNever(() => profiles.isUsernameAvailable(any()));
      });

      testWidgets('taken in the database: flagged, button stays disabled', (
        tester,
      ) async {
        await pumpRegisterPage(tester);
        await fillValid(tester);
        await typeUsername(tester, 'lucks');

        expect(
          find.text('Esse nome de usuário já está em uso.'),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text('Criar conta').last);
        await tester.tap(find.text('Criar conta').last);
        await tester.pump();
        verifyNever(
          () => authCubit.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
            username: any(named: 'username'),
          ),
        );
      });

      testWidgets('free: a check mark, no error', (tester) async {
        await pumpRegisterPage(tester);
        await typeUsername(tester, 'lucas_diogo');

        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
        expect(find.text('Esse nome de usuário já está em uso.'), findsNothing);
      });

      testWidgets('fast typing asks the database once, for the last value', (
        tester,
      ) async {
        await pumpRegisterPage(tester);
        for (final partial in ['luc', 'luca', 'lucas', 'lucas_']) {
          await tester.enterText(field(1), partial);
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pump(const Duration(milliseconds: 450));

        verify(() => profiles.isUsernameAvailable('lucas_')).called(1);
        verifyNoMoreInteractions(profiles);
      });

      testWidgets('the check failing is said, and blocks the button', (
        tester,
      ) async {
        when(
          () => profiles.isUsernameAvailable(any()),
        ).thenAnswer((_) async => Error(ServerFailure()));
        await pumpRegisterPage(tester);
        await fillValid(tester);

        expect(
          find.text(
            'Não deu para verificar o nome de usuário agora. Tente de novo.',
          ),
          findsOneWidget,
        );
        await tester.ensureVisible(find.text('Criar conta').last);
        await tester.tap(find.text('Criar conta').last);
        await tester.pump();
        verifyNever(
          () => authCubit.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
            username: any(named: 'username'),
          ),
        );
      });
    });

    testWidgets(
      'calls signUp with the trimmed email and password when the form is '
      'valid',
      (tester) async {
        await pumpRegisterPage(tester);
        await fillValid(tester, email: '  dash@example.com  ');
        await tester.ensureVisible(find.text('Criar conta').last);
        await tester.tap(find.text('Criar conta').last);
        await tester.pump();

        verify(
          () => authCubit.signUp(
            email: 'dash@example.com',
            password: 'senha123',
            name: 'Lucas Diogo',
            username: 'lucas_diogo',
          ),
        ).called(1);
      },
    );

    testWidgets('ignores a second tap while the sign-up is still finishing', (
      tester,
    ) async {
      // AuthSuccess comes before the profile is saved and the page leaves:
      // the button must stay locked through that window too.
      when(() => authCubit.state).thenReturn(
        const AuthSuccess(AppUser(id: 'u1', email: 'dash@example.com')),
      );
      await pumpRegisterPage(tester);
      final fields = find.byType(TextField);

      await tester.enterText(fields.at(0), 'Lucas Diogo');
      await tester.enterText(fields.at(2), 'dash@example.com');
      await tester.enterText(fields.at(3), 'senha123');
      await tester.enterText(fields.at(4), 'senha123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      verifyNever(
        () => authCubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
          username: any(named: 'username'),
        ),
      );
    });

    testWidgets(
      'an email that already has an account gets its own message and a way '
      'to sign in',
      (tester) async {
        whenListen(
          authCubit,
          Stream<AuthState>.fromIterable(const [
            AuthError(
              'Já existe uma conta com este e-mail.',
              isEmailTaken: true,
            ),
          ]),
          initialState: const AuthInitial(),
        );
        await pumpRegisterPage(tester);
        await tester.pumpAndSettle();

        expect(find.text('Esse e-mail já tem conta'), findsOneWidget);
        expect(find.text('Entrar'), findsOneWidget);
        expect(find.textContaining('already registered'), findsNothing);
      },
    );

    testWidgets('shows a real label above every field, not just hints', (
      tester,
    ) async {
      await pumpRegisterPage(tester);

      expect(find.text('Nome completo'), findsOneWidget);
      // Label and hint are the same text for this field.
      expect(find.text('Nome de usuário'), findsNWidgets(2));
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      // Same as the username field: "Confirmar senha" is both the label
      // and the hint here, so it matches twice.
      expect(find.text('Confirmar senha'), findsNWidgets(2));
    });

    testWidgets('has a back button and no "already have an account" '
        'prompt', (tester) async {
      await pumpRegisterPage(tester);

      expect(find.byIcon(AuthScaffold.backIcon), findsOneWidget);
      expect(
        find.textContaining('Já tem uma conta', findRichText: true),
        findsNothing,
      );
    });

    group('race: the name is taken between the check and the sign-up', () {
      late StreamController<AuthState> states;

      setUp(() {
        states = StreamController<AuthState>();
        whenListen(authCubit, states.stream, initialState: const AuthInitial());
      });

      tearDown(() => states.close());

      Future<void> submit(WidgetTester tester) async {
        await tester.ensureVisible(find.text('Criar conta').last);
        await tester.tap(find.text('Criar conta').last);
        await tester.pump();
      }

      testWidgets('the database refuses it: "já está em uso" on the field, '
          'the name kept, nothing concluded, another name goes through', (
        tester,
      ) async {
        await pumpRegisterPage(tester);
        // The check said "free"...
        await fillValid(tester);
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
        await submit(tester);
        verify(
          () => authCubit.signUp(
            email: 'dash@example.com',
            password: 'senha123',
            name: 'Lucas Diogo',
            username: 'lucas_diogo',
          ),
        ).called(1);

        // ...but someone else got it first: the sign-up transaction is
        // refused as a whole (no account was created).
        states
          ..add(const AuthLoading())
          ..add(
            const AuthError(
              'Esse nome de usuário já está em uso.',
              isUsernameTaken: true,
            ),
          );
        await tester.pump();
        await tester.pump();

        // Not concluded: still on sign-up, no success sheet or navigation.
        expect(find.byType(RegisterPage), findsOneWidget);
        expect(find.byType(BottomSheet), findsNothing);
        // The name the person typed is still there, flagged as taken.
        expect(find.text('lucas_diogo'), findsOneWidget);
        expect(
          find.text('Esse nome de usuário já está em uso.'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
        // Submitting again with the same name does nothing.
        await submit(tester);
        verifyNever(
          () => authCubit.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
            username: 'lucas_diogo',
          ),
        );

        // Another name: checked, free, and the sign-up goes out with it.
        await typeUsername(tester, 'lucas_diogo2');
        expect(find.text('Esse nome de usuário já está em uso.'), findsNothing);
        await submit(tester);
        verify(
          () => authCubit.signUp(
            email: 'dash@example.com',
            password: 'senha123',
            name: 'Lucas Diogo',
            username: 'lucas_diogo2',
          ),
        ).called(1);
      });

      testWidgets('success goes straight to onboarding: the profile was '
          'created with the account', (tester) async {
        await pumpRegisterPage(tester);
        await fillValid(tester);
        await submit(tester);
        states.add(
          const AuthSuccess(AppUser(id: 'u1', email: 'dash@example.com')),
        );
        await tester.pumpAndSettle();

        expect(find.byType(RegisterPage), findsNothing);
        verifyNever(
          () => profiles.createProfile(
            id: any(named: 'id'),
            name: any(named: 'name'),
            username: any(named: 'username'),
          ),
        );
      });
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
