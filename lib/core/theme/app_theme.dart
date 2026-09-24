import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _themeFor(AppColors.light, Brightness.light);

  static ThemeData get dark => _themeFor(AppColors.dark, Brightness.dark);

  static ThemeData _themeFor(AppColors colors, Brightness brightness) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        surface: colors.surface,
        error: colors.error,
        onError: colors.onPrimary,
      ),
      extensions: [colors],
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        hintStyle: base.textTheme.bodyMedium?.copyWith(color: colors.textHint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryFill,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.primaryFill.withValues(alpha: 0.45),
          disabledForegroundColor: colors.onPrimary.withValues(alpha: 0.8),
          // Flat: the brand violet carries the emphasis; a drop shadow on a
          // dark surface just reads as a dirty outline.
          elevation: 0,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: base.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.primary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceElevated,
        modalBackgroundColor: colors.surfaceElevated,
      ),
      dialogTheme: DialogThemeData(backgroundColor: colors.surfaceElevated),
      popupMenuTheme: PopupMenuThemeData(color: colors.surfaceElevated),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.textPrimary,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(
          color: colors.background,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
