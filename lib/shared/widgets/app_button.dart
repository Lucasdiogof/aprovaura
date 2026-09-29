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

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // A screen reader on a disabled-while-loading button would otherwise
      // just say "button, disabled": it keeps its name, and the loader
      // inside adds "Carregando" in the app's language.
      label: isLoading ? label : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        // Same height either way: the loader is smaller than the text line,
        // so the button never jumps.
        child: isLoading
            ? AppAuraLoader.small(color: context.colors.onPrimary)
            : Text(label),
      ),
    );
  }
}
