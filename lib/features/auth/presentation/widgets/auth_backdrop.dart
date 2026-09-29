import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:aura/features/auth/presentation/widgets/auth_palette.dart';

/// The auth screens' background, as in the approved references: soft
/// washes of light at the edges, a thin curve at the top right and two
/// across the bottom, misty hills along the bottom edge, two sparkles and
/// a few dots. Painted once (nothing moves), in fractions of the screen,
/// so it sits the same on every phone and in both themes -- only the
/// colours come from [AuthPalette].
class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = AuthPalette.of(context);
    return ColoredBox(
      color: palette.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: _BackdropPainter(palette)),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter(this.palette);

  final AuthPalette palette;

  static const _dots = [
    Offset(0.21, 0.118),
    Offset(0.13, 0.149),
    Offset(0.052, 0.168),
    Offset(0.90, 0.160),
    Offset(0.94, 0.194),
    Offset(0.968, 0.320),
    Offset(0.035, 0.780),
    Offset(0.32, 0.815),
    Offset(0.41, 0.828),
    Offset(0.65, 0.848),
    Offset(0.91, 0.800),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    Offset at(double x, double y) => Offset(x * w, y * h);

    void glow(Offset center, double radius, Color color) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(center, radius, [
            color,
            color.withValues(alpha: 0),
          ]),
      );
    }

    glow(at(0.5, -0.06), w * 0.70, palette.glowTop);
    glow(at(-0.04, 0.34), w * 0.46, palette.glowLeft);
    glow(at(1.04, 0.26), w * 0.38, palette.glowRight);
    glow(at(0.62, 0.86), w * 0.40, palette.glowLow);

    // A hill: its outline, filled with [color] that fades out towards the
    // bottom edge (mist), with a soft edge and, on dark, light on the crest.
    void hill(Path crest, double endX, Color color, {Color? rim}) {
      final bounds = crest.getBounds();
      final fill = Path.from(crest)
        ..lineTo(endX * w, h)
        ..lineTo(bounds.left, h)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
          ..shader = ui.Gradient.linear(
            Offset(0, bounds.top),
            Offset(0, h * 0.985),
            [color, color, color.withValues(alpha: 0)],
            [0, 0.5, 1],
          ),
      );
      if (rim != null && rim.a > 0) {
        canvas.drawPath(
          crest,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..color = rim
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
    }

    // Each crest runs from off one side to off the other (or under the
    // hill in front), so no hill has a hard vertical edge.
    hill(
      Path()
        ..moveTo(0.02 * w, 0.960 * h)
        ..cubicTo(0.12 * w, 0.880 * h, 0.16 * w, 0.842 * h, 0.24 * w, 0.842 * h)
        ..cubicTo(
          0.31 * w,
          0.842 * h,
          0.40 * w,
          0.890 * h,
          0.52 * w,
          0.960 * h,
        ),
      0.52,
      palette.hillPink,
    );
    hill(
      Path()
        ..moveTo(0, 0.930 * h)
        ..cubicTo(0.10 * w, 0.905 * h, 0.16 * w, 0.897 * h, 0.22 * w, 0.895 * h)
        ..cubicTo(0.38 * w, 0.885 * h, 0.56 * w, 0.852 * h, 0.72 * w, 0.860 * h)
        ..cubicTo(
          0.82 * w,
          0.865 * h,
          0.90 * w,
          0.832 * h,
          1.02 * w,
          0.828 * h,
        ),
      1.02,
      palette.hillRight,
      rim: palette.hillRimRight,
    );
    hill(
      Path()
        ..moveTo(-0.02 * w, 0.800 * h)
        ..cubicTo(0.10 * w, 0.788 * h, 0.24 * w, 0.845 * h, 0.36 * w, 0.895 * h)
        ..cubicTo(0.46 * w, 0.935 * h, 0.58 * w, 0.970 * h, 0.75 * w, 1.0 * h),
      0.75,
      palette.hillLeft,
      rim: palette.hillRimLeft,
    );

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = palette.decoLine;
    // Top right: in from the corner, bowing left, back out at the edge.
    canvas.drawPath(
      Path()
        ..moveTo(w, 0.040 * h)
        ..cubicTo(0.76 * w, 0.110 * h, 0.76 * w, 0.235 * h, w, 0.285 * h),
      line,
    );
    // Bottom: an S from the left edge down to the bottom-right corner.
    canvas.drawPath(
      Path()
        ..moveTo(0, 0.744 * h)
        ..cubicTo(0.30 * w, 0.780 * h, 0.40 * w, 0.890 * h, 0.55 * w, 0.932 * h)
        ..cubicTo(0.70 * w, 0.955 * h, 0.90 * w, 0.935 * h, w, 0.998 * h),
      line,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w, 0.880 * h)
        ..cubicTo(
          0.86 * w,
          0.915 * h,
          0.72 * w,
          0.925 * h,
          0.58 * w,
          0.925 * h,
        ),
      line..color = palette.decoLine.withValues(alpha: 0.3),
    );

    _sparkle(canvas, at(0.836, 0.099), w * 0.017, palette.sparkle);
    _sparkle(canvas, at(0.824, 0.815), w * 0.017, palette.sparkle);

    final dot = Paint()..color = palette.sparkle.withValues(alpha: 0.45);
    for (final d in _dots) {
      canvas.drawCircle(at(d.dx, d.dy), 1.1, dot);
    }
  }

  void _sparkle(Canvas canvas, Offset c, double r, Color color) =>
      _sparkleAt(canvas, c, r, color);

  static void _sparkleAt(Canvas canvas, Offset c, double r, Color color) {
    const k = 0.22;
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r * k, c.dy - r * k)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx + r * k, c.dy + r * k)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r * k, c.dy + r * k)
      ..lineTo(c.dx - r, c.dy)
      ..lineTo(c.dx - r * k, c.dy - r * k)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => old.palette != palette;
}

