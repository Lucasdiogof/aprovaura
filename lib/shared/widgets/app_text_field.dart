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
    this.labelText,
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

  /// A real, static label above the field (e.g. "E-mail") -- distinct from
  /// [hintText], which stays inside the field as a discreet example
  /// ("seuemail@exemplo.com"). Optional so fields that only ever had a
  /// hint (most of the app, so far) don't change.
  final String? labelText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final field = TextField(
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
            ? Icon(prefixIcon, size: 19, color: colors.textSecondary)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
    final label = labelText;
    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
        ),
        field,
      ],
    );
  }
}
