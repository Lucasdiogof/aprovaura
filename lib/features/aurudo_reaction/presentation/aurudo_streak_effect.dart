import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

/// The streak-milestone timeline, in milliseconds from the moment the
/// effect mounts. Plays once; never loops.
///
/// A stylised Aura flame lights up behind Aurudo, flares twice (the second
/// time smaller), and settles; a few embers rise past him while it burns.
abstract final class StreakTimeline {
  static const total = 1400;

  /// The flame grows in from its base and fades in.
  static const igniteEnd = 250;

  /// Two flares, the second smaller: (start, peak, end).
  static const flare1 = (250, 450, 700);
  static const flare2 = (700, 880, 1100);

  /// Each ember on its own delay; the last one is gone by [embersEnd].
  static const emberStart = 300;
  static const emberStagger = 90;
  static const emberDuration = 550;
  static const embersEnd = 1300;

  /// The flicker of the tongues dies down by here.
  static const flickerEnd = 1250;
}

/// The flame's shape and the embers' paths, as fractions of the mascot's
/// box. The flame stands behind him from his feet to just above his head,
/// so what shows is its outline around him -- three tongues over his head
/// and shoulders, the body of the fire at his sides.
abstract final class StreakGeometry {
  /// Where the flame's base sits (it grows and flares from here).
  static const base = Offset(0.5, 0.98);

  /// How much taller the flame stretches at the top of each flare.
  static const flare1Stretch = 0.10;
  static const flare2Stretch = 0.05;

  /// Ignition starts from this fraction of the flame's full size.
  static const igniteFrom = 0.55;

  /// Sideways sway of the tongue tips while it flickers.
  static const flickerAmplitude = 0.018;

  /// Horizontal positions of the rising embers: Aurudo's sides, never
  /// across his visor.
  static const emberXs = [0.12, 0.86, 0.22, 0.76, 0.04, 0.95];
}

/// The effect's state at one instant: everything the painters need, and
/// nothing else, so the timing can be tested without pumping frames.
@immutable
class StreakFrame {
  const StreakFrame._(this.elapsedMs);

  factory StreakFrame.at(double elapsedMs) =>
      StreakFrame._(elapsedMs.clamp(0, StreakTimeline.total).toDouble());

  /// The settled flame: what the animation ends on, and all reduced
  /// motion ever shows.
  static const rest = StreakFrame._(StreakTimeline.total * 1.0);

  final double elapsedMs;

  static double _progress(double ms, num start, num duration) =>
      ((ms - start) / duration).clamp(0.0, 1.0);

  /// A smooth bump: 0 before [f].$1, 1 at [f].$2, 0 again from [f].$3.
  static double _bump(double ms, (int, int, int) f) {
    if (ms <= f.$1 || ms >= f.$3) return 0;
    if (ms <= f.$2) {
      return Curves.easeOutCubic.transform(_progress(ms, f.$1, f.$2 - f.$1));
    }
    return 1 -
        Curves.easeInOutCubic.transform(_progress(ms, f.$2, f.$3 - f.$2));
  }

  /// 0..1: how lit the flame is (grows in over the ignition).
  double get ignition => Curves.easeOutCubic.transform(
    _progress(elapsedMs, 0, StreakTimeline.igniteEnd),
  );

  /// The flame's size about its base: from [StreakGeometry.igniteFrom] to 1
  /// while it ignites.
  double get scale =>
      StreakGeometry.igniteFrom + (1 - StreakGeometry.igniteFrom) * ignition;

  /// Extra height on top of [scale] during the two flares.
  double get stretch =>
      StreakGeometry.flare1Stretch * _bump(elapsedMs, StreakTimeline.flare1) +
      StreakGeometry.flare2Stretch * _bump(elapsedMs, StreakTimeline.flare2);

  /// Brightness of the flame, 0..1: lit, brighter on each flare, settles
  /// at [flameRest] -- the flame stays, quieter, once the scene is done.
  static const flameRest = 0.8;
  double get flame {
    final flares =
        _bump(elapsedMs, StreakTimeline.flare1) +
        0.6 * _bump(elapsedMs, StreakTimeline.flare2);
    final settle = Curves.easeInOutCubic.transform(
      _progress(
        elapsedMs,
        StreakTimeline.flare2.$2,
        StreakTimeline.total - StreakTimeline.flare2.$2,
      ),
    );
    final base = 1 - (1 - flameRest) * settle;
    return (ignition * base + 0.2 * flares).clamp(0.0, 1.0);
  }

  /// The short radial flash behind him: peaks with the first flare,
  /// settles at [glowRest].
  static const glowRest = 0.35;
  double get glow {
    final flash = _bump(elapsedMs, StreakTimeline.flare1);
    final after = elapsedMs >= StreakTimeline.flare1.$2 ? glowRest : 0.0;
    return math.max(
          flash,
          after *
              _progress(
                elapsedMs,
                StreakTimeline.flare1.$2,
                StreakTimeline.flare1.$3 - StreakTimeline.flare1.$2,
              ),
        ) *
        ignition;
  }

