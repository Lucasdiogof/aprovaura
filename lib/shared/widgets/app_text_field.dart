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
  });

  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: context.colors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: context.colors.textSecondary)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
