import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/aurudo_reaction/presentation/aura_particles.dart';

/// The level-up timeline, in milliseconds from the moment the effect
/// mounts. Plays once; never loops.
///
/// Three thin Aura rings are born at Aurudo's feet and rise around him,
/// widening as they climb; the last one stays, settled around his chest.
/// A vertical column of light swells behind him while they rise, and a
/// few sparkles shoot upward past him at the end.
abstract final class LevelUpTimeline {
  static const total = 1400;

  /// When each ring is born. Staggered, so they read as a climb -- one
  /// ring after another -- rather than one big flash.
  static const ringStarts = [150, 350, 550];
  static const ringDuration = 650;

  /// The column of light behind him: swells, peaks, fades out completely.
  static const beamStart = 150;
  static const beamPeak = 600;
  static const beamEnd = 1250;

  /// The glow behind him rises with the rings and settles to [glowRest].
  static const glowPeak = 550;
  static const glowSettled = 1300;

  /// Sparkles shooting upward, each on its own delay inside this window.
  static const sparkleStart = 650;
  static const sparkleStagger = 35;
  static const sparkleDuration = 560;

  /// Whole-character micro-rise: up a hair, then back to exactly where he
  /// stood. He never leaves his spot.
  static const liftPeak = 600;
  static const liftEnd = 1150;

  /// The two sparkles that stay with the last ring, fading in at the end.
  static const restSparklesIn = 1100;
}

/// Where the rings travel, as fractions of the mascot's box. The rings are
/// flattened ellipses (an orbit seen from slightly above), so their upper
/// half is drawn behind Aurudo and their lower half in front of him -- they
/// go *around* him, not just behind.
abstract final class LevelUpGeometry {
  static const ringFromY = 0.90;
  static const ringToY = 0.56;
  static const ringFromRadius = 0.20;
  static const ringToRadius = 0.48;

  /// Each later ring finishes a little higher and wider than the one
  /// before it.
  static const ringStepY = 0.05;
  static const ringStepRadius = 0.035;

  /// Height of a ring relative to its width.
  static const ringFlatten = 0.26;

  /// How thick a ring's stroke is, per logical pixel of mascot.
  static const strokePerSize = 1 / 90;

  /// Horizontal positions of the rising sparkles: kept to Aurudo's sides,
  /// never across his visor.
  static const sparkleXs = [0.0, 1.0, 0.12, 0.88, -0.08, 1.08];
}

/// The effect's state at one instant: everything the painters need, and
/// nothing else, so the timing can be tested without pumping frames.
@immutable
class LevelUpFrame {
  const LevelUpFrame._(this.elapsedMs, {required this.still});

  factory LevelUpFrame.at(double elapsedMs) => LevelUpFrame._(
    elapsedMs.clamp(0, LevelUpTimeline.total).toDouble(),
    still: false,
  );

  /// The settled composition: what the animation ends on, and all reduced
  /// motion ever shows.
  static const rest = LevelUpFrame._(LevelUpTimeline.total * 1.0, still: true);

  final double elapsedMs;
  final bool still;

  static double _progress(double ms, num start, num duration) =>
      ((ms - start) / duration).clamp(0.0, 1.0);

  /// Opacity of the glow behind him, 0..1 (scaled per theme by the
  /// painter). Rests at [glowRest], not at zero: the settled pose keeps a
  /// little light behind him.
  static const glowRest = 0.4;
  double get glow {
    final ms = elapsedMs;
    if (ms <= LevelUpTimeline.glowPeak) {
      return Curves.easeOutCubic.transform(
        _progress(ms, 0, LevelUpTimeline.glowPeak),
      );
    }
    final settle = Curves.easeInOutCubic.transform(
      _progress(
        ms,
        LevelUpTimeline.glowPeak,
        LevelUpTimeline.glowSettled - LevelUpTimeline.glowPeak,
      ),
    );
    return 1 - (1 - glowRest) * settle;
  }

