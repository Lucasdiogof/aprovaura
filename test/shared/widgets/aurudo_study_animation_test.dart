import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';
import 'package:aura/shared/widgets/aura/aurudo_study_animation.dart';

import '../../helpers/pump_app.dart';

Matrix4 _transform(WidgetTester tester, Key key) =>
    tester.widget<Transform>(find.byKey(key)).transform;

void main() {
  test('every study layer is bundled by pubspec', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final asset in StudyGeometry.all) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(1000), reason: asset);
    }
  });

  group(StudyPose, () {
    test('rests on the art before, during the preroll and after', () {
      for (final ms in [0.0, 100.0, StudyTimeline.preroll * 1.0]) {
        final p = StudyPose.at(ms);
        expect(p.angleDegrees, 0, reason: '$ms ms');
        expect(p.pressFor(160), 0, reason: '$ms ms');
      }
      final end = StudyPose.at(StudyTimeline.total * 1.0);
      expect(end.angleDegrees, 0);
      expect(end.pressFor(160), 0);
    });

    test('dips down only, never past its limit, all the way through', () {
      var most = 0.0;
      for (var ms = 0.0; ms <= StudyTimeline.total; ms += 5) {
        final p = StudyPose.at(ms);
        expect(p.angleDegrees, inInclusiveRange(0, StudyTimeline.maxAngleDegrees), reason: '$ms');
        expect(p.pressFor(160), greaterThanOrEqualTo(0), reason: '$ms');
        most = p.angleDegrees > most ? p.angleDegrees : most;
      }
      expect(most, greaterThan(StudyTimeline.maxAngleDegrees * 0.7));
    });

    test('taps a handful of times, not once and not continuously', () {
      // Count sign changes of the velocity (peaks) across the sequence.
      var peaks = 0;
      var rising = true;
      var prev = 0.0;
      for (var ms = 0.0; ms <= StudyTimeline.total; ms += 2) {
        final a = StudyPose.at(ms).angleDegrees;
        if (rising && a < prev) {
          peaks++;
          rising = false;
        } else if (!rising && a > prev) {
          rising = true;
        }
        prev = a;
      }
      expect(peaks, StudyTimeline.tapCount);
    });
  });

  group('the studying pose taps', () {
    testWidgets('studying uses the tap animation; other poses stay still '
        'images', (tester) async {
      await tester.pumpApp(
        const Center(child: AurudoIllustration(pose: AurudoPose.studying)),
      );
      expect(find.byType(AurudoStudyAnimation), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      for (final pose in AurudoPose.values) {
        if (pose == AurudoPose.studying) continue;
        await tester.pumpApp(
          Center(child: AurudoIllustration(key: ValueKey(pose), pose: pose)),
        );
        expect(find.byType(AurudoStudyAnimation), findsNothing, reason: pose.name);
        await tester.pump(const Duration(seconds: 1));
      }
    });

    testWidgets('reduced motion: the still image, no taps, no ticker', (
      tester,
    ) async {
      await tester.pumpApp(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Center(child: AurudoIllustration(pose: AurudoPose.studying)),
        ),
      );
      expect(find.byType(AurudoStudyAnimation), findsNothing);
      expect(tester.binding.transientCallbackCount, 0);
    });
  });

  group(AurudoStudyAnimation, () {
    testWidgets('taps a few times, lands on the art, leaves no ticker', (
      tester,
    ) async {
      await tester.pumpApp(
        const Center(child: AurudoStudyAnimation(size: 160)),
      );
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      // Partway through, the hand should have moved from rest at least once.
      await tester.pump(
        const Duration(
          milliseconds: StudyTimeline.preroll + StudyTimeline.tapDuration ~/ 8,
        ),
      );
      expect(_transform(tester, AurudoStudyAnimation.handGroupKey).isIdentity(), isFalse);
      await tester.pump(const Duration(seconds: 2));
      expect(_transform(tester, AurudoStudyAnimation.handGroupKey).isIdentity(), isTrue);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('instant: the art at once, no ticker', (tester) async {
      await tester.pumpApp(
        const Center(child: AurudoStudyAnimation(size: 160, instant: true)),
      );
      expect(_transform(tester, AurudoStudyAnimation.handGroupKey).isIdentity(), isTrue);
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets('unmounting mid-tap throws nothing', (tester) async {
      await tester.pumpApp(
        const Center(child: AurudoStudyAnimation(size: 160)),
      );
      await tester.pump(const Duration(milliseconds: 600));
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
          child: AurudoStudyAnimation(
            size: 160,
            assets: [
              'lib/assets/mascot/studying_tap/missing.webp',
              StudyGeometry.hand,
              StudyGeometry.knee,
              StudyGeometry.lid,
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
        AurudoStudyAnimation.stillAsset,
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
              body: Center(child: AurudoIllustration(pose: AurudoPose.studying)),
            ),
          ),
        );
        for (var t = 0; t < 20; t++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(tester.takeException(), isNull);
        expect(find.byType(AurudoStudyAnimation), findsOneWidget);
      });
    }
  });
}
