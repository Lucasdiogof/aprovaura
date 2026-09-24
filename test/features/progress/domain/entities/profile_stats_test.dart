import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/progress/domain/entities/profile_stats.dart';

void main() {
  group(ProfileStats, () {
    test('accuracyPercent rounds the correct/total fraction', () {
      const stats = ProfileStats(totalAnswered: 247, correctAnswered: 200);
      expect(stats.accuracyPercent, 81);
    });

    test('accuracyPercent is 0 when nothing has been answered yet', () {
      expect(ProfileStats.empty.accuracyPercent, 0);
    });

    test('accuracyPercent is 100 for a perfect record', () {
      const stats = ProfileStats(totalAnswered: 10, correctAnswered: 10);
      expect(stats.accuracyPercent, 100);
    });
  });
}
