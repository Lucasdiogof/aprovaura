import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/features/profile/presentation/widgets/xp_level_card.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const strings = ProfileStrings(AppLanguage.portuguese);

  testWidgets('shows level and progress in Aura, never "XP"', (tester) async {
    await tester.pumpApp(
      const Scaffold(
        body: XpLevelCard(strings: strings, xp: UserXp(totalXp: 150)),
      ),
    );

    expect(find.text('Nível 2'), findsOneWidget);
    expect(find.text('150 Aura no total'), findsOneWidget);
    expect(find.text('50 / 100 Aura para o nível 3'), findsOneWidget);
    expect(find.textContaining('XP'), findsNothing);
  });

  testWidgets('the progress fill is actually painted at the right width', (
    tester,
  ) async {
    await tester.pumpApp(
      const Scaffold(
        body: SizedBox(
          width: 300,
          child: XpLevelCard(strings: strings, xp: UserXp(totalXp: 150)),
        ),
      ),
    );

    final track = tester.getSize(
      find.ancestor(
        of: find.byType(FractionallySizedBox),
        matching: find.byType(ClipRRect),
      ),
    );
    final fill = tester.getSize(
      find.descendant(
        of: find.byType(FractionallySizedBox),
        matching: find.byType(DecoratedBox),
      ),
    );
    // Regression: the fill used to get a loose height and paint nothing.
    expect(fill.height, 8);
    // 150 total -> 50 of 100 into level 2 -> half the track.
    expect(fill.width, closeTo(track.width / 2, 0.5));
  });

  testWidgets('fits a 360px phone', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpApp(
      const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: XpLevelCard(strings: strings, xp: UserXp(totalXp: 12350)),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
