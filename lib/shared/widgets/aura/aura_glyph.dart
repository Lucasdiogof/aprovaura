import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

/// The Aura mark: the four-point star from the Aprovaura logo, drawn as a
/// vector and filled with the brand gradient. It is the unit symbol of Aura
/// (the score) -- used next to Aura amounts, never as decoration on its own.
class AuraGlyph extends StatelessWidget {
  const AuraGlyph({this.size = 18, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: AuraStarPainter(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colors.auraViolet, colors.auraCyan],
            ),
          ),
        ),
      ),
    );
  }
}

/// Four-point star with concave sides (the logo's sparkle). Public so other
/// brand elements (e.g. a future selection sparkle) share the exact shape.
class AuraStarPainter extends CustomPainter {
  const AuraStarPainter({required this.gradient, this.waist = 0.18});

  final Gradient gradient;

  /// How far the sides pinch toward the center (0 = diamond, 0.5 = cross).
  final double waist;

  static Path starPath(Size size, {double waist = 0.18}) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final pinchX = w * waist;
    final pinchY = h * waist;
    return Path()
      ..moveTo(cx, 0)
      ..quadraticBezierTo(cx + pinchX * 0.35, cy - pinchY * 0.35, w, cy)
      ..quadraticBezierTo(cx + pinchX * 0.35, cy + pinchY * 0.35, cx, h)
      ..quadraticBezierTo(cx - pinchX * 0.35, cy + pinchY * 0.35, 0, cy)
      ..quadraticBezierTo(cx - pinchX * 0.35, cy - pinchY * 0.35, cx, 0)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawPath(
      starPath(size, waist: waist),
      Paint()
        ..isAntiAlias = true
        ..shader = gradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(AuraStarPainter oldDelegate) =>
      oldDelegate.gradient != gradient || oldDelegate.waist != waist;
}
