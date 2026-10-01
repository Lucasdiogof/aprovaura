import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

/// How [AuraParticles] move: [converge] pulls small shapes in from the
/// edge toward the centre (the perfect/daily-goal placeholder -- "energy
/// gathering into the mascot"), [burst] pushes them out from the centre
/// and fades them (great), [ambient] barely moves them at
/// all, just a soft twinkle (writing).
enum AuraParticlesStyle { converge, burst, ambient }

/// A short, one-shot scatter of small Aura-coloured shapes (four-point
/// sparkles and dots, violet/cyan -- nothing rainbow) around whatever this
/// is stacked behind. Runs its animation once per mount and stops: no
/// repeating loop, no ticking once the burst finishes, nothing left
/// running once the scene using it is gone.
class AuraParticles extends StatefulWidget {
  const AuraParticles({required this.style, this.count = 8, super.key});

  final AuraParticlesStyle style;
  final int count;

  static const duration = Duration(milliseconds: 1400);

  @override
  State<AuraParticles> createState() => _AuraParticlesState();
}

class _AuraParticlesState extends State<AuraParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AuraParticles.duration,
  );
  late List<_Particle> _particles = _generate(widget.style, widget.count);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.value == 0 && !_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AuraParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.style == widget.style && oldWidget.count == widget.count) {
      return;
    }
    _particles = _generate(widget.style, widget.count);
    if (!MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static List<_Particle> _generate(AuraParticlesStyle style, int count) {
    // A fixed seed, not a fresh Random() per build: the scatter should
    // look considered, not flicker into a different layout on every
    // rebuild of the same reaction.
    final random = math.Random(count * 31 + style.index);
    return List.generate(count, (i) {
      final angle = (i / count) * 2 * math.pi + random.nextDouble() * 0.5;
      return _Particle(
        angle: angle,
        distance: 0.5 + random.nextDouble() * 0.4,
        delay: random.nextDouble() * 0.35,
        colorIndex: random.nextInt(3),
        sparkle: random.nextBool(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _AuraParticlesPainter(
          progress: _controller,
          particles: _particles,
          style: widget.style,
          palette: [colors.primary, colors.auraViolet, colors.auraCyan],
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.distance,
    required this.delay,
    required this.colorIndex,
    required this.sparkle,
  });

  /// Direction from the centre, in radians.
  final double angle;

  /// How far out this particle's path reaches, as a fraction of the
  /// painted area's half-diagonal.
  final double distance;

  /// Fraction of the animation this particle waits before it starts
  /// moving -- staggers the scatter instead of every piece moving in
  /// lockstep.
  final double delay;
  final int colorIndex;
  final bool sparkle;
}

class _AuraParticlesPainter extends CustomPainter {
  _AuraParticlesPainter({
    required this.progress,
    required this.particles,
    required this.style,
    required this.palette,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final List<_Particle> particles;
  final AuraParticlesStyle style;
  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    for (final particle in particles) {
      final local = ((progress.value - particle.delay) / (1 - particle.delay))
          .clamp(0.0, 1.0);
      if (local <= 0) continue;

      final reach = radius * particle.distance;
      final travel = switch (style) {
        // Starts near the edge, ends near the centre: energy arriving.
        AuraParticlesStyle.converge => 1 - local,
        // Starts near the centre, ends near the edge: energy leaving.
        AuraParticlesStyle.burst => local,
        // Barely moves; it's a twinkle, not a launch.
        AuraParticlesStyle.ambient => 0.85,
      };
      final position =
          center +
          Offset(math.cos(particle.angle), math.sin(particle.angle)) *
              reach *
              travel;

      // Fades in, holds, fades out -- never appears or vanishes with a
      // hard edge.
      final alpha = switch (style) {
        AuraParticlesStyle.ambient => (math.sin(local * math.pi) * 0.8),
        _ => math.sin((local * math.pi).clamp(0, math.pi)),
      };
      if (alpha <= 0) continue;

      final color = palette[particle.colorIndex % palette.length].withValues(
        alpha: alpha.clamp(0.0, 1.0),
      );
      final particleSize = 3.0 + 3.0 * (1 - local * 0.4);
      if (particle.sparkle) {
        _paintSparkle(canvas, position, particleSize, color);
      } else {
        canvas.drawCircle(
          position,
          particleSize * 0.55,
          Paint()..color = color,
        );
      }
    }
  }

  void _paintSparkle(Canvas canvas, Offset at, double size, Color color) =>
      paintAuraSparkle(canvas, at, size, color);

  @override
  bool shouldRepaint(_AuraParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.style != style ||
      !identical(oldDelegate.particles, particles);
}

/// The four-point sparkle every Aura particle uses, shared so each scene
/// (these particles, the farm-Aura animation) draws the same shape.
void paintAuraSparkle(Canvas canvas, Offset at, double size, Color color) {
  final path = Path()
    ..moveTo(at.dx, at.dy - size)
    ..lineTo(at.dx + size * 0.28, at.dy - size * 0.28)
    ..lineTo(at.dx + size, at.dy)
    ..lineTo(at.dx + size * 0.28, at.dy + size * 0.28)
    ..lineTo(at.dx, at.dy + size)
    ..lineTo(at.dx - size * 0.28, at.dy + size * 0.28)
    ..lineTo(at.dx - size, at.dy)
    ..lineTo(at.dx - size * 0.28, at.dy - size * 0.28)
    ..close();
  canvas.drawPath(path, Paint()..color = color);
}
