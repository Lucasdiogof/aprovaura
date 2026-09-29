import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/shared/widgets/app_aura_loader.dart';

/// The app's one async-submit button: same height whether it shows its
/// label or a spinner (so the layout never jumps), already refuses a
/// second tap while [isLoading] is true.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  /// How much of the active fill a loading button keeps.
  static const loadingFillOpacity = 0.92;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      // A screen reader on a disabled-while-loading button would otherwise
      // just say "button, disabled": it keeps its name, and the loader
      // inside adds "Carregando" in the app's language.
      label: isLoading ? label : null,
      child: ElevatedButton(
        // Interaction: loading refuses taps exactly like disabled...
        onPressed: isLoading ? null : onPressed,
        // ...but not the look. Loading is "working on it", not "you can't
        // use this": the active violet stays (at ~92%) instead of the
        // faded disabled fill, so the loader inside reads clearly. A
        // really disabled button keeps the theme's disabled style.
        style: isLoading
            ? ElevatedButton.styleFrom(
                disabledBackgroundColor: colors.primaryFill.withValues(
                  alpha: loadingFillOpacity,
                ),
                disabledForegroundColor: colors.onPrimary,
              )
            : null,
        // Same height either way: the loader is smaller than the text line,
        // so the button never jumps.
        child: isLoading
            ? AppAuraLoader.small(
                palette: [
                  colors.onPrimary,
                  colors.onPrimary.withValues(alpha: 0.8),
                  colors.auraCyan,
                ],
              )
            : Text(label),
      ),
    );
  }
}
