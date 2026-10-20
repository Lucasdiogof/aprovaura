import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/shared/widgets/aura/aurudo_idle.dart';
import 'package:aura/shared/widgets/aura/aurudo_study_animation.dart';
import 'package:aura/shared/widgets/aura/aurudo_thinking_animation.dart';
import 'package:aura/shared/widgets/aura/aurudo_wave_animation.dart';

import '../../../helpers/pump_app.dart';

/// The hand's turn, in degrees, read off the group's transform.
double _angle(WidgetTester tester, Key key) {
  final m = tester.widget<Transform>(find.byKey(key)).transform;
  return math.atan2(m[1], m[0]) * 180 / math.pi;
}

/// Steps through [span] and returns the largest turn seen.
Future<double> _peak(WidgetTester tester, Key key, Duration span) async {
  var peak = 0.0;
  for (var t = Duration.zero; t < span; t += const Duration(milliseconds: 40)) {
    await tester.pump(const Duration(milliseconds: 40));
    peak = math.max(peak, _angle(tester, key).abs());
  }
  return peak;
}

void main() {
  // The repeat timers follow the same switch as the idle drift.
  setUp(() => AurudoIdle.debugEnabled = true);
  tearDown(() => AurudoIdle.debugEnabled = false);

  group('studying keeps typing', () {
    testWidgets('after a pause he types again, and settles again', (
      tester,
    ) async {
      await tester.pumpApp(
        const Center(child: AurudoStudyAnimation(size: 140)),
      );
      // First play, with its entrance.
      await _peak(tester, AurudoStudyAnimation.handGroupKey, 2.sec);
      expect(_angle(tester, AurudoStudyAnimation.handGroupKey), 0);

      // Within the longest pause plus the longest burst he is at it again.
      final again = await _peak(
        tester,
        AurudoStudyAnimation.handGroupKey,
        StudyTimeline.maxPause + 3.sec,
      );
      expect(again, greaterThan(3));
      // Never past what the cut-out holds.
      expect(again, lessThanOrEqualTo(StudyTimeline.maxAngleDegrees));

      // And then he comes to rest on the art.
      await tester.pump(2.sec);
      await tester.pump(StudyTimeline.minPause - 2.sec);
      expect(
        _angle(tester, AurudoStudyAnimation.handGroupKey).abs(),
        lessThanOrEqualTo(StudyTimeline.maxAngleDegrees),
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a replay never fades him in again', (tester) async {
      await tester.pumpApp(
        const Center(child: AurudoStudyAnimation(size: 140)),
      );
      await tester.pump(2.sec);
      await tester.pump(StudyTimeline.minPause + 400.ms);
      for (var i = 0; i < 60; i++) {
        await tester.pump(100.ms);
        final opacity = tester.widgetList<Opacity>(find.byType(Opacity)).first;
        expect(opacity.opacity, 1);
      }
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('unmounting during the pause leaves no timer behind', (
      tester,
    ) async {
      await tester.pumpApp(
        const Center(child: AurudoStudyAnimation(size: 140)),
      );
      await tester.pump(2.sec);
      await tester.pumpWidget(const SizedBox());
      // The framework fails the test if a timer is still pending here.
    });

    testWidgets('reduced motion arms nothing', (tester) async {
      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Center(child: AurudoStudyAnimation(size: 140)),
        ),
      );
      await tester.pump(1.sec);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('taking over from another pose skips the entrance', (
      tester,
    ) async {
      await tester.pumpApp(
        const Center(child: AurudoStudyAnimation(size: 140, entrance: false)),
      );
      final opacity = tester.widgetList<Opacity>(find.byType(Opacity)).first;
      expect(opacity.opacity, 1);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('thinking keeps turning it over', () {
    testWidgets('he taps his chin again later, gently', (tester) async {
      await tester.pumpApp(
        const Center(child: AurudoThinkingAnimation(size: 140)),
      );
      await _peak(tester, AurudoThinkingAnimation.handGroupKey, 2.sec);
      final again = await _peak(
        tester,
        AurudoThinkingAnimation.handGroupKey,
        ThinkingTimeline.maxPause + 4.sec,
      );
      expect(again, greaterThan(2));
      expect(again, lessThanOrEqualTo(ThinkingTimeline.maxAngleDegrees));
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('the hello comes back, rarely', () {
    testWidgets('a second wave after a long pause', (tester) async {
      await tester.pumpApp(const Center(child: AurudoWaveAnimation(size: 140)));
      await _peak(tester, AurudoWaveAnimation.handGroupKey, 2.sec);
      // Nothing for a good while...
      final quiet = await _peak(
        tester,
        AurudoWaveAnimation.handGroupKey,
        WaveTimeline.minPause - 3.sec,
      );
      expect(quiet, lessThan(0.01));
      // ...then one more.
      final again = await _peak(
        tester,
        AurudoWaveAnimation.handGroupKey,
        (WaveTimeline.maxPause - WaveTimeline.minPause) + 5.sec,
      );
      expect(again, greaterThan(2));
      await tester.pumpWidget(const SizedBox());
    });
  });
}

extension on int {
  Duration get sec => Duration(seconds: this);
  Duration get ms => Duration(milliseconds: this);
}
