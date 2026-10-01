import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/aurudo_reaction/presentation/aura_particles.dart';

/// The daily-goal timeline, in milliseconds from the moment the effect
/// mounts. Plays once; never loops.
///
/// A ring around Aurudo fills from 0 to 100%, from the top, clockwise; the
/// moment it closes it pulses once, and a few sparkles light up on it. Then
/// everything stops -- a full ring that stays full, never a spinner.
abstract final class DailyGoalTimeline {
  static const total = 1500;

  /// The empty track fades in while the pose arrives.
  static const trackIn = 150;

  /// The fill: 0% at [fillStart], 100% (closed) at [fillEnd].
  static const fillStart = 150;
  static const fillEnd = 1050;

  /// The completion pulse: (start, peak, end).
  static const pulse = (1050, 1140, 1250);

  /// Sparkles light up one after another, each popping in over
  /// [sparkleDuration]; all of them are settled by 1450.
  static const sparkleStart = 1100;
  static const sparkleStagger = 70;
  static const sparkleDuration = 210;
}

/// Where the ring sits, as fractions of the mascot's box. It is a gauge
/// around the whole composition, not an orbit: wider than the character,
/// with a clear margin between him and the line, and never crossing him.
abstract final class DailyGoalGeometry {
  /// Ring radius. The mascot fills his box (radius 0.5), so this leaves a
  /// gap of about a tenth of his size all around.
  static const radius = 0.61;

  /// Line width, per logical pixel of mascot: thicker than the level-up
  /// rings, so it stays legible on the dark navy background.
  static const strokePerSize = 1 / 52;

  /// The soft glow under the line, as a multiple of its width.
  static const glowWidth = 3.2;

  /// How much the ring grows at the top of the completion pulse.
  static const pulseScale = 0.025;

  /// Where the completion sparkles sit on the ring, in degrees clockwise
  /// from the top -- spread around it, never on top of each other.
  static const sparkleAngles = [38.0, 158.0, 262.0];
  static const sparkleSizes = [0.05, 0.036, 0.042];
}

/// The effect's state at one instant: everything the painter needs, and
/// nothing else, so the timing can be tested without pumping frames.
@immutable
class DailyGoalFrame {
  const DailyGoalFrame._(this.elapsedMs);

  factory DailyGoalFrame.at(double elapsedMs) =>
      DailyGoalFrame._(elapsedMs.clamp(0, DailyGoalTimeline.total).toDouble());

  /// The finished goal: what the animation ends on, and all reduced motion
  /// ever shows.
  static const rest = DailyGoalFrame._(DailyGoalTimeline.total * 1.0);

  final double elapsedMs;

  static double _progress(double ms, num start, num duration) =>
      ((ms - start) / duration).clamp(0.0, 1.0);

  /// Opacity of the empty track the fill runs along.
  double get track => Curves.easeOutCubic.transform(
    _progress(elapsedMs, 0, DailyGoalTimeline.trackIn),
  );

  /// How much of the ring is filled, 0..1. A smooth start and end, but a
  /// steady middle, so a quarter and a half read as a quarter and a half.
  double get fill => Curves.easeInOutSine.transform(
    _progress(
      elapsedMs,
      DailyGoalTimeline.fillStart,
      DailyGoalTimeline.fillEnd - DailyGoalTimeline.fillStart,
    ),
  );

  bool get closed => elapsedMs >= DailyGoalTimeline.fillEnd;

  /// The completion pulse, 0..1: only ever after the ring has closed.
  double get pulse {
    const p = DailyGoalTimeline.pulse;
    final ms = elapsedMs;
    if (ms <= p.$1 || ms >= p.$3) return 0;
    if (ms <= p.$2) {
      return Curves.easeOutCubic.transform(_progress(ms, p.$1, p.$2 - p.$1));
    }
    return 1 -
        Curves.easeInOutCubic.transform(_progress(ms, p.$2, p.$3 - p.$2));
  }

