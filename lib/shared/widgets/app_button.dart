import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/shared/widgets/app_loading_indicator.dart';

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
      // just say "button, disabled" -- this says why.
      label: isLoading ? label : null,
      value: isLoading ? 'loading' : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? AppLoadingIndicator(color: context.colors.onPrimary)
            : Text(label),
      ),
    );
  }
}
