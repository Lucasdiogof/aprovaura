import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:aura/shared/widgets/aura/aurudo_gesture_repeater.dart';
import 'package:aura/shared/widgets/aura/aurudo_tap_sequence.dart';

/// Where everything sits in the studying art, as fractions of its layer
/// canvas.
///
/// The layers are the approved cut-out kit (aprovaura-brand/
/// aurudo-animation-kit/studying-tap), cropped to the same box the still
/// `aurudo_studying.webp` fills (the auto-trim pipeline lands on almost the
/// same box, confirmed to a couple of pixels). Only these fractions are
/// used, never screen pixels, so the motion scales with the mascot.
abstract final class StudyGeometry {
  /// Width / height of the layer canvas (899 × 800 in the source).
  static const aspect = 899 / 800;

  /// Width the layers are exported at; nothing is ever decoded larger.
  static const sourceWidth = 899;

  /// The wrist seam the tapping hand turns about.
  static const wrist = Offset(457 / 899, 738 / 800);

  /// How far the hand sinks into the keyboard at the bottom of a tap, as a
  /// fraction of the canvas height (6px of the 1011px-tall source crop).
  static const pressFraction = 6 / 1011;

  static const base =
      'lib/assets/mascot/studying_tap/aurudo_studying_tap_base.webp';
  static const hand =
      'lib/assets/mascot/studying_tap/aurudo_studying_tap_hand.webp';
  static const knee =
      'lib/assets/mascot/studying_tap/aurudo_studying_tap_knee.webp';
  static const lid =
      'lib/assets/mascot/studying_tap/aurudo_studying_tap_lid.webp';

  /// Paint order, back to front: the knee and the laptop lid both pass in
  /// front of the hand's near corner.
  static const all = [base, hand, knee, lid];
}

/// The typing taps: after the entrance, the hand dips at the wrist a few
/// times, fingers down into the keyboard, then back to the art. After a
/// pause of uneven length he types again, a different burst each time
/// (a few taps, a long run, a lighter touch), for as long as he is on
/// screen -- see [AurudoGestureRepeater]. The arm, head, orbit ring and orb all stay still -- see the
/// kit's README for why (white on white, the ring crosses the helmet, the
/// orb sits behind the ring).
abstract final class StudyTimeline {
  /// Same entrance as the still mascot: fade + [entranceScaleFrom] -> 1.
  static const entranceDuration = 350;
  static const entranceScaleFrom = 0.92;

  /// He arrives, then types.
  static const preroll = 200;
  static const tapDuration = 1200;
  static const total = preroll + tapDuration; // 1400 ms

  /// How many short dips the hand makes over [tapDuration].
  static const tapCount = 4;

  /// The hand's dip at the wrist. The cut-out holds up to about this much;
  /// much less (6-8°) is invisible at the mascot's usual on-screen size.
  static const maxAngleDegrees = 14.0;

  /// Where a replay picks the sequence up: after the entrance, at the first
  /// tap.
  static const replayFrom = preroll / total;

  /// A replay is a short burst, then a pause: busy, not mechanical.
  static const minPause = Duration(milliseconds: 2600);
  static const maxPause = Duration(milliseconds: 6800);

  /// 0..1 through the tap sequence, or null before it starts / after it ends.
  static double? progressAt(double ms) {
    final t = ms - preroll;
    if (t <= 0 || t >= tapDuration) return null;
    return t / tapDuration;
  }
}

/// A replay of the typing: a short burst, never a metronome. The gaps between
/// keys wander around 220-320 ms, every key lands a little differently, and in
/// about one burst in five he stops for an instant in the middle ("typed...
/// thought... went on"). Everything is drawn from the repeater's generator.
abstract final class StudyBurst {
  /// How many keys a replay presses. One reads as a click, six as too long.
  static const countWeights = [
    Weighted(0.22, 2),
    Weighted(0.33, 3),
    Weighted(0.30, 4),
    Weighted(0.15, 5),
  ];

  /// The usual gap between keys of one burst, and how far each gap strays
  /// from it.
  static const gapMs = (220.0, 320.0);
  static const gapJitter = (0.85, 1.15);

  /// The chance that a burst of three or more stops once in the middle, and
  /// for how long.
  static const microPauseChance = 0.20;
  static const microPauseMs = (150.0, 280.0);

  /// A key goes down fast and comes back a little slower.
  static const downMs = (70.0, 100.0);
  static const upMs = (100.0, 150.0);

