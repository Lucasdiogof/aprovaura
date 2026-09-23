import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.hintText,
    super.key,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.errorText,
    this.fillColor,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
  });

  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? errorText;

  /// Overrides the theme's fill. Fields inside a surface-coloured card use
  /// the page background here, so they read as inset instead of dissolving
  /// into the card.
  final Color? fillColor;

  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      style: TextStyle(color: colors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        fillColor: fillColor,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: colors.textSecondary)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
