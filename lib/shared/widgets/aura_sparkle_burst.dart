import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A few four-point sparkles that drift away from a point and vanish.
///
/// Drawn as paths, never emoji or images: they have to take the theme's
/// colours and stay crisp at any density. The burst plays once and leaves
/// nothing behind -- nothing here pulses, loops, or sits on screen after
/// it is done.
///
/// It paints only while [controller] is running, so a bar that is not
/// animating costs one `AnimatedBuilder` that never rebuilds.
class AuraSparkleBurst extends StatelessWidget {
  const AuraSparkleBurst({
    required this.controller,
    required this.colors,
    super.key,
  });

  final Animation<double> controller;

  /// Cycled through the sparkles. Passed in as theme tokens so the burst
  /// follows the palette instead of carrying colours of its own.
  final List<Color> colors;

  /// Three, of different sizes, leaving in different directions. Four was
  /// the ceiling and three already reads as a burst; more turns a tab
  /// change into confetti.
  static const _sparkles = [
    (angle: -0.6, distance: 13.0, size: 4.6, delay: 0.00),
    (angle: -2.4, distance: 11.0, size: 3.2, delay: 0.14),
    (angle: 1.1, distance: 9.0, size: 3.8, delay: 0.24),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => CustomPaint(
            painter: _SparkleBurstPainter(
              progress: controller.value,
              colors: colors,
            ),
          ),
        ),
      ),
    );
  }
}

class _SparkleBurstPainter extends CustomPainter {
  _SparkleBurstPainter({required this.progress, required this.colors});

  final double progress;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = Offset(size.width / 2, size.height / 2);

    for (final (index, sparkle) in AuraSparkleBurst._sparkles.indexed) {
      // Each one starts a little later, so they read as a burst rather
      // than one thing that happens to have three parts.
      final span = 1 - sparkle.delay;
      final t = ((progress - sparkle.delay) / span).clamp(0.0, 1.0);
      if (t <= 0 || t >= 1) continue;

      // In fast, out slower: a linear fade looks like a dimmer switch.
      final opacity = t < 0.35 ? t / 0.35 : 1 - (t - 0.35) / 0.65;
      final scale = t < 0.5 ? 0.5 + t : 1 - (t - 0.5) * 0.4;
      final travel = sparkle.distance * Curves.easeOutCubic.transform(t);
      final offset =
          center +
          Offset(
            math.cos(sparkle.angle) * travel,
            math.sin(sparkle.angle) * travel,
          );

      canvas
        ..save()
        ..translate(offset.dx, offset.dy)
        // A quarter turn over its life: enough to catch the eye, not
        // enough to look like it is spinning.
        ..rotate(t * 0.4)
        ..drawPath(
          _sparklePath(sparkle.size * scale),
          Paint()
            ..color = colors[index % colors.length].withValues(
              alpha: opacity.clamp(0.0, 1.0),
            )
            ..isAntiAlias = true,
        )
        ..restore();
    }
  }

  /// A four-point star with a pinched waist: straight lines would give a
  /// diamond, so the sides curve in towards the centre.
  static Path _sparklePath(double radius) {
    const waist = 0.26;
    final w = radius * waist;
    return Path()
      ..moveTo(0, -radius)
      ..quadraticBezierTo(w, -w, radius, 0)
      ..quadraticBezierTo(w, w, 0, radius)
      ..quadraticBezierTo(-w, w, -radius, 0)
      ..quadraticBezierTo(-w, -w, 0, -radius)
      ..close();
  }

  @override
  bool shouldRepaint(_SparkleBurstPainter old) =>
      old.progress != progress || old.colors != colors;
}
