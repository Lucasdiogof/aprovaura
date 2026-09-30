import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

/// A short band of light running around [child]'s rounded outline while
/// [active].
///
/// It marks the one card worth looking at first on a screen: the daily
/// goal on Home while it is still to do, the level card on Profile.
///
/// Only the border moves: the controller drives a [CustomPainter] through
/// `repaint:`, inside a [RepaintBoundary], so no frame rebuilds or
/// re-lays out [child]. The controller exists only while there is light to
/// run, and it also stops when this can't be seen: another Home tab in
/// front (the shell's IndexedStack keeps this alive), a route pushed on
/// top ([TickerMode]) or reduced motion, which gets a still highlight
/// instead.
///
/// Turning [active] off fades the light out over [fadeDuration] and then
/// pauses the loop; turning it back on resumes it. A card that
/// is built already inactive never animates at all.
class AuraAnimatedBorder extends StatefulWidget {
  const AuraAnimatedBorder({
    required this.active,
    required this.borderRadius,
    required this.child,
    super.key,
  });

  final bool active;
  final double borderRadius;
  final Widget child;

  static const loopDuration = Duration(milliseconds: 3600);
  static const fadeDuration = Duration(milliseconds: 300);

  /// Where the still highlight sits under reduced motion: the top edge,
  /// a little right of the top-left corner.
  static const staticPhase = 0.08;

  @override
  State<AuraAnimatedBorder> createState() =>
      _AuraAnimatedBorderState();
}

class _AuraAnimatedBorderState extends State<AuraAnimatedBorder>
    with TickerProviderStateMixin {
  AnimationController? _loop;

  /// 1 while [AuraAnimatedBorder.active], easing to 0 after it turns
  /// off. The light stays painted (and moving) until this reaches 0.
  late final AnimationController _intensity = AnimationController(
    vsync: this,
    duration: AuraAnimatedBorder.fadeDuration,
    value: widget.active ? 1 : 0,
  )..addStatusListener(_onIntensityStatus);

  bool _reducedMotion = false;
  bool _canRun = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.disableAnimationsOf(context);
    _canRun = TickerMode.valuesOf(context).enabled && Visibility.of(context);
    _syncLoop();
  }

  @override
  void didUpdateWidget(AuraAnimatedBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active) {
      _intensity.value = 1;
    } else if (_reducedMotion) {
      _intensity.value = 0;
    } else {
      _intensity.reverse();
    }
    _syncLoop();
  }

  void _onIntensityStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) _syncLoop();
  }

  bool get _lightVisible => widget.active || _intensity.value > 0;

  /// Creates (on first need), runs or pauses the loop to match what is on
  /// screen. Paused rather than disposed mid-life, so the painter never
  /// holds a dead controller; [dispose] drops it.
  void _syncLoop() {
    final wanted = _lightVisible && !_reducedMotion;
    if (!wanted) {
      _loop?.stop();
      return;
    }
    final loop = _loop ??= AnimationController(
      vsync: this,
      duration: AuraAnimatedBorder.loopDuration,
    );
    if (_canRun) {
      if (!loop.isAnimating) loop.repeat();
    } else {
      loop.stop();
    }
  }

  @override
  void dispose() {
    _loop?.dispose();
    _intensity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loop = _loop;
    return RepaintBoundary(
      child: CustomPaint(
        foregroundPainter: _RunningLightPainter(
          phase: loop == null || _reducedMotion
              ? const AlwaysStoppedAnimation<double>(
                  AuraAnimatedBorder.staticPhase,
                )
              : loop,
          intensity: _intensity,
          radius: widget.borderRadius,
          colors: [colors.primary, colors.auraViolet, colors.auraCyan],
          // Light theme: a softer halo so it doesn't smear on white.
          haloOpacity: isDark ? 0.30 : 0.20,
        ),
        child: widget.child,
      ),
    );
  }
}

/// The travelling band. [phase] is where its head is, as a fraction of the
/// perimeter; [intensity] scales it all (the completion fade-out).
class _RunningLightPainter extends CustomPainter {
  _RunningLightPainter({
    required this.phase,
    required this.intensity,
    required this.radius,
    required this.colors,
    required this.haloOpacity,
  }) : super(repaint: Listenable.merge([phase, intensity]));

  final Animation<double> phase;
  final Animation<double> intensity;
  final double radius;

  /// Tail to head: brand purple, violet, then a touch of cyan at the tip.
  final List<Color> colors;
  final double haloOpacity;

  /// How much of the outline the band covers at once.
  static const bandFraction = 0.2;
  static const strokeWidth = 1.5;
  static const _pieces = 24;

  // Per painter, not static: Home and Profile both keep a border alive
  // behind the shell's IndexedStack, and one shared slot would be
  // recomputed every frame as the two sizes took turns in it.
  Size? _cachedSize;
  double? _cachedRadius;
  ui.PathMetric? _cachedMetric;

  ui.PathMetric _metricFor(Size size) {
    if (_cachedSize == size && _cachedRadius == radius) return _cachedMetric!;
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
    _cachedSize = size;
    _cachedRadius = radius;
    return _cachedMetric = (Path()..addRRect(rrect)).computeMetrics().first;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final strength = intensity.value;
    if (strength <= 0 || size.isEmpty) return;
    final metric = _metricFor(size);
    final length = metric.length;
    final band = length * bandFraction;
    final head = phase.value * length;

    // Path.addRRect starts on the left edge, just under the top-left
    // corner; shifting by that corner puts phase 0 at the top edge.
    final start = head - band + radius * (math.pi / 2);

    Path extract(double from, double to) {
      final span = to - from;
      from %= length;
      to = from + span;
      if (to <= length) return metric.extractPath(from, to);
      return metric.extractPath(from, length)
        ..addPath(metric.extractPath(0, to - length), Offset.zero);
    }

    // Halo: the whole band once, blurred and faint.
    canvas.drawPath(
      extract(start + band * 0.35, start + band),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = colors[1].withValues(alpha: haloOpacity * strength)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Line: faint at the tail, brightest just before the head.
    // Butt caps: the pieces meet edge to edge. Round caps overlapped at
    // every joint and read as a dashed line.
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    final step = band / _pieces;
    for (var i = 0; i < _pieces; i++) {
      final t = (i + 0.5) / _pieces;
      final alpha = math.sin(t * math.pi / 2) * (t > 0.92 ? (1 - t) / 0.08 : 1);
      line.color = _colorAt(t).withValues(alpha: 0.9 * alpha * strength);
      // A hair of overlap hides the anti-aliasing seam between pieces.
      canvas.drawPath(
        extract(start + i * step, start + (i + 1) * step + 0.4),
        line,
      );
    }
  }

  Color _colorAt(double t) => t < 0.6
      ? Color.lerp(colors[0], colors[1], t / 0.6)!
      : Color.lerp(colors[1], colors[2], (t - 0.6) / 0.4 * 0.6)!;

  @override
  bool shouldRepaint(_RunningLightPainter old) =>
      old.phase != phase ||
      old.intensity != intensity ||
      old.radius != radius ||
      old.haloOpacity != haloOpacity ||
      !_sameColors(old.colors, colors);

  static bool _sameColors(List<Color> a, List<Color> b) =>
      a.length == b.length &&
      Iterable<int>.generate(a.length).every((i) => a[i] == b[i]);
}