  /// The tongues' sway, -1..1, dying down to exactly 0 at rest.
  double get flicker {
    if (elapsedMs >= StreakTimeline.flickerEnd) return 0;
    final fade = 1 - _progress(elapsedMs, 0, StreakTimeline.flickerEnd);
    return math.sin(elapsedMs / 1000 * 2 * math.pi * 3.2) * fade;
  }

  /// Ember [i]'s travel, 0..1, or null before it starts / after it ends.
  double? emberTravel(int i) {
    final start = StreakTimeline.emberStart + i * StreakTimeline.emberStagger;
    final p = (elapsedMs - start) / StreakTimeline.emberDuration;
    if (p <= 0 || p >= 1) return null;
    return p;
  }
}

/// Aurudo reaching a streak milestone: [child] (the mascot, untouched) in
/// front of a stylised Aura flame that lights up, flares twice and settles,
/// with a few embers rising past him. Violet and cyan, the app's own
/// colours -- no realistic fire, no emoji, no asset.
///
/// The effect never shows the number of days: the scene's headline already
/// does, and the mascot view is not given it.
///
/// [instant] (or the platform's reduced motion) shows the settled flame
/// straight away, with no controller running. Plays once, then its ticker
/// stops; a muted [TickerMode] (another tab, a covered route) pauses it
/// like any other ticker.
class AurudoStreakEffect extends StatefulWidget {
  const AurudoStreakEffect({
    required this.size,
    required this.child,
    this.instant = false,
    super.key,
  });

  final double size;
  final Widget child;
  final bool instant;

  @visibleForTesting
  static const flameKey = ValueKey('streak-flame');
  @visibleForTesting
  static const embersKey = ValueKey('streak-embers');

  @override
  State<AurudoStreakEffect> createState() => _AurudoStreakEffectState();
}

