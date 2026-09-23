import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The brand marks, as shipped in `lib/assets/branding`.
///
/// [AppLogo.wordmark] is the horizontal logo (symbol + "aura") and scales
/// with the space it is given, so the same widget reads well on a phone and
/// on a wide web window without ever stretching the artwork.
/// [AppLogo.mark] is the monogram on its own, for headers where the wordmark
/// would compete with a page title.
class AppLogo extends StatelessWidget {
  const AppLogo.wordmark({super.key, this.maxWidth = 260}) : size = null;

  const AppLogo.mark({super.key, double this.size = 56}) : maxWidth = null;

  /// Only the wordmark's fill differs between these two: on the dark theme
  /// the navy lettering of the original would be all but invisible.
  static const _logo = 'lib/assets/branding/aura_logo.png';
  static const _logoOnDark = 'lib/assets/branding/aura_logo_on_dark.png';
  static const _markAsset = 'lib/assets/branding/aura_mark.png';

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
        semanticLabel: 'Aura',
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
          isDark ? _logoOnDark : _logo,
          width: width,
          fit: BoxFit.contain,
          semanticLabel: 'Aura',
        );
      },
    );
  }
}
