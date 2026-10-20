import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/shared/widgets/aura/aurudo_idle.dart';

void main() {
  // The suite runs with the drift off (test/flutter_test_config.dart);
  // these are the tests that exist to check it, so they switch it on.
  setUp(() => AurudoIdle.debugEnabled = true);
  tearDown(() => AurudoIdle.debugEnabled = false);

  Widget host({bool reducedMotion = false, IdleChoreography? score}) =>
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reducedMotion),
          child: Scaffold(
            body: Center(
              child: AurudoIdle(
                choreography: score ?? _TestClockChoreography(),
                child: const SizedBox.square(dimension: 140, key: _mascot),
              ),
            ),
          ),
        ),
      );

  Matrix4? matrixOf(WidgetTester tester) {
    final found = find.ancestor(
      of: find.byKey(_mascot),
      matching: find.byType(Transform),
    );
    if (found.evaluate().isEmpty) return null;
    return tester.widget<Transform>(found.first).transform;
  }

  testWidgets('drifts, and keeps drifting', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 500));
    final start = matrixOf(tester);
    expect(start, isNotNull);

    await tester.pump(const Duration(seconds: 2));
    final meio = matrixOf(tester);
    expect(meio, isNot(start));

    // Still moving once the first gesture has come and gone (the first one
    // starts 3.5-6s in). How it keeps going for minutes is a property of the
    // choreography, proved as pure logic below -- not by pumping minutes of
    // frames here.
    await tester.pump(const Duration(seconds: 8));
    await tester.pump(const Duration(milliseconds: 700));
    expect(matrixOf(tester), isNot(meio));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('leaves no ticker behind when it goes away', (tester) async {
    await tester.pumpWidget(host());
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.binding.transientCallbackCount, greaterThan(0));

    await tester.pumpWidget(const SizedBox());
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion leaves him still', (tester) async {
    await tester.pumpWidget(host(reducedMotion: true));
    expect(matrixOf(tester), isNull);
    await tester.pumpAndSettle();
  });

  testWidgets('switched off, nothing moves and settling works', (tester) async {
    AurudoIdle.debugEnabled = false;
    await tester.pumpWidget(host());
    expect(matrixOf(tester), isNull);
    // Would time out against a running loop -- that is what the suite-wide
    // switch buys the other tests.
    await tester.pumpAndSettle();
  });

  testWidgets('two of them on screen move as one', (tester) async {
    final score = _TestClockChoreography(seed: 3);
    await tester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            AurudoIdle(
              choreography: score,
              child: const SizedBox.square(dimension: 140, key: _mascot),
            ),
            AurudoIdle(
              choreography: score,
              child: const SizedBox.square(dimension: 140, key: _other),
            ),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 7));
    await tester.pump(const Duration(milliseconds: 400));
    Matrix4 of(Key k) => tester
        .widget<Transform>(
          find
              .ancestor(of: find.byKey(k), matching: find.byType(Transform))
              .first,
        )
        .transform;
    expect(of(_mascot), of(_other));
    await tester.pumpWidget(const SizedBox());
  });

  group('IdleChoreography', () {
    test('the same seed tells the same story, another seed another', () {
      List<double> story(int seed) {
        final c = IdleChoreography(seed: seed);
        return [
          for (var s = 0; s < 120; s++)
            c.sample(Duration(milliseconds: s * 500)).angle,
        ];
      }

      expect(story(5), story(5));
      expect(story(5), isNot(story(6)));
    });

    test('begins at rest and leaves him time to settle', () {
      final c = IdleChoreography();
      for (var ms = 0; ms < IdleChoreography.firstGestureMs; ms += 100) {
        final p = c.sample(Duration(milliseconds: ms));
        expect(p.angle, 0);
        expect(p.lift, 0);
        expect(p.inhale, 0);
      }
    });

    test('gestures are small, spaced by pauses and never repeat on a beat', () {
      final c = IdleChoreography();
      final starts = <int>[];
      var wasMoving = false;
      var maxLean = 0.0;
      for (var ms = 0; ms < 10 * 60 * 1000; ms += 20) {
        final p = c.sample(Duration(milliseconds: ms));
        maxLean = maxLean < p.angle.abs() ? p.angle.abs() : maxLean;
        final moving = p.angle != 0 || p.inhale != 0;
        if (moving && !wasMoving) starts.add(ms);
        wasMoving = moving;
      }
      // Attentive, not a head turn: under 2 degrees.
      expect(maxLean, lessThan(0.035));
      expect(maxLean, greaterThan(0.012));
      // Pauses between the starts are never all alike and never frantic.
      final gaps = [
        for (var i = 1; i < starts.length; i++) starts[i] - starts[i - 1],
      ];
      expect(gaps.length, greaterThan(40));
      expect(gaps.reduce((a, b) => a < b ? a : b), greaterThan(3500));
      expect(gaps.toSet().length, greaterThan(gaps.length ~/ 2));
    });

    test('still alive minutes later: the motion has no end', () {
      final c = IdleChoreography();
      for (var minute = 1; minute <= 30; minute++) {
        final at = Duration(minutes: minute);
        final a = c.sample(at);
        final b = c.sample(at + const Duration(milliseconds: 700));
        // The continuous drift alone moves him between two nearby instants.
        expect(
          a.bob != b.bob || a.breath != b.breath || a.sway != b.sway,
          isTrue,
          reason: 'frozen at minute $minute',
        );
      }
    });

    test('a gesture comes round again and again, never a long silence', () {
      final c = IdleChoreography();
      var last = 0;
      var longest = 0;
      var gestures = 0;
      var wasMoving = false;
      for (var ms = 0; ms < 60 * 60 * 1000; ms += 50) {
        final p = c.sample(Duration(milliseconds: ms));
        final moving = p.angle != 0 || p.inhale != 0;
        if (moving && !wasMoving) {
          gestures++;
          if (ms - last > longest) longest = ms - last;
          last = ms;
        }
        wasMoving = moving;
      }
      expect(gestures, greaterThan(300));
      // Mostly 3-8s of quiet, now and then a longer one -- never half a minute.
      expect(longest, lessThan(25000));
    });

    test('the shape starts and ends at exactly zero and stays gentle', () {
      expect(IdleChoreography.shape(0), 0);
      expect(IdleChoreography.shape(1).abs(), lessThan(1e-12));
      for (var i = 0; i <= 1000; i++) {
        expect(IdleChoreography.shape(i / 1000).abs(), lessThan(1.1));
      }
      // A hint of anticipation: it first moves the other way.
      expect(IdleChoreography.shape(0.06), lessThan(0));
    });

    test('the continuous drift is smooth: no frame-to-frame jump', () {
      final c = IdleChoreography();
      var prev = c.sample(Duration.zero);
      for (var ms = 16; ms < 120000; ms += 16) {
        final p = c.sample(Duration(milliseconds: ms));
        expect((p.angle - prev.angle).abs(), lessThan(0.0015));
        expect((p.bob - prev.bob).abs(), lessThan(0.04));
        expect((p.breath - prev.breath).abs(), lessThan(0.04));
        prev = p;
      }
    });
  });
}

const _mascot = Key('mascot');
const _other = Key('other');

/// The widget-test clock starts at 2015-01-01 (1 420 070 400 000 ms), so the
/// first frame hands the choreography a time 1.4 trillion milliseconds in --
/// and it fills its score from zero up to whatever it is asked for: tens of
/// seconds of work before the first pixel. A real device starts its frame
/// clock at boot, much closer to zero. This rebases the test clock onto the
/// same scale; the timing the widget uses is untouched.
class _TestClockChoreography extends IdleChoreography {
  _TestClockChoreography({super.seed});

  static const _epoch = Duration(milliseconds: 1420070400000);

  @override
  IdlePose sample(Duration at) => super.sample(at >= _epoch ? at - _epoch : at);
}
