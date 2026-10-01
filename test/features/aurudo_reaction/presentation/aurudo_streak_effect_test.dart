import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/presentation/aura_particles.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_celebrating_animation.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_level_up_effect.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_mascot_view.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_stage.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_streak_effect.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('which renderer each reaction gets', () {
    testWidgets('streakMilestone: the flame behind the celebrating mascot', (
      tester,
    ) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.streakMilestone),
      );
      expect(find.byType(AurudoStreakEffect), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AurudoStreakEffect),
          matching: find.byType(AurudoCelebratingAnimation),
        ),
        findsOneWidget,
      );
      expect(find.byType(AurudoLevelUpEffect), findsNothing);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('levelUp and great never get the flame', (tester) async {
      for (final type in [
        AurudoReactionType.levelUp,
        AurudoReactionType.great,
      ]) {
        await tester.pumpApp(AurudoMascotView(key: ValueKey(type), type: type));
        expect(
          find.byType(AurudoStreakEffect),
          findsNothing,
          reason: type.name,
        );
        await tester.pump(const Duration(seconds: 2));
      }
    });
  });

  group(StreakFrame, () {
    test('starts unlit and small', () {
      final f = StreakFrame.at(0);
      expect(f.flame, 0);
      expect(f.glow, 0);
      expect(f.scale, closeTo(StreakGeometry.igniteFrom, 1e-9));
    });

    test('flares twice, the second time smaller', () {
      final first = StreakFrame.at(StreakTimeline.flare1.$2 * 1.0).stretch;
      final second = StreakFrame.at(StreakTimeline.flare2.$2 * 1.0).stretch;
      expect(first, closeTo(StreakGeometry.flare1Stretch, 1e-9));
      expect(second, closeTo(StreakGeometry.flare2Stretch, 1e-9));
      expect(second, lessThan(first));
      final between = StreakFrame.at(StreakTimeline.flare1.$3 * 1.0).stretch;
      expect(between, 0);
    });

    test('the end of the animation is the settled flame', () {
      final end = StreakFrame.at(StreakTimeline.total * 1.0);
      const rest = StreakFrame.rest;
      expect(end.flame, closeTo(rest.flame, 1e-9));
      expect(end.glow, closeTo(rest.glow, 1e-9));
      expect(end.scale, rest.scale);
      expect(end.stretch, rest.stretch);
      expect(end.flicker, rest.flicker);
    });

    test('at rest: full size, still, quieter, no embers', () {
      const rest = StreakFrame.rest;
      expect(rest.scale, 1);
      expect(rest.stretch, 0);
      expect(rest.flicker, 0);
      expect(rest.flame, closeTo(StreakFrame.flameRest, 1e-9));
      expect(rest.glow, closeTo(StreakFrame.glowRest, 1e-9));
      for (var i = 0; i < StreakGeometry.emberXs.length; i++) {
        expect(rest.emberTravel(i), isNull, reason: 'ember $i');
      }
    });

    test('every ember is gone before the effect ends', () {
      for (var i = 0; i < StreakGeometry.emberXs.length; i++) {
        expect(
          StreakFrame.at(StreakTimeline.embersEnd * 1.0).emberTravel(i),
          isNull,
          reason: 'ember $i',
        );
      }
    });
  });

  group(AurudoStreakEffect, () {
    testWidgets('plays once and leaves no ticker running', (tester) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.streakMilestone),
      );
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      await tester.pump(const Duration(milliseconds: 1800));
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('reduced motion: settled flame at once, no ticker', (
      tester,
    ) async {
      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: AurudoMascotView(type: AurudoReactionType.streakMilestone),
        ),
      );
      expect(find.byType(AurudoStreakEffect), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('instant: settled flame at once, no ticker', (tester) async {
      await tester.pumpApp(
        const AurudoMascotView(
          type: AurudoReactionType.streakMilestone,
          instant: true,
        ),
      );
      expect(find.byType(AurudoStreakEffect), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('unmounting mid-animation throws nothing', (tester) async {
      await tester.pumpApp(
        const AurudoMascotView(type: AurudoReactionType.streakMilestone),
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
                child: AurudoMascotView(
                  type: AurudoReactionType.streakMilestone,
                ),
              ),
            ),
          ),
        );
        for (var t = 0; t < 18; t++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(tester.takeException(), isNull);
        expect(find.byType(AurudoStreakEffect), findsOneWidget);
      });
    }

    testWidgets('the stage adds no burst on top of it', (tester) async {
      await tester.pumpApp(
        const AurudoReactionStage(
          reaction: AurudoReaction(type: AurudoReactionType.streakMilestone),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AurudoStreakEffect), findsOneWidget);
      expect(find.byType(AuraParticles), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
