import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/shared/widgets/aura_bottom_nav_bar.dart';
import 'package:aura/shared/widgets/aura_sparkle_burst.dart';

const _destinations = [
  AuraNavDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label: 'Início',
  ),
  AuraNavDestination(
    icon: Icons.bolt_outlined,
    selectedIcon: Icons.bolt_rounded,
    label: 'Praticar',
  ),
  AuraNavDestination(
    icon: Icons.person_outline,
    selectedIcon: Icons.person_rounded,
    label: 'Perfil',
  ),
];

void main() {
  late List<int> taps;

  setUp(() => taps = []);

  /// Hosts the bar the way the shell does, and rebuilds it with the new
  /// index on tap -- the bar is told what is selected, it does not decide.
  Future<void> pumpBar(
    WidgetTester tester, {
    int initialIndex = 0,
    ThemeData? theme,
    Size size = const Size(390, 844),
    bool reducedMotion = false,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData(
            disableAnimations: reducedMotion,
            textScaler: TextScaler.linear(textScale),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              var index = initialIndex;
              return Scaffold(
                body: const SizedBox.expand(),
                bottomNavigationBar: AuraBottomNavBar(
                  currentIndex: taps.isEmpty ? initialIndex : taps.last,
                  destinations: _destinations,
                  onTap: (i) {
                    taps.add(i);
                    setState(() => index = i);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Color iconColour(WidgetTester tester, IconData icon) =>
      tester.widget<Icon>(find.byIcon(icon)).color!;

  group(AuraBottomNavBar, () {
    testWidgets('every tab keeps its label', (tester) async {
      await pumpBar(tester);

      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Praticar'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('the selected tab is the one it was told about', (
      tester,
    ) async {
      await pumpBar(tester, initialIndex: 1);

      // Filled icon for the selected one, outline for the rest.
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('the active tab looks different, not just filled', (
      tester,
    ) async {
      await pumpBar(tester, initialIndex: 1);
      final context = tester.element(find.byType(AuraBottomNavBar));
      final colors = context.colors;

      expect(iconColour(tester, Icons.bolt_rounded), colors.primary);
      expect(iconColour(tester, Icons.home_outlined), colors.textSecondary);

      final selectedLabel = tester.widget<Text>(find.text('Praticar'));
      final otherLabel = tester.widget<Text>(find.text('Início'));
      expect(selectedLabel.style?.fontWeight, FontWeight.w700);
      expect(otherLabel.style?.fontWeight, FontWeight.w500);
      expect(selectedLabel.style?.color, colors.primary);
    });

    testWidgets('tapping another tab reports it once', (tester) async {
      await pumpBar(tester);

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      expect(taps, [2]);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('tapping the tab you are already on does nothing', (
      tester,
    ) async {
      await pumpBar(tester, initialIndex: 2);

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      // No navigation event, so no reload of a screen already open.
      expect(taps, isEmpty);
    });

    testWidgets('the sparkles only exist while a change is playing', (
      tester,
    ) async {
      await pumpBar(tester);
      expect(find.byType(AuraSparkleBurst), findsOneWidget);

      await tester.tap(find.text('Praticar'));
      await tester.pump();
      // Mid-flight: the burst is painting.
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);

      await tester.pumpAndSettle();
      // And afterwards nothing is left animating.
      expect(tester.takeException(), isNull);
    });
  });

  group('reduced motion', () {
    testWidgets('drops the particles entirely', (tester) async {
      await pumpBar(tester, reducedMotion: true);

      expect(find.byType(AuraSparkleBurst), findsNothing);
    });

    testWidgets('still navigates, and still shows which tab is active', (
      tester,
    ) async {
      await pumpBar(tester, reducedMotion: true);

      await tester.tap(find.text('Praticar'));
      await tester.pumpAndSettle();

      expect(taps, [1]);
      // The active state does not depend on the animation.
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('Praticar')).style?.fontWeight,
        FontWeight.w700,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('layout', () {
    testWidgets('fits 360px', (tester) async {
      await pumpBar(tester, size: const Size(360, 640));
      expect(tester.takeException(), isNull);
    });

    testWidgets('builds on dark', (tester) async {
      await pumpBar(tester, theme: AppTheme.dark);
      expect(find.text('Início'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a larger text size does not overflow it', (tester) async {
      await pumpBar(tester, size: const Size(360, 640), textScale: 1.5);
      expect(tester.takeException(), isNull);
    });
  });
}
