import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/essay_reaction_tier.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_mascot_view.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group(AurudoMascotView, () {
    test('perfectFarmAura is farmingAura, a single pose', () {
      expect(aurudoPoseSequence(AurudoReactionType.perfectFarmAura), [
        AurudoPose.farmingAura,
      ]);
    });

    test('encourage ends in studying, never frustrated', () {
      final poses = aurudoPoseSequence(AurudoReactionType.encourage);
      expect(poses.last, AurudoPose.studying);
      expect(poses, isNot(contains(AurudoPose.frustrated)));
    });

    test('normal ends in neutral', () {
      expect(
        aurudoPoseSequence(AurudoReactionType.normal).last,
        AurudoPose.neutral,
      );
    });

    test('no reaction type ever uses frustrated', () {
      for (final type in AurudoReactionType.values) {
        expect(
          aurudoPoseSequence(type),
          isNot(contains(AurudoPose.frustrated)),
          reason: type.name,
        );
      }
    });

    testWidgets('a two-pose reaction starts on the first pose', (tester) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.encourage),
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is AurudoIllustration && w.pose == AurudoPose.thinking,
        ),
        findsOneWidget,
      );
    });

    testWidgets('a two-pose reaction crosses over to the final pose', (
      tester,
    ) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.encourage),
      );
      await tester.pump(
        AurudoMascotView.firstPoseDuration + const Duration(milliseconds: 50),
      );
      await tester.pump(AurudoMascotView.crossfadeDuration);
      expect(
        find.byWidgetPredicate(
          (w) => w is AurudoIllustration && w.pose == AurudoPose.studying,
        ),
        findsOneWidget,
      );
    });

    testWidgets('reduced motion shows the final pose immediately', (
      tester,
    ) async {
      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: AurudoMascotView(type: AurudoReactionType.encourage),
        ),
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is AurudoIllustration && w.pose == AurudoPose.studying,
        ),
        findsOneWidget,
      );
    });

    testWidgets('instant: shows the final pose immediately, full motion on', (
      tester,
    ) async {
      await tester.pumpApp(
        const AurudoMascotView(
          type: AurudoReactionType.encourage,
          instant: true,
        ),
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is AurudoIllustration && w.pose == AurudoPose.studying,
        ),
        findsOneWidget,
      );
    });

    testWidgets('a single-pose reaction never switches poses', (tester) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.great),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(
        find.byWidgetPredicate(
          (w) => w is AurudoIllustration && w.pose == AurudoPose.celebrating,
        ),
        findsOneWidget,
      );
    });

    group('correctionReady picks its pose from the essay tier', () {
      test('excellent and great both celebrate', () {
        for (final tier in [
          EssayReactionTier.excellent,
          EssayReactionTier.great,
        ]) {
          expect(
            aurudoPoseSequence(
              AurudoReactionType.correctionReady,
              essayTier: tier,
            ),
            [AurudoPose.celebrating],
            reason: tier.name,
          );
        }
      });

      test('developing is neutral', () {
        expect(
          aurudoPoseSequence(
            AurudoReactionType.correctionReady,
            essayTier: EssayReactionTier.developing,
          ),
          [AurudoPose.neutral],
        );
      });

      test('encourage is studying, never frustrated', () {
        expect(
          aurudoPoseSequence(
            AurudoReactionType.correctionReady,
            essayTier: EssayReactionTier.encourage,
          ),
          [AurudoPose.studying],
        );
      });

      test('a missing tier falls back to neutral, not a guess', () {
        expect(aurudoPoseSequence(AurudoReactionType.correctionReady), [
          AurudoPose.neutral,
        ]);
      });

      testWidgets('reduced motion shows the right tier pose immediately', (
        tester,
      ) async {
        await tester.pumpApp(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: AurudoMascotView(
              type: AurudoReactionType.correctionReady,
              essayTier: EssayReactionTier.encourage,
            ),
          ),
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is AurudoIllustration && w.pose == AurudoPose.studying,
          ),
          findsOneWidget,
        );
      });
    });
  });
}
