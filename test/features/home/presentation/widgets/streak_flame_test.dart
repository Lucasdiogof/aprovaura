import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/home/presentation/widgets/streak_flame.dart';

void main() {
  Widget host(Widget child, {bool reducedMotion = false}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reducedMotion),
      child: Scaffold(body: Center(child: child)),
    ),
  );

  /// The flame is the icon; what moves is the [Transform] wrapped around
  /// it, so its matrix is what tells a live flame from a still one.
  Matrix4 matrixOf(WidgetTester tester) => tester
      .widget<Transform>(
        find.ancestor(
          of: find.byIcon(Icons.local_fire_department),
          matching: find.byType(Transform),
        ),
      )
      .transform;

  testWidgets('a live streak breathes', (tester) async {
    await tester.pumpWidget(host(const StreakFlame(alive: true)));
    final start = matrixOf(tester);
    await tester.pump(StreakFlame.period ~/ 4);
    expect(matrixOf(tester), isNot(start));

    // Settling would time out on a loop that never ends -- which is the
    // point of the flame -- so the test leaves it running deliberately.
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('no streak, no movement', (tester) async {
    await tester.pumpWidget(host(const StreakFlame(alive: false)));
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byIcon(Icons.local_fire_department),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion keeps the flame still', (tester) async {
    await tester.pumpWidget(
      host(const StreakFlame(alive: true), reducedMotion: true),
    );
    expect(
      find.ancestor(
        of: find.byIcon(Icons.local_fire_department),
        matching: find.byType(Transform),
      ),
      findsNothing,
    );
    await tester.pumpAndSettle();
  });
}
