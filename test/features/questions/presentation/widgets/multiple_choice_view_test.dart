import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/home/domain/repositories/daily_goal_repository.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/questions/domain/repositories/question_report_repository.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';
import 'package:aura/features/questions/presentation/widgets/multiple_choice_view.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/streak/domain/repositories/streak_repository.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';
import 'package:aura/features/xp/domain/repositories/xp_repository.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/features/xp/presentation/cubit/xp_state.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

import '../../../../helpers/pump_app.dart';

class _MockQuestionRepository extends Mock implements QuestionRepository {}

class _MockProgressRepository extends Mock implements ProgressRepository {}

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

class _MockQuestionReportRepository extends Mock
    implements QuestionReportRepository {}

class _MockDailyGoalRepository extends Mock implements DailyGoalRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockXpRepository extends Mock implements XpRepository {}

class _MockStreakRepository extends Mock implements StreakRepository {}

void main() {
  group(MultipleChoiceView, () {
    late QuestionRepository questionRepository;
    late ProgressRepository progressRepository;
    late FavoritesRepository favoritesRepository;
    late DailyGoalRepository dailyGoalRepository;
    late AuthRepository authRepository;
    late XpRepository xpRepository;
    late StreakRepository streakRepository;
    late XpCubit xpCubit;
    late StreakCubit streakCubit;
    late SharedPreferences prefs;

    const questionA = Question(
      id: 'q1',
      prompt: 'Capital da França?',
      options: ['Paris', 'Londres', 'Roma', 'Berlim'],
      correctIndex: 0,
    );
    const questionB = Question(
      id: 'q2',
      prompt: 'Capital do Japão?',
      options: ['Pequim', 'Tóquio', 'Seul', 'Bangkok'],
      correctIndex: 1,
    );
    const questions = [questionA, questionB];

    setUp(() async {
      await sl.reset();
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      questionRepository = _MockQuestionRepository();
      progressRepository = _MockProgressRepository();
      favoritesRepository = _MockFavoritesRepository();
      dailyGoalRepository = _MockDailyGoalRepository();
      authRepository = _MockAuthRepository();
      xpRepository = _MockXpRepository();
      streakRepository = _MockStreakRepository();

      when(
        () => questionRepository.getQuestions(
          any(),
          difficulty: any(named: 'difficulty'),
        ),
      ).thenAnswer((_) async => const Success(questions));
      when(
        () => progressRepository.registerQuestionAnswered(
          questionId: any(named: 'questionId'),
          isCorrect: any(named: 'isCorrect'),
        ),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => favoritesRepository.getFavoriteQuestionIds(any()),
      ).thenAnswer((_) async => const Success(<String>{}));
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
      when(() => streakRepository.registerActivityCompletion()).thenAnswer(
        (_) async => const Success(
          Streak(
            currentStreak: 1,
            longestStreak: 1,
            streakBreakVersion: 0,
            seenStreakBreakVersion: 0,
          ),
        ),
      );

      sl.registerLazySingleton<ProgressRepository>(() => progressRepository);
      sl.registerLazySingleton<FavoritesRepository>(() => favoritesRepository);
      sl.registerLazySingleton<QuestionReportRepository>(
        () => _MockQuestionReportRepository(),
      );
      sl.registerLazySingleton<DailyGoalRepository>(() => dailyGoalRepository);
      sl.registerLazySingleton<AuthRepository>(() => authRepository);
      sl.registerSingleton<SharedPreferences>(prefs);

      xpCubit = XpCubit(xpRepository);
      streakCubit = StreakCubit(streakRepository);
    });

    Future<void> pumpQuiz(
      WidgetTester tester, {
      bool awardsRewards = true,
      bool isCorrectionMode = false,
      bool trackProgress = true,
    }) => tester.pumpApp(
      MultipleChoiceView(
        catalogNodeId: 'node-1',
        onEmpty: (_) => const Text('vazio'),
        repository: questionRepository,
        awardsRewards: awardsRewards,
        isCorrectionMode: isCorrectionMode,
        trackProgress: trackProgress,
      ),
      providers: [
        BlocProvider<XpCubit>.value(value: xpCubit),
        BlocProvider<StreakCubit>.value(value: streakCubit),
      ],
    );

    // Answers every question, correctly or not per [correct], and lands on
    // the finished screen. Options are found by their own text rather than
    // index, since the cubit reshuffles them on every load().
    Future<void> answerAll(
      WidgetTester tester, {
      required List<bool> correct,
    }) async {
      for (var i = 0; i < correct.length; i++) {
        await tester.pump();
        final question = i == 0 ? questionA : questionB;
        final answered = correct[i]
            ? question.options[question.correctIndex]
            : question.options[(question.correctIndex + 1) %
                  question.options.length];
        await tester.tap(find.text(answered));
        await tester.pump();
        await tester.pump();
        final isLast = i == correct.length - 1;
        await tester.tap(find.text(isLast ? 'Ver resultado' : 'Próxima'));
        await tester.pump();
      }
      // Lets the reward-await chain (XP/streak/daily-goal) and the
      // reaction-resolve setState settle.
      await tester.pumpAndSettle();
    }

    testWidgets('10/10 (all correct) plays perfectFarmAura', (tester) async {
      await pumpQuiz(tester);
      await answerAll(tester, correct: [true, true]);

      expect(
        find.byWidgetPredicate(
          (w) => w is AurudoIllustration && w.pose == AurudoPose.farmingAura,
        ),
        findsOneWidget,
      );
      expect(find.text('Perfeito!'), findsOneWidget);
      verify(
        () => xpRepository.awardQuizXp(
          attemptId: any(named: 'attemptId'),
          correctCount: 2,
        ),
      ).called(1);
      verify(() => streakRepository.registerActivityCompletion()).called(1);
    });

    testWidgets('a non-perfect result never claims perfectFarmAura', (
      tester,
    ) async {
      await pumpQuiz(tester);
      await answerAll(tester, correct: [true, false]);

      expect(
        find.byWidgetPredicate(
          (w) => w is AurudoIllustration && w.pose == AurudoPose.farmingAura,
        ),
        findsNothing,
      );
    });

    testWidgets('a weak result never uses frustrated, and reaches studying', (
      tester,
    ) async {
      await pumpQuiz(tester);
      await answerAll(tester, correct: [false, false]);

      expect(
        find.byWidgetPredicate(
          (w) => w is AurudoIllustration && w.pose == AurudoPose.frustrated,
        ),
        findsNothing,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is AurudoIllustration && w.pose == AurudoPose.studying,
        ),
        findsOneWidget,
      );
    });

    testWidgets('perfect + level up shows the level-up badge alongside it', (
      tester,
    ) async {
      when(
        () => xpRepository.awardQuizXp(
          attemptId: any(named: 'attemptId'),
          correctCount: any(named: 'correctCount'),
        ),
      ).thenAnswer((_) async => const Success(UserXp(totalXp: 720)));
      // Before: level 7 (690 XP). After the award above: level 8 (720 XP).
      xpCubit.emit(const XpLoaded(UserXp(totalXp: 690)));

      await pumpQuiz(tester);
      await answerAll(tester, correct: [true, true]);

      expect(find.text('Perfeito!'), findsOneWidget);
      expect(find.text('Nível 8'), findsOneWidget);
    });

    testWidgets(
      'a correction-mode (error review) session never awards rewards or shows badges',
      (tester) async {
        await pumpQuiz(
          tester,
          awardsRewards: false,
          isCorrectionMode: true,
          trackProgress: true,
        );
        await answerAll(tester, correct: [true, true]);

        expect(find.text('Revisão concluída!'), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (w) => w is AurudoIllustration && w.pose == AurudoPose.farmingAura,
          ),
          findsOneWidget,
        );
        verifyNever(
          () => xpRepository.awardQuizXp(
            attemptId: any(named: 'attemptId'),
            correctCount: any(named: 'correctCount'),
          ),
        );
        verifyNever(() => streakRepository.registerActivityCompletion());
      },
    );

    testWidgets('reduced motion shows the final state almost immediately', (
      tester,
    ) async {
      await tester.pumpApp(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MultipleChoiceView(
            catalogNodeId: 'node-1',
            onEmpty: (_) => const Text('vazio'),
            repository: questionRepository,
          ),
        ),
        providers: [
          BlocProvider<XpCubit>.value(value: xpCubit),
          BlocProvider<StreakCubit>.value(value: streakCubit),
        ],
      );
      await answerAll(tester, correct: [true, true]);

      expect(find.text('Perfeito!'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
    });

    testWidgets(
      'marks the attempt as celebrated in the current user\'s reaction ledger',
      (tester) async {
        await pumpQuiz(tester);
        await answerAll(tester, correct: [true, true]);

        final raw = prefs.getString('aurudo_reaction_ledger_v1_user-1');
        expect(raw, isNotNull);
        final data = jsonDecode(raw!) as Map<String, dynamic>;
        expect((data['recentAttempts'] as List), isNotEmpty);
      },
    );

    testWidgets('retrying starts a new attempt and reaches finished again', (
      tester,
    ) async {
      await pumpQuiz(tester);
      await answerAll(tester, correct: [false, false]);

      await tester.ensureVisible(find.text('Tentar novamente'));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      await answerAll(tester, correct: [true, true]);

      expect(find.text('Perfeito!'), findsOneWidget);
    });
  });
}
