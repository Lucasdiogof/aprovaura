import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

/// The one spinner the app uses everywhere loading needs a visual: inside
/// [AppButton] while it submits, inside [AppLoadingOverlay], and anywhere
/// else that used to reach for a bare `CircularProgressIndicator` sized by
/// hand. Same stroke, same brand colour, one place to change either.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.size = 22, this.color});

  final double size;

  /// Defaults to [AppColors.loadingIndicator]. Only overridden where the
  /// spinner sits on a colour that needs a different one for contrast
  /// (e.g. white on a solid brand-violet button).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        strokeWidth: size <= 24 ? 2.5 : 3,
        color: color ?? context.colors.loadingIndicator,
      ),
    );
  }
}
