import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/essay_reaction_tier.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_celebrating_animation.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_mascot_view.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

import '../../../helpers/pump_app.dart';

/// The opacities of the two poses at one instant of a crossfade.
typedef _Sample = ({int ms, double out, double inn});

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
      // `great` resolves to the single `celebrating` pose, which is the one
      // real animation (AurudoCelebratingAnimation), never the crossfading
      // still AurudoIllustration -- see that animation's own tests.
      expect(find.byType(AurudoCelebratingAnimation), findsOneWidget);
      expect(find.byType(AurudoIllustration), findsNothing);
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

  group('pose transition: out early, in late, never two strong faces', () {
    Future<List<_Sample>> crossfade(
      WidgetTester tester,
      AurudoReactionType type,
    ) async {
      await tester.pumpApp(AurudoMascotView(type: type));
      // A hair past the hold, so the timer has surely fired and the first
      // frame of the crossfade (value 0) is the one on screen.
      await tester.pump(
        AurudoMascotView.firstPoseDuration + const Duration(milliseconds: 1),
      );
      final samples = <_Sample>[];
      final total = AurudoMascotView.crossfadeDuration.inMilliseconds;
      for (var ms = 0; ms <= total + 20; ms += 10) {
        final out = find.byWidgetPredicate(
          (w) => w is AurudoPoseFade && !w.incoming,
        );
        final inn = find.byWidgetPredicate(
          (w) => w is AurudoPoseFade && w.incoming,
        );
        samples.add((
          ms: ms,
          out: out.evaluate().isEmpty
              ? 0.0
              : tester.widget<FadeTransition>(out).opacity.value,
          inn: inn.evaluate().isEmpty
              ? 0.0
              : tester.widget<FadeTransition>(inn).opacity.value,
        ));
        await tester.pump(const Duration(milliseconds: 10));
      }
      return samples;
    }

    final cases = {
      'thinking -> neutral': AurudoReactionType.normal,
      'thinking -> studying': AurudoReactionType.encourage,
    };

    test('is short: 170-190 ms', () {
      expect(
        AurudoMascotView.crossfadeDuration.inMilliseconds,
        inInclusiveRange(170, 190),
      );
    });

    for (final entry in cases.entries) {
      testWidgets(
        '${entry.key}: the old pose is gone early, the new one comes in late',
        (tester) async {
          final s = await crossfade(tester, entry.value);
          final total = AurudoMascotView.crossfadeDuration.inMilliseconds;

          // Starts as the old pose alone.
          expect(s.first.out, 1);
          expect(s.first.inn, 0);

          // The old pose only ever fades out, and is fully gone early.
          for (var i = 1; i < s.length; i++) {
            expect(s[i].out, lessThanOrEqualTo(s[i - 1].out + 1e-9));
          }
          for (final x in s.where(
            (x) => x.ms >= total * AurudoMascotView.fadeOutEnd + 10,
          )) {
            expect(x.out, 0, reason: '${x.ms} ms');
          }

          // The new pose holds back at first, then only ever fades in, and
          // ends fully there.
          for (final x in s.where(
            (x) => x.ms <= total * AurudoMascotView.fadeInStart - 5,
          )) {
            expect(x.inn, lessThan(0.05), reason: '${x.ms} ms');
          }
          for (var i = 1; i < s.length; i++) {
            expect(s[i].inn, greaterThanOrEqualTo(s[i - 1].inn - 1e-9));
          }
          expect(s.last.inn, 1);

          // The new pose is completely there by the end of its window, with
          // the rest of the crossfade left to settle.
          for (final x in s.where(
            (x) => x.ms >= total * AurudoMascotView.fadeInEnd + 10,
          )) {
            expect(x.inn, 1, reason: '${x.ms} ms');
          }
        },
      );

      testWidgets(
        '${entry.key}: never an empty frame, never two strong poses for long',
        (tester) async {
          final s = await crossfade(tester, entry.value);
          for (final x in s) {
            // What is on screen at this instant: old over new.
            final shown = 1 - (1 - x.out) * (1 - x.inn);
            expect(
              shown,
              greaterThanOrEqualTo(0.84),
              reason: '${x.ms} ms: no blink',
            );
          }
          // How long both are above 40% at once (the ghost).
          final ghost = s.where((x) => x.out > 0.4 && x.inn > 0.4).length * 10;
          expect(
            ghost,
            lessThanOrEqualTo(30),
            reason: 'ghost lasted $ghost ms',
          );
        },
      );
    }

    testWidgets('lands on the final pose, with one illustration left', (
      tester,
    ) async {
      await crossfade(tester, AurudoReactionType.encourage);
      expect(find.byType(AurudoIllustration), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is AurudoIllustration && w.pose == AurudoPose.studying,
        ),
        findsOneWidget,
      );
    });

    testWidgets('reduced motion: no fade at all, the final pose at once', (
      tester,
    ) async {
      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: AurudoMascotView(type: AurudoReactionType.normal),
        ),
      );
      expect(
        find.byWidgetPredicate((w) => w is AurudoPoseFade && !w.incoming),
        findsNothing,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is AurudoIllustration && w.pose == AurudoPose.neutral,
        ),
        findsOneWidget,
      );
    });
  });
}
