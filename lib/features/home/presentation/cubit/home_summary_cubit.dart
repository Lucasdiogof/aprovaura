import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/home/domain/repositories/daily_goal_repository.dart';
import 'package:aura/features/home/presentation/cubit/home_summary_state.dart';

/// Feeds Home's daily-goal card and the pending/favorites counts on its
/// practice shortcuts. Lives above the auth boundary like StreakCubit and
/// XpCubit, so load() is triggered explicitly once a session exists
/// (HomeShellPage) instead of eagerly here.
class HomeSummaryCubit extends Cubit<HomeSummaryState> {
  HomeSummaryCubit(
    this._dailyGoalRepository,
    this._errorReviewRepository,
    this._favoritesRepository,
  ) : super(const HomeSummaryLoading());

  final DailyGoalRepository _dailyGoalRepository;
  final ErrorReviewRepository _errorReviewRepository;
  final FavoritesRepository _favoritesRepository;

  Future<void> load() async {
    final (dailyGoalResult, pendingResult, favoritesResult) = await (
      _dailyGoalRepository.getTodayAnsweredCount(),
      _errorReviewRepository.listPendingTopics(),
      _favoritesRepository.listFavoriteTopics(),
    ).wait;
    if (isClosed) return;

    final answeredToday = switch (dailyGoalResult) {
      Success(:final data) => data,
      Error() => 0,
    };
    final pendingErrorsCount = switch (pendingResult) {
      Success(:final data) => data.fold(
        0,
        (sum, topic) => sum + topic.wrongCount,
      ),
      Error() => null,
    };
    final favoritesCount = switch (favoritesResult) {
      Success(:final data) => data.fold(
        0,
        (sum, topic) => sum + topic.favoriteCount,
      ),
      Error() => null,
    };

    emit(
      HomeSummaryLoaded(
        dailyGoal: DailyGoal(answered: answeredToday),
        pendingErrorsCount: pendingErrorsCount,
        favoritesCount: favoritesCount,
      ),
    );
  }

  // Called when Home regains focus after a pushed screen pops (a finished
  // practice session, a resolved error, an unfavorited question) so the
  // counts don't go stale without a full navigation round trip.
  Future<void> refresh() => load();
}
