import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/core/theme/theme_cubit.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/profile/domain/entities/goal.dart';
import 'package:aura/features/profile/domain/entities/user_profile.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/profile/presentation/pages/goal_settings_page.dart';
import 'package:aura/features/profile/presentation/pages/interested_subjects_settings_page.dart';
import 'package:aura/features/profile/presentation/pages/my_account_page.dart';
import 'package:aura/features/profile/presentation/pages/profile_page.dart';
import 'package:aura/features/profile/presentation/pages/settings_page.dart';
import 'package:aura/features/profile/presentation/widgets/delete_account_tile.dart';
import 'package:aura/features/profile/presentation/widgets/settings_group.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/streak/domain/repositories/streak_repository.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/features/xp/domain/repositories/xp_repository.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockProgressRepository extends Mock implements ProgressRepository {}

class _MockXpRepository extends Mock implements XpRepository {}

class _MockStreakRepository extends Mock implements StreakRepository {}

const _authUser = AppUser(id: 'u1', email: 'estudante@exemplo.com');

const _profile = UserProfile(
  id: 'u1',
  name: 'Estudante',
  username: 'estudante',
  goal: Goal.enem,
  interestedSubjects: [Subject.matematica],
);

void main() {
  late ProfileRepository profileRepository;
  late AuthRepository authRepository;
  late AuthCubit authCubit;
  late String location;

  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
    location = '/perfil';

    profileRepository = _MockProfileRepository();
    authRepository = _MockAuthRepository();
    authCubit = AuthCubit(authRepository);

    when(
      () => profileRepository.getCurrent(),
    ).thenAnswer((_) async => const Success(_profile));
    when(() => authRepository.signOut()).thenAnswer((_) async {});
    when(
      () => authRepository.deleteAccount(),
    ).thenAnswer((_) async => const Success(null));

    // The page's own stats/XP/streak blocks only render once loaded; these
    // never resolve, so the tests are about the settings half below them.
    final progress = _MockProgressRepository();
    when(() => progress.getProfileStats()).thenAnswer((_) => Future.any([]));
    sl.registerLazySingleton<ProgressRepository>(() => progress);
  });

  tearDown(() => authCubit.close());

  Future<void> pumpProfile(
    WidgetTester tester, {
    ThemeData? theme,
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final xp = _MockXpRepository();
    final streak = _MockStreakRepository();
    final router = GoRouter(
      initialLocation: '/perfil',
      routes: [
        GoRoute(path: '/perfil', builder: (_, _) => const ProfilePage()),
        GoRoute(
          path: '/login',
          builder: (_, _) {
            location = '/login';
            return const Scaffold(body: Text('tela de login'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<LocaleCubit>(
            create: (_) => LocaleCubit()..emit(AppLanguage.portuguese),
          ),
          BlocProvider<ProfileCubit>(
            create: (_) => ProfileCubit(profileRepository, _authUser),
          ),
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<XpCubit>(create: (_) => XpCubit(xp)),
          BlocProvider<StreakCubit>(create: (_) => StreakCubit(streak)),
          // SettingsPage reads it; in the app it lives above the shell.
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        ],
        child: MaterialApp.router(
          theme: theme ?? AppTheme.light,
          // MaterialApp.router has no `home`, so the text size is applied
          // around whatever the router builds.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child ?? const SizedBox.shrink(),
          ),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group(ProfilePage, () {
    testWidgets('the settings half is grouped, not five loose cards', (
      tester,
    ) async {
      await pumpProfile(tester);
      await tester.scrollUntilVisible(find.text('Excluir minha conta'), 200);

      // Estudos, Conta, Sair -- "Excluir minha conta" is plain text.
      expect(find.byType(SettingsGroup), findsNWidgets(3));
      expect(find.text('Estudos'), findsOneWidget);
      expect(find.text('Conta'), findsOneWidget);
    });

    testWidgets('each row says what is behind it', (tester) async {
      await pumpProfile(tester);
      await tester.scrollUntilVisible(find.text('Configurações'), 200);

      // The current value, not just the row's name.
      expect(find.text('ENEM'), findsOneWidget);
      expect(find.text('1 matéria selecionada'), findsOneWidget);
      expect(find.text('Nome, usuário e e-mail'), findsOneWidget);
      expect(find.text('Tema, idioma e preferências'), findsOneWidget);
    });

    testWidgets('the goal row opens the goal screen', (tester) async {
      await pumpProfile(tester);
      await tester.scrollUntilVisible(find.text('Meu objetivo'), 200);
      await tester.tap(find.text('Meu objetivo'));
      await tester.pumpAndSettle();

      expect(find.byType(GoalSettingsPage), findsOneWidget);
    });

    testWidgets('the subjects row opens the subjects screen', (tester) async {
      await pumpProfile(tester);
      await tester.scrollUntilVisible(find.text('Matérias em foco'), 200);
      await tester.tap(find.text('Matérias em foco'));
      await tester.pumpAndSettle();

      expect(find.byType(InterestedSubjectsSettingsPage), findsOneWidget);
    });

    testWidgets('the account row opens the account screen', (tester) async {
      await pumpProfile(tester);
      await tester.scrollUntilVisible(find.text('Minha conta'), 200);
      await tester.tap(find.text('Minha conta'));
      await tester.pumpAndSettle();

      expect(find.byType(MyAccountPage), findsOneWidget);
    });

    testWidgets('the settings row opens settings', (tester) async {
      await pumpProfile(tester);
      await tester.scrollUntilVisible(find.text('Configurações'), 200);
      await tester.tap(find.text('Configurações'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });

  group('signing out', () {
    testWidgets('asks first, and cancelling keeps the session', (tester) async {
      await pumpProfile(tester);
      await tester.scrollUntilVisible(find.text('Sair'), 200);
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      expect(find.text('Sair da sua conta?'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      verifyNever(() => authRepository.signOut());
      expect(location, '/perfil');
    });

    testWidgets('confirming signs out and lands on the login screen', (
      tester,
    ) async {
      await pumpProfile(tester);
      await tester.scrollUntilVisible(find.text('Sair'), 200);
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sair'));
      await tester.pumpAndSettle();

      verify(() => authRepository.signOut()).called(1);
      expect(find.text('tela de login'), findsOneWidget);
    });
  });

  group('deleting the account', () {
    Future<void> openConfirmation(WidgetTester tester) async {
      await tester.scrollUntilVisible(find.text('Excluir minha conta'), 200);
      await tester.tap(find.text('Excluir minha conta'));
      await tester.pumpAndSettle();
    }

    testWidgets('sits apart from signing out, and says what it does', (
      tester,
    ) async {
      await pumpProfile(tester);
      await tester.scrollUntilVisible(find.text('Excluir minha conta'), 200);

      // Centered red text, not a card.
      final label = find.text('Excluir minha conta');
      expect(
        find.ancestor(of: label, matching: find.byType(SettingsGroup)),
        findsNothing,
      );
      expect(
        find.ancestor(of: label, matching: find.byType(TextButton)),
        findsOneWidget,
      );
      final context = tester.element(label);
      expect(tester.widget<Text>(label).style?.color, context.colors.error);
    });

    testWidgets('asks before doing anything', (tester) async {
      await pumpProfile(tester);
      await openConfirmation(tester);

      expect(find.text('Excluir sua conta?'), findsOneWidget);
      expect(find.textContaining('não pode ser desfeita'), findsOneWidget);
      verifyNever(() => authRepository.deleteAccount());
    });

    testWidgets('cancelling deletes nothing', (tester) async {
      await pumpProfile(tester);
      await openConfirmation(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      verifyNever(() => authRepository.deleteAccount());
      expect(find.text('Excluir minha conta'), findsOneWidget);
    });

    testWidgets('confirming deletes once and goes to the login screen', (
      tester,
    ) async {
      await pumpProfile(tester);
      await openConfirmation(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Excluir conta'));
      await tester.pumpAndSettle();

      verify(() => authRepository.deleteAccount()).called(1);
      expect(find.text('tela de login'), findsOneWidget);
    });

    testWidgets('a second tap while it runs does not delete twice', (
      tester,
    ) async {
      // Never completes: the row stays in its loading state, which is
      // exactly the window a double tap would land in.
      when(
        () => authRepository.deleteAccount(),
      ).thenAnswer((_) => Future.any([]));

      await pumpProfile(tester);
      await openConfirmation(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Excluir conta'));
      await tester.pump();

      // The label turns into a spinner; tapping the button again is a no-op.
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      await tester.tap(
        find.descendant(
          of: find.byType(DeleteAccountTile),
          matching: find.byType(TextButton),
        ),
        warnIfMissed: false,
      );
      await tester.pump();

      verify(() => authRepository.deleteAccount()).called(1);
    });

    testWidgets('a failure keeps the user signed in and says so', (
      tester,
    ) async {
      when(
        () => authRepository.deleteAccount(),
      ).thenAnswer((_) async => Error(ServerFailure()));

      await pumpProfile(tester);
      await openConfirmation(tester);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Excluir conta'));
      await tester.pumpAndSettle();

      // Still here, still signed in, with an explanation.
      expect(find.text('tela de login'), findsNothing);
      expect(find.byType(ProfilePage), findsOneWidget);
      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();
      expect(find.text('Excluir minha conta'), findsOneWidget);
    });
  });

  group('layout', () {
    testWidgets('fits 360px', (tester) async {
      await pumpProfile(tester, size: const Size(360, 640));
      await tester.scrollUntilVisible(find.text('Excluir minha conta'), 200);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders on dark', (tester) async {
      await pumpProfile(tester, theme: AppTheme.dark);
      await tester.scrollUntilVisible(find.text('Excluir minha conta'), 200);
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a larger text size', (tester) async {
      await pumpProfile(tester, size: const Size(360, 640), textScale: 1.5);
      await tester.scrollUntilVisible(find.text('Excluir minha conta'), 200);
      expect(tester.takeException(), isNull);
    });
  });
}