  /// Quiet before the first key and after the last.
  static const leadMs = (70.0, 110.0);
  static const tailMs = (90.0, 130.0);

  /// How hard each key lands: never so light it looks like a glitch.
  static const amplitude = (0.70, 1.0);

  static TapSequence draw(AurudoGestureRepeater r) {
    final count = pickWeighted(countWeights, r.between(0, 1));
    return build(r, count);
  }

  static TapSequence build(AurudoGestureRepeater r, int count) {
    final lead = r.between(leadMs.$1, leadMs.$2);
    final base = r.between(gapMs.$1, gapMs.$2);
    // Where the optional stop falls: after key 1 .. key count-2 (never at the
    // very start or the very end of the burst).
    final pauseAfter = count >= 3 && r.chance(microPauseChance)
        ? r.betweenInt(1, count - 2)
        : -1;
    final pause = pauseAfter >= 0
        ? r.between(microPauseMs.$1, microPauseMs.$2)
        : 0.0;

    final taps = <TapSpec>[];
    var at = lead;
    for (var i = 0; i < count; i++) {
      var gap = 0.0;
      if (i < count - 1) {
        gap = base * r.between(gapJitter.$1, gapJitter.$2);
        if (i == pauseAfter) gap += pause;
      }
      final down = r.between(downMs.$1, downMs.$2);
      // Never still going back up when the next key comes down.
      final up = i < count - 1
          ? math.min(
              r.between(upMs.$1, upMs.$2),
              math.max(60.0, gap - down - 10),
            )
          : r.between(upMs.$1, upMs.$2);
      taps.add(
        TapSpec(
          startMs: at,
          downMs: down,
          upMs: up,
          amplitude: r.between(amplitude.$1, amplitude.$2),
        ),
      );
      at += gap;
    }
    return TapSequence(
      taps: taps,
      leadMs: lead,
      tailMs: r.between(tailMs.$1, tailMs.$2),
      pauseAfterTap: pauseAfter >= 0 ? pauseAfter : null,
      pauseMs: pause,
    );
  }
}

/// The pose at one instant, before it is placed on screen. At rest (before
/// and after the taps, and always under reduced motion) it is exactly the
/// art: 0°, no press.
@immutable
class StudyPose {
  const StudyPose._(this.k);

  factory StudyPose.at(
    double elapsedMs, {
    int tapCount = StudyTimeline.tapCount,
    double amplitude = 1,
    TapSequence? sequence,
  }) {
    final p = StudyTimeline.progressAt(elapsedMs);
    if (p == null) return rest;
    // A replay plays its own drawn burst by time; the first play keeps the
    // approved swell below.
    if (sequence != null) {
      return StudyPose._(sequence.k(p * sequence.durationMs));
    }
    // One smooth swell over the whole sequence (starts and ends at exactly
    // 0, so the pose lands on the art with no jump), rectified so only the
    // downward half of each cycle shows: short dips, not a full swing.
    final envelope = math.sqrt(math.sin(math.pi * p));
    final wave = math.sin(2 * math.pi * tapCount * p);
    return StudyPose._((wave > 0 ? wave : 0) * envelope * amplitude);
  }

  static const rest = StudyPose._(0);

  /// 0 at rest, 1 at the bottom of a dip.
  final double k;

  /// The hand's turn about [StudyGeometry.wrist]; fingers down into the
  /// keyboard is clockwise on screen (positive here, unlike an arm turning
  /// inward toward the head).
  double get angleDegrees => StudyTimeline.maxAngleDegrees * k;
  double pressFor(double size) => size * StudyGeometry.pressFraction * k;
}

/// Aurudo studying: the `encourage` reaction's final pose (after thinking,
/// below a 50% result) and any other still `studying` spot.
///
/// The hand taps at the wrist, dipping into the keyboard a few times, then
/// settles exactly on the art. Everything else -- arm, head, backpack,
/// orbit ring -- stays still: see [StudyGeometry]'s kit for why only the
/// hand could be cut out.
///
/// [instant] (or the platform's reduced motion) shows the art as it is: no
/// entrance, no ticker. If any layer fails to load, the still image stands
/// in.
class AurudoStudyAnimation extends StatefulWidget {
  const AurudoStudyAnimation({
    required this.size,
    this.instant = false,
    this.entrance = true,
    @visibleForTesting this.assets = StudyGeometry.all,
    @visibleForTesting this.seed,
    super.key,
  });

  final double size;
  final bool instant;

  /// Whether he fades and scales in. Off when he takes over from another
  /// pose that is already on screen, so only the crossfade shows.
  final bool entrance;

