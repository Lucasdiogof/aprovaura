import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/di/injection_container.dart';
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

  testWidgets('"Enviar link" stays disabled until the e-mail is valid, and '
      'the error follows the typing', (tester) async {
    await open(tester);
    final field = find.byType(TextField);

    await tester.tap(find.text('Enviar link'));
    await tester.pump();
    verifyNever(() => auth.sendPasswordReset(email: any(named: 'email')));
    expect(find.text('Informe seu e-mail.'), findsNothing);

    await tester.enterText(field, 'dash@');
    await tester.pump();
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);

    await tester.enterText(field, 'dash@example.com');
    await tester.pump();
    expect(find.text('Informe um e-mail válido.'), findsNothing);
    await tester.tap(find.text('Enviar link'));
    await tester.pumpAndSettle();
    verify(() => auth.sendPasswordReset(email: 'dash@example.com')).called(1);
  });
}
