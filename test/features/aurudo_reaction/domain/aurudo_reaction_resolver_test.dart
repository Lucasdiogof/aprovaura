import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/aurudo_reaction/domain/aurudo_reaction_resolver.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_activity_outcome.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_secondary_achievement.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';

void main() {
  group(AurudoReactionResolver, () {
    const resolver = AurudoReactionResolver();

    Streak streak(int current) => Streak(
      currentStreak: current,
      longestStreak: current,
      streakBreakVersion: 0,
      seenStreakBreakVersion: 0,
    );

    group('resolveActivity', () {
      test('10/10 is perfectFarmAura', () {
        final reaction = resolver.resolveActivity(
          const AurudoActivityOutcome(correctCount: 10, totalAnswered: 10),
        );
        expect(reaction.type, AurudoReactionType.perfectFarmAura);
        expect(reaction.secondary, isEmpty);
      });

      test('a good-but-not-perfect result is great', () {
        final reaction = resolver.resolveActivity(
          const AurudoActivityOutcome(correctCount: 8, totalAnswered: 10),
        );
        expect(reaction.type, AurudoReactionType.great);
      });

      test('a middling result is normal', () {
        final reaction = resolver.resolveActivity(
          const AurudoActivityOutcome(correctCount: 4, totalAnswered: 10),
        );
        expect(reaction.type, AurudoReactionType.normal);
      });

      test('a weak result is encourage, never perfect or normal', () {
        final reaction = resolver.resolveActivity(
          const AurudoActivityOutcome(correctCount: 0, totalAnswered: 10),
        );
        expect(reaction.type, AurudoReactionType.encourage);
      });

      test('perfect + level up + streak milestone + daily goal: '
          'perfectFarmAura wins, all three ride along as secondary', () {
        final reaction = resolver.resolveActivity(
          AurudoActivityOutcome(
            correctCount: 10,
            totalAnswered: 10,
            xpBefore: const UserXp(totalXp: 690),
            xpAfter: const UserXp(totalXp: 720),
            streakBefore: streak(6),
            streakAfter: streak(7),
            dailyGoalBefore: const DailyGoal(answered: 9),
            dailyGoalAfter: const DailyGoal(answered: 10),
          ),
        );
        expect(reaction.type, AurudoReactionType.perfectFarmAura);
        expect(reaction.secondary, hasLength(3));
        expect(
          reaction.secondary,
          containsAll([
            const AurudoSecondaryAchievement(
              AurudoSecondaryAchievementType.levelUp,
              value: 8,
            ),
            const AurudoSecondaryAchievement(
              AurudoSecondaryAchievementType.streakMilestone,
              value: 7,
            ),
            const AurudoSecondaryAchievement(
              AurudoSecondaryAchievementType.dailyGoalComplete,
            ),
          ]),
        );
      });

      test('no perfect, but a level up: levelUp is the main reaction', () {
        final reaction = resolver.resolveActivity(
          const AurudoActivityOutcome(
            correctCount: 6,
            totalAnswered: 10,
            xpBefore: UserXp(totalXp: 690),
            xpAfter: UserXp(totalXp: 720),
          ),
        );
        expect(reaction.type, AurudoReactionType.levelUp);
      });

      test('no perfect and no level up, but a streak milestone: '
          'streakMilestone is the main reaction', () {
        final reaction = resolver.resolveActivity(
          AurudoActivityOutcome(
            correctCount: 6,
            totalAnswered: 10,
            streakBefore: streak(6),
            streakAfter: streak(7),
          ),
        );
        expect(reaction.type, AurudoReactionType.streakMilestone);
      });

      test('the daily goal completing on its own is dailyGoalComplete', () {
        final reaction = resolver.resolveActivity(
          const AurudoActivityOutcome(
            correctCount: 6,
            totalAnswered: 10,
            dailyGoalBefore: DailyGoal(answered: 9),
            dailyGoalAfter: DailyGoal(answered: 10),
          ),
        );
        expect(reaction.type, AurudoReactionType.dailyGoalComplete);
      });

      test(
        'skipping a milestone in one activity still finds the highest one',
        () {
          final reaction = resolver.resolveActivity(
            AurudoActivityOutcome(
              correctCount: 6,
              totalAnswered: 10,
              streakBefore: streak(2),
              streakAfter: streak(15),
            ),
          );
          expect(
            reaction.secondary.single,
            const AurudoSecondaryAchievement(
              AurudoSecondaryAchievementType.streakMilestone,
              value: 14,
            ),
          );
        },
      );

      test('no before/after signal at all: no secondary achievements', () {
        final reaction = resolver.resolveActivity(
          const AurudoActivityOutcome(correctCount: 4, totalAnswered: 10),
        );
        expect(reaction.secondary, isEmpty);
        expect(reaction.type, AurudoReactionType.normal);
      });

      test(
        'an empty activity (0 questions) does not crash: it is encourage',
        () {
          final reaction = resolver.resolveActivity(
            const AurudoActivityOutcome(correctCount: 0, totalAnswered: 0),
          );
          expect(reaction.type, AurudoReactionType.encourage);
        },
      );

      test(
        'the daily goal already complete before this activity: no badge',
        () {
          final reaction = resolver.resolveActivity(
            const AurudoActivityOutcome(
              correctCount: 6,
              totalAnswered: 10,
              dailyGoalBefore: DailyGoal(answered: 10),
              dailyGoalAfter: DailyGoal(answered: 12),
            ),
          );
          expect(reaction.secondary, isEmpty);
        },
      );
    });

    test('resolveEssayWriting is always writing', () {
      expect(resolver.resolveEssayWriting().type, AurudoReactionType.writing);
    });

    test('resolveEssayCorrection is always correctionReady', () {
      expect(
        resolver.resolveEssayCorrection().type,
        AurudoReactionType.correctionReady,
      );
    });
  });
}
