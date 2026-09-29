import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/aurudo_reaction/data/aurudo_reaction_ledger.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_secondary_achievement.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_activity_completion.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

/// The result screen is where an achievement is celebrated; marking it
/// seen there is what keeps Home from celebrating it a second time.
void main() {
  late SharedPreferences prefs;

  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    final auth = _MockAuthRepository();
    when(
      () => auth.currentUser,
    ).thenReturn(const AppUser(id: 'user-1', email: 'a@b.com'));
    sl.registerLazySingleton<AuthRepository>(() => auth);
    sl.registerSingleton<SharedPreferences>(prefs);
  });

  AurudoReactionLedger ledger() =>
      AurudoReactionLedger(prefs, userId: 'user-1');

  test('a perfect run spends every achievement it showed as a badge', () {
    const reaction = AurudoReaction(
      type: AurudoReactionType.perfectFarmAura,
      secondary: [
        AurudoSecondaryAchievement(
          AurudoSecondaryAchievementType.levelUp,
          value: 8,
        ),
        AurudoSecondaryAchievement(
          AurudoSecondaryAchievementType.streakMilestone,
          value: 7,
        ),
        AurudoSecondaryAchievement(
          AurudoSecondaryAchievementType.dailyGoalComplete,
        ),
      ],
    );

    expect(markReactionSeen('attempt-1', reaction), isFalse);

    final seen = ledger();
    expect(seen.hasCelebratedAttempt('attempt-1'), isTrue);
    expect(seen.hasCelebratedLevel(8), isTrue);
    expect(seen.hasCelebratedStreakMilestone(7), isTrue);
    // Filed under the goal's own day -- the same key Home asks with.
    expect(
      seen.hasCelebratedDailyGoal(DailyGoal.dayOf(DateTime.now())),
      isTrue,
    );
  });

  test('the same attempt again says "already seen" and changes nothing', () {
    const reaction = AurudoReaction(type: AurudoReactionType.great);
    expect(markReactionSeen('attempt-1', reaction), isFalse);
    expect(markReactionSeen('attempt-1', reaction), isTrue);
  });

  test('a plain result spends no achievement it did not have', () {
    markReactionSeen(
      'attempt-2',
      const AurudoReaction(type: AurudoReactionType.normal),
    );

    final seen = ledger();
    expect(seen.hasCelebratedLevel(2), isFalse);
    expect(seen.hasCelebratedStreakMilestone(3), isFalse);
    expect(
      seen.hasCelebratedDailyGoal(DailyGoal.dayOf(DateTime.now())),
      isFalse,
    );
  });
}
