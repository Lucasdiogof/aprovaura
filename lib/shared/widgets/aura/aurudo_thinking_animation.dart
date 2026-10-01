import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Where everything sits in the thinking art, as fractions of its layer
/// canvas.
///
/// The layers are the approved cut-out kit (aprovaura-brand/
/// aurudo-animation-kit/thinking-tap), cropped to the same box the still
/// `aurudo_thinking.webp` fills (2% padding around the real content, the
/// same trim `gerar_assets.py` already uses for the still asset). Only
/// these fractions are used, never screen pixels, so the motion scales with
/// the mascot.
abstract final class ThinkingGeometry {
  /// Width / height of the layer canvas (786 × 800 in the source).
  static const aspect = 786 / 800;

  /// Width the layers are exported at; nothing is ever decoded larger.
  static const sourceWidth = 786;

  /// The wrist seam the hand turns about, tapping the chin.
  static const wrist = Offset(435 / 786, 426 / 800);

  static const particles =
      'lib/assets/mascot/thinking_tap/aurudo_thinking_tap_particles.webp';
  static const base = 'lib/assets/mascot/thinking_tap/aurudo_thinking_tap_base.webp';
  static const hand = 'lib/assets/mascot/thinking_tap/aurudo_thinking_tap_hand.webp';

  /// Paint order, back to front.
  static const all = [particles, base, hand];
}

/// The chin taps: after the entrance, the raised hand taps the chin a
/// couple of times -- slower and gentler than the studying keyboard taps --
/// then settles exactly on the art. Plays once; never loops. The arm, head,
/// orbit ring, bubbles and question mark all stay still: see the kit's
/// README for why (white on white, the ring crosses the helmet).
abstract final class ThinkingTimeline {
  /// Same entrance as the still mascot: fade + [entranceScaleFrom] -> 1.
  static const entranceDuration = 350;
  static const entranceScaleFrom = 0.92;

  /// He arrives, then taps his chin, unhurried.
  static const preroll = 250;
  static const tapDuration = 1400;
  static const total = preroll + tapDuration; // 1650 ms

  /// How many gentle dips the hand makes over [tapDuration].
  static const tapCount = 2;

  /// The hand's dip at the wrist. The cut-out holds up to about this much;
  /// tested clean to 9 degrees, this keeps a safety margin.
  static const maxAngleDegrees = 8.0;

  /// 0..1 through the tap sequence, or null before it starts / after it ends.
  static double? progressAt(double ms) {
    final t = ms - preroll;
    if (t <= 0 || t >= tapDuration) return null;
    return t / tapDuration;
  }
}

/// The pose at one instant, before it is placed on screen. At rest (before
/// and after the taps, and always under reduced motion) it is exactly the
/// art: 0 degrees.
@immutable
class ThinkingPose {
  const ThinkingPose._(this.k);

  factory ThinkingPose.at(double elapsedMs) {
    final p = ThinkingTimeline.progressAt(elapsedMs);
    if (p == null) return rest;
    // One smooth swell over the whole sequence (starts and ends at exactly
    // 0), rectified so only the downward half of each cycle shows: gentle
    // taps, not a full swing.
    final envelope = math.sqrt(math.sin(math.pi * p));
    final wave = math.sin(2 * math.pi * ThinkingTimeline.tapCount * p);
    return ThinkingPose._((wave > 0 ? wave : 0) * envelope);
  }

  static const rest = ThinkingPose._(0);

  /// 0 at rest, 1 at the bottom of a tap.
  final double k;

  /// The hand's turn about [ThinkingGeometry.wrist]; tapping the chin is
  /// clockwise on screen (positive here).
  double get angleDegrees => ThinkingTimeline.maxAngleDegrees * k;
}

/// Aurudo thinking: taps his chin a couple of times with the raised hand,
/// then settles on the still `thinking` pose.
///
/// Everything else -- arm, head, backpack, orbit ring, bubbles, question
/// mark -- stays still: see [ThinkingGeometry]'s kit for why only the hand
/// could be cut out.
///
/// [instant] (or the platform's reduced motion) shows the art as it is: no
/// entrance, no ticker. If any layer fails to load, the still image stands
/// in.
class AurudoThinkingAnimation extends StatefulWidget {
  const AurudoThinkingAnimation({
    required this.size,
    this.instant = false,
    @visibleForTesting this.assets = ThinkingGeometry.all,
    super.key,
  });

  final double size;
  final bool instant;

  /// Particles, base and hand layers, in that order.
  final List<String> assets;

  /// The still pose this animates, used if a layer fails to load.
  static const stillAsset = 'lib/assets/mascot/aurudo_thinking.webp';

  /// Key on the moving hand group, so tests can read its transform.
  @visibleForTesting
  static const handGroupKey = ValueKey('thinking-hand-group');

  @override
  State<AurudoThinkingAnimation> createState() =>
      _AurudoThinkingAnimationState();
}

class _AurudoThinkingAnimationState extends State<AurudoThinkingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: ThinkingTimeline.total),
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
      return ExcludeSemantics(
        child: Image.asset(
          AurudoThinkingAnimation.stillAsset,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, _, _) => SizedBox.square(dimension: widget.size),
        ),
      );
    }
    final still = _still;
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _clock,
          builder: (context, _) => _ThinkingFrame(
            size: widget.size,
            elapsedMs: _clock.value * ThinkingTimeline.total,
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
  final decodeWidth = (size * ThinkingGeometry.aspect * dpr).round().clamp(
    64,
    ThinkingGeometry.sourceWidth,
  );
  return [
    for (final asset in assets)
      ResizeImage(AssetImage(asset), width: decodeWidth),
  ];
}

class _ThinkingFrame extends StatelessWidget {
  const _ThinkingFrame({
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
    final width = size * ThinkingGeometry.aspect;
    final left = (size - width) / 2;
    Offset at(Offset f) => Offset(left + f.dx * width, f.dy * height);

    final pose = still ? ThinkingPose.rest : ThinkingPose.at(elapsedMs);
    final angle = pose.angleDegrees * math.pi / 180;
    final wristPoint = at(ThinkingGeometry.wrist);

    final hand = Matrix4.translationValues(wristPoint.dx, wristPoint.dy, 0)
      ..multiply(Matrix4.rotationZ(angle))
      ..multiply(
        Matrix4.translationValues(-wristPoint.dx, -wristPoint.dy, 0),
      );
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
            (elapsedMs / ThinkingTimeline.entranceDuration).clamp(0.0, 1.0),
          );
    const scaleFrom = ThinkingTimeline.entranceScaleFrom;

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
              layer(1), // base: everything but the tapping hand
              Positioned.fill(
                child: Transform(
                  key: AurudoThinkingAnimation.handGroupKey,
                  transform: hand,
                  child: Stack(clipBehavior: Clip.none, children: [layer(2)]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