  /// Opacity of the column of light, 0..1. Gone at rest.
  double get beam {
    final ms = elapsedMs;
    if (ms <= LevelUpTimeline.beamStart || ms >= LevelUpTimeline.beamEnd) {
      return 0;
    }
    if (ms <= LevelUpTimeline.beamPeak) {
      return Curves.easeOutCubic.transform(
        _progress(
          ms,
          LevelUpTimeline.beamStart,
          LevelUpTimeline.beamPeak - LevelUpTimeline.beamStart,
        ),
      );
    }
    return 1 -
        Curves.easeInCubic.transform(
          _progress(
            ms,
            LevelUpTimeline.beamPeak,
            LevelUpTimeline.beamEnd - LevelUpTimeline.beamPeak,
          ),
        );
  }

  /// How far up the column of light has travelled, 0 (feet) .. 1 (chest).
  double get beamRise => Curves.easeOutCubic.transform(
    _progress(
      elapsedMs,
      LevelUpTimeline.beamStart,
      LevelUpTimeline.beamEnd - LevelUpTimeline.beamStart,
    ),
  );

  /// Ring [i]'s travel, 0..1 (0 = not born yet).
  double ringTravel(int i) => _progress(
    elapsedMs,
    LevelUpTimeline.ringStarts[i],
    LevelUpTimeline.ringDuration,
  );

  /// Opacity of ring [i], 0..1. Every ring fades in as it is born; the
  /// first ones fade out as they reach the top, the last one stays at
  /// [lastRingRest].
  static const lastRingRest = 0.75;
  double ringOpacity(int i) {
    final p = ringTravel(i);
    if (p <= 0) return 0;
    final fadeIn = (p / 0.2).clamp(0.0, 1.0);
    final isLast = i == LevelUpTimeline.ringStarts.length - 1;
    if (isLast) return fadeIn * (1 - (1 - lastRingRest) * p);
    if (p >= 1) return 0;
    final fadeOut = p < 0.55 ? 1.0 : 1 - (p - 0.55) / 0.45;
    return fadeIn * fadeOut.clamp(0.0, 1.0);
  }

  /// Sparkle [i]'s travel, 0..1, or null before it starts / after it ends.
  double? sparkleTravel(int i) {
    final start =
        LevelUpTimeline.sparkleStart + i * LevelUpTimeline.sparkleStagger;
    final p = (elapsedMs - start) / LevelUpTimeline.sparkleDuration;
    if (p <= 0 || p >= 1) return null;
    return p;
  }

  /// Opacity of the two sparkles that stay with the settled ring.
  double get restSparkles => _progress(
    elapsedMs,
    LevelUpTimeline.restSparklesIn,
    LevelUpTimeline.total - LevelUpTimeline.restSparklesIn,
  );

  /// The character's micro-rise, as a fraction of his size (negative = up).
  static const maxLift = 0.022;
  double get lift {
    final ms = elapsedMs;
    if (ms >= LevelUpTimeline.liftEnd) return 0;
    if (ms <= LevelUpTimeline.liftPeak) {
      return -maxLift *
          Curves.easeOutCubic.transform(
            _progress(ms, 0, LevelUpTimeline.liftPeak),
          );
    }
    return -maxLift *
        (1 -
            Curves.easeInOutCubic.transform(
              _progress(
                ms,
                LevelUpTimeline.liftPeak,
                LevelUpTimeline.liftEnd - LevelUpTimeline.liftPeak,
              ),
            ));
  }
}

/// Aurudo leveling up: [child] (the mascot, untouched) with an ascension
/// scene around him -- rings of Aura rising from his feet, a column of
/// light swelling behind him, sparkles shooting upward. No confetti: that
/// is the `great` celebration's, and a level is a different kind of win.
///
/// The effect never shows a number. The level is already in the scene's
/// headline, and the mascot view is not given it.
///
/// [instant] (or the platform's reduced motion) shows the settled
/// composition straight away -- the last ring around his chest, a little
/// light behind him -- with no controller running. Plays once, then its
/// ticker stops; a muted [TickerMode] (another tab, a covered route)
/// pauses it like any other ticker.
class AurudoLevelUpEffect extends StatefulWidget {
  const AurudoLevelUpEffect({
    required this.size,
    required this.child,
    this.instant = false,
    super.key,
  });

  final double size;
  final Widget child;
  final bool instant;

