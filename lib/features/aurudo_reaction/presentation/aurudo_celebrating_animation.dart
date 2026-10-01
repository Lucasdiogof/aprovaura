import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

/// Where everything sits in the celebrating art, as fractions of its canvas.
///
/// The layers are the approved cut-out kit (aprovaura-brand/
/// aurudo-animation-kit/celebrating), cropped to the same box the static
/// `aurudo_celebrating.webp` fills, so the animated Aurudo occupies the same
/// space as the still one at every size. Only these fractions are used --
/// never screen pixels -- so the motion scales with the mascot.
abstract final class CelebratingGeometry {
  /// Width / height of the canvas (780 × 773 in the source).
  static const aspect = 780 / 773;

  /// Width the layers are exported at; nothing is ever decoded larger.
  static const sourceWidth = 780;

  /// The hidden shoulder the raised (right) arm turns about.
  static const armPivot = Offset(0.325, 0.455);

  static const particles =
      'lib/assets/mascot/celebrating/aurudo_celebrating_particles.webp';
  static const base = 'lib/assets/mascot/celebrating/aurudo_celebrating_base.webp';
  static const rightArm =
      'lib/assets/mascot/celebrating/aurudo_celebrating_right_arm.webp';

  /// Paint order, back to front: nothing passes in front of the arm here,
  /// unlike farm-Aura's helmet rim -- the cut falls on open background/ring,
  /// never on the head.
  static const all = [particles, base, rightArm];
}

/// The celebrating timeline: a couple of clear pumps of the raised fist,
/// fitted inside the reaction scene the same way farm-Aura's pulls are.
/// Plays once; never loops. No orb, no particle pull -- the burst behind
/// the mascot is [AuraParticlesStyle.burst], drawn separately by
/// `AurudoReactionStage`.
abstract final class CelebratingTimeline {
  /// Same entrance as the still mascot: fade + [entranceScaleFrom] -> 1.
  static const entranceDuration = 350;
  static const entranceScaleFrom = 0.92;

  /// A beat of stillness before the first pump.
  static const preroll = 100;
  static const pumpCycleDuration = 760;
  static const cycles = 2;
  static const total = preroll + pumpCycleDuration * cycles; // 1620 ms

  /// Where in each pump the top sits.
  static const peakAt = 0.45;

  /// Further up/inward only: the pose in the art is the lowest point of the
  /// pump, same rule as farm-Aura's arm.
  static const maxArmAngleDegrees = 6.0;

  /// Lift at the top of a pump per logical pixel of mascot.
  static const liftPerSize = 1 / 160;

  /// (pump index, phase 0..1) while pumping; null before and after.
  static (int, double)? pumpAt(double ms) {
    final t = ms - preroll;
    if (t < 0 || t >= pumpCycleDuration * cycles) return null;
    return (t ~/ pumpCycleDuration, (t % pumpCycleDuration) / pumpCycleDuration);
  }

  /// 0 at rest, 1 at the top of a pump; smooth both ways, no bounce.
  static double energyAt(double ms) {
    final pump = pumpAt(ms);
    if (pump == null) return 0;
    final p = pump.$2;
    return p <= peakAt
        ? Curves.easeInOutCubic.transform(p / peakAt)
        : Curves.easeInOutCubic.transform(1 - (p - peakAt) / (1 - peakAt));
  }

  /// Milliseconds from the start to the top of pump [index].
  static double peakMs(int index) =>
      preroll + pumpCycleDuration * (index + peakAt);
}

/// The pose at one instant, before it is placed on screen. At rest (before,
/// between and after the pumps, and always under reduced motion) it is
/// exactly the art: 0°, no lift.
@immutable
class CelebratingPose {
  const CelebratingPose._(this.energy);

  factory CelebratingPose.at(double elapsedMs) =>
      CelebratingPose._(CelebratingTimeline.energyAt(elapsedMs));

  static const rest = CelebratingPose._(0);

  final double energy;

  /// The arm's turn about [CelebratingGeometry.armPivot]; positive is
  /// further up/inward (clockwise on screen for this, the character's right,
  /// arm -- mirrored from farm-Aura's left arm, where inward is negative).
  double get armAngleDegrees => CelebratingTimeline.maxArmAngleDegrees * energy;
  double liftFor(double size) => size * CelebratingTimeline.liftPerSize * energy;
}

