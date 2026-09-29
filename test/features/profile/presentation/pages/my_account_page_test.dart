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
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/profile_state.dart';
import 'package:aura/features/profile/presentation/pages/my_account_page.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';

import '../../../../helpers/pump_app.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

void main() {
  late ProfileRepository profiles;
  late ProfileCubit profileCubit;

  const taken = 'Esse nome de usuário já está em uso.';
  const length = 'Use de 3 a 20 caracteres.';
  const characters = 'Use só letras, números, ponto e _ (sem espaços).';
  const checkFailed =
      'Não deu para verificar o nome de usuário agora. Tente de novo.';

  setUp(() async {
    await sl.reset();
    profiles = _MockProfileRepository();
    // "lucks" is someone else's, in any casing; every other name is free.
    when(() => profiles.isUsernameAvailable(any())).thenAnswer(
      (call) async => Success(
        (call.positionalArguments.first as String).toLowerCase() != 'lucks',
      ),
    );
    sl.registerSingleton<ProfileRepository>(profiles);
    profileCubit = _MockProfileCubit();
    when(() => profileCubit.state).thenReturn(
      const ProfileState(
        authUser: AppUser(id: 'u1', email: 'dash@x.com'),
      ),
    );
    when(
      () => profileCubit.updateProfile(
        name: any(named: 'name'),
        username: any(named: 'username'),
      ),
    ).thenAnswer((_) async => const Success(null));
  });

  /// Opens "Minha conta" on top of a launcher, as from the profile.
  Future<void> open(WidgetTester tester, {String? username = 'Lucas_Diogo'}) {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    return tester
        .pumpApp(
          BlocProvider<ProfileCubit>.value(
            value: profileCubit,
            child: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider<ProfileCubit>.value(
                        value: profileCubit,
                        child: MyAccountPage(
                          initialName: 'Lucas Diogo',
                          initialUsername: username,
                          email: 'dash@x.com',
                        ),
                      ),
                    ),
                  ),
                  child: const Text('abrir'),
                ),
              ),
            ),
          ),
        )
        .then((_) async {
          await tester.tap(find.text('abrir'));
          await tester.pumpAndSettle();
        });
  }

  Finder usernameField() => find.byType(TextField).at(1);

  Future<void> typeUsername(WidgetTester tester, String value) async {
    await tester.enterText(usernameField(), value);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(find.text('Salvar'));
    await tester.pump();
  }

  void expectNoSave() => verifyNever(
    () => profileCubit.updateProfile(
      name: any(named: 'name'),
      username: any(named: 'username'),
    ),
  );

  testWidgets('1. the current username is valid as it is, without asking '
      'the database', (tester) async {
    await open(tester);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.text(taken), findsNothing);
    verifyNever(() => profiles.isUsernameAvailable(any()));
  });

  testWidgets('2. under 3 characters: invalid, save disabled', (tester) async {
    await open(tester);
    await typeUsername(tester, 'lu');
    expect(find.text(length), findsOneWidget);
    await tapSave(tester);
    expectNoSave();
  });

  testWidgets('3. over 20 characters: invalid', (tester) async {
    await open(tester);
    await typeUsername(tester, 'a' * 21);
    expect(find.text(length), findsOneWidget);
    verifyNever(() => profiles.isUsernameAvailable(any()));
  });

  testWidgets('4. a forbidden character: invalid', (tester) async {
    await open(tester);
    await typeUsername(tester, 'lucas!');
    expect(find.text(characters), findsOneWidget);
    await typeUsername(tester, 'lucás');
    expect(find.text(characters), findsOneWidget);
  });

  testWidgets('5. a free username: a check mark, save enabled', (tester) async {
    await open(tester);
    await typeUsername(tester, 'novo_nome');
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    await tapSave(tester);
    verify(
      () => profileCubit.updateProfile(
        name: 'Lucas Diogo',
        username: 'novo_nome',
      ),
    ).called(1);
  });

  testWidgets('6. a taken username: the message, save disabled', (
    tester,
  ) async {
    await open(tester);
    await typeUsername(tester, 'lucks');
    expect(find.text(taken), findsOneWidget);
    await tapSave(tester);
    expectNoSave();
  });

  testWidgets('7. case-insensitive: the own name in another casing is '
      'kept (and saved as typed); someone else\'s is taken in any casing', (
    tester,
  ) async {
    await open(tester);
    await typeUsername(tester, 'LUCKS');
    expect(find.text(taken), findsOneWidget);

    await typeUsername(tester, 'lucas_diogo');
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.text(taken), findsNothing);
    verifyNever(() => profiles.isUsernameAvailable('lucas_diogo'));
    await tapSave(tester);
    verify(
      () => profileCubit.updateProfile(
        name: 'Lucas Diogo',
        username: 'lucas_diogo',
      ),
    ).called(1);
  });

  testWidgets('8. the check failing blocks saving', (tester) async {
    when(
      () => profiles.isUsernameAvailable(any()),
    ).thenAnswer((_) async => Error(ServerFailure()));
    await open(tester);
    await typeUsername(tester, 'novo_nome');
    expect(find.text(checkFailed), findsOneWidget);
    await tapSave(tester);
    expectNoSave();
  });

  testWidgets('9. a late answer about an older text never overwrites the '
      'newer one', (tester) async {
    final slow = Completer<Result<bool>>();
    when(
      () => profiles.isUsernameAvailable('primeiro'),
    ).thenAnswer((_) => slow.future);
    await open(tester);
    await typeUsername(tester, 'primeiro');
    await typeUsername(tester, 'segundo');
    slow.complete(const Success(false));
    await tester.pump();

    expect(find.text(taken), findsNothing);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('10. the database refusing it on save (someone took it '
      'meanwhile) is the field\'s own message, not a generic error', (
    tester,
  ) async {
    when(
      () => profileCubit.updateProfile(
        name: any(named: 'name'),
        username: any(named: 'username'),
      ),
    ).thenAnswer((_) async => Error(UsernameTakenFailure()));
    await open(tester);
    await typeUsername(tester, 'novo_nome');
    await tapSave(tester);
    await tester.pumpAndSettle();

    expect(find.text(taken), findsOneWidget);
    expect(find.byType(AppInfoBottomSheet), findsNothing);
    expect(find.byType(MyAccountPage), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
  });

  testWidgets('11. success saves and closes the page', (tester) async {
    await open(tester);
    await typeUsername(tester, 'novo_nome');
    await tapSave(tester);
    await tester.pumpAndSettle();

    verify(
      () => profileCubit.updateProfile(
        name: 'Lucas Diogo',
        username: 'novo_nome',
      ),
    ).called(1);
    expect(find.byType(MyAccountPage), findsNothing);
  });

  testWidgets('12. a second tap while saving does nothing', (tester) async {
    final saving = Completer<Result<void>>();
    when(
      () => profileCubit.updateProfile(
        name: any(named: 'name'),
        username: any(named: 'username'),
      ),
    ).thenAnswer((_) => saving.future);
    await open(tester);
    await typeUsername(tester, 'novo_nome');
    await tapSave(tester);
    // The label gave way to the loader; tap the button itself again.
    expect(find.text('Salvar'), findsNothing);
    await tester.tap(find.byType(AppButton));
    await tester.pump();

    verify(
      () => profileCubit.updateProfile(
        name: any(named: 'name'),
        username: any(named: 'username'),
      ),
    ).called(1);
    saving.complete(const Success(null));
    await tester.pumpAndSettle();
  });

  testWidgets('an account without a username (created before it was '
      'required) must choose one to save', (tester) async {
    await open(tester, username: null);
    expect(find.text('Escolha um nome de usuário.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Outro Nome');
    await tester.pump();
    await tapSave(tester);
    expectNoSave();
  });
}
