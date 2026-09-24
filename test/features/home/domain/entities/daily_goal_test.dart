import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';

void main() {
  group(DailyGoal, () {
    test('progress is the answered/target fraction', () {
      const goal = DailyGoal(answered: 7, target: 10);
      expect(goal.progress, 0.7);
      expect(goal.isComplete, isFalse);
    });

    test('progress clamps at 1.0 once past the target', () {
      const goal = DailyGoal(answered: 14, target: 10);
      expect(goal.progress, 1.0);
      expect(goal.isComplete, isTrue);
      // The raw count is still exposed as-is for "14/10" style display.
      expect(goal.answered, 14);
    });

    test('is complete exactly at the target', () {
      const goal = DailyGoal(answered: 10, target: 10);
      expect(goal.isComplete, isTrue);
      expect(goal.progress, 1.0);
    });

    test('defaults to a target of 10', () {
      const goal = DailyGoal(answered: 3);
      expect(goal.target, 10);
    });

    test('does not divide by zero when the target is zero', () {
      const goal = DailyGoal(answered: 3, target: 0);
      expect(goal.progress, 0);
    });
  });
}
