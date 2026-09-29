import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_sequence.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_stage.dart';

import '../../../helpers/pump_app.dart';

/// `_Reveal` keeps its child in the tree at all times and only ever
/// changes its opacity -- so `find.text(...)` always finds it, faded out
/// or not. Reading the opacity is the only way to tell whether a label is
/// actually visible.
double _opacityOf(WidgetTester tester, String text) => tester
    .widget<AnimatedOpacity>(
      find.ancestor(
        of: find.text(text),
        matching: find.byType(AnimatedOpacity),
      ),
    )
    .opacity;

void main() {
  group(AurudoReactionStage, () {
    const reaction = AurudoReaction(type: AurudoReactionType.perfectFarmAura);

    testWidgets('the result is not on screen on the very first frame', (
      tester,
    ) async {
      await tester.pumpApp(
        const AurudoReactionStage(
          reaction: reaction,
          content: Text('17 de 17'),
        ),
      );
      expect(_opacityOf(tester, '17 de 17'), 0);
    });

    testWidgets('headline, result and cta appear in that order over time', (
      tester,
    ) async {
      await tester.pumpApp(
        const AurudoReactionStage(
          reaction: reaction,
          headline: Text('Perfeito!'),
          content: Text('17 de 17'),
          cta: Text('Continuar'),
        ),
      );

      const total = AurudoReactionSequence.totalDuration;

      // Just past headlineAt, before resultAt: only the headline is up.
      await tester.pump(total * AurudoReactionSequence.headlineAt);
      await tester.pump(const Duration(milliseconds: 10));
      expect(_opacityOf(tester, 'Perfeito!'), 1);
      expect(_opacityOf(tester, '17 de 17'), 0);
      expect(_opacityOf(tester, 'Continuar'), 0);

      // Just past resultAt, before ctaAt: headline and result are up, the
      // CTA still isn't.
      await tester.pump(
        total *
            (AurudoReactionSequence.resultAt -
                AurudoReactionSequence.headlineAt),
      );
      await tester.pump(const Duration(milliseconds: 10));
      expect(_opacityOf(tester, '17 de 17'), 1);
      expect(_opacityOf(tester, 'Continuar'), 0);

      // Past ctaAt: everything, including the CTA, is up.
      await tester.pump(
        total *
            (AurudoReactionSequence.ctaAt - AurudoReactionSequence.resultAt),
      );
      await tester.pump(const Duration(milliseconds: 10));
      expect(_opacityOf(tester, 'Continuar'), 1);
    });

    testWidgets('secondary achievements (stats) are rendered when supplied', (
      tester,
    ) async {
      await tester.pumpApp(
        const AurudoReactionStage(reaction: reaction, stats: Text('Nível 8')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nível 8'), findsOneWidget);
    });

    testWidgets('calls onSequenceCompleted once the timeline finishes', (
      tester,
    ) async {
      var completed = 0;
      await tester.pumpApp(
        AurudoReactionStage(
          reaction: reaction,
          onSequenceCompleted: () => completed++,
        ),
      );
      await tester.pumpAndSettle();
      expect(completed, 1);
    });

    testWidgets('reduced motion: everything available almost immediately', (
      tester,
    ) async {
      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: AurudoReactionStage(
            reaction: reaction,
            headline: Text('Perfeito!'),
            content: Text('17 de 17'),
            cta: Text('Continuar'),
          ),
        ),
      );
      // Only the reveal steps' own short fade is left to settle -- no
      // 2-second wait, unlike the full-motion case above.
      await tester.pumpAndSettle();
      expect(_opacityOf(tester, 'Perfeito!'), 1);
      expect(_opacityOf(tester, '17 de 17'), 1);
      expect(_opacityOf(tester, 'Continuar'), 1);
    });

    testWidgets(
      'instant: everything available immediately even with full motion on',
      (tester) async {
        await tester.pumpApp(
          const AurudoReactionStage(
            reaction: reaction,
            instant: true,
            headline: Text('Perfeito!'),
            content: Text('17 de 17'),
            cta: Text('Continuar'),
          ),
        );
        await tester.pumpAndSettle();
        expect(_opacityOf(tester, 'Perfeito!'), 1);
        expect(_opacityOf(tester, '17 de 17'), 1);
        expect(_opacityOf(tester, 'Continuar'), 1);
      },
    );

    testWidgets('a tap before the skip delay does nothing', (tester) async {
      await tester.pumpApp(
        const AurudoReactionStage(reaction: reaction, cta: Text('Continuar')),
      );
      await tester.tap(find.byType(AurudoReactionStage));
      await tester.pump(const Duration(milliseconds: 50));
      expect(_opacityOf(tester, 'Continuar'), 0);
    });

    testWidgets('a tap after the skip delay reveals everything at once', (
      tester,
    ) async {
      await tester.pumpApp(
        const AurudoReactionStage(reaction: reaction, cta: Text('Continuar')),
      );
      await tester.pump(
        AurudoReactionStage.skipUnlockDelay + const Duration(milliseconds: 10),
      );
      await tester.tap(find.byType(AurudoReactionStage));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_opacityOf(tester, 'Continuar'), 1);
    });

    testWidgets('renders without error on both light and dark themes', (
      tester,
    ) async {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(body: AurudoReactionStage(reaction: reaction)),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$theme');
      }
    });

    testWidgets('disposes cleanly, no ticker left running', (tester) async {
      await tester.pumpApp(const AurudoReactionStage(reaction: reaction));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpApp(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    for (final type in AurudoReactionType.values) {
      testWidgets('${type.name}: builds without error', (tester) async {
        await tester.pumpApp(
          AurudoReactionStage(reaction: AurudoReaction(type: type)),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
