import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.border,
    required this.error,
    required this.success,
    required this.warning,
  });

  final Color background;
  final Color surface;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color border;
  final Color error;
  final Color success;
  final Color warning;

  static const light = AppColors(
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF1E3A5F),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFE8EDF5),
    textPrimary: Color(0xFF12161C),
    textSecondary: Color(0xFF5B6470),
    textHint: Color(0xFF9AA1AC),
    border: Color(0xFFE1E4EA),
    error: Color(0xFFD64545),
    success: Color(0xFF2E9E6B),
    warning: Color(0xFFE0A22D),
  );

  static const dark = AppColors(
    background: Color(0xFF0B0E14),
    surface: Color(0xFF151920),
    primary: Color(0xFF4C7CD1),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF1E2530),
    textPrimary: Color(0xFFF2F4F7),
    textSecondary: Color(0xFFA7AEB8),
    textHint: Color(0xFF6B7280),
    border: Color(0xFF262B33),
    error: Color(0xFFFF6B6B),
    success: Color(0xFF4CC38A),
    warning: Color(0xFFF2C063),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? border,
    Color? error,
    Color? success,
    Color? warning,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      border: border ?? this.border,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      border: Color.lerp(border, other.border, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
