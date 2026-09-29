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
  const AppLogo.wordmark({super.key, this.maxWidth = 260})
    : size = null,
      textWidth = null;

  const AppLogo.mark({super.key, double this.size = 56})
    : maxWidth = null,
      textWidth = null;

  /// "Aprovaura" alone, without the symbol, at exactly [width] -- for
  /// headers that stack the symbol above the name (the auth screens).
  const AppLogo.text({super.key, required double width})
    : textWidth = width,
      size = null,
      maxWidth = null;

  /// Same artwork; only the "Aprov" lettering differs. The dark file is the
  /// official asset (near-white "Aprov", for dark surfaces); the light file
  /// recolors just those pixels to the light theme's text color so it reads
  /// on light surfaces -- symbol, gradient "aura" and type are untouched.
  static const _logoLight = 'lib/assets/branding/aprovaura_logo_light.png';
  static const _logoDark = 'lib/assets/branding/aprovaura_logo_dark.png';
  static const _markAsset = 'lib/assets/branding/aprovaura_mark.png';
  static const _textLight = 'lib/assets/branding/aprovaura_wordmark_light.png';
  static const _textDark = 'lib/assets/branding/aprovaura_wordmark_dark.png';
  static const _semanticLabel = 'Aprovaura';

  static const _minWordmarkWidth = 160.0;

  // Width / height of each file, so the widget has its final height before
  // the image is decoded: without it, the first frame lays out at height 0
  // and everything under the logo jumps (or an AnimatedSize around it
  // grows) once the image arrives.
  static const _markAspect = 512 / 398;
  static const _textAspect = 1400 / 301;

  /// Upper bound for the wordmark's width; null for [AppLogo.mark].
  final double? maxWidth;

  /// Width of the monogram; null for the other variants.
  final double? size;

  /// Width of the name alone; null for the other variants.
  final double? textWidth;

  @override
  Widget build(BuildContext context) {
    final size = this.size;
    if (size != null) {
      return Image.asset(
        _markAsset,
        width: size,
        height: size / _markAspect,
        fit: BoxFit.contain,
        semanticLabel: _semanticLabel,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textWidth = this.textWidth;
    if (textWidth != null) {
      return Image.asset(
        isDark ? _textDark : _textLight,
        width: textWidth,
        height: textWidth / _textAspect,
        fit: BoxFit.contain,
        semanticLabel: _semanticLabel,
      );
    }
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
