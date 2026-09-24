import 'package:equatable/equatable.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/mock_exam/domain/entities/active_mock_exam.dart';

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
    this.activeMockExam,
  });

  final DailyGoal dailyGoal;
  // Null means that particular count failed to load -- shown as a plain
  // shortcut with no number rather than a misleading 0.
  final int? pendingErrorsCount;
  final int? favoritesCount;
  // The in-progress mock exam, if any. Null both when there is none and
  // when it failed to load -- either way the shortcut falls back to
  // "Montar simulado", and the server still refuses a second active exam
  // (the setup screen then offers to continue/discard it).
  final ActiveMockExam? activeMockExam;

  @override
  List<Object?> get props => [
    dailyGoal,
    pendingErrorsCount,
    favoritesCount,
    activeMockExam,
  ];
}
