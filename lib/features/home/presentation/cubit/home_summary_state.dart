import 'package:equatable/equatable.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';

sealed class HomeSummaryState extends Equatable {
  const HomeSummaryState();

  @override
  List<Object?> get props => [];
}

class HomeSummaryLoading extends HomeSummaryState {
  const HomeSummaryLoading();
}

class HomeSummaryLoaded extends HomeSummaryState {
  const HomeSummaryLoaded({
    required this.dailyGoal,
    this.pendingErrorsCount,
    this.favoritesCount,
  });

  final DailyGoal dailyGoal;
  // Null means that particular count failed to load -- shown as a plain
  // shortcut with no number rather than a misleading 0.
  final int? pendingErrorsCount;
  final int? favoritesCount;

  @override
  List<Object?> get props => [dailyGoal, pendingErrorsCount, favoritesCount];
}
