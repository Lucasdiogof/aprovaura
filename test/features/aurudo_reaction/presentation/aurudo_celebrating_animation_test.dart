import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_celebrating_animation.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_mascot_view.dart';
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

  bool allAtRest(WidgetTester tester) => tester
      .widgetList<Transform>(
        find.descendant(
          of: find.byType(AurudoCelebratingAnimation),
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

  // On-screen turn of a 2D transform, in degrees.
  double degreesOf(Matrix4 m) =>
      math.atan2(m.storage[1], m.storage[0]) * 180 / math.pi;

  group(CelebratingPose, () {
    test('peaks at exactly the approved +6° on both pumps', () {
      for (final pump in [0, 1]) {
        final top = CelebratingPose.at(CelebratingTimeline.peakMs(pump));
        expect(top.armAngleDegrees, closeTo(6, 1e-4));
        expect(top.liftFor(160), closeTo(1, 1e-4));
        expect(top.liftFor(320), closeTo(2, 1e-4));
      }
    });

    test('never overshoots, all the way through', () {
      for (var ms = 0.0; ms <= CelebratingTimeline.total + 200; ms += 5) {
        final pose = CelebratingPose.at(ms);
        expect(pose.armAngleDegrees, inInclusiveRange(0, 6), reason: '$ms');
      }
    });

    test('back to rest between the pumps, exactly the art after', () {
      final between = CelebratingPose.at(
        CelebratingTimeline.preroll +
            CelebratingTimeline.pumpCycleDuration -
            0.001,
      );
      expect(between.armAngleDegrees, closeTo(0, 1e-3));
      for (final end in [
        CelebratingPose.at(CelebratingTimeline.total.toDouble()),
        CelebratingPose.rest,
      ]) {
        expect(end.armAngleDegrees, 0);
        expect(end.liftFor(320), 0);
      }
    });
  });

  group('which renderer plays', () {
    for (final type in [
      AurudoReactionType.great,
      AurudoReactionType.levelUp,
      AurudoReactionType.streakMilestone,
    ]) {
      testWidgets('$type is the real animation', (tester) async {
        await pump(tester, AurudoMascotView(type: type));
        expect(find.byType(AurudoCelebratingAnimation), findsOneWidget);
        expect(find.byType(AurudoIllustration), findsNothing);
        await tester.pump(const Duration(seconds: 2));
      });
    }

    testWidgets('reduced motion through the mascot view: the still final '
        'pose, nothing ticking', (tester) async {
      await pump(
        tester,
        const AurudoMascotView(type: AurudoReactionType.great),
        reducedMotion: true,
      );
      await tester.pump();
      expect(find.byType(AurudoCelebratingAnimation), findsOneWidget);
      expect(allAtRest(tester), isTrue);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });

  group(AurudoCelebratingAnimation, () {
    testWidgets('pumps the arm, then settles exactly on the base pose and '
        'stops ticking', (tester) async {
      await pump(tester, const AurudoCelebratingAnimation(size: 180));
      await tester.pump(
        Duration(milliseconds: CelebratingTimeline.peakMs(0).round()),
      );
      expect(allAtRest(tester), isFalse);

      await tester.pump(
        const Duration(milliseconds: CelebratingTimeline.total),
      );
      expect(allAtRest(tester), isTrue);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('at the top of a pump the arm group turns +6° further '
        'up/inward', (tester) async {
      await pump(tester, const AurudoCelebratingAnimation(size: 180));
      await tester.pump(
        Duration(milliseconds: CelebratingTimeline.peakMs(1).round()),
      );
      final arm = transformOf(
        tester,
        AurudoCelebratingAnimation.armGroupKey,
      );
      expect(degreesOf(arm), closeTo(6, 0.01));
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('never loops: once settled the clock stays stopped', (
      tester,
    ) async {
      await pump(tester, const AurudoCelebratingAnimation(size: 180));
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: CelebratingTimeline.total + 100),
      );
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pump(const Duration(seconds: 5));
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(allAtRest(tester), isTrue);
    });

    testWidgets('reduced motion: the final pose at once, no ticker', (
      tester,
    ) async {
      await pump(
        tester,
        const AurudoCelebratingAnimation(size: 180),
        reducedMotion: true,
      );
      await tester.pump();
      expect(allAtRest(tester), isTrue);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('instant (a scene already seen) behaves the same', (
      tester,
    ) async {
      await pump(
        tester,
        const AurudoCelebratingAnimation(size: 180, instant: true),
      );
      await tester.pump();
      expect(allAtRest(tester), isTrue);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('removed mid-pump: the controller goes with it', (
      tester,
    ) async {
      await pump(tester, const AurudoCelebratingAnimation(size: 180));
      await tester.pump(const Duration(milliseconds: 300));
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
          await pump(
            tester,
            AurudoCelebratingAnimation(size: size),
            theme: theme,
          );
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
        const AurudoCelebratingAnimation(
          size: 180,
          assets: [
            CelebratingGeometry.particles,
            'lib/assets/mascot/celebrating/does_not_exist.webp',
            CelebratingGeometry.rightArm,
          ],
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
      expect(
        find.byWidgetPredicate(
          (w) => w is AurudoIllustration && w.pose == AurudoPose.celebrating,
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
