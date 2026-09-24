import 'package:flutter/material.dart';

/// Aprovaura palette. Values follow the brand brief exactly, with one
/// accessibility adaptation: [primary] is the *content* color (text, icons,
/// outlines, progress on app surfaces) and must stay legible on them. On the
/// light theme that is the brand violet #7C3AED itself (5.7:1 on white). On
/// the dark theme #7C3AED is only 3.3:1 on the #0B0F1A background and 2.6:1
/// on #1F2937 cards, so content uses #A78BFA -- the light step of the same
/// violet family (7.0:1 / 5.4:1). Solid brand surfaces with white content
/// (the main button, selected badges) keep #7C3AED via [primaryFill] on both
/// themes (white on it: 5.7:1).
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.primary,
    required this.primaryFill,
    required this.onPrimary,
    required this.secondary,
    required this.auraViolet,
    required this.auraCyan,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.border,
    required this.error,
    required this.success,
    required this.warning,
  });

  /// Page background.
  final Color background;

  /// Cards, rows, list containers.
  final Color surface;

  /// Bottom sheets and dialogs.
  final Color surfaceElevated;

  /// Brand violet for content on app surfaces (see class doc).
  final Color primary;

  /// Brand violet #7C3AED as a solid fill; pair with [onPrimary].
  final Color primaryFill;

  /// Content on [primaryFill].
  final Color onPrimary;

  /// Tonal, quieter surface (segmented controls, neutral chips, tracks).
  final Color secondary;

  /// "Secondary Aura" #A855F7 -- brand accent for Aura moments.
  final Color auraViolet;

  /// "Accent Cyan" #22D3EE -- the other end of the Aura gradient.
  final Color auraCyan;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color border;
  final Color error;
  final Color success;
  final Color warning;

  /// The brand gradient. Reserved for the logo, Aura rewards and
  /// celebrations -- never as a general background.
  LinearGradient get auraGradient => LinearGradient(
    colors: [primaryFill, auraViolet, auraCyan],
    stops: const [0, 0.45, 1],
  );

  static const light = AppColors(
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    primary: Color(0xFF7C3AED),
    primaryFill: Color(0xFF7C3AED),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFEEF2F7),
    auraViolet: Color(0xFFA855F7),
    auraCyan: Color(0xFF22D3EE),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF475569),
    textHint: Color(0xFF94A3B8),
    border: Color(0xFFCBD5E1),
    error: Color(0xFFDC2626),
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
  );

  static const dark = AppColors(
    background: Color(0xFF0B0F1A),
    surface: Color(0xFF1F2937),
    surfaceElevated: Color(0xFF111827),
    primary: Color(0xFFA78BFA),
    primaryFill: Color(0xFF7C3AED),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF111827),
    auraViolet: Color(0xFFA855F7),
    auraCyan: Color(0xFF22D3EE),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFFCBD5E1),
    textHint: Color(0xFF64748B),
    border: Color(0xFF334155),
    error: Color(0xFFEF4444),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? primary,
    Color? primaryFill,
    Color? onPrimary,
    Color? secondary,
    Color? auraViolet,
    Color? auraCyan,
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
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      primary: primary ?? this.primary,
      primaryFill: primaryFill ?? this.primaryFill,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      auraViolet: auraViolet ?? this.auraViolet,
      auraCyan: auraCyan ?? this.auraCyan,
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
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceElevated: mix(surfaceElevated, other.surfaceElevated),
      primary: mix(primary, other.primary),
      primaryFill: mix(primaryFill, other.primaryFill),
      onPrimary: mix(onPrimary, other.onPrimary),
      secondary: mix(secondary, other.secondary),
      auraViolet: mix(auraViolet, other.auraViolet),
      auraCyan: mix(auraCyan, other.auraCyan),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textHint: mix(textHint, other.textHint),
      border: mix(border, other.border),
      error: mix(error, other.error),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