  /// The ring's size: 1, a hair bigger at the top of the pulse, 1 again.
  double get scale => 1 + DailyGoalGeometry.pulseScale * pulse;

  /// The glow under the line: rises with the fill, peaks with the pulse,
  /// settles at [glowRest].
  static const glowRest = 0.45;
  double get glow {
    if (!closed) return 0.5 * fill;
    final settle = Curves.easeInOutCubic.transform(
      _progress(
        elapsedMs,
        DailyGoalTimeline.pulse.$2,
        DailyGoalTimeline.total - DailyGoalTimeline.pulse.$2,
      ),
    );
    final afterPeak = 1 - (1 - glowRest) * settle;
    return elapsedMs < DailyGoalTimeline.pulse.$2
        ? 0.5 + 0.5 * pulse
        : afterPeak;
  }

  /// The bright point leading the fill. It goes out as the ring closes:
  /// a finished gauge has no moving head (that is what a spinner has).
  double get head {
    if (fill <= 0) return 0;
    if (closed) return 0;
    return 1 - _progress(fill, 0.92, 0.08);
  }

  /// Sparkle [i]'s pop, 0..1: 0 before it lights up, 1 once it is settled.
  /// They light up only once the ring has closed, and then they stay.
  double sparkle(int i) => _progress(
    elapsedMs,
    DailyGoalTimeline.sparkleStart + i * DailyGoalTimeline.sparkleStagger,
    DailyGoalTimeline.sparkleDuration,
  );
}

/// Aurudo's daily goal: [child] (the still farm-Aura pose -- never the
/// 100% animation, which stays reserved for a perfect result) inside a
/// ring that fills from 0 to 100%, pulses once when it closes and lights
/// a few sparkles on itself. Then it stays: a full ring, low glow, the
/// sparkles in place. Nothing keeps moving, so it reads as "done", not as
/// a loader still waiting.
///
/// [instant] (or the platform's reduced motion) shows that finished state
/// straight away, with no controller running. Plays once, then its ticker
/// stops; a muted [TickerMode] (another tab, a covered route) pauses it
/// like any other ticker.
class AurudoDailyGoalEffect extends StatefulWidget {
  const AurudoDailyGoalEffect({
    required this.size,
    required this.child,
    this.instant = false,
    super.key,
  });

  final double size;
  final Widget child;
  final bool instant;

  @visibleForTesting
  static const ringKey = ValueKey('daily-goal-ring');

  @override
  State<AurudoDailyGoalEffect> createState() => _AurudoDailyGoalEffectState();
}

