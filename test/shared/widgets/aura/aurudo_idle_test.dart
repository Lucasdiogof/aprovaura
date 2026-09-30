import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/shared/widgets/aura/aurudo_idle.dart';

void main() {
  // The suite runs with the drift off (test/flutter_test_config.dart);
  // these are the tests that exist to check it, so they switch it on.
  setUp(() => AurudoIdle.debugEnabled = true);
  tearDown(() => AurudoIdle.debugEnabled = false);

  Widget host({bool reducedMotion = false}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reducedMotion),
      child: const Scaffold(
        body: Center(
          child: AurudoIdle(child: SizedBox.square(dimension: 140, key: _mascot)),
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
    final start = matrixOf(tester);
    expect(start, isNotNull);

    await tester.pump(AurudoIdle.period ~/ 8);
    final meio = matrixOf(tester);
    expect(meio, isNot(start));

    // Still moving much later: the loop has no end, which is the point.
    await tester.pump(AurudoIdle.period * 3);
    await tester.pump(AurudoIdle.period ~/ 5);
    expect(matrixOf(tester), isNot(meio));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('one full period lands back where it started', (tester) async {
    await tester.pumpWidget(host());
    final start = matrixOf(tester)!;
    await tester.pump(AurudoIdle.period);
    final volta = matrixOf(tester)!;
    for (var i = 0; i < 16; i++) {
      expect(volta[i], closeTo(start[i], 1e-9), reason: 'cell $i');
    }
    await tester.pumpWidget(const SizedBox());
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
}

const _mascot = Key('mascot');
