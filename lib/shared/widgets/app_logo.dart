import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.color,
    this.fontSize = 40,
    this.tagline,
    this.showIcon = false,
    this.useWordmark = false,
  });

  /// Horizontal logo, in its light-surface and dark-surface versions. Only
  /// the wordmark's fill differs between them: on [AppColors.dark] the navy
  /// lettering of the original would be all but invisible.
  static const _logo = 'lib/assets/branding/aura_logo.png';
  static const _logoOnDark = 'lib/assets/branding/aura_logo_on_dark.png';

  /// The monogram on its own, for compact placements.
  static const _mark = 'lib/assets/branding/aura_mark.png';

  static const _minLogoWidth = 160.0;
  static const _maxLogoWidth = 260.0;

  final Color? color;
  final double fontSize;
  final String? tagline;
  final bool showIcon;
  final bool useWordmark;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? context.colors.textPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (useWordmark)
          _Wordmark(isDark: Theme.of(context).brightness == Brightness.dark)
        else ...[
          if (showIcon) ...[
            Image.asset(_mark, width: fontSize * 2, fit: BoxFit.contain),
            const SizedBox(height: 12),
          ],
          Text(
            'Aura',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: foreground,
            ),
          ),
        ],
        if (tagline != null) ...[
          const SizedBox(height: 8),
          Text(
            tagline!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: foreground.withValues(alpha: 0.85),
            ),
          ),
        ],
      ],
    );
  }
}

/// Scales with the space it is given instead of with a fixed size, so the
/// same widget reads well on a phone and on a wide web/tablet window without
/// ever stretching the artwork.
class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final width = math.min(
          available,
          (available * 0.62).clamp(
            AppLogo._minLogoWidth,
            AppLogo._maxLogoWidth,
          ),
        );
        return Image.asset(
          isDark ? AppLogo._logoOnDark : AppLogo._logo,
          width: width,
          fit: BoxFit.contain,
          semanticLabel: 'Aura',
        );
      },
    );
  }
}
