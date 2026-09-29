import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/aurudo_reaction/domain/aurudo_reaction_resolver.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_activity_outcome.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_secondary_achievement.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/essay_reaction_tier.dart';
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

    group('resolveEssayCorrection', () {
      test('is always correctionReady, whatever the score', () {
        for (final score in [0, 250, 500, 750, 900, 1000]) {
          expect(
            resolver.resolveEssayCorrection(score).type,
            AurudoReactionType.correctionReady,
          );
        }
      });

      test(
        '1000 is excellent -- left prepared for a future special reaction',
        () {
          expect(
            resolver.resolveEssayCorrection(1000).essayTier,
            EssayReactionTier.excellent,
          );
        },
      );

      test('920 is excellent', () {
        expect(
          resolver.resolveEssayCorrection(920).essayTier,
          EssayReactionTier.excellent,
        );
      });

      test('800 is great', () {
        expect(
          resolver.resolveEssayCorrection(800).essayTier,
          EssayReactionTier.great,
        );
      });

      test('600 is developing', () {
        expect(
          resolver.resolveEssayCorrection(600).essayTier,
          EssayReactionTier.developing,
        );
      });

      test('400 is encourage', () {
        expect(
          resolver.resolveEssayCorrection(400).essayTier,
          EssayReactionTier.encourage,
        );
      });

      test('899/900 is the great/excellent boundary', () {
        expect(
          resolver.resolveEssayCorrection(899).essayTier,
          EssayReactionTier.great,
        );
        expect(
          resolver.resolveEssayCorrection(900).essayTier,
          EssayReactionTier.excellent,
        );
      });

      test('699/700 is the developing/great boundary', () {
        expect(
          resolver.resolveEssayCorrection(699).essayTier,
          EssayReactionTier.developing,
        );
        expect(
          resolver.resolveEssayCorrection(700).essayTier,
          EssayReactionTier.great,
        );
      });

      test('499/500 is the encourage/developing boundary', () {
        expect(
          resolver.resolveEssayCorrection(499).essayTier,
          EssayReactionTier.encourage,
        );
        expect(
          resolver.resolveEssayCorrection(500).essayTier,
          EssayReactionTier.developing,
        );
      });
    });
  });
}
