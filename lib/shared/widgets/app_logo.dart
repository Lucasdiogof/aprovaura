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
          Image.asset('lib/assets/login_logo.png', width: fontSize * 5.6)
        else ...[
          if (showIcon) ...[
            Image.asset(
              'lib/assets/logo.png',
              width: fontSize * 2,
              height: fontSize * 2,
            ),
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
