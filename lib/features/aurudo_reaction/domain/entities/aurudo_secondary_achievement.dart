import 'package:equatable/equatable.dart';

enum AurudoSecondaryAchievementType {
  levelUp,
  streakMilestone,
  dailyGoalComplete,
}

/// A badge-worthy event that happened alongside the main reaction, but
/// didn't win the priority race in `AurudoReactionResolver` -- shown as a
/// secondary badge on the result screen (e.g. "Level 8"), never as its
/// own animation.
class AurudoSecondaryAchievement extends Equatable {
  const AurudoSecondaryAchievement(this.type, {this.value});

  final AurudoSecondaryAchievementType type;

  /// The new level for [AurudoSecondaryAchievementType.levelUp], the
  /// streak length for [AurudoSecondaryAchievementType.streakMilestone];
  /// null for [AurudoSecondaryAchievementType.dailyGoalComplete].
  final int? value;

  @override
  List<Object?> get props => [type, value];
}
