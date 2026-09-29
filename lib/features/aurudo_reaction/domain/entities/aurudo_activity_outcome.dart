import 'package:equatable/equatable.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';

/// One quiz-like activity finishing -- prática normal, prática rápida,
/// mapa, simulado. [correctCount]/[totalAnswered] decide the base
/// reaction; the optional before/after snapshots let the resolver notice
/// a level, streak or daily-goal achievement earned by this same
/// activity. Leave a pair null when that signal isn't tracked at the call
/// site -- the resolver simply won't look for that achievement, it never
/// guesses.
class AurudoActivityOutcome extends Equatable {
  const AurudoActivityOutcome({
    required this.correctCount,
    required this.totalAnswered,
    this.xpBefore,
    this.xpAfter,
    this.streakBefore,
    this.streakAfter,
    this.dailyGoalBefore,
    this.dailyGoalAfter,
  });

  final int correctCount;
  final int totalAnswered;
  final UserXp? xpBefore;
  final UserXp? xpAfter;
  final Streak? streakBefore;
  final Streak? streakAfter;
  final DailyGoal? dailyGoalBefore;
  final DailyGoal? dailyGoalAfter;

  @override
  List<Object?> get props => [
    correctCount,
    totalAnswered,
    xpBefore,
    xpAfter,
    streakBefore,
    streakAfter,
    dailyGoalBefore,
    dailyGoalAfter,
  ];
}
