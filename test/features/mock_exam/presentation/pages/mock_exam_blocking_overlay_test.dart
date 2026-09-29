import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/loading/app_blocking_loading_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_stage.dart';
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
import 'package:aura/features/xp/domain/entities/user_xp.dart';
import 'package:aura/features/xp/domain/repositories/xp_repository.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/shared/widgets/app_aura_loader.dart';
import 'package:aura/shared/widgets/app_loading_overlay.dart';

class _MockMockExamRepository extends Mock implements MockExamRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockXpRepository extends Mock implements XpRepository {}

class _MockStreakRepository extends Mock implements StreakRepository {}

const _examId = 'e1';

MockExamResult _result() => const MockExamResult(
  mockExamId: _examId,
  questionCount: 1,
  correctCount: 1,
  wrongCount: 0,
  blankCount: 0,
  accuracyPercent: 100,
  xpAwarded: 10,
  subjectCount: 1,
  bySubject: [],
  byDifficulty: [],
);

/// Handing in and abandoning a mock exam go through the app's one blocking
/// overlay: the screen stays visible behind it, nothing responds, and it
/// always comes down -- before the result, never alongside Aurudo.
void main() {
  late MockExamRepository repository;
  late XpCubit xpCubit;
  late StreakCubit streakCubit;
  late AppBlockingLoadingCubit loading;

  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repository = _MockMockExamRepository();
    final auth = _MockAuthRepository();
    final xpRepository = _MockXpRepository();
    final streakRepository = _MockStreakRepository();

    when(
      () => auth.currentUser,
    ).thenReturn(const AppUser(id: 'user-1', email: 'a@b.com'));
    when(
      () => xpRepository.getCurrent(),
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
    when(() => repository.getSession(_examId)).thenAnswer(
      (_) async =>
          const Success(MockExamSessionInfo(status: MockExamStatus.inProgress)),
    );
    // One question, already answered: the footer offers "Entregar".
    when(() => repository.getItems(_examId)).thenAnswer(
      (_) async => const Success([
        MockExamItem(
          position: 1,
          questionId: 'q1',
          subject: 'geografia',
          difficulty: QuestionDifficulty.dificil,
          prompt: 'Qual é a capital?',
          options: ['Opção um', 'Opção dois'],
          selectedIndex: 0,
        ),
      ]),
    );
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
    when(
      () => repository.getResult(_examId),
    ).thenAnswer((_) async => Success(_result()));

    sl.registerLazySingleton<MockExamRepository>(() => repository);
    sl.registerLazySingleton<AuthRepository>(() => auth);
    sl.registerSingleton<SharedPreferences>(prefs);

    xpCubit = XpCubit(xpRepository);
    streakCubit = StreakCubit(streakRepository);
    loading = AppBlockingLoadingCubit();
  });

  tearDown(() async {
    await xpCubit.close();
    await streakCubit.close();
    await loading.close();
  });

  /// The session opened from a launcher screen (so abandoning has
  /// somewhere to pop back to), under the real app-level overlay.
  Future<void> pumpSession(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<LocaleCubit>(
            create: (_) => LocaleCubit()..emit(AppLanguage.portuguese),
          ),
          BlocProvider<AppBlockingLoadingCubit>.value(value: loading),
          BlocProvider<XpCubit>.value(value: xpCubit),
          BlocProvider<StreakCubit>.value(value: streakCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) =>
              Stack(children: [child!, const AppLoadingOverlay()]),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const MockExamSessionPage(mockExamId: _examId),
                    ),
                  ),
                  child: const Text('abrir simulado'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir simulado'));
    await tester.pumpAndSettle();
  }

  /// "Entregar" on the last question, then the confirmation.
  Future<void> handIn(WidgetTester tester) async {
    await tester.tap(find.text('Entregar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entregar simulado').last);
    await tester.pump();
  }

  Future<void> confirmAbandon(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abandonar simulado'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abandonar simulado').last);
    await tester.pump();
  }

  group('handing in', () {
    testWidgets('the overlay comes up at once, with its line; nothing behind '
        'it responds, a second tap does nothing, back does nothing', (
      tester,
    ) async {
      final finishing = Completer<Result<void>>();
      when(
        () => repository.finishMockExam(_examId),
      ).thenAnswer((_) => finishing.future);
      await pumpSession(tester);
      await handIn(tester);

      // Immediately, before the server answers.
      expect(loading.state.isVisible, isTrue);
      expect(find.byType(AppAuraLoader), findsOneWidget);
      expect(find.text('Finalizando simulado...'), findsOneWidget);

      // The question behind cannot be answered...
      await tester.tap(find.text('Opção dois'), warnIfMissed: false);
      await tester.pump();
      verifyNever(
        () => repository.answerItem(
          any(),
          position: any(named: 'position'),
          selectedIndex: 1,
        ),
      );
      // ...nor handed in a second time...
      await tester.tap(find.text('Entregar'), warnIfMissed: false);
      await tester.pump();
      // ...and back does not leave.
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byType(MockExamSessionPage), findsOneWidget);

      finishing.complete(const Success(null));
      await tester.pump();
      await tester.pump();
      verify(() => repository.finishMockExam(_examId)).called(1);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('success: the overlay leaves, then the result (and Aurudo) '
        'opens -- never both at once', (tester) async {
      when(
        () => repository.finishMockExam(_examId),
      ).thenAnswer((_) async => const Success(null));
      await pumpSession(tester);
      await handIn(tester);
      await tester.pump();
      await tester.pump();

      expect(loading.state.isVisible, isFalse);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(MockExamResultPage), findsOneWidget);
      expect(find.text('Finalizando simulado...'), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('failure: the overlay always comes down, no result, and '
        'handing in again works', (tester) async {
      when(() => repository.finishMockExam(_examId)).thenAnswer(
        (_) async => Error(MockExamFailure(MockExamFailureKind.network)),
      );
      await pumpSession(tester);
      await handIn(tester);
      await tester.pumpAndSettle();

      expect(loading.state.isVisible, isFalse);
      expect(find.byType(MockExamResultPage), findsNothing);
      expect(find.byType(AurudoReactionStage), findsNothing);

      // The error sheet, dismissed; then a second, working try.
      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();
      when(
        () => repository.finishMockExam(_examId),
      ).thenAnswer((_) async => const Success(null));
      await handIn(tester);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      verify(() => repository.finishMockExam(_examId)).called(2);
      expect(find.byType(MockExamResultPage), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('abandoning', () {
    testWidgets('confirmed: the overlay with its line, one call, then back '
        'where the exam was opened -- and never a reaction', (tester) async {
      final abandoning = Completer<Result<void>>();
      when(
        () => repository.abandonMockExam(_examId),
      ).thenAnswer((_) => abandoning.future);
      await pumpSession(tester);
      await confirmAbandon(tester);

      expect(loading.state.isVisible, isTrue);
      expect(find.text('Abandonando simulado...'), findsOneWidget);
      // No indeterminate 2px bar anymore: the overlay is the feedback.
      // (The question-progress bar, a real value, stays.)
      expect(
        find.byWidgetPredicate(
          (w) => w is LinearProgressIndicator && w.value == null,
        ),
        findsNothing,
      );

      abandoning.complete(const Success(null));
      await tester.pumpAndSettle();

      verify(() => repository.abandonMockExam(_examId)).called(1);
      expect(loading.state.isVisible, isFalse);
      expect(find.byType(MockExamSessionPage), findsNothing);
      expect(find.text('abrir simulado'), findsOneWidget);
      expect(find.byType(AurudoReactionStage), findsNothing);
      expect(find.byType(MockExamResultPage), findsNothing);
    });

    testWidgets('failure: the overlay comes down and the exam stays open', (
      tester,
    ) async {
      when(() => repository.abandonMockExam(_examId)).thenAnswer(
        (_) async => Error(MockExamFailure(MockExamFailureKind.network)),
      );
      await pumpSession(tester);
      await confirmAbandon(tester);
      await tester.pumpAndSettle();

      expect(loading.state.isVisible, isFalse);
      expect(find.byType(MockExamSessionPage), findsOneWidget);
      expect(find.byType(AurudoReactionStage), findsNothing);
    });
  });
}
