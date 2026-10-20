import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/shared/widgets/aura/aurudo_gesture_repeater.dart';
import 'package:aura/shared/widgets/aura/aurudo_idle.dart';
import 'package:aura/shared/widgets/aura/aurudo_study_animation.dart';
import 'package:aura/shared/widgets/aura/aurudo_tap_sequence.dart';
import 'package:aura/shared/widgets/aura/aurudo_thinking_animation.dart';
import 'package:aura/shared/widgets/aura/aurudo_wave_animation.dart';

import '../../../helpers/pump_app.dart';

AurudoGestureRepeater _rng(int seed) => AurudoGestureRepeater(
  minPause: Duration.zero,
  maxPause: Duration.zero,
  onFire: () {},
  seed: seed,
);

/// Signed local peaks of a sampled curve (turning points of its magnitude).
List<double> _peaks(List<double> a, {double min = 0.05}) {
  final out = <double>[];
  for (var i = 1; i < a.length - 1; i++) {
    if (a[i].abs() > min &&
        a[i].abs() >= a[i - 1].abs() &&
        a[i].abs() > a[i + 1].abs() &&
        (a[i] > 0) == (a[i] >= a[i - 1])) {
      out.add(a[i]);
    }
  }
  return out;
}

List<double> _waveHand({
  double amplitude = 1,
  double cycles = 2,
  double decay = 1,
}) => [
  for (var ms = 0.0; ms <= WaveTimeline.total; ms += 2)
    WavePose.at(
      ms,
      amplitude: amplitude,
      cycles: cycles,
      decay: decay,
    ).handDegrees,
];

