import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

import '../../helpers/pump_app.dart';

void main() {
  test('every pose points at an asset bundled by pubspec', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final pose in AurudoPose.values) {
      final data = await rootBundle.load(pose.asset);
      expect(data.lengthInBytes, greaterThan(1000), reason: pose.name);
    }
  });

  testWidgets('animates in by default', (tester) async {
    await tester.pumpApp(
      const Center(child: AurudoIllustration(pose: AurudoPose.celebrating)),
    );
    expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion: no entrance animation at all', (tester) async {
    await tester.pumpApp(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Center(child: AurudoIllustration(pose: AurudoPose.neutral)),
      ),
    );
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('is decorative for screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(
      const Center(child: AurudoIllustration(pose: AurudoPose.thinking)),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
    handle.dispose();
  });
}
