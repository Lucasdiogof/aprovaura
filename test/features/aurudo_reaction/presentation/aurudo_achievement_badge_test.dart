import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_secondary_achievement.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_achievement_badge.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group(AurudoAchievementBadge, () {
    testWidgets('shows exactly the label the caller gave it', (tester) async {
      await tester.pumpApp(
        const AurudoAchievementBadge(
          achievement: AurudoSecondaryAchievement(
            AurudoSecondaryAchievementType.levelUp,
            value: 8,
          ),
          label: 'Nível 8',
        ),
      );
      expect(find.text('Nível 8'), findsOneWidget);
    });

    testWidgets('renders for all three achievement types without error', (
      tester,
    ) async {
      for (final type in AurudoSecondaryAchievementType.values) {
        await tester.pumpApp(
          AurudoAchievementBadge(
            achievement: AurudoSecondaryAchievement(type),
            label: type.name,
          ),
        );
        expect(tester.takeException(), isNull, reason: type.name);
      }
    });
  });
}
