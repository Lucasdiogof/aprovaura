import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Where everything sits in the frustrated art, as fractions of its layer
/// canvas.
///
/// The layers are the cut-out kit (aprovaura-brand/aurudo-animation-kit/
/// frustrated), cropped to the same box the still `aurudo_frustrated.webp`
/// fills (2% padding around the real content, the same trim
/// `gerar_assets.py` already uses for the still asset). Only these
/// fractions are used, never screen pixels, so the motion scales with the
/// mascot.
abstract final class FrustratedGeometry {
  /// Width / height of the layer canvas (837 × 800 in the source).
  static const aspect = 837 / 800;

  /// Width the layers are exported at; nothing is ever decoded larger.
  static const sourceWidth = 837;

  /// The angry scribble's centre: where it swells and rocks.
  static const scribble = Offset(704 / 837, 108 / 800);

  static const sparks =
      'lib/assets/mascot/frustrated/aurudo_frustrated_sparks.webp';
  static const scribbleAsset =
      'lib/assets/mascot/frustrated/aurudo_frustrated_scribble.webp';
  static const base =
      'lib/assets/mascot/frustrated/aurudo_frustrated_base.webp';

  /// Paint order, back to front.
  static const all = [sparks, scribbleAsset, base];
}

/// The huff: the scribble above his head swells and rocks while he shakes
/// once, briefly, and the impact marks flare with him. Plays once; never
/// loops, and settles exactly on the art.
///
/// Deliberately small. This pose only ever shows up when a question list
/// failed to load — the person is already annoyed, and a mascot throwing a
/// tantrum on the error screen would be the app joining in. The scribble
/// carries the feeling; the body barely moves.
abstract final class FrustratedTimeline {
  /// Same entrance as the still mascot: fade + [entranceScaleFrom] -> 1.
  static const entranceDuration = 350;
  static const entranceScaleFrom = 0.92;

  /// He lands, then huffs once.
  static const preroll = 250;
  static const huffDuration = 1300;
  static const total = preroll + huffDuration; // 1550 ms

  /// Swells of the scribble over [huffDuration].
  static const scribbleBeats = 2;

  /// How much bigger the scribble gets at the top of a beat.
  static const scribbleSwell = 0.09;

  /// How far the scribble rocks, in degrees.
  static const scribbleRockDegrees = 3.5;

  /// The body's shake, as a fraction of the art's width. Four quick
  /// shivers that die out -- a huff, not a seizure.
  static const bodyShake = 0.007;
  static const bodyShivers = 4;

  /// How far the impact marks dim between flares.
  static const sparksDim = 0.45;

  /// 0..1 through the huff, or null before it starts / after it ends.
  static double? progressAt(double ms) {
    final t = ms - preroll;
    if (t <= 0 || t >= huffDuration) return null;
    return t / huffDuration;
  }
}

/// The pose at one instant, before it is placed on screen. At rest (before
/// and after the huff, and always under reduced motion) it is exactly the
/// art: nothing moved, nothing dimmed.
@immutable
class FrustratedPose {
  const FrustratedPose._(this.beats, this.envelope, this.shake);

  factory FrustratedPose.at(double elapsedMs) {
    final p = FrustratedTimeline.progressAt(elapsedMs);
    if (p == null) return rest;
    // One smooth swell over the whole sequence, so it starts and ends at
    // exactly 0 -- no jump into or out of the art.
    final envelope = math.sqrt(math.sin(math.pi * p));
    final beats = math.sin(
      2 * math.pi * FrustratedTimeline.scribbleBeats * p,
    );
    // The body's shivers are front-loaded: they fade as the huff goes on,
    // while the scribble keeps going.
    final shivers =
        math.sin(2 * math.pi * FrustratedTimeline.bodyShivers * p) *
        (1 - p) *
        (1 - p);
    return FrustratedPose._(beats, envelope, shivers);
  }

  static const rest = FrustratedPose._(0, 0, 0);

  /// -1..1 through a scribble beat. Non-zero even at rest's edges, so it
  /// is never read on its own -- always through [envelope].
  final double beats;

  /// 0 at both ends of the huff, 1 in the middle. Everything is scaled by
  /// it, which is what guarantees the pose starts and ends on the art.
  final double envelope;

  /// -1..1 of the body's shake; 0 at rest.
  final double shake;

  /// The scribble's drive: the beat, faded in and out by the envelope.
  double get k => beats * envelope;

  /// The scribble's size, 1 at rest.
  double get scribbleScale =>
      1 + FrustratedTimeline.scribbleSwell * (k > 0 ? k : 0);

  /// The scribble's rock, in degrees.
  double get scribbleAngleDegrees => FrustratedTimeline.scribbleRockDegrees * k;

