import 'package:flutter/material.dart';
import 'package:aura/features/auth/presentation/widgets/auth_layout.dart';
import 'package:aura/features/auth/presentation/widgets/auth_palette.dart';
import 'package:aura/shared/widgets/app_logo.dart';

/// The auth screens' header, the same on login and sign-up: the symbol,
/// the "Aprovaura" wordmark under it (the light or dark official file, by
/// theme) and a one-line subtitle.
class AuthHeader extends StatelessWidget {
  const AuthHeader({required this.subtitle, required this.layout, super.key});

  final String subtitle;
  final AuthLayout layout;

  @override
  Widget build(BuildContext context) {
    final palette = AuthPalette.of(context);
    return Column(
      children: [
        SizedBox(height: layout.markTop),
        const AppLogo.mark(size: AuthLayout.markWidth),
        SizedBox(height: layout.markToWordmark),
        const AppLogo.text(width: AuthLayout.wordmarkWidth),
        SizedBox(height: layout.wordmarkToSubtitle),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AuthLayout.subtitleSize,
            height: 1.3,
            fontWeight: FontWeight.w400,
            color: palette.subtitle,
          ),
        ),
        SizedBox(height: layout.subtitleToCard),
      ],
    );
  }
}
