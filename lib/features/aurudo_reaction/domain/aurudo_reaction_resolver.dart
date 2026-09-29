import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_activity_outcome.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_secondary_achievement.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/essay_reaction_tier.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/questions/presentation/quiz_result_tier.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';

/// Decides which single Aurudo reaction plays for an event, and which
/// other achievements ride along as secondary badges. No I/O, no
/// randomness, no Flutter import -- every call is a pure function of its
/// input, which is what makes it worth testing on its own.
///
/// Priority when nothing is perfect: levelUp > streakMilestone >
/// dailyGoalComplete > great > normal > encourage. A perfect result
/// always wins outright -- [AurudoReactionType.perfectFarmAura] is the
/// app's signature reaction -- but every other achievement earned in the
/// same activity still shows up in [AurudoReaction.secondary], never
/// silently dropped.
class AurudoReactionResolver {
  const AurudoReactionResolver();

  /// The streak lengths worth a milestone reaction. Not a rule of the
  /// streak system itself -- just which of its values earn extra
  /// celebration here.
  static const streakMilestones = [3, 7, 14, 30, 50, 100];

  AurudoReaction resolveActivity(AurudoActivityOutcome outcome) {
    final tier = outcome.totalAnswered > 0
        ? QuizResultTier.fromFraction(
            outcome.correctCount / outcome.totalAnswered,
          )
        : QuizResultTier.zero;
    final perfect = tier == QuizResultTier.excellent;

    final leveledUpTo = _leveledUpTo(outcome.xpBefore, outcome.xpAfter);
    final milestoneReached = _streakMilestoneReached(
      outcome.streakBefore,
      outcome.streakAfter,
    );
    final goalJustCompleted = _dailyGoalJustCompleted(
      outcome.dailyGoalBefore,
      outcome.dailyGoalAfter,
    );

    final secondary = [
      if (leveledUpTo case final level?)
        AurudoSecondaryAchievement(
          AurudoSecondaryAchievementType.levelUp,
          value: level,
        ),
      if (milestoneReached case final days?)
        AurudoSecondaryAchievement(
          AurudoSecondaryAchievementType.streakMilestone,
          value: days,
        ),
      if (goalJustCompleted)
        const AurudoSecondaryAchievement(
          AurudoSecondaryAchievementType.dailyGoalComplete,
        ),
    ];

    if (perfect) {
      return AurudoReaction(
        type: AurudoReactionType.perfectFarmAura,
        secondary: secondary,
      );
    }
    if (leveledUpTo != null) {
      return AurudoReaction(
        type: AurudoReactionType.levelUp,
        secondary: secondary,
      );
    }
    if (milestoneReached != null) {
      return AurudoReaction(
        type: AurudoReactionType.streakMilestone,
        secondary: secondary,
      );
    }
    if (goalJustCompleted) {
      return AurudoReaction(
        type: AurudoReactionType.dailyGoalComplete,
        secondary: secondary,
      );
    }
    // excellent never reaches here: `perfect` already returned above.
    final type = switch (tier) {
      QuizResultTier.excellent => AurudoReactionType.perfectFarmAura,
      QuizResultTier.good => AurudoReactionType.great,
      QuizResultTier.developing => AurudoReactionType.normal,
      QuizResultTier.zero => AurudoReactionType.encourage,
    };
    return AurudoReaction(type: type, secondary: secondary);
  }

  /// Sending an essay off for correction: always the same reaction --
  /// there is no score yet to react to.
  AurudoReaction resolveEssayWriting() =>
      const AurudoReaction(type: AurudoReactionType.writing);

  /// Opening an essay's evaluation for the first time. The reaction type
  /// is always `correctionReady` regardless of the grade -- only the
  /// [EssayReactionTier] the score falls into changes, which the view
  /// layer uses to pick the mascot's pose.
  AurudoReaction resolveEssayCorrection(int score) => AurudoReaction(
    type: AurudoReactionType.correctionReady,
    essayTier: EssayReactionTier.fromScore(score),
  );

  int? _leveledUpTo(UserXp? before, UserXp? after) {
    if (before == null || after == null) return null;
    return after.level > before.level ? after.level : null;
  }

  int? _streakMilestoneReached(Streak? before, Streak? after) {
    if (before == null || after == null) return null;
    final crossed = streakMilestones.where(
      (m) => before.currentStreak < m && after.currentStreak >= m,
    );
    return crossed.isEmpty ? null : crossed.last;
  }

  bool _dailyGoalJustCompleted(DailyGoal? before, DailyGoal? after) =>
      before != null && after != null && !before.isComplete && after.isComplete;
}
