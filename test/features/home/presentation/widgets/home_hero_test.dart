import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/home/l10n/home_strings.dart';
import 'package:aura/features/home/presentation/widgets/home_hero.dart';
import 'package:aura/shared/widgets/aura/aura_badge.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group(HomeHero, () {
    testWidgets('shows the time-of-day greeting and the name, no emoji', (
      tester,
    ) async {
      await tester.pumpApp(
        const HomeHero(
          strings: HomeStrings(AppLanguage.portuguese),
          displayName: 'Ana',
        ),
      );

      expect(find.text('Ana'), findsOneWidget);
      expect(
        find.textContaining(RegExp('Bom dia|Boa tarde|Boa noite')),
        findsOneWidget,
      );
      // Never a stray emoji next to the name -- the point of this redesign.
      expect(find.textContaining('👋'), findsNothing);
    });

    testWidgets('hides the Aura pill until the total has loaded', (
      tester,
    ) async {
      await tester.pumpApp(
        const HomeHero(
          strings: HomeStrings(AppLanguage.portuguese),
          displayName: 'Ana',
        ),
      );

      expect(find.byType(AuraCounter), findsNothing);
    });

    testWidgets('shows the Aura total once it is known', (tester) async {
      await tester.pumpApp(
        const HomeHero(
          strings: HomeStrings(AppLanguage.portuguese),
          displayName: 'Ana',
          auraTotal: 340,
        ),
      );

      expect(find.byType(AuraCounter), findsOneWidget);
    });

    testWidgets('subtitle follows the selected language', (tester) async {
      await tester.pumpApp(
        const HomeHero(
          strings: HomeStrings(AppLanguage.spanish),
          displayName: 'Ana',
        ),
      );

      expect(find.text('¿Listo para avanzar un poco más?'), findsOneWidget);
    });
  });
}
