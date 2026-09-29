import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/aurudo_reaction/data/current_aurudo_reaction_ledger.dart';
import 'package:aura/features/aurudo_reaction/domain/aurudo_reaction_resolver.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_activity_outcome.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/home/domain/repositories/daily_goal_repository.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/streak/presentation/cubit/streak_state.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/features/xp/presentation/cubit/xp_state.dart';

/// Where an activity stood *before* its own answers could move anything.
///
/// The resolver spots a level up, a streak milestone or the daily goal
/// completing by diffing these against the numbers after the rewards
/// land, so they have to be read while the activity is still running --
/// not on the result screen, by which time they have already changed.
class AurudoRewardsSnapshot {
  const AurudoRewardsSnapshot({this.xp, this.streak, this.dailyGoal});

  final UserXp? xp;
  final Streak? streak;
  final DailyGoal? dailyGoal;

  /// XP and streak come straight from the cubits already in the tree;
  /// only the daily goal needs a round trip, so it arrives later through
  /// [withDailyGoal] rather than holding up the screen.
  factory AurudoRewardsSnapshot.fromCubits(BuildContext context) {
    UserXp? currentXp;
    if (context.read<XpCubit>().state case XpLoaded(:final xp)) currentXp = xp;
    Streak? currentStreak;
    if (context.read<StreakCubit>().state case StreakLoaded(:final streak)) {
      currentStreak = streak;
    }
    return AurudoRewardsSnapshot(xp: currentXp, streak: currentStreak);
  }

  AurudoRewardsSnapshot withDailyGoal(DailyGoal? goal) =>
      AurudoRewardsSnapshot(xp: xp, streak: streak, dailyGoal: goal);

  static Future<DailyGoal?> readDailyGoal() async {
    final result = await sl<DailyGoalRepository>().getTodayAnsweredCount();
    if (result case Success(:final data)) return DailyGoal(answered: data);
    return null;
  }
}

/// The numbers as they stand right now, once an activity's rewards have
/// landed. [includeDailyGoal] is false where the goal cannot be
/// attributed to this activity -- see the mock exam, whose answers
/// already counted toward the goal while it was being taken.
Future<AurudoRewardsSnapshot> currentRewardsSnapshot(
  BuildContext context, {
  bool includeDailyGoal = true,
}) async {
  final snapshot = AurudoRewardsSnapshot.fromCubits(context);
  if (!includeDailyGoal) return snapshot;
  return snapshot.withDailyGoal(await AurudoRewardsSnapshot.readDailyGoal());
}

/// The one reaction that should play, from what changed between [before]
/// and [after].
///
/// A signal missing on either side is simply not looked at: the resolver
/// never guesses an achievement it cannot see happening.
AurudoReaction resolveFromSnapshots({
  required AurudoRewardsSnapshot? before,
  required AurudoRewardsSnapshot? after,
  required int correctCount,
  required int totalAnswered,
}) => const AurudoReactionResolver().resolveActivity(
  AurudoActivityOutcome(
    correctCount: correctCount,
    totalAnswered: totalAnswered,
    xpBefore: before?.xp,
    xpAfter: after?.xp,
    streakBefore: before?.streak,
    streakAfter: after?.streak,
    dailyGoalBefore: before?.dailyGoal,
    dailyGoalAfter: after?.dailyGoal,
  ),
);

/// Grants this activity's rewards, then resolves the one reaction that
/// should play.
///
/// Shared by every activity that finishes with a score -- the quiz deck
/// (prática, prática rápida, Atualidades, Favoritos, revisar erros) and
/// the map quiz -- so there is exactly one place that decides *when* the
/// numbers are final and *what* the resolver is asked. No screen repeats
/// a threshold of its own.
///
/// The awards are awaited on purpose: fire-and-forget would let the
/// result appear with the XP, streak and goal of a moment ago, and the
/// reaction would miss the very achievement this activity just earned.
///
/// [awardedCorrectCount] is what `award_quiz_xp` is told, which is not
/// always [correctCount]: the map grants a flat amount per finished map
/// rather than per region. The reaction always reads the real score.
Future<AurudoReaction> awardAndResolveReaction({
  required BuildContext context,
  required AurudoRewardsSnapshot? before,
  required String attemptId,
  required int correctCount,
  required int totalAnswered,
  int? awardedCorrectCount,
}) async {
  // No snapshot means the caller grants nothing (reviewing already
  // answered questions): score alone decides, and there is no
  // achievement to look for.
  if (before == null) {
    return resolveFromSnapshots(
      before: null,
      after: null,
      correctCount: correctCount,
      totalAnswered: totalAnswered,
    );
  }

  final xpCubit = context.read<XpCubit>();
  final streakCubit = context.read<StreakCubit>();

  await Future.wait([
    streakCubit.registerActivityCompletion(),
    xpCubit.awardQuizXp(
      attemptId: attemptId,
      correctCount: awardedCorrectCount ?? correctCount,
    ),
  ]);
  if (!context.mounted) {
    return resolveFromSnapshots(
      before: null,
      after: null,
      correctCount: correctCount,
      totalAnswered: totalAnswered,
    );
  }

  return resolveFromSnapshots(
    before: before,
    after: await currentRewardsSnapshot(context),
    correctCount: correctCount,
    totalAnswered: totalAnswered,
  );
}

/// Records that [attemptId] has now been celebrated, and says whether it
/// already had been.
///
/// True means this attempt is being shown again -- a rebuild, a theme
/// change, coming back to a result already seen -- and the caller should
/// open straight in the final state instead of replaying the scene. The
/// mark happens at the moment the scene actually starts presenting, never
/// while the activity is still finishing.
bool markReactionSeen(String attemptId) {
  final ledger = currentAurudoReactionLedger();
  final already = ledger?.hasCelebratedAttempt(attemptId) ?? false;
  if (!already) ledger?.markAttemptCelebrated(attemptId);
  return already;
}