class _AurudoDailyGoalEffectState extends State<AurudoDailyGoalEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: DailyGoalTimeline.total),
  );

  bool get _still => widget.instant || MediaQuery.disableAnimationsOf(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_still) {
      if (_clock.isAnimating) _clock.stop();
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

  DailyGoalFrame _frame() => _still || _clock.value >= 1
      ? DailyGoalFrame.rest
      : DailyGoalFrame.at(_clock.value * DailyGoalTimeline.total);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          // The ring never crosses him, so one layer, in front, is enough.
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: RepaintBoundary(
                  child: CustomPaint(
                    key: AurudoDailyGoalEffect.ringKey,
                    painter: _RingPainter(
                      clock: _clock,
                      frame: _frame,
                      palette: _DailyGoalPalette.of(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The same ring in both themes; only intensity changes. Light starts the
/// gradient on the deeper violet so the line holds on a white page; dark
/// uses the brighter violet and a stronger glow, so the line stays clearly
/// visible on navy without outshining the mascot.
@immutable
class _DailyGoalPalette {
  const _DailyGoalPalette({
    required this.start,
    required this.middle,
    required this.track,
    required this.glow,
    required this.sparkle,
  });

  factory _DailyGoalPalette.of(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _DailyGoalPalette(
      start: dark ? colors.auraViolet : colors.primary,
      middle: colors.auraCyan,
      track: dark ? 0.16 : 0.12,
      glow: dark ? 0.30 : 0.22,
      sparkle: colors.auraCyan,
    );
  }

  final Color start;
  final Color middle;

  /// Opacity of the empty track and of the glow, per theme.
  final double track;
  final double glow;
  final Color sparkle;

  @override
  bool operator ==(Object other) =>
      other is _DailyGoalPalette &&
      other.start == start &&
      other.middle == middle &&
      other.track == track &&
      other.glow == glow;

  @override
  int get hashCode => Object.hash(start, middle, track, glow);
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.clock,
    required this.frame,
    required this.palette,
  }) : super(repaint: clock);

  final Animation<double> clock;
  final DailyGoalFrame Function() frame;
  final _DailyGoalPalette palette;

  static const _top = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final f = frame();
    final s = size.shortestSide;
    final center = size.center(Offset.zero);
    final radius = s * DailyGoalGeometry.radius * f.scale;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final stroke = s * DailyGoalGeometry.strokePerSize;

    // The empty track, so the fill reads as progress along something.
    if (f.track > 0) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = palette.start.withValues(alpha: palette.track * f.track),
      );
    }

    final sweep = 2 * math.pi * f.fill;
    if (sweep > 0) {
      // Violet at the top, cyan halfway round, violet again where it
      // closes -- so the closed ring has no visible seam.
      final shader = SweepGradient(
        colors: [palette.start, palette.middle, palette.start],
        transform: const GradientRotation(_top),
      ).createShader(rect);

      // The glow: the same arc, wider, faint and softened -- one small
      // blur on one thin path, not a blurred area. A paint's opacity scales
      // its shader, so this is the gradient at [glow].
      final glow = palette.glow * f.glow;
      if (glow > 0.005) {
        _arc(
          canvas,
          rect,
          sweep,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = stroke * DailyGoalGeometry.glowWidth
            ..strokeCap = StrokeCap.round
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke)
            ..shader = shader
            ..color = Colors.white.withValues(alpha: glow),
        );
      }

      _arc(
        canvas,
        rect,
        sweep,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = f.closed ? StrokeCap.butt : StrokeCap.round
          ..shader = shader,
      );

      // The bright point leading the fill.
      if (f.head > 0.01) {
        final tip =
            center +
            Offset(math.cos(_top + sweep), math.sin(_top + sweep)) * radius;
        canvas.drawCircle(
          tip,
          stroke * 1.9,
          Paint()
            ..shader = RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.9 * f.head),
                palette.middle.withValues(alpha: 0.5 * f.head),
                palette.middle.withValues(alpha: 0),
              ],
            ).createShader(Rect.fromCircle(center: tip, radius: stroke * 1.9)),
        );
      }
    }

    // The completion sparkles, on the ring itself: pop a little past full
    // size, then settle and stay.
    for (var i = 0; i < DailyGoalGeometry.sparkleAngles.length; i++) {
      final p = f.sparkle(i);
      if (p <= 0) continue;
      final pop = p < 0.6
          ? Curves.easeOutCubic.transform(p / 0.6) * 1.25
          : 1.25 - 0.25 * Curves.easeInOutCubic.transform((p - 0.6) / 0.4);
      final angle = _top + DailyGoalGeometry.sparkleAngles[i] * math.pi / 180;
      final at = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      paintAuraSparkle(
        canvas,
        at,
        s * DailyGoalGeometry.sparkleSizes[i] * pop,
        (i.isEven ? palette.sparkle : palette.start).withValues(
          alpha: math.min(1, p * 2),
        ),
      );
    }
  }

  void _arc(Canvas canvas, Rect rect, double sweep, Paint paint) {
    if (sweep >= 2 * math.pi - 1e-6) {
      canvas.drawOval(rect, paint);
    } else {
      canvas.drawArc(rect, _top, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.clock != clock || old.palette != palette;
}