  @visibleForTesting
  static const backKey = ValueKey('level-up-back');
  @visibleForTesting
  static const frontKey = ValueKey('level-up-front');
  @visibleForTesting
  static const liftKey = ValueKey('level-up-lift');

  @override
  State<AurudoLevelUpEffect> createState() => _AurudoLevelUpEffectState();
}

class _AurudoLevelUpEffectState extends State<AurudoLevelUpEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: LevelUpTimeline.total),
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

  LevelUpFrame _frame() => _still || _clock.value >= 1
      ? LevelUpFrame.rest
      : LevelUpFrame.at(_clock.value * LevelUpTimeline.total);

  @override
  Widget build(BuildContext context) {
    final palette = _LevelUpPalette.of(context);
    final size = widget.size;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: RepaintBoundary(
                child: CustomPaint(
                  key: AurudoLevelUpEffect.backKey,
                  painter: _LevelUpBackPainter(
                    clock: _clock,
                    frame: _frame,
                    palette: palette,
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _clock,
            child: widget.child,
            builder: (context, child) => Transform.translate(
              key: AurudoLevelUpEffect.liftKey,
              offset: Offset(0, _frame().lift * size),
              child: child,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: RepaintBoundary(
                  child: CustomPaint(
                    key: AurudoLevelUpEffect.frontKey,
                    painter: _LevelUpFrontPainter(
                      clock: _clock,
                      frame: _frame,
                      palette: palette,
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

/// The same structure in both themes; only intensity changes. Light needs
/// the deeper violet and a bit more opacity so nothing washes out on a
/// white page; dark keeps the glow lower so it never turns into neon.
@immutable
class _LevelUpPalette {
  const _LevelUpPalette({
    required this.violet,
    required this.cyan,
    required this.deep,
    required this.glow,
    required this.beam,
    required this.ring,
    required this.sparkle,
  });

  factory _LevelUpPalette.of(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _LevelUpPalette(
      violet: colors.auraViolet,
      cyan: colors.auraCyan,
      deep: colors.primary,
      glow: dark ? 0.26 : 0.30,
      beam: dark ? 0.34 : 0.44,
      ring: dark ? 0.85 : 1.0,
      sparkle: dark ? 0.9 : 1.0,
    );
  }

  final Color violet;
  final Color cyan;
  final Color deep;

  /// Peak opacities, per theme.
  final double glow;
  final double beam;
  final double ring;
  final double sparkle;

  @override
  bool operator ==(Object other) =>
      other is _LevelUpPalette &&
      other.violet == violet &&
      other.cyan == cyan &&
      other.deep == deep &&
      other.glow == glow;

  @override
  int get hashCode => Object.hash(violet, cyan, deep, glow);
}

/// One ring's ellipse at frame [f], in [size]'s box.
Rect? _ringRect(LevelUpFrame f, int i, Size size) {
  final p = f.ringTravel(i);
  if (p <= 0) return null;
  final e = Curves.easeOutCubic.transform(p);
  final s = size.shortestSide;
  final toY = LevelUpGeometry.ringToY - LevelUpGeometry.ringStepY * i;
  final toR = LevelUpGeometry.ringToRadius + LevelUpGeometry.ringStepRadius * i;
  final cy =
      s * (LevelUpGeometry.ringFromY + (toY - LevelUpGeometry.ringFromY) * e);
  final rx =
      s *
      (LevelUpGeometry.ringFromRadius +
          (toR - LevelUpGeometry.ringFromRadius) * e);
  final ry = rx * LevelUpGeometry.ringFlatten;
  return Rect.fromCenter(
    center: Offset(size.width / 2, cy),
    width: rx * 2,
    height: ry * 2,
  );
}

/// Half a ring: [back] is the far (upper) half, behind Aurudo; otherwise
/// the near (lower) half, in front of him.
void _paintRingHalf(
  Canvas canvas,
  Size size,
  LevelUpFrame f,
  _LevelUpPalette palette, {
  required bool back,
}) {
  for (var i = 0; i < LevelUpTimeline.ringStarts.length; i++) {
    final rect = _ringRect(f, i, size);
    if (rect == null) continue;
    // The near half sits over the body, so it is kept quieter: it should
    // read as passing in front of him, not as a line drawn across him.
    final alpha = f.ringOpacity(i) * palette.ring * (back ? 1 : 0.7);
    if (alpha <= 0.01) continue;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * LevelUpGeometry.strokePerSize
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          palette.deep.withValues(alpha: alpha),
          palette.cyan.withValues(alpha: alpha),
          palette.violet.withValues(alpha: alpha),
        ],
      ).createShader(rect);
    canvas.drawArc(rect, back ? math.pi : 0, math.pi, false, paint);
  }
}

class _LevelUpBackPainter extends CustomPainter {
  _LevelUpBackPainter({
    required this.clock,
    required this.frame,
    required this.palette,
  }) : super(repaint: clock);

  final Animation<double> clock;
  final LevelUpFrame Function() frame;
  final _LevelUpPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final f = frame();
    final s = size.shortestSide;
    final center = Offset(size.width / 2, s * 0.58);

    // Soft round glow behind him.
    final glow = f.glow * palette.glow;
    if (glow > 0.005) {
      final r = s * 0.6;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              palette.violet.withValues(alpha: glow),
              palette.violet.withValues(alpha: glow * 0.35),
              palette.violet.withValues(alpha: 0),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }

    // The column of light: a radial glow squeezed sideways, rising from
    // his feet. No blur filter -- the gradient is the softness.
    final beam = f.beam * palette.beam;
    if (beam > 0.005) {
      final cy = s * (0.78 - 0.30 * f.beamRise);
      canvas.save();
      canvas.translate(size.width / 2, cy);
      canvas.scale(0.34, 1);
      final r = s * 0.62;
      canvas.drawCircle(
        Offset.zero,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              palette.cyan.withValues(alpha: beam),
              palette.violet.withValues(alpha: beam * 0.45),
              palette.violet.withValues(alpha: 0),
            ],
            stops: const [0, 0.5, 1],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)),
      );
      canvas.restore();
    }

    _paintRingHalf(canvas, size, f, palette, back: true);
  }

  @override
  bool shouldRepaint(_LevelUpBackPainter old) =>
      old.clock != clock || old.palette != palette;
}

class _LevelUpFrontPainter extends CustomPainter {
  _LevelUpFrontPainter({
    required this.clock,
    required this.frame,
    required this.palette,
  }) : super(repaint: clock);

  final Animation<double> clock;
  final LevelUpFrame Function() frame;
  final _LevelUpPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final f = frame();
    final s = size.shortestSide;
    _paintRingHalf(canvas, size, f, palette, back: false);

    // Sparkles shooting upward along his sides, each with a short fading
    // trail below it.
    final colors = [palette.cyan, palette.violet, palette.deep];
    for (var i = 0; i < LevelUpGeometry.sparkleXs.length; i++) {
      final p = f.sparkleTravel(i);
      if (p == null) continue;
      final e = Curves.easeOutCubic.transform(p);
      final x = s * LevelUpGeometry.sparkleXs[i];
      final y = s * (0.95 - 0.85 * e);
      final alpha = math.sin(p * math.pi) * palette.sparkle;
      final color = colors[i % colors.length];
      final trail = s * 0.16 * (1 - p * 0.5);
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + trail),
        Paint()
          ..strokeWidth = s * 0.011
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: alpha * 0.8),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(x - 1, y, 2, trail)),
      );
      paintAuraSparkle(
        canvas,
        Offset(x, y),
        s * 0.034,
        color.withValues(alpha: alpha),
      );
    }

    // The two sparkles that stay with the settled ring, at its ends.
    final rest = f.restSparkles * palette.sparkle;
    if (rest > 0.01) {
      final rect = _ringRect(f, LevelUpTimeline.ringStarts.length - 1, size);
      if (rect != null) {
        paintAuraSparkle(
          canvas,
          rect.centerLeft + Offset(-s * 0.02, -s * 0.04),
          s * 0.03,
          palette.cyan.withValues(alpha: rest),
        );
        paintAuraSparkle(
          canvas,
          rect.centerRight + Offset(s * 0.015, -s * 0.07),
          s * 0.022,
          palette.violet.withValues(alpha: rest),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_LevelUpFrontPainter old) =>
      old.clock != clock || old.palette != palette;
}
