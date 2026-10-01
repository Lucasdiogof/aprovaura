import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/shared/widgets/aura/aurudo_frustrated_animation.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

import '../../helpers/pump_app.dart';

Matrix4 _transform(WidgetTester tester, Key key) =>
    tester.widget<Transform>(find.byKey(key)).transform;

void main() {
  test('every frustrated layer is bundled by pubspec', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final asset in FrustratedGeometry.all) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(1000), reason: asset);
    }
  });

  group(FrustratedPose, () {
    test('rests on the art before, during the preroll and after', () {
      for (final ms in [0.0, 100.0, FrustratedTimeline.preroll * 1.0]) {
        final p = FrustratedPose.at(ms);
        expect(p.scribbleAngleDegrees, 0, reason: '$ms ms');
        expect(p.scribbleScale, 1, reason: '$ms ms');
        expect(p.bodyShiftFraction, 0, reason: '$ms ms');
        expect(p.sparksOpacity, 1, reason: '$ms ms');
      }
      final end = FrustratedPose.at(FrustratedTimeline.total * 1.0);
      expect(end.scribbleAngleDegrees, 0);
      expect(end.scribbleScale, 1);
      expect(end.bodyShiftFraction, 0);
      expect(end.sparksOpacity, 1);
    });

    test('nothing ever leaves its limits', () {
      for (var ms = 0.0; ms <= FrustratedTimeline.total; ms += 2) {
        final p = FrustratedPose.at(ms);
        expect(
          p.scribbleAngleDegrees.abs(),
          lessThanOrEqualTo(FrustratedTimeline.scribbleRockDegrees + 1e-9),
          reason: '$ms',
        );
        expect(
          p.scribbleScale,
          inInclusiveRange(1, 1 + FrustratedTimeline.scribbleSwell + 1e-9),
          reason: '$ms',
        );
        expect(
          p.bodyShiftFraction.abs(),
          lessThanOrEqualTo(FrustratedTimeline.bodyShake + 1e-9),
          reason: '$ms',
        );
        expect(
          p.sparksOpacity,
          inInclusiveRange(1 - FrustratedTimeline.sparksDim - 1e-9, 1.0),
          reason: '$ms',
        );
      }
    });

    test('the scribble swells, and more than a hair', () {
      var most = 1.0;
      for (var ms = 0.0; ms <= FrustratedTimeline.total; ms += 2) {
        final s = FrustratedPose.at(ms).scribbleScale;
        most = s > most ? s : most;
      }
      expect(
        most,
        greaterThan(1 + FrustratedTimeline.scribbleSwell * 0.7),
      );
    });

    test('the scribble beats the agreed number of times', () {
      var peaks = 0;
      var rising = true;
      var prev = 1.0;
      for (var ms = 0.0; ms <= FrustratedTimeline.total; ms += 2) {
        final s = FrustratedPose.at(ms).scribbleScale;
        if (rising && s < prev) {
          peaks++;
          rising = false;
        } else if (!rising && s > prev) {
          rising = true;
        }
        prev = s;
      }
      expect(peaks, FrustratedTimeline.scribbleBeats);
    });

    test('the body shake dies out while the scribble keeps going', () {
      // The shivers are front-loaded on purpose: a huff, not a seizure.
      double peakIn(double from, double to) {
        var most = 0.0;
        for (var ms = from; ms <= to; ms += 2) {
          final v = FrustratedPose.at(ms).bodyShiftFraction.abs();
          most = v > most ? v : most;
        }
        return most;
      }

      const start = FrustratedTimeline.preroll * 1.0;
      const end = FrustratedTimeline.total * 1.0;
      final first = peakIn(start, start + (end - start) / 3);
      final last = peakIn(end - (end - start) / 3, end);
      expect(first, greaterThan(0));
      expect(last, lessThan(first / 3));
    });
  });

  group('the frustrated pose huffs', () {
    testWidgets('frustrated uses the huff; other poses do not', (tester) async {
      await tester.pumpApp(
        const Center(child: AurudoIllustration(pose: AurudoPose.frustrated)),
      );
      expect(find.byType(AurudoFrustratedAnimation), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      for (final pose in AurudoPose.values) {
        if (pose == AurudoPose.frustrated) continue;
        await tester.pumpApp(
          Center(child: AurudoIllustration(key: ValueKey(pose), pose: pose)),
        );
        expect(
          find.byType(AurudoFrustratedAnimation),
          findsNothing,
          reason: pose.name,
        );
        await tester.pump(const Duration(seconds: 1));
      }
    });

    testWidgets('reduced motion: the still image, no huff, no ticker', (
      tester,
    ) async {
      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Center(child: AurudoIllustration(pose: AurudoPose.frustrated)),
        ),
      );
      expect(find.byType(AurudoFrustratedAnimation), findsNothing);
      expect(tester.binding.transientCallbackCount, 0);
    });
  });

  group(AurudoFrustratedAnimation, () {
    testWidgets('huffs once, lands on the art, leaves no ticker', (
      tester,
    ) async {
      await tester.pumpApp(
        const Center(child: AurudoFrustratedAnimation(size: 160)),
      );
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      await tester.pump(
        const Duration(
          milliseconds:
              FrustratedTimeline.preroll +
              FrustratedTimeline.huffDuration ~/ 4,
        ),
      );
      expect(
        _transform(
          tester,
          AurudoFrustratedAnimation.scribbleGroupKey,
        ).isIdentity(),
        isFalse,
      );
      await tester.pump(const Duration(seconds: 2));
      expect(
        _transform(
          tester,
          AurudoFrustratedAnimation.scribbleGroupKey,
        ).isIdentity(),
        isTrue,
      );
      expect(
        _transform(tester, AurudoFrustratedAnimation.bodyGroupKey).isIdentity(),
        isTrue,
      );
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('instant: the art at once, no ticker', (tester) async {
      await tester.pumpApp(
        const Center(
          child: AurudoFrustratedAnimation(size: 160, instant: true),
        ),
      );
      expect(
        _transform(
          tester,
          AurudoFrustratedAnimation.scribbleGroupKey,
        ).isIdentity(),
        isTrue,
      );
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('unmounting mid-huff throws nothing', (tester) async {
      await tester.pumpApp(
        const Center(child: AurudoFrustratedAnimation(size: 160)),
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
          child: AurudoFrustratedAnimation(
            size: 160,
            assets: [
              'lib/assets/mascot/frustrated/missing.webp',
              FrustratedGeometry.scribbleAsset,
              FrustratedGeometry.base,
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
        AurudoFrustratedAnimation.stillAsset,
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
                child: AurudoIllustration(pose: AurudoPose.frustrated),
              ),
            ),
          ),
        );
        for (var t = 0; t < 20; t++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(tester.takeException(), isNull);
        expect(find.byType(AurudoFrustratedAnimation), findsOneWidget);
      });
    }
  });
}
