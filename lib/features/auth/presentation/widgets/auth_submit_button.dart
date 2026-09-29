import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/auth/presentation/widgets/auth_layout.dart';
import 'package:aura/features/auth/presentation/widgets/auth_palette.dart';
import 'package:aura/shared/widgets/app_aura_loader.dart';
import 'package:aura/shared/widgets/app_button.dart';

/// The auth screens' main button ("Entrar", "Criar conta"): the violet
/// gradient of the references. Loading behaves exactly like [AppButton] --
/// the official small Aura loader in place of the label, the same height,
/// and a second tap refused until it is done. A null [onPressed] (the form
/// is not complete and valid yet) shows it faded and ignores taps.
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    required this.layout,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final AuthLayout layout;
  final String label;
  final VoidCallback? onPressed;

  /// How much a disabled button keeps, as the app theme does.
  static const disabledOpacity = 0.45;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final palette = AuthPalette.of(context);
    final colors = context.colors;
    final radius = BorderRadius.circular(AuthLayout.buttonRadius);
    final enabled = onPressed != null && !isLoading;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: !isLoading,
      child: Opacity(
        opacity: isLoading
            ? AppButton.loadingFillOpacity
            : onPressed == null
            ? disabledOpacity
            : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palette.buttonGradient,
            ),
            border: palette.buttonRim.a > 0
                ? Border.all(color: palette.buttonRim)
                : null,
            boxShadow: [
              BoxShadow(
                color: palette.buttonShadow,
                blurRadius: 18,
                spreadRadius: -6,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              onTap: enabled ? onPressed : null,
              child: SizedBox(
                height: layout.buttonHeight,
                child: Center(
                  child: isLoading
                      ? AppAuraLoader.small(
                          palette: [
                            colors.onPrimary,
                            colors.onPrimary.withValues(alpha: 0.8),
                            colors.auraCyan,
                          ],
                        )
                      : Text(
                          label,
                          style: TextStyle(
                            fontSize: layout.buttonTextSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
