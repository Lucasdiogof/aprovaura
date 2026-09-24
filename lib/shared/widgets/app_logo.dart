import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The Aprovaura brand marks, as shipped in `lib/assets/branding`.
///
/// [AppLogo.wordmark] is the horizontal logo (symbol + "Aprovaura") and scales
/// with the space it is given, so the same widget reads well on a phone and
/// on a wide web window without ever stretching the artwork.
/// [AppLogo.mark] is the monogram on its own, for headers where the wordmark
/// would compete with a page title.
class AppLogo extends StatelessWidget {
  const AppLogo.wordmark({super.key, this.maxWidth = 260}) : size = null;

  const AppLogo.mark({super.key, double this.size = 56}) : maxWidth = null;

  /// Same artwork; only the "Aprov" lettering differs. The dark file is the
  /// official asset (near-white "Aprov", for dark surfaces); the light file
  /// recolors just those pixels to the light theme's text color so it reads
  /// on light surfaces -- symbol, gradient "aura" and type are untouched.
  static const _logoLight = 'lib/assets/branding/aprovaura_logo_light.png';
  static const _logoDark = 'lib/assets/branding/aprovaura_logo_dark.png';
  static const _markAsset = 'lib/assets/branding/aprovaura_mark.png';
  static const _semanticLabel = 'Aprovaura';

  static const _minWordmarkWidth = 160.0;

  /// Upper bound for the wordmark's width; null for [AppLogo.mark].
  final double? maxWidth;

  /// Width of the monogram; null for [AppLogo.wordmark].
  final double? size;

  @override
  Widget build(BuildContext context) {
    final size = this.size;
    if (size != null) {
      return Image.asset(
        _markAsset,
        width: size,
        fit: BoxFit.contain,
        semanticLabel: _semanticLabel,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final upper = maxWidth!;
        final width = math.min<double>(
          available,
          (available * 0.62)
              .clamp(math.min(_minWordmarkWidth, upper), upper)
              .toDouble(),
        );
        return Image.asset(
          isDark ? _logoDark : _logoLight,
          width: width,
          fit: BoxFit.contain,
          semanticLabel: _semanticLabel,
        );
      },
    );
  }
}
