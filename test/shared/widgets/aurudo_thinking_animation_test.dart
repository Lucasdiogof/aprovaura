import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';
import 'package:aura/shared/widgets/aura/aurudo_thinking_animation.dart';

import '../../helpers/pump_app.dart';

Matrix4 _transform(WidgetTester tester, Key key) =>
    tester.widget<Transform>(find.byKey(key)).transform;

void main() {
  test('every thinking layer is bundled by pubspec', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final asset in ThinkingGeometry.all) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(1000), reason: asset);
    }
  });

  group(ThinkingPose, () {
    test('rests on the art before, during the preroll and after', () {
      for (final ms in [0.0, 100.0, ThinkingTimeline.preroll * 1.0]) {
        final p = ThinkingPose.at(ms);
        expect(p.angleDegrees, 0, reason: '$ms ms');
      }
      final end = ThinkingPose.at(ThinkingTimeline.total * 1.0);
      expect(end.angleDegrees, 0);
    });

    test('taps down only, never past its limit, all the way through', () {
      var most = 0.0;
      for (var ms = 0.0; ms <= ThinkingTimeline.total; ms += 5) {
        final p = ThinkingPose.at(ms);
        expect(
          p.angleDegrees,
          inInclusiveRange(0, ThinkingTimeline.maxAngleDegrees),
          reason: '$ms',
        );
        most = p.angleDegrees > most ? p.angleDegrees : most;
      }
      expect(most, greaterThan(ThinkingTimeline.maxAngleDegrees * 0.7));
    });

    test('taps a couple of times, not once and not continuously', () {
      var peaks = 0;
      var rising = true;
      var prev = 0.0;
      for (var ms = 0.0; ms <= ThinkingTimeline.total; ms += 2) {
        final a = ThinkingPose.at(ms).angleDegrees;
        if (rising && a < prev) {
          peaks++;
          rising = false;
        } else if (!rising && a > prev) {
          rising = true;
        }
        prev = a;
      }
      expect(peaks, ThinkingTimeline.tapCount);
    });
  });

  group('the thinking pose taps its chin', () {
    testWidgets('thinking uses the tap animation; other poses stay still '
        'images', (tester) async {
      await tester.pumpApp(
        const Center(child: AurudoIllustration(pose: AurudoPose.thinking)),
      );
      expect(find.byType(AurudoThinkingAnimation), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      for (final pose in AurudoPose.values) {
        if (pose == AurudoPose.thinking) continue;
        await tester.pumpApp(
          Center(child: AurudoIllustration(key: ValueKey(pose), pose: pose)),
        );
        expect(
          find.byType(AurudoThinkingAnimation),
          findsNothing,
          reason: pose.name,
        );
        await tester.pump(const Duration(seconds: 1));
      }
    });

    testWidgets('reduced motion: the still image, no taps, no ticker', (
      tester,
    ) async {
      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Center(child: AurudoIllustration(pose: AurudoPose.thinking)),
        ),
      );
      expect(find.byType(AurudoThinkingAnimation), findsNothing);
      expect(tester.binding.transientCallbackCount, 0);
    });
  });

  group(AurudoThinkingAnimation, () {
    testWidgets('taps a couple of times, lands on the art, leaves no '
        'ticker', (tester) async {
      await tester.pumpApp(
        const Center(child: AurudoThinkingAnimation(size: 160)),
      );
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      await tester.pump(
        const Duration(
          milliseconds:
              ThinkingTimeline.preroll + ThinkingTimeline.tapDuration ~/ 4,
        ),
      );
      expect(
        _transform(tester, AurudoThinkingAnimation.handGroupKey).isIdentity(),
        isFalse,
      );
      await tester.pump(const Duration(seconds: 2));
      expect(
        _transform(tester, AurudoThinkingAnimation.handGroupKey).isIdentity(),
        isTrue,
      );
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('instant: the art at once, no ticker', (tester) async {
      await tester.pumpApp(
        const Center(child: AurudoThinkingAnimation(size: 160, instant: true)),
      );
      expect(
        _transform(tester, AurudoThinkingAnimation.handGroupKey).isIdentity(),
        isTrue,
      );
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('unmounting mid-tap throws nothing', (tester) async {
      await tester.pumpApp(
        const Center(child: AurudoThinkingAnimation(size: 160)),
      );
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpApp(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('a missing layer falls back to the still image', (
      tester,
    ) async {
      await tester.pumpApp(
        const Center(
          child: AurudoThinkingAnimation(
            size: 160,
            assets: [
              'lib/assets/mascot/thinking_tap/missing.webp',
              ThinkingGeometry.base,
              ThinkingGeometry.hand,
            ],
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump(const Duration(seconds: 2));
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(images, hasLength(1));
      expect(
        (images.single.image as AssetImage).assetName,
        AurudoThinkingAnimation.stillAsset,
      );
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
                child: AurudoIllustration(pose: AurudoPose.thinking),
              ),
            ),
          ),
        );
        for (var t = 0; t < 20; t++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(tester.takeException(), isNull);
        expect(find.byType(AurudoThinkingAnimation), findsOneWidget);
      });
    }
  });
}