void main() {
  setUp(() => AurudoIdle.debugEnabled = true);
  tearDown(() => AurudoIdle.debugEnabled = false);

  group('wave: the first hello is untouched', () {
    test('the default pose is exactly the approved curve', () {
      // The formula as it was before the replays learned to vary.
      double oldHand(double ms) {
        final p = WaveTimeline.progressAt(ms);
        if (p == null) return 0;
        final envelope = math.sin(math.pi * p);
        return WaveTimeline.maxHandDegrees *
            math.sin(2 * math.pi * WaveTimeline.handCycles * p) *
            math.sqrt(envelope);
      }

      double oldArm(double ms) {
        final p = WaveTimeline.progressAt(ms);
        if (p == null) return 0;
        return WaveTimeline.maxArmDegrees * math.sin(math.pi * p);
      }

      for (var ms = 0.0; ms <= WaveTimeline.total; ms += 7) {
        final pose = WavePose.at(ms);
        expect(pose.handDegrees, closeTo(oldHand(ms), 1e-12), reason: '$ms');
        expect(pose.armDegrees, closeTo(oldArm(ms), 1e-12), reason: '$ms');
      }
    });
  });

  group('wave replays', () {
    test('three kinds, chosen by weight (40 / 45 / 15)', () {
      WaveVariant at(double roll) => pickWeighted(WaveReplay.weights, roll);
      expect(at(0), WaveVariant.short);
      expect(at(0.399), WaveVariant.short);
      expect(at(0.401), WaveVariant.normal);
      expect(at(0.849), WaveVariant.normal);
      expect(at(0.851), WaveVariant.excited);
      expect(at(0.999), WaveVariant.excited);
    });

    test('each kind keeps to its own cycles, length and strength', () {
      for (final v in WaveVariant.values) {
        for (var seed = 0; seed < 60; seed++) {
          final r = WaveReplay.forVariant(_rng(seed), v);
          final d = WaveReplay.durationMsOf[v]!;
          final a = WaveReplay.amplitudeOf[v]!;
          expect(r.cycles, WaveReplay.cyclesOf[v]);
          expect(r.durationMs, inInclusiveRange(d.$1, d.$2));
          expect(r.amplitude, inInclusiveRange(a.$1, a.$2));
          expect(r.decay, inInclusiveRange(0.75, 0.85));
        }
      }
      expect(WaveReplay.cyclesOf.values.toSet(), {1.5, 2.0, 2.5});
    });

    test('known seeds reach every kind, and a seed always tells the same', () {
      final seen = <WaveVariant>{};
      for (var seed = 0; seed < 200; seed++) {
        final a = WaveReplay.draw(_rng(seed));
        final b = WaveReplay.draw(_rng(seed));
        expect(a.variant, b.variant);
        expect(a.durationMs, b.durationMs);
        expect(a.amplitude, b.amplitude);
        seen.add(a.variant);
      }
      expect(seen, WaveVariant.values.toSet());
    });

    test(
      'the number of swings follows the kind: 3, 4 or 5 turns of the hand',
      () {
        expect(_peaks(_waveHand(cycles: 1.5)).length, 3);
        expect(_peaks(_waveHand(cycles: 2)).length, 4);
        expect(_peaks(_waveHand(cycles: 2.5)).length, 5);
      },
    );

    test('lands on the art: rest at both ends, whatever the kind', () {
      for (final c in [1.5, 2.0, 2.5]) {
        final hand = _waveHand(cycles: c, decay: 0.8);
        expect(hand.first, 0);
        expect(hand.last.abs(), lessThan(1e-9));
        expect(
          hand.map((e) => e.abs()).reduce(math.max),
          lessThanOrEqualTo(8.0),
        );
      }
    });

    test('the last swing is weaker than the first, by the chosen decay', () {
      for (final c in [1.5, 2.0, 2.5]) {
        for (final decay in [0.75, 0.8, 0.85]) {
          final peaks = _peaks(_waveHand(cycles: c, decay: decay));
          final ratio = peaks.last.abs() / peaks.first.abs();
          expect(ratio, closeTo(decay, 0.06), reason: 'c=$c decay=$decay');
          expect(peaks.last.abs(), lessThan(peaks.first.abs()));
        }
      }
      // No decay: the swings keep an even strength, as the first hello does.
      final even = _peaks(_waveHand());
      expect(even.last.abs() / even.first.abs(), closeTo(1, 0.03));
    });

    test('a replay is not the first hello with a different size', () {
      final first = _peaks(_waveHand()).map((e) => e.abs()).toList();
      final excited = _peaks(
        _waveHand(cycles: 2.5, decay: 0.8),
      ).map((e) => e.abs()).toList();
      expect(excited.length, isNot(first.length));
    });
  });

  group('thinking replays', () {
    test('one tap, two or three, chosen by weight (30 / 55 / 15)', () {
      int at(double roll) => pickWeighted(ThinkingBurst.countWeights, roll);
      expect(at(0), 1);
      expect(at(0.299), 1);
      expect(at(0.301), 2);
      expect(at(0.849), 2);
      expect(at(0.851), 3);
      expect(at(0.999), 3);
    });

    test(
      'known seeds reach 1, 2 and 3 taps, and a seed always tells the same',
      () {
        final counts = <int>{};
        for (var seed = 0; seed < 200; seed++) {
          final a = ThinkingBurst.draw(_rng(seed));
          final b = ThinkingBurst.draw(_rng(seed));
          expect(a.count, b.count);
          expect(a.beats, b.beats);
          expect(a.durationMs, b.durationMs);
          counts.add(a.count);
        }
        expect(counts, {1, 2, 3});
      },
    );

    test('the gaps are human and never a fixed beat', () {
      final firstGaps = <double>{};
      for (var seed = 0; seed < 80; seed++) {
        final s = ThinkingBurst.build(_rng(seed), 3);
        final gaps = [s.beats[1] - s.beats[0], s.beats[2] - s.beats[1]];
        expect(gaps[0], inInclusiveRange(550, 700));
        expect(gaps[1], inInclusiveRange(450, 600));
        firstGaps.add(gaps[0].roundToDouble());
      }
      expect(firstGaps.length, greaterThan(40));
    });

    test('each tap goes down in 100-150 ms and comes back in 180-260', () {
      for (var seed = 0; seed < 80; seed++) {
        for (final t in ThinkingBurst.build(_rng(seed), 3).taps) {
          expect(t.downMs, inInclusiveRange(100, 150));
          expect(t.upMs, inInclusiveRange(180, 260));
          expect(t.downMs, lessThan(t.upMs));
        }
      }
    });

    test('the whole thing lasts what a "hmm... hmm" lasts', () {
      for (var seed = 0; seed < 80; seed++) {
        expect(
          ThinkingBurst.build(_rng(seed), 1).durationMs,
          inInclusiveRange(520, 820),
        );
        expect(
          ThinkingBurst.build(_rng(seed), 2).durationMs,
          inInclusiveRange(1050, 1520),
        );
        expect(
          ThinkingBurst.build(_rng(seed), 3).durationMs,
          inInclusiveRange(1500, 2120),
        );
      }
    });

    test(
      'the last tap is about 10% lighter than the first, when there are two or more',
      () {
        for (var seed = 0; seed < 40; seed++) {
          final two = ThinkingBurst.build(_rng(seed), 2).taps;
          expect(two.last.amplitude, closeTo(two.first.amplitude * 0.9, 1e-12));
          final three = ThinkingBurst.build(_rng(seed), 3).taps;
          expect(
            three.last.amplitude,
            closeTo(three.first.amplitude * 0.9, 1e-12),
          );
          expect(
            three[1].amplitude,
            closeTo(three.first.amplitude * 0.95, 1e-12),
          );
          final one = ThinkingBurst.build(_rng(seed), 1).taps;
          expect(one.single.amplitude, inInclusiveRange(0.7, 1.0));
        }
      },
    );

    test('settles on the art', () {
      final s = ThinkingBurst.draw(_rng(3));
      expect(s.k(0), 0);
      expect(s.k(s.durationMs), 0);
      final peak = [
        for (var ms = 0.0; ms < s.durationMs; ms++) s.k(ms),
      ].reduce(math.max);
      expect(
        peak * ThinkingTimeline.maxAngleDegrees,
        lessThanOrEqualTo(ThinkingTimeline.maxAngleDegrees),
      );
    });
  });

  group('study replays', () {
    test('two to five keys, never one click and never six', () {
      final counts = <int>{};
      for (var seed = 0; seed < 300; seed++) {
        final s = StudyBurst.draw(_rng(seed));
        expect(s.count, inInclusiveRange(2, 5));
        counts.add(s.count);
      }
      expect(counts, {2, 3, 4, 5});
    });

    test('the count follows its weights', () {
      int at(double roll) => pickWeighted(StudyBurst.countWeights, roll);
      expect(at(0), 2);
      expect(at(0.219), 2);
      expect(at(0.221), 3);
      expect(at(0.549), 3);
      expect(at(0.551), 4);
      expect(at(0.849), 4);
      expect(at(0.851), 5);
    });

    test('the gaps wander around 220-320 ms instead of keeping a beat', () {
      final distinct = <double>{};
      for (var seed = 0; seed < 80; seed++) {
        final s = StudyBurst.build(_rng(seed), 5);
        if (s.pauseAfterTap != null) continue;
        final gaps = [
          for (var i = 1; i < s.beats.length; i++) s.beats[i] - s.beats[i - 1],
        ];
        for (final g in gaps) {
          expect(g, inInclusiveRange(220 * 0.85, 320 * 1.15));
          distinct.add(g.roundToDouble());
        }
        // Not one gap repeated: within one burst they differ.
        expect(gaps.toSet().length, gaps.length);
      }
      expect(distinct.length, greaterThan(100));
    });

    test('some bursts stop for an instant in the middle, others never do', () {
      var withPause = 0;
      var without = 0;
      for (var seed = 0; seed < 200; seed++) {
        final s = StudyBurst.build(_rng(seed), 4);
        final after = s.pauseAfterTap;
        if (after == null) {
          without++;
          expect(s.pauseMs, 0);
          continue;
        }
        withPause++;
        // In the middle only: after key 1 .. count-2 (indexes 1 and 2 of 4).
        expect(after, inInclusiveRange(1, 2));
        expect(s.pauseMs, inInclusiveRange(150, 280));
        final gap = s.beats[after + 1] - s.beats[after];
        // The usual gap plus the pause, and nothing else stretched.
        expect(gap - s.pauseMs, inInclusiveRange(220 * 0.85, 320 * 1.15));
      }
      expect(withPause, greaterThan(0));
      expect(without, greaterThan(withPause));
    });

    test(
      'a burst of two never has a pause (nothing to stop in the middle of)',
      () {
        for (var seed = 0; seed < 200; seed++) {
          expect(StudyBurst.build(_rng(seed), 2).pauseAfterTap, isNull);
        }
      },
    );

    test('every key lands a little differently, never too light', () {
      final amps = <double>{};
      for (var seed = 0; seed < 80; seed++) {
        for (final t in StudyBurst.build(_rng(seed), 4).taps) {
          expect(t.amplitude, inInclusiveRange(0.70, 1.0));
          amps.add(double.parse(t.amplitude.toStringAsFixed(3)));
        }
      }
      expect(amps.length, greaterThan(100));
    });

    test('a key never goes down while the last one is still coming back', () {
      for (var seed = 0; seed < 200; seed++) {
        final taps = StudyBurst.draw(_rng(seed)).taps;
        for (var i = 1; i < taps.length; i++) {
          expect(
            taps[i].startMs,
            greaterThanOrEqualTo(taps[i - 1].endMs - 1e-9),
          );
        }
      }
    });

    test('a seed always tells the same burst', () {
      for (var seed = 0; seed < 60; seed++) {
        final a = StudyBurst.draw(_rng(seed));
        final b = StudyBurst.draw(_rng(seed));
        expect(a.beats, b.beats);
        expect(a.durationMs, b.durationMs);
        expect(a.pauseAfterTap, b.pauseAfterTap);
      }
    });
  });

  group('on screen, a seed fixes the whole story', () {
    Future<List<double>> series(
      WidgetTester tester,
      Widget widget,
      Key key,
      Duration span,
    ) async {
      double angle() {
        final m = tester.widget<Transform>(find.byKey(key)).transform;
        return math.atan2(m[1], m[0]) * 180 / math.pi;
      }

      await tester.pumpApp(Center(child: widget));
      final out = <double>[];
      for (
        var t = Duration.zero;
        t < span;
        t += const Duration(milliseconds: 60)
      ) {
        await tester.pump(const Duration(milliseconds: 60));
        out.add(angle());
      }
      await tester.pumpWidget(const SizedBox());
      return out;
    }

    testWidgets('study: same seed, same typing; another seed, another', (
      tester,
    ) async {
      const span = Duration(seconds: 24);
      final a = await series(
        tester,
        const AurudoStudyAnimation(size: 140, seed: 7),
        AurudoStudyAnimation.handGroupKey,
        span,
      );
      final b = await series(
        tester,
        const AurudoStudyAnimation(size: 140, seed: 7),
        AurudoStudyAnimation.handGroupKey,
        span,
      );
      final c = await series(
        tester,
        const AurudoStudyAnimation(size: 140, seed: 8),
        AurudoStudyAnimation.handGroupKey,
        span,
      );
      expect(a, b);
      expect(a, isNot(c));
      // And he does keep typing after the first burst.
      expect(a.skip(60).map((e) => e.abs()).reduce(math.max), greaterThan(3));
    });

    testWidgets('thinking: a seed fixes the replays, and they keep coming', (
      tester,
    ) async {
      const span = Duration(seconds: 40);
      final a = await series(
        tester,
        const AurudoThinkingAnimation(size: 140, seed: 5),
        AurudoThinkingAnimation.handGroupKey,
        span,
      );
      final b = await series(
        tester,
        const AurudoThinkingAnimation(size: 140, seed: 5),
        AurudoThinkingAnimation.handGroupKey,
        span,
      );
      expect(a, b);
      expect(a.skip(80).map((e) => e.abs()).reduce(math.max), greaterThan(2));
    });

    testWidgets('wave: a seed fixes the replays, and they keep coming', (
      tester,
    ) async {
      const span = Duration(seconds: 70);
      final a = await series(
        tester,
        const AurudoWaveAnimation(size: 140, seed: 5),
        AurudoWaveAnimation.handGroupKey,
        span,
      );
      final b = await series(
        tester,
        const AurudoWaveAnimation(size: 140, seed: 5),
        AurudoWaveAnimation.handGroupKey,
        span,
      );
      expect(a, b);
      expect(a.skip(100).map((e) => e.abs()).reduce(math.max), greaterThan(3));
    });

    testWidgets('reduced motion arms nothing, for all three', (tester) async {
      for (final w in const <Widget>[
        AurudoWaveAnimation(size: 140),
        AurudoStudyAnimation(size: 140),
        AurudoThinkingAnimation(size: 140),
      ]) {
        await tester.pumpApp(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Center(child: w),
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpWidget(const SizedBox());
        // The framework fails the test if a timer is left pending.
      }
    });

    testWidgets('going away leaves no ticker and no timer', (tester) async {
      await tester.pumpApp(
        const Center(child: AurudoStudyAnimation(size: 140, seed: 1)),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpWidget(const SizedBox());
      expect(tester.binding.transientCallbackCount, 0);
    });
  });
}