/// A lighter touch of [AuthBackdrop] for sheets opened over the auth
/// screens (password recovery): the sheet's own surface, the same washes
/// of light at its top corners, one thin curve and a sparkle -- no hills,
/// so the form stays the focus.
class AuthSheetBackdrop extends StatelessWidget {
  const AuthSheetBackdrop({required this.child, super.key});

  final Widget child;

  static const radius = BorderRadius.vertical(top: Radius.circular(28));

  @override
  Widget build(BuildContext context) {
    final palette = AuthPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.sheetFill,
        borderRadius: radius,
        border: Border(top: BorderSide(color: palette.cardBorder)),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(painter: _SheetPainter(palette)),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _SheetPainter extends CustomPainter {
  const _SheetPainter(this.palette);

  final AuthPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void glow(Offset center, double radius, Color color) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = ui.Gradient.radial(center, radius, [
            color,
            color.withValues(alpha: 0),
          ]),
      );
    }

    glow(Offset(w * 0.5, -h * 0.10), w * 0.60, palette.glowTop);
    glow(Offset(-w * 0.06, h * 0.30), w * 0.40, palette.glowLeft);
    glow(Offset(w * 1.06, h * 0.12), w * 0.36, palette.glowRight);

    canvas.drawPath(
      Path()
        ..moveTo(w, 0.02 * h)
        ..cubicTo(0.80 * w, 0.10 * h, 0.80 * w, 0.30 * h, w, 0.40 * h),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = palette.decoLine.withValues(alpha: 0.6),
    );
    _BackdropPainter._sparkleAt(
      canvas,
      Offset(0.12 * w, 0.14 * h),
      w * 0.016,
      palette.sparkle,
    );
    final dot = Paint()..color = palette.sparkle.withValues(alpha: 0.45);
    for (final d in const [
      Offset(0.22, 0.08),
      Offset(0.07, 0.30),
      Offset(0.86, 0.22),
      Offset(0.93, 0.52),
    ]) {
      canvas.drawCircle(Offset(d.dx * w, d.dy * h), 1.1, dot);
    }
  }

  @override
  bool shouldRepaint(_SheetPainter old) => old.palette != palette;
}