class _AurudoStreakEffectState extends State<AurudoStreakEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: StreakTimeline.total),
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

  StreakFrame _frame() => _still || _clock.value >= 1
      ? StreakFrame.rest
      : StreakFrame.at(_clock.value * StreakTimeline.total);

  @override
  Widget build(BuildContext context) {
    final palette = _StreakPalette.of(context);
    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: RepaintBoundary(
                child: CustomPaint(
                  key: AurudoStreakEffect.flameKey,
                  painter: _FlamePainter(
                    clock: _clock,
                    frame: _frame,
                    palette: palette,
                  ),
                ),
              ),
            ),
          ),
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: RepaintBoundary(
                  child: CustomPaint(
                    key: AurudoStreakEffect.embersKey,
                    painter: _EmbersPainter(
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

/// The same flame in both themes; only intensity changes. Light needs more
/// opacity so the flame doesn't wash out on a white page; dark keeps it
/// lower so it never turns into neon.
@immutable
class _StreakPalette {
  const _StreakPalette({
    required this.violet,
    required this.cyan,
    required this.deep,
    required this.flame,
    required this.glow,
    required this.ember,
  });

  factory _StreakPalette.of(BuildContext context) {
    final colors = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _StreakPalette(
      violet: colors.auraViolet,
      cyan: colors.auraCyan,
      deep: colors.primary,
      flame: dark ? 0.46 : 0.50,
      glow: dark ? 0.24 : 0.28,
      ember: dark ? 0.9 : 1.0,
    );
  }

  final Color violet;
  final Color cyan;
  final Color deep;

  /// Peak opacities, per theme.
  final double flame;
  final double glow;
  final double ember;

  @override
  bool operator ==(Object other) =>
      other is _StreakPalette &&
      other.violet == violet &&
      other.cyan == cyan &&
      other.deep == deep &&
      other.flame == flame;

  @override
  int get hashCode => Object.hash(violet, cyan, deep, flame);
}

/// The flame outline in a unit box (x 0..1, y 0 = top .. 1 = bottom): a
/// body that narrows to its base and breaks into five tongues of different
/// heights, the tallest in the middle -- the notches between them are what
/// make it read as fire rather than a drop. [sway] leans the tips sideways
/// (-1..1).
Path _flamePath(double sway) {
  final a = StreakGeometry.flickerAmplitude * sway;
  // Each tongue rises with one side bowed and the other hollow, so its tip
  // curls instead of standing as a straight spike.
  return Path()
    ..moveTo(0.5, 0.96)
    ..cubicTo(0.30, 0.96, 0.08, 0.82, 0.10, 0.62)
    ..cubicTo(0.12, 0.50, 0.06 + a, 0.40, 0.12 + a, 0.26)
    ..cubicTo(0.14, 0.34, 0.22, 0.36, 0.23, 0.44)
    ..cubicTo(0.20, 0.30, 0.22 + a, 0.16, 0.29 + a, 0.06)
    ..cubicTo(0.30, 0.16, 0.37, 0.24, 0.38, 0.34)
    ..cubicTo(0.36, 0.18, 0.47 - a, 0.10, 0.49 - a, -0.06)
    ..cubicTo(0.56 - a, 0.08, 0.63, 0.16, 0.62, 0.33)
    ..cubicTo(0.64, 0.22, 0.76 + a, 0.17, 0.72 + a, 0.05)
    ..cubicTo(0.80, 0.16, 0.78, 0.30, 0.77, 0.44)
    ..cubicTo(0.79, 0.36, 0.86, 0.37, 0.89 + a, 0.26)
    ..cubicTo(0.95, 0.40, 0.88, 0.50, 0.90, 0.62)
    ..cubicTo(0.92, 0.82, 0.70, 0.96, 0.50, 0.96)
    ..close();
}

class _FlamePainter extends CustomPainter {
  _FlamePainter({
    required this.clock,
    required this.frame,
    required this.palette,
  }) : super(repaint: clock);

  final Animation<double> clock;
  final StreakFrame Function() frame;
  final _StreakPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final f = frame();
    final s = size.shortestSide;
    final light = f.flame * palette.flame;
    if (light <= 0.005) return;

    final base = Offset(
      StreakGeometry.base.dx * size.width,
      StreakGeometry.base.dy * s,
    );

    // Short radial flash behind him, around his chest.
    final glow = f.glow * palette.glow;
    if (glow > 0.005) {
      final c = Offset(size.width / 2, s * 0.55);
      final r = s * 0.62;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              palette.violet.withValues(alpha: glow),
              palette.violet.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    final path = _flamePath(f.flicker);
    final scaleX = f.scale;
    final scaleY = f.scale * (1 + f.stretch);

    void drawFlame(double sx, double sy, Shader shader) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.scale(s * sx, s * sy);
      canvas.translate(-StreakGeometry.base.dx, -StreakGeometry.base.dy);
      canvas.drawPath(path, Paint()..shader = shader);
      canvas.restore();
    }

    // In the unit box: top of the flame at y = 0, base at y = 1.
    const unit = Rect.fromLTWH(0, -0.05, 1, 1.05);

    // A slightly larger, fainter copy first: the soft edge, without a blur.
    drawFlame(
      scaleX * 1.07,
      scaleY * 1.05,
      LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          palette.violet.withValues(alpha: 0),
          palette.violet.withValues(alpha: light * 0.3),
          palette.violet.withValues(alpha: light * 0.2),
        ],
        stops: const [0.1, 0.55, 1],
      ).createShader(unit),
    );
    // The fire itself. Transparent at the base -- it must never pool under
    // his feet -- brightest around his shoulders, cyan-hot at the tips.
    drawFlame(
      scaleX,
      scaleY,
      LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          palette.deep.withValues(alpha: 0),
          palette.deep.withValues(alpha: light * 0.75),
          palette.violet.withValues(alpha: light),
          palette.cyan.withValues(alpha: light * 0.75),
        ],
        stops: const [0.12, 0.45, 0.72, 1],
      ).createShader(unit),
    );
  }

  @override
  bool shouldRepaint(_FlamePainter old) =>
      old.clock != clock || old.palette != palette;
}

class _EmbersPainter extends CustomPainter {
  _EmbersPainter({
    required this.clock,
    required this.frame,
    required this.palette,
  }) : super(repaint: clock);

  final Animation<double> clock;
  final StreakFrame Function() frame;
  final _StreakPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final f = frame();
    final s = size.shortestSide;
    final colors = [palette.cyan, palette.violet, palette.deep];
    for (var i = 0; i < StreakGeometry.emberXs.length; i++) {
      final p = f.emberTravel(i);
      if (p == null) continue;
      final e = Curves.easeOutCubic.transform(p);
      // Embers drift, they don't shoot: a small sideways wobble on the way
      // up, unlike the level-up's straight sparks.
      final wobble = math.sin(p * math.pi * 2 + i) * s * 0.025;
      final at = Offset(
        s * StreakGeometry.emberXs[i] + wobble,
        s * (0.88 - 0.70 * e),
      );
      final alpha = math.sin(p * math.pi) * palette.ember;
      final color = colors[i % colors.length];
      final r = s * (0.016 - 0.006 * p);
      // A soft glow around each ember (a gradient, not a ring: a hard halo
      // reads as a bubble).
      canvas.drawCircle(
        at,
        r * 2.4,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: alpha * 0.35),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: at, radius: r * 2.4)),
      );
      canvas.drawCircle(at, r, Paint()..color = color.withValues(alpha: alpha));
    }
  }

  @override
  bool shouldRepaint(_EmbersPainter old) =>
      old.clock != clock || old.palette != palette;
}
