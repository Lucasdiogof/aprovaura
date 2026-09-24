import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/home/domain/repositories/daily_goal_repository.dart';
import 'package:aura/features/home/presentation/cubit/home_summary_cubit.dart';
import 'package:aura/features/mock_exam/domain/entities/active_mock_exam.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_item.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_session_page.dart';
import 'package:aura/features/practice/presentation/widgets/practice_options_list.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

import '../../../../helpers/pump_app.dart';

class _MockDailyGoalRepository extends Mock implements DailyGoalRepository {}

class _MockErrorReviewRepository extends Mock
    implements ErrorReviewRepository {}

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

class _MockMockExamRepository extends Mock implements MockExamRepository {}

void main() {
  late MockExamRepository mockExamRepository;
  late HomeSummaryCubit summaryCubit;

  setUp(() async {
    await sl.reset();
    mockExamRepository = _MockMockExamRepository();
    sl.registerLazySingleton<MockExamRepository>(() => mockExamRepository);

    final dailyGoal = _MockDailyGoalRepository();
    final errorReview = _MockErrorReviewRepository();
    final favorites = _MockFavoritesRepository();
    when(
      () => dailyGoal.getTodayAnsweredCount(),
    ).thenAnswer((_) async => const Success(0));
    when(
      () => errorReview.listPendingTopics(),
    ).thenAnswer((_) async => const Success([]));
    when(
      () => favorites.listFavoriteTopics(),
    ).thenAnswer((_) async => const Success([]));
    when(() => mockExamRepository.getActiveMockExam()).thenAnswer(
      (_) async => const Success(
        ActiveMockExam(
          id: 'e1',
          questionCount: 90,
          answeredCount: 37,
          currentItemPosition: 38,
        ),
      ),
    );
    when(() => mockExamRepository.getItems('e1')).thenAnswer(
      (_) async => const Success([
        MockExamItem(
          position: 38,
          questionId: 'q38',
          subject: 'historia',
          difficulty: QuestionDifficulty.medio,
          prompt: 'Quando começou a Era Vargas?',
          options: ['1930', '1945'],
        ),
      ]),
    );
    summaryCubit = HomeSummaryCubit(
      dailyGoal,
      errorReview,
      favorites,
      mockExamRepository,
    );
    await summaryCubit.load();
  });

  testWidgets('"Continuar simulado" opens the real exam, not a placeholder', (
    tester,
  ) async {
    await tester.pumpApp(
      const Scaffold(body: SingleChildScrollView(child: PracticeOptionsList())),
      providers: [BlocProvider<HomeSummaryCubit>.value(value: summaryCubit)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Continuar simulado'), findsOneWidget);
    expect(find.text('37 de 90 questões respondidas'), findsOneWidget);
    expect(find.text('Montar outro'), findsOneWidget);

    await tester.tap(find.text('Continuar simulado'));
    await tester.pumpAndSettle();

    expect(find.byType(MockExamSessionPage), findsOneWidget);
    expect(find.text('Quando começou a Era Vargas?'), findsOneWidget);
    expect(find.text('Simulado salvo'), findsNothing);
  });
}
