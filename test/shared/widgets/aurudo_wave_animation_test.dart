import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';
import 'package:aura/shared/widgets/aura/aurudo_wave_animation.dart';

import '../../helpers/pump_app.dart';

Matrix4 _transform(WidgetTester tester, Key key) =>
    tester.widget<Transform>(find.byKey(key)).transform;

void main() {
  test('every wave layer is bundled by pubspec', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final asset in WaveGeometry.all) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(1000), reason: asset);
    }
  });

  group(WavePose, () {
    test('rests on the art before, during the preroll and after', () {
      for (final ms in [0.0, 150.0, WaveTimeline.preroll * 1.0]) {
        final p = WavePose.at(ms);
        expect(p.armDegrees, 0, reason: '$ms ms');
        expect(p.handDegrees, 0, reason: '$ms ms');
      }
      final end = WavePose.at(WaveTimeline.total * 1.0);
      expect(end.armDegrees, 0);
      expect(end.handDegrees, 0);
    });

    test('the hand swings both ways, never past its limit', () {
      var most = 0.0, least = 0.0;
      for (var ms = 0.0; ms <= WaveTimeline.total; ms += 5) {
        final h = WavePose.at(ms).handDegrees;
        most = h > most ? h : most;
        least = h < least ? h : least;
        expect(h.abs(), lessThanOrEqualTo(WaveTimeline.maxHandDegrees));
      }
      expect(most, greaterThan(WaveTimeline.maxHandDegrees * 0.7));
      expect(least, lessThan(-WaveTimeline.maxHandDegrees * 0.7));
    });

    test('the arm only opens outward, never toward the helmet', () {
      for (var ms = 0.0; ms <= WaveTimeline.total; ms += 5) {
        final a = WavePose.at(ms).armDegrees;
        expect(a, greaterThanOrEqualTo(0), reason: '$ms ms');
        expect(a, lessThanOrEqualTo(WaveTimeline.maxArmDegrees));
      }
    });
  });

  group('the neutral pose waves', () {
    testWidgets('neutral uses the wave; other poses stay still images', (
      tester,
    ) async {
      await tester.pumpApp(
        const Center(child: AurudoIllustration(pose: AurudoPose.neutral)),
      );
      expect(find.byType(AurudoWaveAnimation), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      for (final pose in AurudoPose.values) {
        if (pose == AurudoPose.neutral) continue;
        await tester.pumpApp(
          Center(
            child: AurudoIllustration(key: ValueKey(pose), pose: pose),
          ),
        );
        expect(
          find.byType(AurudoWaveAnimation),
          findsNothing,
          reason: pose.name,
        );
        await tester.pump(const Duration(seconds: 1));
      }
    });

    testWidgets('reduced motion: the still image, no wave, no ticker', (
      tester,
    ) async {
      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Center(child: AurudoIllustration(pose: AurudoPose.neutral)),
        ),
      );
      expect(find.byType(AurudoWaveAnimation), findsNothing);
      expect(tester.binding.transientCallbackCount, 0);
    });
  });

  group(AurudoWaveAnimation, () {
    testWidgets('waves once, lands on the art, leaves no ticker', (
      tester,
    ) async {
      await tester.pumpApp(const Center(child: AurudoWaveAnimation(size: 160)));
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      // A quarter into the wave the hand is swung out.
      await tester.pump(
        const Duration(
          milliseconds: WaveTimeline.preroll + WaveTimeline.waveDuration ~/ 8,
        ),
      );
      expect(
        _transform(tester, AurudoWaveAnimation.handGroupKey).isIdentity(),
        isFalse,
      );
      await tester.pump(const Duration(seconds: 2));
      expect(
        _transform(tester, AurudoWaveAnimation.handGroupKey).isIdentity(),
        isTrue,
      );
      expect(
        _transform(tester, AurudoWaveAnimation.armGroupKey).isIdentity(),
        isTrue,
      );
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('instant: the art at once, no ticker', (tester) async {
      await tester.pumpApp(
        const Center(child: AurudoWaveAnimation(size: 160, instant: true)),
      );
      expect(
        _transform(tester, AurudoWaveAnimation.handGroupKey).isIdentity(),
        isTrue,
      );
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('unmounting mid-wave throws nothing', (tester) async {
      await tester.pumpApp(const Center(child: AurudoWaveAnimation(size: 160)));
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
          child: AurudoWaveAnimation(
            size: 160,
            assets: [
              'lib/assets/mascot/neutral_wave/missing.webp',
              WaveGeometry.forearm,
              WaveGeometry.hand,
              WaveGeometry.cuff,
              WaveGeometry.strap,
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
        AurudoWaveAnimation.stillAsset,
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
              body: Center(child: AurudoIllustration(pose: AurudoPose.neutral)),
            ),
          ),
        );
        for (var t = 0; t < 20; t++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(tester.takeException(), isNull);
        expect(find.byType(AurudoWaveAnimation), findsOneWidget);
      });
    }
  });
}
