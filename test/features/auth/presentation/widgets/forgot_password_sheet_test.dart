import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/widgets/forgot_password_sheet.dart';
import 'package:aura/shared/widgets/app_logo.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _PortugueseLocale extends LocaleCubit {
  _PortugueseLocale() {
    emit(AppLanguage.portuguese);
  }
}

void main() {
  late AuthRepository auth;

  setUp(() async {
    await sl.reset();
    auth = _MockAuthRepository();
    when(
      () => auth.sendPasswordReset(email: any(named: 'email')),
    ).thenAnswer((_) async => const Success(null));
    sl.registerSingleton<AuthRepository>(auth);
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> open(WidgetTester tester, {String email = ''}) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider<LocaleCubit>(
        create: (_) => _PortugueseLocale(),
        child: MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    ForgotPasswordSheet.show(context, initialEmail: email),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('opens with the Aprovaura symbol', (tester) async {
    await open(tester);
    expect(find.byType(AppLogo), findsOneWidget);
  });

  testWidgets('"Enviar código" stays disabled until the e-mail is valid, and '
      'the error follows the typing', (tester) async {
    await open(tester);
    final field = find.byType(TextField);

    await tester.tap(find.text('Enviar código'));
    await tester.pump();
    verifyNever(() => auth.sendPasswordReset(email: any(named: 'email')));
    expect(find.text('Informe seu e-mail.'), findsNothing);

    await tester.enterText(field, 'dash@');
    await tester.pump();
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);

    await tester.enterText(field, 'dash@example.com');
    await tester.pump();
    expect(find.text('Informe um e-mail válido.'), findsNothing);
    await tester.tap(find.text('Enviar código'));
    await tester.pumpAndSettle();
    verify(() => auth.sendPasswordReset(email: 'dash@example.com')).called(1);
  });

  testWidgets('walks email -> code -> new password -> done', (tester) async {
    when(
      () => auth.verifyRecoveryCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      ),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => auth.updatePassword(newPassword: any(named: 'newPassword')),
    ).thenAnswer((_) async => const Success(null));
    when(() => auth.signOut()).thenAnswer((_) async {});
    await open(tester, email: 'dash@example.com');

    await tester.tap(find.text('Enviar código'));
    await tester.pumpAndSettle();
    expect(find.text('Código de 6 dígitos'), findsOneWidget);

    // Letters are dropped, only 6 digits fit, and the button waits for all 6.
    await tester.enterText(find.byType(TextField), '12ab34567890');
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '123456',
    );
    await tester.tap(find.text('Confirmar código'));
    await tester.pumpAndSettle();
    verify(
      () => auth.verifyRecoveryCode(email: 'dash@example.com', code: '123456'),
    ).called(1);

    expect(find.text('Salvar nova senha'), findsOneWidget);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'segredo123');
    await tester.enterText(fields.at(1), 'segredo123');
    await tester.pump();
    await tester.tap(find.text('Salvar nova senha'));
    await tester.pumpAndSettle();
    verify(() => auth.updatePassword(newPassword: 'segredo123')).called(1);
    expect(find.text('Senha alterada'), findsOneWidget);
  });

  testWidgets('a wrong code shows the error and keeps the code step', (
    tester,
  ) async {
    when(
      () => auth.verifyRecoveryCode(
        email: any(named: 'email'),
        code: any(named: 'code'),
      ),
    ).thenAnswer(
      (_) async => Error(AuthFailure('Código incorreto ou expirado.')),
    );
    await open(tester, email: 'dash@example.com');
    await tester.tap(find.text('Enviar código'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '000000');
    await tester.pump();
    await tester.tap(find.text('Confirmar código'));
    await tester.pumpAndSettle();
    expect(find.text('Código incorreto ou expirado.'), findsOneWidget);
    expect(find.text('Confirmar código'), findsOneWidget);
  });
}
