import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Where everything sits in the waving art, as fractions of its layer canvas.
///
/// The layers are the approved cut-out kit (aprovaura-brand/
/// aurudo-animation-kit/neutral-wave), cropped to the same box the still
/// `aurudo_neutral.webp` fills -- plus a margin on the right, so the hand
/// never leaves the image while it waves. Only these fractions are used,
/// never screen pixels, so the motion scales with the mascot.
abstract final class WaveGeometry {
  /// Width / height of the layer canvas (1181 × 1150 in the source).
  static const aspect = 1181 / 1150;

  /// Width of the still pose's own box, as a fraction of the height: the
  /// layers line up with the still image when this part is centred.
  static const stillAspect = 1120 / 1150;

  /// Width the layers are exported at; nothing is ever decoded larger.
  static const sourceWidth = 822;

  /// The hidden shoulder (behind the backpack strap) the arm turns about.
  static const shoulder = Offset(753 / 1181, 691 / 1150);

  /// The middle of the wrist band the hand turns about.
  static const wrist = Offset(939 / 1181, 615 / 1150);

  static const base =
      'lib/assets/mascot/neutral_wave/aurudo_neutral_wave_base.webp';
  static const forearm =
      'lib/assets/mascot/neutral_wave/aurudo_neutral_wave_forearm.webp';
  static const hand =
      'lib/assets/mascot/neutral_wave/aurudo_neutral_wave_hand.webp';
  static const cuff =
      'lib/assets/mascot/neutral_wave/aurudo_neutral_wave_cuff.webp';
  static const strap =
      'lib/assets/mascot/neutral_wave/aurudo_neutral_wave_strap.webp';

  /// Paint order, back to front: the wrist band passes in front of the
  /// hand, and the backpack strap in front of the arm's root -- both hide
  /// a joint, like farm-Aura's helmet rim.
  static const all = [base, forearm, hand, cuff, strap];
}

/// The wave: after the entrance, the hand swings to and fro twice at the
/// wrist while the arm opens a little at the shoulder and comes back. Plays
/// once; never loops.
abstract final class WaveTimeline {
  /// Same entrance as the still mascot: fade + [entranceScaleFrom] -> 1.
  static const entranceDuration = 350;
  static const entranceScaleFrom = 0.92;

  /// He arrives, then waves.
  static const preroll = 300;
  static const waveDuration = 1200;
  static const total = preroll + waveDuration; // 1500 ms

  /// The hand's swing either way at the wrist. The cut-out holds up to
  /// about this much; past it the joint starts to show.
  static const maxHandDegrees = 8.0;
  static const handCycles = 2;

  /// The arm only opens outward (away from the head -- inward, the index
  /// finger would run into the helmet), and only a little: the wave is in
  /// the hand.
  static const maxArmDegrees = 3.0;

  /// 0..1 through the wave, or null before it starts / after it ends.
  static double? progressAt(double ms) {
    final t = ms - preroll;
    if (t <= 0 || t >= waveDuration) return null;
    return t / waveDuration;
  }
}

/// The pose at one instant, before it is placed on screen. At rest (before
/// and after the wave, and always under reduced motion) it is exactly the
/// art: 0° and 0°.
@immutable
class WavePose {
  const WavePose._(this.armDegrees, this.handDegrees);

  factory WavePose.at(double elapsedMs) {
    final p = WaveTimeline.progressAt(elapsedMs);
    if (p == null) return rest;
    // One smooth swell over the whole wave: both motions start and end at
    // exactly 0, so the pose lands on the art with no jump.
    final envelope = math.sin(math.pi * p);
    return WavePose._(
      WaveTimeline.maxArmDegrees * envelope,
      WaveTimeline.maxHandDegrees *
          math.sin(2 * math.pi * WaveTimeline.handCycles * p) *
          math.sqrt(envelope),
    );
  }

  static const rest = WavePose._(0, 0);

  /// The arm's turn about [WaveGeometry.shoulder]; positive is outward
  /// (clockwise on screen).
  final double armDegrees;

