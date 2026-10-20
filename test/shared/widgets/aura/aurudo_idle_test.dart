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
                choreography: score ?? IdleChoreography(),
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
    final score = IdleChoreography(seed: 3);
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

  testWidgets('the first frame costs the same whatever the clock reads', (
    tester,
  ) async {
    // The test clock starts in 2015: a frame timestamp 1.4 trillion ms from
    // zero. The score must not draw its way there.
    final score = IdleChoreography();
    await tester.pumpWidget(host(score: score));
    await tester.pump(const Duration(milliseconds: 500));
    expect(matrixOf(tester), isNotNull);
    // Measured from its own zero: only the first ~20s of the story is drawn.
    expect(score.debugGenerated, lessThan(8));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('one that appears later joins the same instant of the motion', (
    tester,
  ) async {
    final score = IdleChoreography(seed: 4);
    Widget two({required bool second}) => MaterialApp(
      home: Column(
        children: [
          AurudoIdle(
            choreography: score,
            child: const SizedBox.square(dimension: 140, key: _mascot),
          ),
          if (second)
            AurudoIdle(
              choreography: score,
              child: const SizedBox.square(dimension: 140, key: _other),
            ),
        ],
      ),
    );
    Matrix4 of(Key k) => tester
        .widget<Transform>(
          find
              .ancestor(of: find.byKey(k), matching: find.byType(Transform))
              .first,
        )
        .transform;

    await tester.pumpWidget(two(second: false));
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpWidget(two(second: true));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 400));
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

    test('the cost of a sample does not grow with the time asked for', () {
      for (final days in [10, 30, 365]) {
        final c = IdleChoreography();
        final p = c.sample(Duration(days: days));
        expect(p.angle.abs(), lessThan(0.035), reason: '$days days');
        // Structural, not a stopwatch: the work is bounded by the catch-up
        // window, not by how far the clock is from zero.
        expect(c.debugGenerated, lessThan(80), reason: '$days days');
        expect(c.debugStored, lessThan(80), reason: '$days days');
      }
    });

    test('a short gap is still drawn gesture by gesture, as before', () {
      final jumpy = IdleChoreography(seed: 9);
      final steady = IdleChoreography(seed: 9);
      // Under the catch-up window, jumping in one go and walking in small
      // steps tell exactly the same story.
      final end = Duration(
        milliseconds: (IdleChoreography.maxCatchUpMs - 1).round(),
      );
      for (var ms = 0; ms <= end.inMilliseconds; ms += 500) {
        steady.sample(Duration(milliseconds: ms));
      }
      for (final ms in [123456, 200000, 250001]) {
        final at = Duration(milliseconds: ms);
        expect(jumpy.sample(at).angle, steady.sample(at).angle);
      }
    });

    test('the same seed still tells the same story after a long jump', () {
      List<double> story(int seed) {
        final c = IdleChoreography(seed: seed);
        const far = Duration(days: 30);
        return [
          for (var s = 0; s < 240; s++)
            c.sample(far + Duration(milliseconds: s * 500)).angle,
        ];
      }

      expect(story(5), story(5));
      expect(story(5), isNot(story(6)));
    });

    test('gestures keep coming round after a long jump', () {
      final c = IdleChoreography();
      const far = Duration(days: 365);
      var gestures = 0;
      var wasMoving = false;
      for (var ms = 0; ms < 5 * 60 * 1000; ms += 50) {
        final p = c.sample(far + Duration(milliseconds: ms));
        final moving = p.angle != 0 || p.inhale != 0;
        if (moving && !wasMoving) gestures++;
        wasMoving = moving;
      }
      expect(gestures, greaterThan(20));
    });

    test('the first frame it sees is its zero, however late the clock is', () {
      for (final boot in [
        Duration.zero,
        const Duration(seconds: 5),
        const Duration(days: 10),
        const Duration(days: 30),
        const Duration(days: 365),
      ]) {
        final c = IdleChoreography();
        expect(c.peekLocalTime(boot), isNull, reason: 'no origin yet');
        expect(c.localTime(boot), Duration.zero, reason: '$boot');
        expect(
          c.localTime(boot + const Duration(seconds: 2)),
          const Duration(seconds: 2),
        );
        // A latecomer on the same score joins the same instant.
        expect(
          c.peekLocalTime(boot + const Duration(seconds: 7)),
          const Duration(seconds: 7),
        );
      }
    });

    test('the approved idle is unchanged: pinned samples of seed 11', () {
      // Taken from the idle as approved. Bob, breath, sway and the gestures
      // must not move when the replays around them are polished.
      const pins = <int, List<double>>{
        0: [0, 0, 0, 0, 0, 0],
        1000: [
          0.9999903274045842,
          0.9061813920525295,
          0.9055267637488259,
          0,
          0,
          0,
        ],
        3500: [
          -0.7232862171507481,
          0.6322061066139286,
          -0.7242348848827929,
          0,
          0,
          0,
        ],
        6000: [
          0.16584605274663208,
          -0.7184355816839757,
          0.43256689292325906,
          0,
          0.009026676834952304,
          1.0029640927724783,
        ],
        12000: [
          -0.9039362339548784,
          -0.6456818202933348,
          0.5394306445457229,
          0.013560948090743976,
          0.006029992169776218,
          0.40199947798508123,
        ],
        28400: [
          -0.703755794946086,
          -0.8085002778335333,
          -0.9999979492755318,
          -0.022705628886641294,
          0.006030588901118776,
          0.40203926007458507,
        ],
        90000: [
          0.04220205950809041,
          0.888132240096437,
          0.9828773566126808,
          0,
          0,
          0,
        ],
      };
      final c = IdleChoreography();
      pins.forEach((ms, v) {
        final p = c.sample(Duration(milliseconds: ms));
        final got = [p.bob, p.breath, p.sway, p.angle, p.lift, p.inhale];
        for (var i = 0; i < 6; i++) {
          expect(got[i], closeTo(v[i], 1e-12), reason: 'field $i at $ms ms');
        }
      });
      expect(IdleChoreography.firstGestureMs, 3500);
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
