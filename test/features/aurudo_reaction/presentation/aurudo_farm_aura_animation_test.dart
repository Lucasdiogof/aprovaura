import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/presentation/aura_particles.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_farm_aura_animation.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_mascot_view.dart';
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

  Finder pullParticles() => find.byWidgetPredicate(
    (w) => w is CustomPaint && '${w.painter.runtimeType}' == '_PullPainter',
  );

  bool allAtRest(WidgetTester tester) => tester
      .widgetList<Transform>(
        find.descendant(
          of: find.byType(AurudoFarmAuraAnimation),
          matching: find.byType(Transform),
        ),
      )
      .every((t) {
        final m = t.transform;
        final id = Matrix4.identity();
        for (var i = 0; i < 16; i++) {
          if ((m.storage[i] - id.storage[i]).abs() > 1e-6) return false;
        }
        return true;
      });

  Matrix4 transformOf(WidgetTester tester, Key key) =>
      tester.widget<Transform>(find.byKey(key)).transform;

  // On-screen turn of a 2D transform, in degrees (negative = counter-
  // clockwise: the arm going inward/up).
  double degreesOf(Matrix4 m) =>
      math.atan2(m.storage[1], m.storage[0]) * 180 / math.pi;
  double scaleOf(Matrix4 m) =>
      math.sqrt(m.storage[0] * m.storage[0] + m.storage[1] * m.storage[1]);

  group(FarmAuraPose, () {
    test('peaks at exactly the approved +4° / 1.04 on both pulls', () {
      for (final pull in [0, 1]) {
        final top = FarmAuraPose.at(FarmAuraTimeline.peakMs(pull));
        expect(top.armAngleDegrees, closeTo(4, 1e-4));
        expect(top.orbScale, closeTo(1.04, 1e-4));
        expect(top.glowOpacity, closeTo(0.20, 1e-4));
        expect(top.liftFor(120), closeTo(1, 1e-4));
        expect(top.liftFor(240), closeTo(2, 1e-4));
      }
    });

    test('never turns outward and never overshoots, all the way through', () {
      for (var ms = 0.0; ms <= FarmAuraTimeline.total + 200; ms += 5) {
        final pose = FarmAuraPose.at(ms);
        expect(pose.armAngleDegrees, inInclusiveRange(0, 4), reason: '$ms');
        expect(pose.orbScale, inInclusiveRange(1, 1.04), reason: '$ms');
      }
    });

    test('back to rest between the pulls, exactly the art after', () {
      final between = FarmAuraPose.at(
        FarmAuraTimeline.preroll + FarmAuraTimeline.farmCycleDuration - 0.001,
      );
      expect(between.armAngleDegrees, closeTo(0, 1e-3));
      for (final end in [
        FarmAuraPose.at(FarmAuraTimeline.total.toDouble()),
        FarmAuraPose.rest,
      ]) {
        expect(end.armAngleDegrees, 0);
        expect(end.orbScale, 1);
        expect(end.glowOpacity, 0);
        expect(end.liftFor(240), 0);
      }
    });

    test('ten particles, one origin each', () {
      expect(FarmAuraTimeline.particleCount, 10);
      expect(
        FarmAuraGeometry.particleOrigins,
        hasLength(FarmAuraTimeline.particleCount),
      );
    });
  });

  group('which renderer plays', () {
    testWidgets('perfectFarmAura is the real animation', (tester) async {
      await pump(
        tester,
        const AurudoMascotView(type: AurudoReactionType.perfectFarmAura),
      );
      expect(find.byType(AurudoFarmAuraAnimation), findsOneWidget);
      expect(find.byType(AurudoIllustration), findsNothing);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('every other reaction keeps its still pose(s), unchanged', (
      tester,
    ) async {
      for (final type in AurudoReactionType.values.where(
        (t) => t != AurudoReactionType.perfectFarmAura,
      )) {
        await pump(tester, AurudoMascotView(type: type));
        expect(
          find.byType(AurudoFarmAuraAnimation),
          findsNothing,
          reason: '$type',
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(milliseconds: 500));
        // Settled on the same last pose as before the layers existed.
        expect(
          tester
              .widgetList<AurudoIllustration>(find.byType(AurudoIllustration))
              .map((w) => w.pose),
          [aurudoPoseSequence(type).last],
          reason: '$type',
        );
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('dailyGoalComplete keeps the still farming pose and its own '
        'particles, never the signature animation', (tester) async {
      await pump(
        tester,
        const AurudoReactionStage(
          reaction: AurudoReaction(type: AurudoReactionType.dailyGoalComplete),
          mascotSize: 160,
          headline: Text('Meta do dia!'),
          content: Text('ok'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(AurudoFarmAuraAnimation), findsNothing);
      expect(
        tester.widget<AurudoIllustration>(find.byType(AurudoIllustration)).pose,
        AurudoPose.farmingAura,
      );
      expect(
        tester.widget<AuraParticles>(find.byType(AuraParticles)).style,
        AuraParticlesStyle.converge,
      );
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('perfect: the stage adds no second set of particles', (
      tester,
    ) async {
      await pump(
        tester,
        const AurudoReactionStage(
          reaction: AurudoReaction(type: AurudoReactionType.perfectFarmAura),
          mascotSize: 160,
          headline: Text('Perfeito!'),
          content: Text('10 de 10'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(AurudoFarmAuraAnimation), findsOneWidget);
      expect(find.byType(AuraParticles), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('reduced motion through the mascot view: the still final '
        'pose, nothing ticking', (tester) async {
      await pump(
        tester,
        const AurudoMascotView(type: AurudoReactionType.perfectFarmAura),
        reducedMotion: true,
      );
      await tester.pump();
      expect(find.byType(AurudoFarmAuraAnimation), findsOneWidget);
      expect(allAtRest(tester), isTrue);
      expect(pullParticles(), findsNothing);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });

  group(AurudoFarmAuraAnimation, () {
    testWidgets('pulls with particles, then settles exactly on the base pose '
        'and stops ticking', (tester) async {
      await pump(tester, const AurudoFarmAuraAnimation(size: 180));
      await tester.pump(
        Duration(milliseconds: FarmAuraTimeline.peakMs(0).round()),
      );
      expect(allAtRest(tester), isFalse);
      expect(pullParticles(), findsOneWidget);

      await tester.pump(const Duration(milliseconds: FarmAuraTimeline.total));
      expect(allAtRest(tester), isTrue);
      expect(pullParticles(), findsNothing);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('at the top of a pull the arm group turns +4° inward while '
        'the orb counter-rotates (stays level) and grows to 1.04', (
      tester,
    ) async {
      await pump(tester, const AurudoFarmAuraAnimation(size: 180));
      await tester.pump(
        Duration(milliseconds: FarmAuraTimeline.peakMs(1).round()),
      );
      final arm = transformOf(tester, AurudoFarmAuraAnimation.armGroupKey);
      final orb = transformOf(tester, AurudoFarmAuraAnimation.orbKey);
      expect(degreesOf(arm), closeTo(-4, 0.01));
      expect(degreesOf(orb), closeTo(4, 0.01));
      final onScreen = arm.multiplied(orb);
      expect(degreesOf(onScreen), closeTo(0, 1e-6));
      expect(scaleOf(onScreen), closeTo(1.04, 1e-3));
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('never loops: once settled the clock stays stopped', (
      tester,
    ) async {
      await pump(tester, const AurudoFarmAuraAnimation(size: 180));
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: FarmAuraTimeline.total + 100),
      );
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pump(const Duration(seconds: 5));
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(allAtRest(tester), isTrue);
    });

    testWidgets('reduced motion: the final pose at once, no particles, no '
        'ticker', (tester) async {
      await pump(
        tester,
        const AurudoFarmAuraAnimation(size: 180),
        reducedMotion: true,
      );
      await tester.pump();
      expect(allAtRest(tester), isTrue);
      expect(pullParticles(), findsNothing);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('instant (a scene already seen) behaves the same', (
      tester,
    ) async {
      await pump(
        tester,
        const AurudoFarmAuraAnimation(size: 180, instant: true),
      );
      await tester.pump();
      expect(allAtRest(tester), isTrue);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('removed mid-pull: the controller goes with it', (
      tester,
    ) async {
      await pump(tester, const AurudoFarmAuraAnimation(size: 180));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    });

    for (final (name, theme) in [
      ('light', AppTheme.light),
      ('dark', AppTheme.dark),
    ]) {
      testWidgets('$name theme, 120/180/240: renders without errors', (
        tester,
      ) async {
        for (final size in [120.0, 180.0, 240.0]) {
          await pump(tester, AurudoFarmAuraAnimation(size: size), theme: theme);
          await tester.pump(const Duration(milliseconds: 600));
          expect(tester.takeException(), isNull);
          await tester.pump(const Duration(seconds: 2));
        }
      });
    }

    testWidgets('a layer that fails to load falls back to the still pose', (
      tester,
    ) async {
      await pump(
        tester,
        const AurudoFarmAuraAnimation(
          size: 180,
          assets: [
            FarmAuraGeometry.base,
            'lib/assets/mascot/farm_aura/does_not_exist.webp',
            FarmAuraGeometry.leftArm,
            FarmAuraGeometry.helmetFront,
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
      await tester.pump(const Duration(seconds: 2));
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

    // Headline at the approved beat (~900ms), while Aurudo is between pulls.
    await tester.pump(
      AurudoReactionSequence.totalDuration * AurudoReactionSequence.headlineAt +
          const Duration(milliseconds: 50),
    );
    expect(opacityOf('Perfeito!'), 1);
    expect(find.byType(AurudoFarmAuraAnimation), findsOneWidget);

    // The whole scene done at the stage's own ~2s, never 2.9s.
    await tester.pump(const Duration(milliseconds: 1200));
    expect(opacityOf('10 de 10'), 1);
    expect(completed, isTrue);
    await tester.pump(const Duration(seconds: 1));
  });
}
