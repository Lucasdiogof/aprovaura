import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';

void main() {
  Streak withLast(DateTime? last) => Streak(
    currentStreak: 1,
    longestStreak: 1,
    streakBreakVersion: 0,
    seenStreakBreakVersion: 0,
    lastActivityDate: last,
  );

  group('isActiveToday', () {
    test('false with no activity yet', () {
      expect(withLast(null).isActiveToday(), isFalse);
    });

    test('true when the last activity is today in São Paulo', () {
      // 20:50 in São Paulo on 28/09 is already 29/09 in UTC.
      final now = DateTime.utc(2026, 9, 29, 0, 50);
      expect(withLast(DateTime(2026, 9, 28)).isActiveToday(now: now), isTrue);
    });

    test('false when the last activity was yesterday', () {
      final now = DateTime.utc(2026, 9, 29, 15);
      expect(withLast(DateTime(2026, 9, 28)).isActiveToday(now: now), isFalse);
    });
  });
}
