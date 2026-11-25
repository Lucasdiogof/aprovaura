import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_farm_hands_animation.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_sequence.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_stage.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool reducedMotion = false,
    ThemeData? theme,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reducedMotion),
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    ),
  );

  Finder painter() => find.byWidgetPredicate(
    (w) =>
        w is CustomPaint && '${w.painter.runtimeType}' == '_FarmHandsPainter',
  );

  // Asset decoding needs real async time in widget tests.
  Future<void> load(WidgetTester tester) async {
    for (var i = 0; i < 20 && painter().evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    // Settle the rebuild the last decoded layer asked for.
    await tester.pump();
  }

  group(FarmHandsTimeline, () {
    test('the arms see-saw: one palm high while the other is low', () {
      expect(
        FarmHandsTimeline.raise(0, right: false, loop: true),
        closeTo(0, 1e-9),
      );
      expect(
        FarmHandsTimeline.raise(
          FarmHandsTimeline.period / 2,
          right: false,
          loop: true,
        ),
        closeTo(1, 1e-9),
      );
      expect(
        FarmHandsTimeline.raise(
          FarmHandsTimeline.period / 2,
          right: true,
          loop: true,
        ),
        closeTo(0, 1e-9),
      );
      expect(
        FarmHandsTimeline.raise(
          FarmHandsTimeline.period,
          right: true,
          loop: true,
        ),
        closeTo(1, 1e-9),
      );
    });

    test('the loop is seamless: one period later it is the same pose', () {
      for (var t = 3.0; t < 6; t += .037) {
        for (final right in [false, true]) {
          expect(
            FarmHandsTimeline.raise(
              t + FarmHandsTimeline.period,
              right: right,
              loop: true,
            ),
            closeTo(FarmHandsTimeline.raise(t, right: right, loop: true), 1e-9),
          );
        }
        expect(
          FarmHandsTimeline.orbsAt(
            t + FarmHandsTimeline.period,
            loop: true,
          ).length,
          FarmHandsTimeline.orbsAt(t, loop: true).length,
        );
      }
    });

    test('the one-shot: two raises per arm, four orbs, then rest', () {
      expect(FarmHandsTimeline.onceOrbs, hasLength(4));
      const end = FarmHandsTimeline.onceTotal - FarmHandsTimeline.lead;
      expect(FarmHandsTimeline.raise(end, right: false, loop: false), 0);
      expect(FarmHandsTimeline.raise(end, right: true, loop: false), 0);
      expect(FarmHandsTimeline.orbsAt(end, loop: false), isEmpty);
      expect(FarmHandsTimeline.charge(end, loop: false), 0);
      // Fully charged once the last orb has landed, before the fade.
      expect(
        FarmHandsTimeline.charge(FarmHandsTimeline.onceFadeStart, loop: false),
        closeTo(1, 1e-9),
      );
    });

    test('an orb is born in each palm on every raise', () {
      final born = FarmHandsTimeline.onceOrbs;
      expect(born.where((o) => o.right), hasLength(2));
      expect(born.where((o) => !o.right), hasLength(2));
      for (final o in born) {
        final r = FarmHandsTimeline.raise(
          o.startsAt,
          right: o.right,
          loop: false,
        );
        expect(r, greaterThan(.9), reason: 'palm almost at the top');
      }
    });
  });

  group(FarmHandsGeometry, () {
    test('both palms face up, mirrored about the body', () {
      final r = FarmHandsGeometry.palm(right: true);
      final l = FarmHandsGeometry.palm(right: false);
      expect(r.dy, l.dy);
      expect(FarmHandsGeometry.mirrorX(r.dx), closeTo(l.dx, 1e-9));
      // Lower arm pose has the hand rotated ~180°: the palm is up.
      expect(FarmHandsGeometry.armPose(0).handTurn, 176);
      expect(FarmHandsGeometry.armPose(1).handTurn, 172);
    });

    test('raising lifts the wrist', () {
      expect(
        FarmHandsGeometry.armPose(1).wrist.dy,
        lessThan(FarmHandsGeometry.armPose(0).wrist.dy - 40),
      );
    });
  });

  group(AurudoFarmHandsAnimation, () {
    testWidgets('plays once and stops ticking', (tester) async {
      await pump(tester, const AurudoFarmHandsAnimation(size: 180));
      await load(tester);
      expect(painter(), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('loop keeps going', (tester) async {
      await pump(tester, const AurudoFarmHandsAnimation(size: 180, loop: true));
      await load(tester);
      await tester.pump(const Duration(seconds: 6));
      expect(tester.binding.hasScheduledFrame, isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('reduced motion: the resting pose, no ticker', (tester) async {
      await pump(
        tester,
        const AurudoFarmHandsAnimation(size: 180, loop: true),
        reducedMotion: true,
      );
      await load(tester);
      expect(painter(), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('instant behaves the same', (tester) async {
      await pump(
        tester,
        const AurudoFarmHandsAnimation(size: 180, instant: true),
      );
      await load(tester);
      expect(painter(), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    for (final (name, theme) in [
      ('light', AppTheme.light),
      ('dark', AppTheme.dark),
    ]) {
      testWidgets('$name theme, 120/200/240: paints without errors', (
        tester,
      ) async {
        for (final size in [120.0, 200.0, 240.0]) {
          await pump(
            tester,
            AurudoFarmHandsAnimation(size: size, loop: true),
            theme: theme,
          );
          await load(tester);
          for (var i = 0; i < 12; i++) {
            await tester.pump(const Duration(milliseconds: 150));
          }
          expect(tester.takeException(), isNull);
          expect(
            tester.getSize(find.byType(AurudoFarmHandsAnimation)),
            Size(size * FarmHandsGeometry.aspect, size),
          );
        }
      });
    }

    testWidgets('a layer that fails to load falls back to the still pose', (
      tester,
    ) async {
      await pump(
        tester,
        const AurudoFarmHandsAnimation(
          size: 180,
          assets: [
            FarmHandsGeometry.body,
            'lib/assets/mascot/farm_hands/does_not_exist.webp',
            FarmHandsGeometry.hand,
            FarmHandsGeometry.cuff,
          ],
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
      expect(
        find.byWidgetPredicate(
          (w) => w is AurudoIllustration && w.pose == AurudoPose.farmingAura,
        ),
        findsOneWidget,
      );
    });
  });

  testWidgets('in the stage, the headline and the result do not wait for the '
      'animation to finish', (tester) async {
    var completed = false;
    await pump(
      tester,
      AurudoReactionStage(
        reaction: const AurudoReaction(
          type: AurudoReactionType.perfectFarmAura,
        ),
        mascotSize: 160,
        headline: const Text('Perfeito!'),
        content: const Text('10 de 10'),
        onSequenceCompleted: () => completed = true,
      ),
    );
    double opacityOf(String text) => tester
        .widget<AnimatedOpacity>(
          find
              .ancestor(
                of: find.text(text),
                matching: find.byType(AnimatedOpacity),
              )
              .first,
        )
        .opacity;

    await tester.pump(
      AurudoReactionSequence.totalDuration * AurudoReactionSequence.headlineAt +
          const Duration(milliseconds: 50),
    );
    expect(opacityOf('Perfeito!'), 1);
    expect(find.byType(AurudoFarmHandsAnimation), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));
    expect(opacityOf('10 de 10'), 1);
    expect(completed, isTrue);
    await tester.pump(const Duration(seconds: 4));
  });
}
