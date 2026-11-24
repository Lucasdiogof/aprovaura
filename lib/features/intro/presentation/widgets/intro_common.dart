import 'package:material_ui/material_ui.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/intro/presentation/widgets/intro_scene.dart';

/// Every visual is drawn in one design box and scaled to the space it gets.
const kIntroBox = Size(320, 360);

/// Fade + rise used by most pieces.
Widget introPop(double p, Widget child, {double dy = 14}) => Opacity(
  opacity: p,
  child: Transform.translate(offset: Offset(0, (1 - p) * dy), child: child),
);

/// Soft violet/cyan halo behind a scene.
class IntroGlow extends StatelessWidget {
  const IntroGlow({required this.size, this.opacity = 0.28, super.key});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              c.auraViolet.withValues(alpha: opacity),
              c.auraCyan.withValues(alpha: opacity * 0.35),
              c.auraViolet.withValues(alpha: 0),
            ],
            stops: const [0, 0.5, 1],
          ),
        ),
      ),
    );
  }
}

class IntroCard extends StatelessWidget {
  const IntroCard({required this.child, this.width = 292, super.key});

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.auraViolet.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IntroChip extends StatelessWidget {
  const _IntroChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c.auraViolet),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Feature chips that pop in one after the other starting at [from].
Widget introChips(double t, double from, List<(String, IconData)> items) =>
    Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < items.length; i++)
          Builder(
            builder: (_) {
              final p = introSeg(t, from + i * 0.06, from + 0.2 + i * 0.06);
              return Transform.scale(
                scale: 0.85 + 0.15 * p,
                child: Opacity(
                  opacity: p,
                  child: _IntroChip(label: items[i].$1, icon: items[i].$2),
                ),
              );
            },
          ),
      ],
    );
