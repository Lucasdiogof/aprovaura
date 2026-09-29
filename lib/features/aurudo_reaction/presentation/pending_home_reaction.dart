import 'package:aura/features/aurudo_reaction/data/current_aurudo_reaction_ledger.dart';
import 'package:aura/features/aurudo_reaction/domain/aurudo_reaction_resolver.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_secondary_achievement.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';

/// An achievement that really happened and that no result screen ever
/// showed.
///
/// There is one way for that to occur today, and it is by design: the
/// daily goal can be reached on question 10 of a 30-question mock exam,
/// which is handed in twenty questions later. The exam's result refuses
/// to claim it (celebrating a moment that passed long ago would be a
/// lie), so Home picks it up instead -- once.
///
/// Everything else normally arrives already celebrated: a result screen
/// marks what it showed, so coming back to Home only updates numbers.
/// Home stays the fallback for the rare case where nothing did.
class PendingHomeReaction {
  const PendingHomeReaction._(this.reaction, this._commit);

  final AurudoReaction reaction;
  final void Function() _commit;

  /// Writes it down as celebrated. Called when the reaction actually
  /// starts playing, never while merely deciding there is one.
  void markCelebrated() => _commit();
}

/// The one thing Home should celebrate right now, or null.
///
/// At most one, by the same priority the resolver uses elsewhere: a level
/// outranks a streak milestone, which outranks the daily goal. The rest
/// simply show up as the updated numbers they already are.
///
/// Returns null while any of the numbers is still loading -- a
/// celebration decided on half-loaded data would be a guess.
PendingHomeReaction? pendingHomeReaction({
  required UserXp? xp,
  required Streak? streak,
  required DailyGoal? dailyGoal,
  required DateTime today,
}) {
  if (xp == null || streak == null || dailyGoal == null) return null;
  final ledger = currentAurudoReactionLedger();
  if (ledger == null) return null;

  // First time this device sees this user: write the standing down as
  // already seen. Otherwise a fresh install would read a 30-day streak as
  // something that just happened.
  if (!ledger.hasBaseline) {
    ledger.takeBaseline(
      level: xp.level,
      streakDays: streak.currentStreak,
      dailyGoalComplete: dailyGoal.isComplete,
      today: today,
    );
    return null;
  }

  if (xp.level > 1 && !ledger.hasCelebratedLevel(xp.level)) {
    return PendingHomeReaction._(
      AurudoReaction(
        type: AurudoReactionType.levelUp,
        secondary: [
          AurudoSecondaryAchievement(
            AurudoSecondaryAchievementType.levelUp,
            value: xp.level,
          ),
        ],
      ),
      () => ledger.markLevelCelebrated(xp.level),
    );
  }

  final milestone = AurudoReactionResolver.streakMilestones
      .where((days) => days == streak.currentStreak)
      .where((days) => !ledger.hasCelebratedStreakMilestone(days))
      .firstOrNull;
  if (milestone != null) {
    return PendingHomeReaction._(
      AurudoReaction(
        type: AurudoReactionType.streakMilestone,
        secondary: [
          AurudoSecondaryAchievement(
            AurudoSecondaryAchievementType.streakMilestone,
            value: milestone,
          ),
        ],
      ),
      () => ledger.markStreakMilestoneCelebrated(milestone),
    );
  }

  if (dailyGoal.isComplete && !ledger.hasCelebratedDailyGoal(today)) {
    return PendingHomeReaction._(
      const AurudoReaction(
        type: AurudoReactionType.dailyGoalComplete,
        secondary: [
          AurudoSecondaryAchievement(
            AurudoSecondaryAchievementType.dailyGoalComplete,
          ),
        ],
      ),
      () => ledger.markDailyGoalCelebrated(today),
    );
  }

  return null;
}