  /// The body's sideways shift, as a fraction of the art's width.
  double get bodyShiftFraction => FrustratedTimeline.bodyShake * shake;

  /// The impact marks' opacity: full with the scribble at the top of a
  /// beat, dimmer between them. The dip is scaled by [envelope], so at
  /// rest -- before the huff and after it -- they sit at full strength,
  /// exactly as the art has them.
  double get sparksOpacity =>
      1 -
      FrustratedTimeline.sparksDim *
          envelope *
          (1 - (beats > 0 ? beats : 0));
}

/// Aurudo frustrated: the scribble over his head swells and rocks, the
/// impact marks flare with it, and he shakes once — then everything
/// settles on the still `frustrated` pose.
///
/// His hands and arms stay still: they are white on a white helmet, with no
/// seam to cut along (the same wall the `thinking-tap` and `studying-tap`
/// kits hit). What moves is what could be separated cleanly — the scribble
/// and the marks, which never touched the body — plus the body as a whole.
///
/// [instant] (or the platform's reduced motion) shows the art as it is: no
/// entrance, no ticker. If any layer fails to load, the still image stands
/// in.
class AurudoFrustratedAnimation extends StatefulWidget {
  const AurudoFrustratedAnimation({
    required this.size,
    this.instant = false,
    @visibleForTesting this.assets = FrustratedGeometry.all,
    super.key,
  });

  final double size;
  final bool instant;

  /// Sparks, scribble and base layers, in that order.
  final List<String> assets;

  /// The still pose this animates, used if a layer fails to load.
  static const stillAsset = 'lib/assets/mascot/aurudo_frustrated.webp';

  /// Key on the moving scribble group, so tests can read its transform.
  @visibleForTesting
  static const scribbleGroupKey = ValueKey('frustrated-scribble-group');

  /// Key on the shaking body group.
  @visibleForTesting
  static const bodyGroupKey = ValueKey('frustrated-body-group');

  @override
  State<AurudoFrustratedAnimation> createState() =>
      _AurudoFrustratedAnimationState();
}

class _AurudoFrustratedAnimationState extends State<AurudoFrustratedAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: FrustratedTimeline.total),
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
          AurudoFrustratedAnimation.stillAsset,
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
          builder: (context, _) => _FrustratedFrame(
            size: widget.size,
            elapsedMs: _clock.value * FrustratedTimeline.total,
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
  final decodeWidth = (size * FrustratedGeometry.aspect * dpr).round().clamp(
    64,
    FrustratedGeometry.sourceWidth,
  );
  return [
    for (final asset in assets)
      ResizeImage(AssetImage(asset), width: decodeWidth),
  ];
}

class _FrustratedFrame extends StatelessWidget {
  const _FrustratedFrame({
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
    final width = size * FrustratedGeometry.aspect;
    final left = (size - width) / 2;
    Offset at(Offset f) => Offset(left + f.dx * width, f.dy * height);

    final pose = still ? FrustratedPose.rest : FrustratedPose.at(elapsedMs);
    final pivot = at(FrustratedGeometry.scribble);
    final angle = pose.scribbleAngleDegrees * math.pi / 180;
    final scale = pose.scribbleScale;

    // Swell and rock share the scribble's own centre, so it never drifts
    // off the tail that ties it to his head.
    final scribble = Matrix4.translationValues(pivot.dx, pivot.dy, 0)
      ..multiply(Matrix4.rotationZ(angle))
      ..multiply(Matrix4.diagonal3Values(scale, scale, 1))
      ..multiply(Matrix4.translationValues(-pivot.dx, -pivot.dy, 0));
    final body = Matrix4.translationValues(
      pose.bodyShiftFraction * width,
      0,
      0,
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
            (elapsedMs / FrustratedTimeline.entranceDuration).clamp(0.0, 1.0),
          );
    const scaleFrom = FrustratedTimeline.entranceScaleFrom;

    return SizedBox.square(
      dimension: size,
      child: Opacity(
        opacity: entranceT,
        child: Transform.scale(
          scale: scaleFrom + (1 - scaleFrom) * entranceT,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: pose.sparksOpacity,
                  child: Stack(clipBehavior: Clip.none, children: [layer(0)]),
                ),
              ),
              Positioned.fill(
                child: Transform(
                  key: AurudoFrustratedAnimation.scribbleGroupKey,
                  transform: scribble,
                  child: Stack(clipBehavior: Clip.none, children: [layer(1)]),
                ),
              ),
              Positioned.fill(
                child: Transform(
                  key: AurudoFrustratedAnimation.bodyGroupKey,
                  transform: body,
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