  /// Base, hand, knee and lid layers, in that order.
  final List<String> assets;

  /// Fixes the replays' draw, for tests and previews. Null: a fresh draw.
  final int? seed;

  /// The still pose this animates, used if a layer fails to load.
  static const stillAsset = 'lib/assets/mascot/aurudo_studying.webp';

  /// Key on the moving hand group, so tests can read its transform.
  @visibleForTesting
  static const handGroupKey = ValueKey('study-hand-group');

  @override
  State<AurudoStudyAnimation> createState() => _AurudoStudyAnimationState();
}

class _AurudoStudyAnimationState extends State<AurudoStudyAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: StudyTimeline.total),
  );
  late final AurudoGestureRepeater _repeater = AurudoGestureRepeater(
    minPause: StudyTimeline.minPause,
    maxPause: StudyTimeline.maxPause,
    onFire: _replay,
    seed: widget.seed,
  );
  TapSequence? _sequence;
  bool _replaying = false;
  bool _failed = false;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _clock.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted && !_still) {
        _repeater.arm();
      }
    });
  }

  void _replay() {
    if (!mounted) return;
    // Behind another route or tab, or under reduced motion: skip this one,
    // try again after the next pause.
    if (_still || !TickerMode.valuesOf(context).enabled) {
      _repeater.arm();
      return;
    }
    final sequence = StudyBurst.draw(_repeater);
    setState(() {
      _replaying = true;
      _sequence = sequence;
    });
    _clock.value = StudyTimeline.replayFrom;
    _clock.animateTo(
      1,
      duration: Duration(milliseconds: sequence.durationMs.round()),
      curve: Curves.linear,
    );
  }

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
    _repeater.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return ExcludeSemantics(
        child: Image.asset(
          AurudoStudyAnimation.stillAsset,
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
          builder: (context, _) => _StudyFrame(
            size: widget.size,
            elapsedMs: _clock.value * StudyTimeline.total,
            assets: widget.assets,
            still: still,
            entrance: widget.entrance && !_replaying,
            sequence: _sequence,
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
  final decodeWidth = (size * StudyGeometry.aspect * dpr).round().clamp(
    64,
    StudyGeometry.sourceWidth,
  );
  return [
    for (final asset in assets)
      ResizeImage(AssetImage(asset), width: decodeWidth),
  ];
}

class _StudyFrame extends StatelessWidget {
  const _StudyFrame({
    required this.size,
    required this.elapsedMs,
    required this.assets,
    required this.still,
    required this.entrance,
    required this.sequence,
  });

  final double size;
  final double elapsedMs;
  final List<String> assets;
  final bool still;
  final bool entrance;
  final TapSequence? sequence;

  @override
  Widget build(BuildContext context) {
    final height = size;
    final width = size * StudyGeometry.aspect;
    final left = (size - width) / 2;
    Offset at(Offset f) => Offset(left + f.dx * width, f.dy * height);

    final pose = still
        ? StudyPose.rest
        : StudyPose.at(elapsedMs, sequence: sequence);
    final angle = pose.angleDegrees * math.pi / 180;
    final press = pose.pressFor(size);
    final wristPoint = at(StudyGeometry.wrist);

    final hand = Matrix4.translationValues(0, press, 0)
      ..multiply(Matrix4.translationValues(wristPoint.dx, wristPoint.dy, 0))
      ..multiply(Matrix4.rotationZ(angle))
      ..multiply(Matrix4.translationValues(-wristPoint.dx, -wristPoint.dy, 0));
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

    final entranceT = still || !entrance
        ? 1.0
        : Curves.easeOutCubic.transform(
            (elapsedMs / StudyTimeline.entranceDuration).clamp(0.0, 1.0),
          );
    const scaleFrom = StudyTimeline.entranceScaleFrom;

    return SizedBox.square(
      dimension: size,
      child: Opacity(
        opacity: entranceT,
        child: Transform.scale(
          scale: scaleFrom + (1 - scaleFrom) * entranceT,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              layer(0), // base: everything but the tapping hand
              Positioned.fill(
                child: Transform(
                  key: AurudoStudyAnimation.handGroupKey,
                  transform: hand,
                  child: Stack(clipBehavior: Clip.none, children: [layer(1)]),
                ),
              ),
              layer(2), // knee, in front of the hand's near corner
              layer(3), // laptop lid, in front of the fingers
            ],
          ),
        ),
      ),
    );
  }
}
