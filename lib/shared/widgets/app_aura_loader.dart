import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/shared/l10n/shared_strings.dart';

/// The Aprovaura loader: three four-pointed sparkles orbiting an invisible
/// centre -- Aura moving, not a spinner with a star on top. The one
/// "something is being processed" sign in the app, from a button to a
/// blocking overlay; Aurudo never appears here (he is a reward, not a
/// wait).
///
/// Only the painter repaints each frame (the controller drives it through
/// `repaint:`, inside a [RepaintBoundary]); nothing around it rebuilds.
/// Under reduced motion it is a still composition and no ticker runs at
/// all.
class AppAuraLoader extends StatefulWidget {
  const AppAuraLoader({
    super.key,
    this.size = mediumSize,
    this.color,
    this.palette,
    this.semanticsLabel,
  });

  /// Inside a button.
  const AppAuraLoader.small({
    super.key,
    this.color,
    this.palette,
    this.semanticsLabel,
  }) : size = smallSize;

  /// In a card, a list, a screen section.
  const AppAuraLoader.medium({
    super.key,
    this.color,
    this.palette,
    this.semanticsLabel,
  }) : size = mediumSize;

  /// On the blocking overlay or a whole screen.
  const AppAuraLoader.large({
    super.key,
    this.color,
    this.palette,
    this.semanticsLabel,
  }) : size = largeSize;

  static const smallSize = 20.0;
  static const mediumSize = 32.0;
  static const largeSize = 52.0;

  /// One lap of the orbit.
  static const lapDuration = Duration(milliseconds: 1400);

  final double size;

  /// All three sparkles in this one colour (at different strengths), for
  /// a loader sitting on a brand-coloured surface where the brand colours
  /// would vanish -- white inside a filled button. Null uses the brand:
  /// violet, light purple and Aura cyan.
  final Color? color;

  /// Main, secondary and small sparkle colours, for a surface that needs
  /// its own mix -- white with a touch of cyan on a violet button. Wins
  /// over [color] when both are given.
  final List<Color>? palette;

  /// What a screen reader says. Defaults to "Carregando" in the app's
  /// language; pass the specific action ("Saindo...") where there is one.
  final String? semanticsLabel;

  @override
  State<AppAuraLoader> createState() => _AppAuraLoaderState();
}

class _AppAuraLoaderState extends State<AppAuraLoader>
    with TickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      // Still composition: no controller, no ticker, nothing running.
      _controller?.dispose();
      _controller = null;
    } else {
      _controller ??= AnimationController(
        vsync: this,
        duration: AppAuraLoader.lapDuration,
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _defaultLabel() {
    // Loaders also live in places without the app's locale provider (a
    // bare widget in a test, a button built very early): fall back to
    // Portuguese rather than fail.
    AppLanguage language;
    try {
      language = context.read<LocaleCubit>().state;
    } on ProviderNotFoundException {
      language = AppLanguage.portuguese;
    }
    return SharedStrings(language).loadingLabel;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final single = widget.color;
    final palette =
        widget.palette ??
        (single == null
            ? [colors.primary, colors.auraViolet, colors.auraCyan]
            : [
                single,
                single.withValues(alpha: 0.75),
                single.withValues(alpha: 0.6),
              ]);
    return Semantics(
      label: widget.semanticsLabel ?? _defaultLabel(),
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: widget.size,
          child: CustomPaint(
            painter: _SparklesPainter(
              progress:
                  _controller ??
                  const AlwaysStoppedAnimation<double>(_stillPhase),
              palette: palette,
              // A faint halo where there is contrast to spare: dark mode,
              // brand colours only (never around white-on-violet).
              halo: isDark && single == null && widget.palette == null,
            ),
          ),
        ),
      ),
    );
  }

  /// Where the still (reduced-motion) composition sits: spread out, the
  /// main sparkle top-right.
  static const _stillPhase = 0.12;
}

class _SparklesPainter extends CustomPainter {
  _SparklesPainter({
    required this.progress,
    required this.palette,
    required this.halo,
  }) : super(repaint: progress);

  final Animation<double> progress;

  /// Main, secondary, small.
  final List<Color> palette;
  final bool halo;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    final wave = math.cos(2 * math.pi * t);
    final center = size.center(Offset.zero);
    final orbit = size.shortestSide * 0.28;
    final lap = 2 * math.pi * t;

    // Same orbit, different phase, size and breathing for each: depth
    // without anything flashing.
    final sparkles = [
      // Main: breathes 0.80 -> 1.0 -> 0.80.
      (angle: lap, radius: 0.24, scale: 0.9 + 0.1 * wave, opacity: 1.0),
      // Secondary: 1.0 -> 0.75 -> 1.0, out of step with the main one.
      (
        angle: lap + 2.3,
        radius: 0.18,
        scale: 0.875 - 0.125 * wave,
        opacity: 0.95,
      ),
      // Small: only its strength changes, gently.
      (angle: lap + 4.3, radius: 0.12, scale: 1.0, opacity: 0.7 + 0.25 * wave),
    ];

    for (var i = 0; i < sparkles.length; i++) {
      final s = sparkles[i];
      final at = center + Offset(math.cos(s.angle), math.sin(s.angle)) * orbit;
      final r = size.shortestSide * s.radius * s.scale;
      final color = palette[i];
      if (halo) {
        canvas.drawPath(
          _sparkle(at, r * 1.45),
          Paint()..color = color.withValues(alpha: 0.16 * s.opacity),
        );
      }
      canvas.drawPath(
        _sparkle(at, r),
        Paint()..color = color.withValues(alpha: color.a * s.opacity),
      );
    }
  }

  /// A four-pointed star: points up, right, down and left, with concave
  /// sides pulled in toward the centre.
  static Path _sparkle(Offset c, double r) {
    final k = r * 0.16;
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + k, c.dy - k, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + k, c.dy + k, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - k, c.dy + k, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - k, c.dy - k, c.dx, c.dy - r)
      ..close();
  }

  @override
  bool shouldRepaint(_SparklesPainter old) =>
      old.progress != progress ||
      old.halo != halo ||
      old.palette.length != palette.length ||
      Iterable<int>.generate(
        palette.length,
      ).any((i) => old.palette[i] != palette[i]);
}
