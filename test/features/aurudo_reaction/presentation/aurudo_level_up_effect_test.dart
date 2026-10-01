import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/presentation/aura_particles.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_celebrating_animation.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_farm_aura_animation.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_level_up_effect.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_mascot_view.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_stage.dart';

import '../../../helpers/pump_app.dart';

double _lift(WidgetTester tester) => tester
    .widget<Transform>(find.byKey(AurudoLevelUpEffect.liftKey))
    .transform
    .getTranslation()
    .y;

void main() {
  group('which renderer each reaction gets', () {
    testWidgets('levelUp: the level-up scene around the celebrating mascot', (
      tester,
    ) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.levelUp),
      );
      expect(find.byType(AurudoLevelUpEffect), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AurudoLevelUpEffect),
          matching: find.byType(AurudoCelebratingAnimation),
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('great: still the plain celebrating animation', (tester) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.great),
      );
      expect(find.byType(AurudoCelebratingAnimation), findsOneWidget);
      expect(find.byType(AurudoLevelUpEffect), findsNothing);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('perfectFarmAura: still the farm-Aura animation', (
      tester,
    ) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.perfectFarmAura),
      );
      expect(find.byType(AurudoFarmAuraAnimation), findsOneWidget);
      expect(find.byType(AurudoLevelUpEffect), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });
  });

  group(LevelUpFrame, () {
    test('starts with nothing drawn yet', () {
      final f = LevelUpFrame.at(0);
      expect(f.glow, 0);
      expect(f.beam, 0);
      expect(f.lift, 0);
      for (var i = 0; i < LevelUpTimeline.ringStarts.length; i++) {
        expect(f.ringOpacity(i), 0, reason: 'ring $i');
      }
    });

    test('rings are born one after another, in order', () {
      final f = LevelUpFrame.at(LevelUpTimeline.ringStarts[1] + 10.0);
      expect(f.ringTravel(0), greaterThan(f.ringTravel(1)));
      expect(f.ringTravel(1), greaterThan(0));
      expect(f.ringTravel(2), 0);
    });

    test('rises a hair and comes back to exactly where he stood', () {
      expect(LevelUpFrame.at(LevelUpTimeline.liftPeak * 1.0).lift, lessThan(0));
      expect(
        LevelUpFrame.at(LevelUpTimeline.liftPeak * 1.0).lift.abs(),
        lessThanOrEqualTo(LevelUpFrame.maxLift),
      );
      expect(LevelUpFrame.at(LevelUpTimeline.liftEnd * 1.0).lift, 0);
    });

    test('the end of the animation is the settled composition', () {
      final end = LevelUpFrame.at(LevelUpTimeline.total * 1.0);
      const rest = LevelUpFrame.rest;
      expect(end.glow, closeTo(rest.glow, 1e-9));
      expect(end.beam, rest.beam);
      expect(end.lift, rest.lift);
      expect(end.restSparkles, rest.restSparkles);
      for (var i = 0; i < LevelUpTimeline.ringStarts.length; i++) {
        expect(end.ringOpacity(i), rest.ringOpacity(i), reason: 'ring $i');
      }
    });

    test('at rest: only the last ring stays, with a little glow', () {
      const rest = LevelUpFrame.rest;
      expect(rest.ringOpacity(0), 0);
      expect(rest.ringOpacity(1), 0);
      expect(rest.ringOpacity(2), LevelUpFrame.lastRingRest);
      expect(rest.glow, closeTo(LevelUpFrame.glowRest, 1e-9));
      expect(rest.beam, 0);
      expect(rest.restSparkles, 1);
    });

    test('every rising sparkle is done before the effect ends', () {
      for (var i = 0; i < 6; i++) {
        expect(
          LevelUpFrame.at(LevelUpTimeline.total - 1.0).sparkleTravel(i),
          isNull,
          reason: 'sparkle $i',
        );
      }
    });
  });

  group(AurudoLevelUpEffect, () {
    testWidgets('plays once and leaves no ticker running', (tester) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.levelUp),
      );
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      await tester.pump(const Duration(milliseconds: 600));
      expect(_lift(tester), lessThan(0));
      await tester.pump(const Duration(milliseconds: 1200));
      expect(_lift(tester), 0);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('reduced motion: settled scene at once, no ticker', (
      tester,
    ) async {
      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: AurudoMascotView(type: AurudoReactionType.levelUp),
        ),
      );
      expect(find.byType(AurudoLevelUpEffect), findsOneWidget);
      expect(_lift(tester), 0);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('instant: settled scene at once, no ticker', (tester) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.levelUp, instant: true),
      );
      expect(_lift(tester), 0);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('unmounting mid-animation throws nothing', (tester) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.levelUp),
      );
      await tester.pump(const Duration(milliseconds: 500));
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
                child: AurudoMascotView(type: AurudoReactionType.levelUp),
              ),
            ),
          ),
        );
        for (var t = 0; t < 18; t++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(tester.takeException(), isNull);
        expect(find.byType(AurudoLevelUpEffect), findsOneWidget);
      });
    }

    testWidgets('the stage adds no burst on top of it', (tester) async {
      await tester.pumpApp(
        const AurudoReactionStage(
          reaction: AurudoReaction(type: AurudoReactionType.levelUp),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AurudoLevelUpEffect), findsOneWidget);
      expect(find.byType(AuraParticles), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('great keeps its burst on the stage', (tester) async {
      await tester.pumpApp(
        const AurudoReactionStage(
          reaction: AurudoReaction(type: AurudoReactionType.great),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AuraParticles), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
