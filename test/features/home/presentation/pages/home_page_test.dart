
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
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_mascot_view.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/home/domain/repositories/daily_goal_repository.dart';
import 'package:aura/features/home/presentation/cubit/home_summary_cubit.dart';
import 'package:aura/features/home/presentation/pages/home_page.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/profile/domain/entities/user_profile.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/streak/domain/repositories/streak_repository.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/streak/presentation/cubit/streak_state.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';
import 'package:aura/features/xp/domain/repositories/xp_repository.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/features/xp/presentation/cubit/xp_state.dart';

class _MockDailyGoalRepository extends Mock implements DailyGoalRepository {}

class _MockErrorReviewRepository extends Mock
    implements ErrorReviewRepository {}

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

class _MockMockExamRepository extends Mock implements MockExamRepository {}

class _MockProfileRepository extends Mock implements ProfileRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockXpRepository extends Mock implements XpRepository {}

class _MockStreakRepository extends Mock implements StreakRepository {}

const _user = AppUser(id: 'user-1', email: 'estudante@exemplo.com');

Streak _streak(int days) => Streak(
  currentStreak: days,
  longestStreak: days,
  lastActivityDate: DateTime.now(),
  streakBreakVersion: 0,
  seenStreakBreakVersion: 0,
);

/// Home shows where things stand, and celebrates only what no result
/// screen was in a position to celebrate.
void main() {
  late DailyGoalRepository dailyGoalRepository;
  late XpCubit xpCubit;
  late StreakCubit streakCubit;
  late HomeSummaryCubit summaryCubit;
  late ProfileCubit profileCubit;
  late SharedPreferences prefs;

  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    dailyGoalRepository = _MockDailyGoalRepository();
    final errors = _MockErrorReviewRepository();
    final favorites = _MockFavoritesRepository();
    final exams = _MockMockExamRepository();
    final profiles = _MockProfileRepository();
    final auth = _MockAuthRepository();

    when(() => auth.currentUser).thenReturn(_user);
    when(
      () => errors.listPendingTopics(),
    ).thenAnswer((_) async => const Success([]));
    when(
      () => favorites.listFavoriteTopics(),
    ).thenAnswer((_) async => const Success([]));
    when(
      () => exams.getActiveMockExam(),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => profiles.getCurrent(),
    ).thenAnswer((_) async => const Success(UserProfile(id: 'user-1')));
    when(
      () => dailyGoalRepository.getTodayAnsweredCount(),
    ).thenAnswer((_) async => const Success(3));

    sl.registerLazySingleton<AuthRepository>(() => auth);
    sl.registerLazySingleton<DailyGoalRepository>(() => dailyGoalRepository);
    sl.registerSingleton<SharedPreferences>(prefs);

    xpCubit = XpCubit(_MockXpRepository());
    streakCubit = StreakCubit(_MockStreakRepository());
    summaryCubit = HomeSummaryCubit(
      dailyGoalRepository,
      errors,
      favorites,
      exams,
    );
    profileCubit = ProfileCubit(profiles, _user);
  });

  tearDown(() async {
    await xpCubit.close();
    await streakCubit.close();
    await summaryCubit.close();
    await profileCubit.close();
  });

  /// Pumps a few frames without waiting for the tree to go still: while
  /// the daily goal is incomplete its card runs a continuous border
  /// animation (approved in 4800adc), so nothing on Home ever "settles".
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
  }

  /// Puts the app in a known standing, which the first look records as a
  /// baseline -- everything after that is a real change.
  Future<void> settleBaseline(
    WidgetTester tester, {
    int totalXp = 0,
    int streakDays = 1,
  }) async {
    xpCubit.emit(XpLoaded(UserXp(totalXp: totalXp)));
    streakCubit.emit(StreakLoaded(_streak(streakDays)));
    await summaryCubit.load();
    await settle(tester);
  }

  Future<void> pumpHome(
    WidgetTester tester, {
    ThemeData? theme,
    Widget home = const HomePage(),
  }) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<LocaleCubit>(
            create: (_) => LocaleCubit()..emit(AppLanguage.portuguese),
          ),
          BlocProvider<XpCubit>.value(value: xpCubit),
          BlocProvider<StreakCubit>.value(value: streakCubit),
          BlocProvider<HomeSummaryCubit>.value(value: summaryCubit),
          BlocProvider<ProfileCubit>.value(value: profileCubit),
        ],
        child: MaterialApp(theme: theme ?? AppTheme.light, home: home),
      ),
    );
    await tester.pump();
  }

  group('what Home shows', () {
    testWidgets('the numbers as they stand right now', (tester) async {
      when(
        () => dailyGoalRepository.getTodayAnsweredCount(),
      ).thenAnswer((_) async => const Success(10));
      await pumpHome(tester);
      await settleBaseline(tester, totalXp: 720, streakDays: 7);

      // Goal complete, streak and Aura from the real cubits -- no reload,
      // no pull-to-refresh, no app restart needed.
      expect(find.text('Meta batida!'), findsWidgets);
      expect(find.textContaining('7'), findsWidgets);
      expect(find.textContaining('720'), findsWidgets);
    });

    testWidgets('a goal gone past still shows the real count', (tester) async {
      when(
        () => dailyGoalRepository.getTodayAnsweredCount(),
      ).thenAnswer((_) async => const Success(14));
      await pumpHome(tester);
      await settleBaseline(tester);

      expect(find.textContaining('14'), findsWidgets);
    });
  });

  testWidgets('Home never puts Aurudo over the screen, even for a goal '
      'nobody celebrated', (tester) async {
    await pumpHome(tester);
    await settleBaseline(tester);

    // Reached during a mock exam, whose result screen does not claim it.
    when(
      () => dailyGoalRepository.getTodayAnsweredCount(),
    ).thenAnswer((_) async => const Success(12));
    await summaryCubit.load();
    await settle(tester);

    // The card shows it; nothing pops up in the middle of the screen.
    expect(find.text('Meta batida!'), findsWidgets);
    expect(find.byType(AurudoMascotView), findsNothing);
  });
}
