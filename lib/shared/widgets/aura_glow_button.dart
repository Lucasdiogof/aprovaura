import 'package:material_ui/material_ui.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/aura/aura_animated_border.dart';

/// The primary call to action of the purchase flow and onboarding: an
/// [AppButton] with the same running light around its edge as Home's daily
/// goal card ([AuraAnimatedBorder]) and a soft violet halo under it.
///
/// The light only runs while the button can be tapped; a disabled or
/// loading button is just the plain button. Reduced motion gets the still
/// highlight (handled by [AuraAnimatedBorder]).
class AuraGlowButton extends StatelessWidget {
  const AuraGlowButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Matches the theme's elevated button shape.
  static const radius = 16.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final live = onPressed != null && !isLoading;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: live
            ? [
                BoxShadow(
                  color: colors.auraViolet.withValues(alpha: 0.30),
                  blurRadius: 22,
                  spreadRadius: -2,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: AuraAnimatedBorder(
        active: live,
        borderRadius: radius,
        child: AppButton(
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
        ),
      ),
    );
  }
}
