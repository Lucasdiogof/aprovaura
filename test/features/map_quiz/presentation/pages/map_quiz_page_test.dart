import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_farm_aura_animation.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_achievement_badge.dart';
import 'package:aura/features/home/domain/repositories/daily_goal_repository.dart';
import 'package:aura/features/map_quiz/domain/entities/map_board.dart';
import 'package:aura/features/map_quiz/domain/entities/map_interaction_type.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';
import 'package:aura/features/map_quiz/domain/entities/map_viewport_spec.dart';
import 'package:aura/features/map_quiz/domain/repositories/map_quiz_repository.dart';
import 'package:aura/features/map_quiz/presentation/cubit/map_quiz_cubit.dart';
import 'package:aura/features/map_quiz/presentation/cubit/map_quiz_state.dart';
import 'package:aura/features/map_quiz/presentation/pages/map_quiz_page.dart';
import 'package:aura/features/map_quiz/presentation/widgets/map_quiz_board.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/streak/domain/repositories/streak_repository.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';
import 'package:aura/features/xp/domain/repositories/xp_repository.dart';
import 'package:aura/features/streak/presentation/cubit/streak_state.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/features/xp/presentation/cubit/xp_state.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

import '../../../../helpers/pump_app.dart';

class _MockMapQuizRepository extends Mock implements MapQuizRepository {}

class _MockProgressRepository extends Mock implements ProgressRepository {}

class _MockDailyGoalRepository extends Mock implements DailyGoalRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockXpRepository extends Mock implements XpRepository {}

class _MockStreakRepository extends Mock implements StreakRepository {}

/// How long the page waits before moving past a revealed answer -- the
/// same 1800ms the map has always used, plus room for the frame.
const _revealWait = Duration(milliseconds: 2000);

Streak _streak(int days) => Streak(
  currentStreak: days,
  longestStreak: days,
  streakBreakVersion: 0,
  seenStreakBreakVersion: 0,
);

