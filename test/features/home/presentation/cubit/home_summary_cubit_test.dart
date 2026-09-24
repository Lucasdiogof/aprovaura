import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/error_review/domain/entities/error_topic.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';
import 'package:aura/features/favorites/domain/entities/favorite_topic.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/home/domain/repositories/daily_goal_repository.dart';
import 'package:aura/features/home/presentation/cubit/home_summary_cubit.dart';
import 'package:aura/features/home/presentation/cubit/home_summary_state.dart';

class _MockDailyGoalRepository extends Mock implements DailyGoalRepository {}

class _MockErrorReviewRepository extends Mock
    implements ErrorReviewRepository {}

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  group(HomeSummaryCubit, () {
    late DailyGoalRepository dailyGoalRepository;
    late ErrorReviewRepository errorReviewRepository;
    late FavoritesRepository favoritesRepository;

    setUp(() {
      dailyGoalRepository = _MockDailyGoalRepository();
      errorReviewRepository = _MockErrorReviewRepository();
      favoritesRepository = _MockFavoritesRepository();
    });

    HomeSummaryCubit build() => HomeSummaryCubit(
      dailyGoalRepository,
      errorReviewRepository,
      favoritesRepository,
    );

    test('starts in $HomeSummaryLoading', () {
      when(
        () => dailyGoalRepository.getTodayAnsweredCount(),
      ).thenAnswer((_) async => const Success(0));
      when(
        () => errorReviewRepository.listPendingTopics(),
      ).thenAnswer((_) async => const Success([]));
      when(
        () => favoritesRepository.listFavoriteTopics(),
      ).thenAnswer((_) async => const Success([]));
      expect(build().state, const HomeSummaryLoading());
    });

    blocTest<HomeSummaryCubit, HomeSummaryState>(
      'sums pending/favorite counts across topics and reports the daily count',
      build: () {
        when(
          () => dailyGoalRepository.getTodayAnsweredCount(),
        ).thenAnswer((_) async => const Success(7));
        when(() => errorReviewRepository.listPendingTopics()).thenAnswer(
          (_) async => const Success([
            ErrorTopic(
              catalogNodeId: 'n1',
              subject: 'geografia',
              title: 'Relevo',
              wrongCount: 2,
            ),
            ErrorTopic(
              catalogNodeId: 'n2',
              subject: 'matematica',
              title: 'Álgebra',
              wrongCount: 4,
            ),
          ]),
        );
        when(() => favoritesRepository.listFavoriteTopics()).thenAnswer(
          (_) async => const Success([
            FavoriteTopic(
              catalogNodeId: 'n3',
              subject: 'historia',
              title: 'Era Vargas',
              favoriteCount: 3,
            ),
          ]),
        );
        return build();
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const HomeSummaryLoaded(
          dailyGoal: DailyGoal(answered: 7),
          pendingErrorsCount: 6,
          favoritesCount: 3,
        ),
      ],
    );

    blocTest<HomeSummaryCubit, HomeSummaryState>(
      'falls back to 0 answered and null counts when a call fails',
      build: () {
        when(
          () => dailyGoalRepository.getTodayAnsweredCount(),
        ).thenAnswer((_) async => Error(ServerFailure('boom')));
        when(
          () => errorReviewRepository.listPendingTopics(),
        ).thenAnswer((_) async => Error(ServerFailure('boom')));
        when(
          () => favoritesRepository.listFavoriteTopics(),
        ).thenAnswer((_) async => Error(ServerFailure('boom')));
        return build();
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        const HomeSummaryLoaded(
          dailyGoal: DailyGoal(answered: 0),
          pendingErrorsCount: null,
          favoritesCount: null,
        ),
      ],
    );

    blocTest<HomeSummaryCubit, HomeSummaryState>(
      'refresh reloads exactly like load',
      build: () {
        when(
          () => dailyGoalRepository.getTodayAnsweredCount(),
        ).thenAnswer((_) async => const Success(1));
        when(
          () => errorReviewRepository.listPendingTopics(),
        ).thenAnswer((_) async => const Success([]));
        when(
          () => favoritesRepository.listFavoriteTopics(),
        ).thenAnswer((_) async => const Success([]));
        return build();
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [
        const HomeSummaryLoaded(
          dailyGoal: DailyGoal(answered: 1),
          pendingErrorsCount: 0,
          favoritesCount: 0,
        ),
      ],
    );
  });
}
