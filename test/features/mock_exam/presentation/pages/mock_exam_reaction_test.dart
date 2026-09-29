import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_achievement_badge.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_activity_completion.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_item.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_result.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_session_info.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_result_page.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_session_page.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/streak/domain/repositories/streak_repository.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/streak/presentation/cubit/streak_state.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';
import 'package:aura/features/xp/domain/repositories/xp_repository.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/features/xp/presentation/cubit/xp_state.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

import '../../../../helpers/pump_app.dart';

class _MockMockExamRepository extends Mock implements MockExamRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockXpRepository extends Mock implements XpRepository {}

class _MockStreakRepository extends Mock implements StreakRepository {}

const _examId = 'e1';

Streak _streak(int days) => Streak(
  currentStreak: days,
  longestStreak: days,
  streakBreakVersion: 0,
  seenStreakBreakVersion: 0,
);

MockExamResult _result({
  required int correct,
  int total = 10,
  int blank = 0,
  String id = _examId,
}) => MockExamResult(
  mockExamId: id,
  questionCount: total,
  correctCount: correct,
  wrongCount: total - correct - blank,
  blankCount: blank,
  accuracyPercent: total == 0 ? 0 : correct * 100 / total,
  xpAwarded: correct * 10,
  subjectCount: 1,
  bySubject: [
    MockExamResultLine(
      key: 'fisica',
      questionCount: total,
      correctCount: correct,
      wrongCount: total - correct - blank,
      blankCount: blank,
      accuracyPercent: total == 0 ? 0 : correct * 100 / total,
    ),
  ],
  byDifficulty: [
    MockExamResultLine(
      key: 'medio',
      questionCount: total,
      correctCount: correct,
      wrongCount: total - correct - blank,
      blankCount: blank,
      accuracyPercent: total == 0 ? 0 : correct * 100 / total,
    ),
  ],
);

MockExamItem _item(int position) => MockExamItem(
  position: position,
  questionId: 'q$position',
  subject: 'geografia',
  difficulty: QuestionDifficulty.dificil,
  prompt: 'Pergunta $position?',
  options: const ['Opção um', 'Opção dois'],
);

