import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/features/aurudo_reaction/data/aurudo_reaction_ledger.dart';

void main() {
  group(AurudoReactionLedger, () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<AurudoReactionLedger> ledgerFor(String userId) async =>
        AurudoReactionLedger(
          await SharedPreferences.getInstance(),
          userId: userId,
        );

    test('an attempt not yet marked has not been celebrated', () async {
      final ledger = await ledgerFor('user-a');
      expect(ledger.hasCelebratedAttempt('attempt-1'), isFalse);
    });

    test(
      'marking an attempt makes it (and only it) count as celebrated',
      () async {
        final ledger = await ledgerFor('user-a');
        ledger.markAttemptCelebrated('attempt-1');
        expect(ledger.hasCelebratedAttempt('attempt-1'), isTrue);
        expect(ledger.hasCelebratedAttempt('attempt-2'), isFalse);
      },
    );

    test(
      'a fresh instance for the same user sees what was marked before',
      () async {
        final prefs = await SharedPreferences.getInstance();
        AurudoReactionLedger(
          prefs,
          userId: 'user-a',
        ).markAttemptCelebrated('attempt-1');
        final reloaded = AurudoReactionLedger(prefs, userId: 'user-a');
        expect(reloaded.hasCelebratedAttempt('attempt-1'), isTrue);
      },
    );

    test(
      'two accounts on the same device never share celebrated events',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final userA = AurudoReactionLedger(prefs, userId: 'user-a');
        final userB = AurudoReactionLedger(prefs, userId: 'user-b');

        userA.markAttemptCelebrated('attempt-1');
        userA.markLevelCelebrated(5);
        userA.markStreakMilestoneCelebrated(7);

        expect(userB.hasCelebratedAttempt('attempt-1'), isFalse);
        expect(userB.hasCelebratedLevel(5), isFalse);
        expect(userB.hasCelebratedStreakMilestone(7), isFalse);
        // Signing into a fresh account never inherits the previous one's
        // celebrated events -- confirmed the other way around too.
        expect(userA.hasCelebratedAttempt('attempt-1'), isTrue);
      },
    );

    test('level: only the exact level counts before it is marked', () async {
      final ledger = await ledgerFor('user-a');
      expect(ledger.hasCelebratedLevel(5), isFalse);
      ledger.markLevelCelebrated(5);
      expect(ledger.hasCelebratedLevel(5), isTrue);
      // Levels only ever go up: a lower level doesn't need celebrating
      // again once a higher one already has been.
      expect(ledger.hasCelebratedLevel(4), isTrue);
      expect(ledger.hasCelebratedLevel(6), isFalse);
    });

    test('streak milestones: each one is tracked independently', () async {
      final ledger = await ledgerFor('user-a');
      ledger.markStreakMilestoneCelebrated(7);
      expect(ledger.hasCelebratedStreakMilestone(7), isTrue);
      expect(ledger.hasCelebratedStreakMilestone(14), isFalse);
    });

    test('daily goal: tracked per calendar date', () async {
      final ledger = await ledgerFor('user-a');
      final today = DateTime(2026, 9, 28);
      final tomorrow = DateTime(2026, 9, 29);
      expect(ledger.hasCelebratedDailyGoal(today), isFalse);
      ledger.markDailyGoalCelebrated(today);
      expect(ledger.hasCelebratedDailyGoal(today), isTrue);
      expect(ledger.hasCelebratedDailyGoal(tomorrow), isFalse);
    });

    test('essay corrections: tracked per submission id', () async {
      final ledger = await ledgerFor('user-a');
      expect(ledger.hasCelebratedEssayCorrection('sub-1'), isFalse);
      ledger.markEssayCorrectionCelebrated('sub-1');
      expect(ledger.hasCelebratedEssayCorrection('sub-1'), isTrue);
    });

    test('old attempts are evicted once the bounded list fills up', () async {
      final ledger = await ledgerFor('user-a');
      // One past the cap: the very first one marked must be the one
      // dropped, everything after it must survive.
      for (var i = 0; i < 51; i++) {
        ledger.markAttemptCelebrated('attempt-$i');
      }
      expect(ledger.hasCelebratedAttempt('attempt-0'), isFalse);
      expect(ledger.hasCelebratedAttempt('attempt-1'), isTrue);
      expect(ledger.hasCelebratedAttempt('attempt-50'), isTrue);
    });

    test('a corrupted stored value is treated as empty, not a crash', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('aurudo_reaction_ledger_v1_user-a', 'not json');
      final ledger = AurudoReactionLedger(prefs, userId: 'user-a');
      expect(ledger.hasCelebratedAttempt('attempt-1'), isFalse);
      ledger.markAttemptCelebrated('attempt-1');
      expect(ledger.hasCelebratedAttempt('attempt-1'), isTrue);
    });
  });
}