  /// The hand's turn about [WaveGeometry.wrist], on top of the arm's.
  final double handDegrees;
}

/// Aurudo waving hello: the still `neutral` pose, with a real wave -- the
/// hand swings at the wrist, the arm opens a touch at the shoulder. The
/// body, head and the other arm stay still.
///
/// [instant] (or the platform's reduced motion) shows the art as it is: no
/// entrance, no ticker. If any layer fails to load, the still image stands
/// in.
class AurudoWaveAnimation extends StatefulWidget {
  const AurudoWaveAnimation({
    required this.size,
    this.instant = false,
    @visibleForTesting this.assets = WaveGeometry.all,
    super.key,
  });

  final double size;
  final bool instant;

  /// Base, forearm, hand, cuff and strap layers, in that order.
  final List<String> assets;

  /// The still pose this animates, used if a layer fails to load.
  static const stillAsset = 'lib/assets/mascot/aurudo_neutral.webp';

  /// Keys on the moving groups, so tests can read their transforms.
  @visibleForTesting
  static const armGroupKey = ValueKey('wave-arm-group');
  @visibleForTesting
  static const handGroupKey = ValueKey('wave-hand-group');

  @override
  State<AurudoWaveAnimation> createState() => _AurudoWaveAnimationState();
}

class _AurudoWaveAnimationState extends State<AurudoWaveAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: WaveTimeline.total),
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
          AurudoWaveAnimation.stillAsset,
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
          builder: (context, _) => _WaveFrame(
            size: widget.size,
            elapsedMs: _clock.value * WaveTimeline.total,
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
  final decodeWidth = (size * WaveGeometry.aspect * dpr).round().clamp(
    64,
    WaveGeometry.sourceWidth,
  );
  return [
    for (final asset in assets)
      ResizeImage(AssetImage(asset), width: decodeWidth),
  ];
}

class _WaveFrame extends StatelessWidget {
  const _WaveFrame({
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
    final width = size * WaveGeometry.aspect;
    // Centre the still pose's own box, exactly where the still image sits;
    // the extra margin for the hand hangs off to the right.
    final left = (size - size * WaveGeometry.stillAspect) / 2;
    Offset at(Offset f) => Offset(left + f.dx * width, f.dy * height);

    final pose = still ? WavePose.rest : WavePose.at(elapsedMs);
    Matrix4 about(Offset o, double degrees) =>
        Matrix4.translationValues(o.dx, o.dy, 0)
          ..multiply(Matrix4.rotationZ(degrees * math.pi / 180))
          ..multiply(Matrix4.translationValues(-o.dx, -o.dy, 0));

    final arm = about(at(WaveGeometry.shoulder), pose.armDegrees);
    final hand = arm.clone()
      ..multiply(about(at(WaveGeometry.wrist), pose.handDegrees));
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

    Widget group(Key key, Matrix4 m, int i) => Positioned.fill(
      child: Transform(
        key: key,
        transform: m,
        child: Stack(clipBehavior: Clip.none, children: [layer(i)]),
      ),
    );

    final entranceT = still
        ? 1.0
        : Curves.easeOutCubic.transform(
            (elapsedMs / WaveTimeline.entranceDuration).clamp(0.0, 1.0),
          );
    const scaleFrom = WaveTimeline.entranceScaleFrom;

    return SizedBox.square(
      dimension: size,
      child: Opacity(
        opacity: entranceT,
        child: Transform.scale(
          scale: scaleFrom + (1 - scaleFrom) * entranceT,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              layer(0), // base: everything but the waving arm
              group(AurudoWaveAnimation.armGroupKey, arm, 1), // forearm
              group(AurudoWaveAnimation.handGroupKey, hand, 2), // hand
              group(const ValueKey('wave-cuff'), arm, 3), // wrist band
              layer(4), // backpack strap, in front of the arm's root
            ],
          ),
        ),
      ),
    );
  }
}