/// Aurudo celebrating: the `great` / `levelUp` / `streakMilestone` / essay
/// `excellent`-`great` reactions.
///
/// The body, legs and resting (left) arm stay still. The raised right arm
/// pumps further up/inward about the hidden shoulder and back, twice, then
/// settles on the exact base pose -- never outward, the pose in the art is
/// already the lowest point. One [AnimationController] drives it.
///
/// [instant] (or the platform's reduced motion) shows that final pose
/// straight away: no entrance, no ticker. If any layer fails to load, the
/// still `celebrating` illustration stands in.
class AurudoCelebratingAnimation extends StatefulWidget {
  const AurudoCelebratingAnimation({
    required this.size,
    this.instant = false,
    @visibleForTesting this.assets = CelebratingGeometry.all,
    super.key,
  });

  final double size;
  final bool instant;

  /// Particles, base and arm layers, in that order.
  final List<String> assets;

  /// Key on the moving arm group, so tests can read its transform.
  @visibleForTesting
  static const armGroupKey = ValueKey('celebrating-arm-group');

  @override
  State<AurudoCelebratingAnimation> createState() =>
      _AurudoCelebratingAnimationState();
}

class _AurudoCelebratingAnimationState
    extends State<AurudoCelebratingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: CelebratingTimeline.total),
  );
  bool _failed = false;
  bool _precached = false;

  bool get _still => widget.instant || MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      for (final image in _layersFor(context, widget.size, widget.assets)) {
        precacheImage(
          image,
          context,
          onError: (_, _) {
            if (mounted && !_failed) setState(() => _failed = true);
          },
        );
      }
    }
    if (_still) {
      _clock.value = 1;
    } else if (!_clock.isAnimating && _clock.value == 0) {
      _clock.forward();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return AurudoIllustration(
        pose: AurudoPose.celebrating,
        size: widget.size,
        animate: !_still,
      );
    }
    final still = _still;
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _clock,
          builder: (context, _) => _CelebratingFrame(
            size: widget.size,
            elapsedMs: _clock.value * CelebratingTimeline.total,
            assets: widget.assets,
            still: still,
          ),
        ),
      ),
    );
  }
}

/// The layers decoded at the width they are drawn, never at full size.
List<ImageProvider> _layersFor(
  BuildContext context,
  double size,
  List<String> assets,
) {
  final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2;
  final decodeWidth = (size * CelebratingGeometry.aspect * dpr).round().clamp(
    64,
    CelebratingGeometry.sourceWidth,
  );
  return [
    for (final asset in assets)
      ResizeImage(AssetImage(asset), width: decodeWidth),
  ];
}

class _CelebratingFrame extends StatelessWidget {
  const _CelebratingFrame({
    required this.size,
    required this.elapsedMs,
    required this.assets,
    required this.still,
  });

  final double size;
  final double elapsedMs;
  final List<String> assets;
  final bool still;

  @override
  Widget build(BuildContext context) {
    final height = size;
    final width = size * CelebratingGeometry.aspect;
    final left = (size - width) / 2;
    Offset at(Offset f) => Offset(left + f.dx * width, f.dy * height);

    final pose = still ? CelebratingPose.rest : CelebratingPose.at(elapsedMs);
    // Further up/inward is clockwise on screen for this (right) arm --
    // mirrored from farm-Aura's left arm, where inward is counter-clockwise
    // (negative). Positive here, unlike there.
    final armAngle = pose.armAngleDegrees * math.pi / 180;
    final lift = pose.liftFor(size);
    final pivot = at(CelebratingGeometry.armPivot);

    Matrix4 about(Offset o, Matrix4 m) =>
        Matrix4.translationValues(o.dx, o.dy, 0)
          ..multiply(m)
          ..multiply(Matrix4.translationValues(-o.dx, -o.dy, 0));

    final group = Matrix4.translationValues(0, -lift, 0)
      ..multiply(about(pivot, Matrix4.rotationZ(armAngle)));
    final images = _layersFor(context, size, assets);

    Widget layer(int i) => Positioned(
      left: left,
      top: 0,
      width: width,
      height: height,
      child: Image(
        image: images[i],
        fit: BoxFit.fill,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
      ),
    );

    final entranceT = still
        ? 1.0
        : Curves.easeOutCubic.transform(
            (elapsedMs / CelebratingTimeline.entranceDuration).clamp(0.0, 1.0),
          );
    const scaleFrom = CelebratingTimeline.entranceScaleFrom;

    return SizedBox.square(
      dimension: size,
      child: Opacity(
        opacity: entranceT,
        child: Transform.scale(
          scale: scaleFrom + (1 - scaleFrom) * entranceT,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              layer(0), // particles
              layer(1), // base body (legs, resting arm, rings, head)
              Positioned.fill(
                child: Transform(
                  key: AurudoCelebratingAnimation.armGroupKey,
                  transform: group,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [layer(2)], // raised right arm
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
