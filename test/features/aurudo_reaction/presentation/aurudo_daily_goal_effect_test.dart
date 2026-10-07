import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/presentation/aura_particles.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_celebrating_animation.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_daily_goal_effect.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_farm_aura_animation.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_level_up_effect.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_mascot_view.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_stage.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_streak_effect.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('which renderer each reaction gets', () {
    testWidgets('dailyGoalComplete: the still farm-Aura pose in its ring', (
      tester,
    ) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.dailyGoalComplete),
      );
      expect(find.byType(AurudoDailyGoalEffect), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AurudoDailyGoalEffect),
          matching: find.byWidgetPredicate(
            (w) => w is AurudoIllustration && w.pose == AurudoPose.farmingAura,
          ),
        ),
        findsOneWidget,
      );
      // Never the 100% animation: that one stays reserved for perfect.
      expect(find.byType(AurudoFarmAuraAnimation), findsNothing);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('every other reaction keeps its own renderer', (tester) async {
      final expected = <AurudoReactionType, Type>{
        AurudoReactionType.perfectFarmAura: AurudoFarmAuraAnimation,
        AurudoReactionType.levelUp: AurudoLevelUpEffect,
        AurudoReactionType.streakMilestone: AurudoStreakEffect,
        AurudoReactionType.great: AurudoCelebratingAnimation,
      };
      for (final MapEntry(key: type, value: renderer) in expected.entries) {
        await tester.pumpApp(AurudoMascotView(key: ValueKey(type), type: type));
        expect(find.byType(renderer), findsOneWidget, reason: type.name);
        expect(
          find.byType(AurudoDailyGoalEffect),
          findsNothing,
          reason: type.name,
        );
        await tester.pump(const Duration(seconds: 3));
      }
      // `great` is the plain celebrating animation, with no scene around it.
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.great),
      );
      expect(find.byType(AurudoLevelUpEffect), findsNothing);
      expect(find.byType(AurudoStreakEffect), findsNothing);
      await tester.pump(const Duration(seconds: 2));
    });
  });

  group(DailyGoalFrame, () {
    test('starts empty', () {
      final f = DailyGoalFrame.at(0);
      expect(f.fill, 0);
      expect(f.closed, isFalse);
      expect(f.pulse, 0);
      expect(f.head, 0);
    });

    test('fills steadily through a quarter and a half', () {
      // A third of the way through the fill reads as a quarter, the
      // midpoint as a half: a gauge, not a lurch.
      const span = DailyGoalTimeline.fillEnd - DailyGoalTimeline.fillStart;
      final quarter = DailyGoalFrame.at(
        DailyGoalTimeline.fillStart + span / 3,
      ).fill;
      final half = DailyGoalFrame.at(
        DailyGoalTimeline.fillStart + span / 2,
      ).fill;
      expect(quarter, closeTo(0.25, 0.03));
      expect(half, closeTo(0.5, 0.01));
      expect(DailyGoalFrame.at(DailyGoalTimeline.fillStart + span / 2).head, 1);
    });

    test('closes at 100% at the end of the fill', () {
      final f = DailyGoalFrame.at(DailyGoalTimeline.fillEnd * 1.0);
      expect(f.fill, 1);
      expect(f.closed, isTrue);
      expect(f.head, 0);
    });

    test('the pulse only happens after the ring has closed', () {
      for (var ms = 0.0; ms < DailyGoalTimeline.fillEnd; ms += 25) {
        expect(DailyGoalFrame.at(ms).pulse, 0, reason: '$ms ms');
        expect(DailyGoalFrame.at(ms).scale, 1, reason: '$ms ms');
      }
      final peak = DailyGoalFrame.at(DailyGoalTimeline.pulse.$2 * 1.0);
      expect(peak.pulse, 1);
      expect(peak.scale, closeTo(1 + DailyGoalGeometry.pulseScale, 1e-9));
      expect(DailyGoalFrame.at(DailyGoalTimeline.pulse.$3 * 1.0).scale, 1);
    });

    test('sparkles light up only once the ring is complete', () {
      for (var ms = 0.0; ms <= DailyGoalTimeline.fillEnd; ms += 25) {
        for (var i = 0; i < DailyGoalGeometry.sparkleAngles.length; i++) {
          expect(DailyGoalFrame.at(ms).sparkle(i), 0, reason: '$i @ $ms ms');
        }
      }
      final end = DailyGoalFrame.at(1450);
      for (var i = 0; i < DailyGoalGeometry.sparkleAngles.length; i++) {
        expect(end.sparkle(i), 1, reason: 'sparkle $i');
      }
    });

    test('the end of the animation is the finished state', () {
      final end = DailyGoalFrame.at(DailyGoalTimeline.total * 1.0);
      const rest = DailyGoalFrame.rest;
      expect(end.fill, rest.fill);
      expect(end.scale, rest.scale);
      expect(end.glow, closeTo(rest.glow, 1e-9));
      expect(end.head, rest.head);
      for (var i = 0; i < DailyGoalGeometry.sparkleAngles.length; i++) {
        expect(end.sparkle(i), rest.sparkle(i));
      }
      expect(rest.fill, 1);
      expect(rest.glow, closeTo(DailyGoalFrame.glowRest, 1e-9));
    });
  });

  group(AurudoDailyGoalEffect, () {
    testWidgets('plays once and leaves no ticker running', (tester) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.dailyGoalComplete),
      );
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      await tester.pump(const Duration(milliseconds: 1800));
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('reduced motion: finished ring at once, no ticker', (
      tester,
    ) async {
      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: AurudoMascotView(type: AurudoReactionType.dailyGoalComplete),
        ),
      );
      expect(find.byType(AurudoDailyGoalEffect), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('instant: finished ring at once, no ticker', (tester) async {
      await tester.pumpApp(
        const AurudoMascotView(
          type: AurudoReactionType.dailyGoalComplete,
          instant: true,
        ),
      );
      expect(find.byType(AurudoDailyGoalEffect), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('unmounting mid-animation throws nothing', (tester) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.dailyGoalComplete),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpApp(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
      expect(tester.binding.transientCallbackCount, 0);
    });

    for (final (name, theme) in [
      ('light', AppTheme.light),
      ('dark', AppTheme.dark),
    ]) {
      testWidgets('renders on the $name theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(
              body: Center(
                child: AurudoMascotView(
                  type: AurudoReactionType.dailyGoalComplete,
                ),
              ),
            ),
          ),
        );
        for (var t = 0; t < 18; t++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(tester.takeException(), isNull);
        expect(find.byType(AurudoDailyGoalEffect), findsOneWidget);
      });
    }

    testWidgets('the stage adds no particles on top of it', (tester) async {
      await tester.pumpApp(
        const AurudoReactionStage(
          reaction: AurudoReaction(type: AurudoReactionType.dailyGoalComplete),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AurudoDailyGoalEffect), findsOneWidget);
      expect(find.byType(AuraParticles), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });
  });

  test('which renderers bring their own particles', () {
    expect(
      {
        for (final t in AurudoReactionType.values)
          if (aurudoReactionHasOwnParticles(t)) t,
      },
      {
        AurudoReactionType.perfectFarmAura,
        AurudoReactionType.levelUp,
        AurudoReactionType.streakMilestone,
        AurudoReactionType.dailyGoalComplete,
      },
    );
  });
}