/// The finished map goes through the Aurudo Reaction System: the same
/// resolver and the same Stage the quiz deck uses. These tests drive the
/// real page and the real cubit, and assert on what the reaction produced
/// -- never on a threshold reimplemented here.
void main() {
  late MapQuizRepository mapRepository;
  late ProgressRepository progressRepository;
  late DailyGoalRepository dailyGoalRepository;
  late XpRepository xpRepository;
  late StreakRepository streakRepository;
  late XpCubit xpCubit;
  late StreakCubit streakCubit;

  const regionA = MapRegion(
    id: 'sp',
    name: 'São Paulo',
    parts: [
      [LatLng(-23.5, -46.6)],
    ],
  );
  const regionB = MapRegion(
    id: 'rj',
    name: 'Rio de Janeiro',
    parts: [
      [LatLng(-22.9, -43.2)],
    ],
  );

  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    mapRepository = _MockMapQuizRepository();
    progressRepository = _MockProgressRepository();
    dailyGoalRepository = _MockDailyGoalRepository();
    xpRepository = _MockXpRepository();
    streakRepository = _MockStreakRepository();
    final authRepository = _MockAuthRepository();

    when(
      () => mapRepository.loadRegions(any()),
    ).thenAnswer((_) async => const Success([regionA, regionB]));
    when(
      () => mapRepository.loadViewportSpec(any()),
    ).thenAnswer((_) async => MapViewportSpec.fallback);
    when(
      () => progressRepository.registerRegionFound(
        catalogNodeId: any(named: 'catalogNodeId'),
        regionId: any(named: 'regionId'),
      ),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => dailyGoalRepository.getTodayAnsweredCount(),
    ).thenAnswer((_) async => const Success(0));
    when(
      () => authRepository.currentUser,
    ).thenReturn(const AppUser(id: 'user-1', email: 'a@b.com'));
    when(
      () => xpRepository.awardQuizXp(
        attemptId: any(named: 'attemptId'),
        correctCount: any(named: 'correctCount'),
      ),
    ).thenAnswer((_) async => const Success(UserXp(totalXp: 10)));
    when(
      () => streakRepository.registerActivityCompletion(),
    ).thenAnswer((_) async => Success(_streak(1)));

    sl.registerLazySingleton<MapQuizRepository>(() => mapRepository);
    sl.registerLazySingleton<ProgressRepository>(() => progressRepository);
    sl.registerLazySingleton<DailyGoalRepository>(() => dailyGoalRepository);
    sl.registerLazySingleton<AuthRepository>(() => authRepository);
    sl.registerSingleton<SharedPreferences>(prefs);

    xpCubit = XpCubit(xpRepository);
    streakCubit = StreakCubit(streakRepository);
  });

  Future<void> pumpMap(WidgetTester tester, {Size? size}) async {
    if (size != null) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    await tester.pumpApp(
      const MapQuizPage(
        mapId: 'brazil_states',
        catalogNodeId: 'node-1',
        interactionType: MapInteractionType.polygon,
        title: 'Estados do Brasil',
        attemptIdGenerator: _fixedAttemptId,
        boardBuilder: _buildBoardHere,
      ),
      providers: [
        BlocProvider<XpCubit>.value(value: xpCubit),
        BlocProvider<StreakCubit>.value(value: streakCubit),
      ],
    );
    await tester.pumpAndSettle();
  }

  MapQuizCubit cubitOf(WidgetTester tester) =>
      tester.element(find.byType(MapQuizBoard)).read<MapQuizCubit>();

  /// Whichever region the cubit queued next -- the order is shuffled, so
  /// the test asks instead of assuming.
  String targetOf(MapQuizCubit cubit) =>
      (cubit.state as MapQuizPlaying).currentTargetId;

  /// Lets the page's own delayed callbacks elapse -- the 700ms that clears
  /// a tap's feedback, and the short beat before the reaction scene --
  /// so no timer is left pending when the tree comes down.
  Future<void> settleCompletion(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  /// Answers every region correctly, in whatever order the cubit queued
  /// them, and settles on the result.
  Future<void> finishPerfect(WidgetTester tester) async {
    for (var i = 0; i < 2; i++) {
      final cubit = cubitOf(tester);
      cubit.onRegionTapped(targetOf(cubit));
      await tester.pump();
    }
    await settleCompletion(tester);
  }

  /// Misses every region until each one is revealed, which is how a map
  /// ends at zero without ever showing a "you failed" screen.
  Future<void> finishWithNothingRight(WidgetTester tester) async {
    for (var i = 0; i < 2; i++) {
      final cubit = cubitOf(tester);
      final wrong = targetOf(cubit) == 'sp' ? 'rj' : 'sp';
      for (var miss = 0; miss < 3; miss++) {
        cubit.onRegionTapped(wrong);
        await tester.pump();
      }
      await tester.pump(_revealWait);
    }
    await settleCompletion(tester);
  }

  Finder poseFinder(AurudoPose pose) =>
      find.byWidgetPredicate((w) => w is AurudoIllustration && w.pose == pose);

  group('$MapQuizPage completion', () {
    testWidgets('a perfect map plays perfectFarmAura', (tester) async {
      await pumpMap(tester);
      await finishPerfect(tester);

      expect(find.byType(AurudoFarmAuraAnimation), findsOneWidget);
      expect(find.text('Perfeito!'), findsOneWidget);
      expect(find.text('Você acertou 2 de 2.'), findsOneWidget);
    });

    testWidgets('a map that was not perfect never claims perfectFarmAura', (
      tester,
    ) async {
      await pumpMap(tester);
      // One found, one revealed after three misses.
      final first = cubitOf(tester);
      first.onRegionTapped(targetOf(first));
      await tester.pump();
      final second = cubitOf(tester);
      final wrong = targetOf(second) == 'sp' ? 'rj' : 'sp';
      for (var miss = 0; miss < 3; miss++) {
        second.onRegionTapped(wrong);
        await tester.pump();
      }
      await tester.pump(_revealWait);
      await settleCompletion(tester);

      expect(find.byType(AurudoFarmAuraAnimation), findsNothing);
      expect(find.text('Você acertou 1 de 2.'), findsOneWidget);
    });

    testWidgets('a map with nothing right encourages, and never sulks', (
      tester,
    ) async {
      await pumpMap(tester);
      await finishWithNothingRight(tester);

      // encourage settles on studying -- frustrated is never used as a
      // reaction to a result.
      expect(poseFinder(AurudoPose.studying), findsOneWidget);
      expect(poseFinder(AurudoPose.frustrated), findsNothing);
      expect(find.text('Vamos continuar?'), findsOneWidget);
    });
  });

  group('$MapQuizPage last answer', () {
    testWidgets('the region just found stays on screen before the result', (
      tester,
    ) async {
      await pumpMap(tester);
      for (var i = 0; i < 2; i++) {
        final cubit = cubitOf(tester);
        cubit.onRegionTapped(targetOf(cubit));
        await tester.pump();
      }

      // Mid-feedback: the board is still up, showing the answer, and the
      // result has not taken over.
      await tester.pump(MapQuizCubit.feedbackDuration ~/ 2);
      expect(find.byType(MapQuizBoard), findsOneWidget);
      expect(find.text('Perfeito!'), findsNothing);

      await settleCompletion(tester);
      expect(find.byType(MapQuizBoard), findsNothing);
    });

    testWidgets('after that feedback the perfect reaction plays', (
      tester,
    ) async {
      await pumpMap(tester);
      await finishPerfect(tester);

      expect(find.byType(AurudoFarmAuraAnimation), findsOneWidget);
      expect(find.text('Perfeito!'), findsOneWidget);
      expect(find.text('Você acertou 2 de 2.'), findsOneWidget);
    });

    testWidgets('a revealed last answer keeps its own longer moment', (
      tester,
    ) async {
      await pumpMap(tester);
      final first = cubitOf(tester);
      first.onRegionTapped(targetOf(first));
      await tester.pump();

      final second = cubitOf(tester);
      final wrong = targetOf(second) == 'sp' ? 'rj' : 'sp';
      for (var miss = 0; miss < 3; miss++) {
        second.onRegionTapped(wrong);
        await tester.pump();
      }

      // Still revealed well past the shorter feedback wait: a reveal is
      // not shortened to match a correct answer.
      await tester.pump(MapQuizCubit.feedbackDuration);
      expect(find.byType(MapQuizBoard), findsOneWidget);

      await tester.pump(_revealWait);
      await settleCompletion(tester);
      expect(find.byType(MapQuizBoard), findsNothing);
    });

    testWidgets('leaving during that feedback leaves nothing pending', (
      tester,
    ) async {
      await pumpMap(tester);
      for (var i = 0; i < 2; i++) {
        final cubit = cubitOf(tester);
        cubit.onRegionTapped(targetOf(cubit));
        await tester.pump();
      }

      // Out of the page before the feedback is over.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    });
  });

  group('$MapQuizPage achievements', () {
    testWidgets('a level up rides along as a badge, perfect stays the scene', (
      tester,
    ) async {
      when(
        () => xpRepository.awardQuizXp(
          attemptId: any(named: 'attemptId'),
          correctCount: any(named: 'correctCount'),
        ),
      ).thenAnswer((_) async => const Success(UserXp(totalXp: 720)));
      xpCubit.emit(const XpLoaded(UserXp(totalXp: 690)));

      await pumpMap(tester);
      await finishPerfect(tester);

      expect(find.byType(AurudoFarmAuraAnimation), findsOneWidget);
      expect(find.text('Perfeito!'), findsOneWidget);
      expect(find.text('Nível 8'), findsOneWidget);
    });

    testWidgets('the daily goal completing rides along as a badge', (
      tester,
    ) async {
      // Under the goal before the map, over it after.
      var reads = 0;
      when(() => dailyGoalRepository.getTodayAnsweredCount()).thenAnswer((
        _,
      ) async {
        reads++;
        return Success(reads == 1 ? 0 : 10);
      });

      await pumpMap(tester);
      await finishPerfect(tester);

      expect(find.text('Meta batida'), findsOneWidget);
      expect(find.text('Perfeito!'), findsOneWidget);
    });

    testWidgets('a streak milestone rides along as a badge', (tester) async {
      when(
        () => streakRepository.registerActivityCompletion(),
      ).thenAnswer((_) async => Success(_streak(7)));
      streakCubit.emit(StreakLoaded(_streak(6)));

      await pumpMap(tester);
      await finishPerfect(tester);

      expect(find.text('7 dias seguidos'), findsOneWidget);
    });

    testWidgets('everything at once is still one scene', (tester) async {
      when(
        () => xpRepository.awardQuizXp(
          attemptId: any(named: 'attemptId'),
          correctCount: any(named: 'correctCount'),
        ),
      ).thenAnswer((_) async => const Success(UserXp(totalXp: 720)));
      xpCubit.emit(const XpLoaded(UserXp(totalXp: 690)));
      when(
        () => streakRepository.registerActivityCompletion(),
      ).thenAnswer((_) async => Success(_streak(7)));
      streakCubit.emit(StreakLoaded(_streak(6)));
      var reads = 0;
      when(() => dailyGoalRepository.getTodayAnsweredCount()).thenAnswer((
        _,
      ) async {
        reads++;
        return Success(reads == 1 ? 0 : 10);
      });

      await pumpMap(tester);
      await finishPerfect(tester);

      expect(find.byType(AurudoFarmAuraAnimation), findsOneWidget);
      expect(find.byType(AurudoAchievementBadge), findsNWidgets(3));
      expect(find.text('Perfeito!'), findsOneWidget);
    });
  });

  group('$MapQuizPage replay', () {
    testWidgets('rebuilding the finished map does not celebrate again', (
      tester,
    ) async {
      await pumpMap(tester);
      await finishPerfect(tester);

      // A rebuild of the same attempt (theme change, tab switch) must not
      // award anything a second time.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      verify(
        () => xpRepository.awardQuizXp(
          attemptId: any(named: 'attemptId'),
          correctCount: any(named: 'correctCount'),
        ),
      ).called(1);
      verify(() => streakRepository.registerActivityCompletion()).called(1);
    });

    testWidgets('retrying the map is a new attempt that can react again', (
      tester,
    ) async {
      await pumpMap(tester);
      await finishPerfect(tester);

      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      // Back on the board, playing a fresh attempt.
      expect(find.byType(MapQuizBoard), findsOneWidget);
      await finishPerfect(tester);
      expect(find.byType(AurudoFarmAuraAnimation), findsOneWidget);
    });
  });

  group('$MapQuizPage the map itself', () {
    testWidgets('the board is gone once the reaction is on screen', (
      tester,
    ) async {
      await pumpMap(tester);
      await finishPerfect(tester);

      // No camera, zoom or repaint running behind the celebration.
      expect(find.byType(MapQuizBoard), findsNothing);
    });

    testWidgets('a revealed answer is still shown before the map ends', (
      tester,
    ) async {
      await pumpMap(tester);
      final first = cubitOf(tester);
      first.onRegionTapped(targetOf(first));
      await tester.pump();

      final second = cubitOf(tester);
      final wrong = targetOf(second) == 'sp' ? 'rj' : 'sp';
      for (var miss = 0; miss < 3; miss++) {
        second.onRegionTapped(wrong);
        await tester.pump();
      }

      // The last answer is revealed on the board, and the result only
      // arrives after that reveal has had its time.
      expect(find.byType(MapQuizBoard), findsOneWidget);
      await tester.pump(_revealWait);
      await settleCompletion(tester);
      expect(find.byType(MapQuizBoard), findsNothing);
    });

    testWidgets('finishing grants exactly what it always granted', (
      tester,
    ) async {
      await pumpMap(tester);
      await finishPerfect(tester);

      // Flat award per finished map, not per region, and one streak
      // registration -- unchanged by this phase.
      verify(
        () => xpRepository.awardQuizXp(
          attemptId: 'attempt-fixed',
          correctCount: 1,
        ),
      ).called(1);
      verify(() => streakRepository.registerActivityCompletion()).called(1);
      verify(
        () => progressRepository.registerRegionFound(
          catalogNodeId: 'node-1',
          regionId: any(named: 'regionId'),
        ),
      ).called(2);
    });
  });

  group('$MapQuizPage presentation', () {
    testWidgets('reduced motion lands on the final pose with no animation', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SizedBox.shrink(),
        ),
      );
      await pumpMap(tester);
      await finishPerfect(tester);

      expect(find.byType(AurudoFarmAuraAnimation), findsOneWidget);
      expect(find.text('Perfeito!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the result fits a 360px screen', (tester) async {
      await pumpMap(tester, size: const Size(360, 640));
      await finishPerfect(tester);

      expect(find.text('Perfeito!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the result fits a tablet', (tester) async {
      await pumpMap(tester, size: const Size(834, 1112));
      await finishPerfect(tester);

      expect(find.text('Perfeito!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

String _fixedAttemptId() => 'attempt-fixed';

/// Builds the board on the test's own thread: the app sends this through
/// compute(), which a widget test cannot pump.
Future<MapBoard> _buildBoardHere(MapBoardInput input) async =>
    buildMapBoard(input);