/// The Aurudo Reaction System on the mock exam: it opens the result and
/// then gets out of the report's way. Nothing here grants anything --
/// finish_mock_exam() already did, server-side -- so these tests are
/// about what the screen reads and shows.
void main() {
  late MockExamRepository repository;
  late AuthRepository authRepository;
  late XpRepository xpRepository;
  late StreakRepository streakRepository;
  late XpCubit xpCubit;
  late StreakCubit streakCubit;

  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    repository = _MockMockExamRepository();
    authRepository = _MockAuthRepository();
    xpRepository = _MockXpRepository();
    streakRepository = _MockStreakRepository();

    when(
      () => authRepository.currentUser,
    ).thenReturn(const AppUser(id: 'user-1', email: 'a@b.com'));
    when(
      () => xpRepository.getCurrent(),
    ).thenAnswer((_) async => const Success(UserXp(totalXp: 10)));
    when(
      () => streakRepository.registerActivityCompletion(),
    ).thenAnswer((_) async => Success(_streak(1)));

    sl.registerLazySingleton<MockExamRepository>(() => repository);
    sl.registerLazySingleton<AuthRepository>(() => authRepository);
    sl.registerSingleton<SharedPreferences>(prefs);

    xpCubit = XpCubit(xpRepository);
    streakCubit = StreakCubit(streakRepository);
  });

  void stubResult(MockExamResult result) {
    when(
      () => repository.getResult(result.mockExamId),
    ).thenAnswer((_) async => Success(result));
  }

  void useTallScreen(WidgetTester tester, {Size? size}) {
    tester.view.physicalSize = size ?? const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  /// Opens the result the way the session screen does: with the numbers
  /// as they stood before handing in.
  Future<void> pumpResult(
    WidgetTester tester, {
    AurudoRewardsSnapshot? before = const AurudoRewardsSnapshot(),
    String id = _examId,
  }) async {
    await tester.pumpApp(
      MockExamResultPage(mockExamId: id, before: before),
      providers: [
        BlocProvider<XpCubit>.value(value: xpCubit),
        BlocProvider<StreakCubit>.value(value: streakCubit),
      ],
    );
    await tester.pumpAndSettle();
  }

  Finder poseFinder(AurudoPose pose) =>
      find.byWidgetPredicate((w) => w is AurudoIllustration && w.pose == pose);

  group('the reaction that opens the result', () {
    testWidgets('a perfect exam farms Aura', (tester) async {
      useTallScreen(tester);
      stubResult(_result(correct: 10));
      await pumpResult(tester);

      expect(poseFinder(AurudoPose.farmingAura), findsOneWidget);
      expect(find.text('Perfeito!'), findsOneWidget);
    });

    testWidgets('a good exam keeps the exam\'s own sober headline', (
      tester,
    ) async {
      useTallScreen(tester);
      stubResult(_result(correct: 8));
      await pumpResult(tester);

      expect(poseFinder(AurudoPose.farmingAura), findsNothing);
      expect(find.text('Bom desempenho'), findsOneWidget);
    });

    testWidgets('a low result points at the report instead of sulking', (
      tester,
    ) async {
      useTallScreen(tester);
      // The approved resolver keeps encourage for a genuine zero; a
      // middling score is "normal", not a pep talk.
      stubResult(_result(correct: 0));
      await pumpResult(tester);

      expect(poseFinder(AurudoPose.studying), findsOneWidget);
      expect(poseFinder(AurudoPose.frustrated), findsNothing);
      expect(find.text('Vale revisar alguns pontos'), findsOneWidget);
    });

    testWidgets('a level up earned by handing in rides along as a badge', (
      tester,
    ) async {
      useTallScreen(tester);
      stubResult(_result(correct: 10));
      xpCubit.emit(const XpLoaded(UserXp(totalXp: 720)));
      await pumpResult(
        tester,
        before: const AurudoRewardsSnapshot(xp: UserXp(totalXp: 690)),
      );

      // Perfect stays the scene; the level is a badge beside it.
      expect(poseFinder(AurudoPose.farmingAura), findsOneWidget);
      expect(find.text('Perfeito!'), findsOneWidget);
      expect(find.text('Nível 8'), findsOneWidget);
    });

    testWidgets('a level and a streak milestone are one scene, not two', (
      tester,
    ) async {
      useTallScreen(tester);
      stubResult(_result(correct: 10));
      xpCubit.emit(const XpLoaded(UserXp(totalXp: 720)));
      streakCubit.emit(StreakLoaded(_streak(7)));
      await pumpResult(
        tester,
        before: AurudoRewardsSnapshot(
          xp: const UserXp(totalXp: 690),
          streak: _streak(6),
        ),
      );

      expect(poseFinder(AurudoPose.farmingAura), findsOneWidget);
      expect(find.byType(AurudoAchievementBadge), findsNWidgets(2));
      expect(find.text('Nível 8'), findsOneWidget);
      expect(find.text('7 dias seguidos'), findsOneWidget);
    });

    testWidgets('the daily goal is never claimed by handing in', (
      tester,
    ) async {
      useTallScreen(tester);
      stubResult(_result(correct: 10));
      await pumpResult(tester);

      // An exam's answers count toward the goal while it is being taken,
      // so hand-in cannot know it was the moment the goal was reached.
      // Better no badge than one on the wrong moment.
      expect(find.text('Meta batida'), findsNothing);
    });
  });

  group('the report underneath', () {
    testWidgets('keeps every number the server sent', (tester) async {
      useTallScreen(tester);
      stubResult(_result(correct: 8, total: 10, blank: 1));
      await pumpResult(tester);

      // Said once in the headline of the score card, and again inside
      // each breakdown line -- the card's own is the rich one.
      expect(
        find.textContaining('8 / 10 corretas', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('80%'), findsWidgets);
      // Exactly what finish_mock_exam credited, not recomputed here.
      expect(find.text('+80'), findsOneWidget);
      expect(find.text('Por matéria'), findsOneWidget);
      expect(find.text('Por dificuldade'), findsOneWidget);
      expect(find.text('Física'), findsOneWidget);
      expect(find.text('Em branco'), findsOneWidget);
    });

    testWidgets('the review of wrong questions is still reachable', (
      tester,
    ) async {
      useTallScreen(tester);
      stubResult(_result(correct: 6));
      await pumpResult(tester);

      expect(find.text('Ver questões erradas'), findsOneWidget);
    });

    testWidgets('fits 360px with the reaction on top', (tester) async {
      useTallScreen(tester, size: const Size(360, 720));
      stubResult(_result(correct: 10));
      await pumpResult(tester);

      expect(find.text('Perfeito!'), findsOneWidget);
      expect(tester.takeException(), isNull);
      // The report is still reachable by scrolling, not cut off.
      await tester.scrollUntilVisible(find.text('Por dificuldade'), 200);
      expect(find.text('Por dificuldade'), findsOneWidget);
    });

    testWidgets('fits a tablet', (tester) async {
      useTallScreen(tester, size: const Size(834, 1112));
      stubResult(_result(correct: 10));
      await pumpResult(tester);

      expect(find.text('Perfeito!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('the ledger', () {
    testWidgets('reopening the same result does not replay the scene', (
      tester,
    ) async {
      useTallScreen(tester);
      stubResult(_result(correct: 10));
      await pumpResult(tester);
      expect(find.text('Perfeito!'), findsOneWidget);

      // Same exam, opened again: straight to the final state.
      await pumpResult(tester);
      expect(find.text('Perfeito!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a result reached without having just been handed in opens '
        'in its final state', (tester) async {
      useTallScreen(tester);
      stubResult(_result(correct: 10));
      // No snapshot: an exam closed on another device, or a future
      // history screen. Nothing to celebrate, nothing to diff.
      await pumpResult(tester, before: null);

      expect(find.text('Perfeito!'), findsOneWidget);
      expect(find.byType(AurudoAchievementBadge), findsNothing);
    });

    testWidgets('another exam gets its own reaction', (tester) async {
      useTallScreen(tester);
      stubResult(_result(correct: 10));
      await pumpResult(tester);

      stubResult(_result(correct: 10, id: 'e2'));
      await pumpResult(tester, id: 'e2');
      expect(find.text('Perfeito!'), findsOneWidget);
    });

    testWidgets('another user has a ledger of their own', (tester) async {
      useTallScreen(tester);
      stubResult(_result(correct: 10));
      await pumpResult(tester);

      when(
        () => authRepository.currentUser,
      ).thenReturn(const AppUser(id: 'user-2', email: 'b@c.com'));
      await pumpResult(tester);
      expect(find.text('Perfeito!'), findsOneWidget);
    });
  });

  group('handing in', () {
    setUp(() {
      when(() => repository.getSession(_examId)).thenAnswer(
        (_) async => const Success(
          MockExamSessionInfo(status: MockExamStatus.inProgress),
        ),
      );
      when(
        () => repository.getItems(_examId),
      ).thenAnswer((_) async => Success([_item(1)]));
      when(
        () => repository.answerItem(
          any(),
          position: any(named: 'position'),
          selectedIndex: any(named: 'selectedIndex'),
        ),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => repository.setCurrentPosition(any(), any()),
      ).thenAnswer((_) async => const Success(null));
      stubResult(_result(correct: 1, total: 1));
    });

    Future<void> answerAndSubmit(WidgetTester tester) async {
      await tester.tap(find.text('Opção um'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entregar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entregar simulado'));
      await tester.pumpAndSettle();
    }

    Future<void> pumpSession(WidgetTester tester) async {
      await tester.pumpApp(
        const MockExamSessionPage(mockExamId: _examId),
        providers: [
          BlocProvider<XpCubit>.value(value: xpCubit),
          BlocProvider<StreakCubit>.value(value: streakCubit),
        ],
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a failed hand-in never celebrates', (tester) async {
      useTallScreen(tester);
      when(() => repository.finishMockExam(_examId)).thenAnswer(
        (_) async => Error(MockExamFailure(MockExamFailureKind.network)),
      );

      await pumpSession(tester);
      await answerAndSubmit(tester);

      // Still on the exam, with an error -- no result, no Aurudo.
      expect(find.byType(MockExamResultPage), findsNothing);
      expect(find.text('Perfeito!'), findsNothing);
    });

    testWidgets('a successful hand-in opens the result with its reaction', (
      tester,
    ) async {
      useTallScreen(tester);
      when(
        () => repository.finishMockExam(_examId),
      ).thenAnswer((_) async => const Success(null));

      await pumpSession(tester);
      await answerAndSubmit(tester);

      expect(find.byType(MockExamResultPage), findsOneWidget);
      expect(find.text('Perfeito!'), findsOneWidget);
      // The streak is registered once, by the hand-in -- never twice.
      verify(() => streakRepository.registerActivityCompletion()).called(1);
      verify(() => repository.finishMockExam(_examId)).called(1);
    });
  });
}
