import 'package:flutter/material.dart';
import 'package:aura/features/auth/presentation/widgets/auth_layout.dart';
import 'package:aura/features/auth/presentation/widgets/auth_palette.dart';

/// The surface the auth forms sit on: a slightly translucent panel with a
/// hairline border and one soft shadow (a violet glow on dark).
class AuthCard extends StatelessWidget {
  const AuthCard({required this.layout, required this.child, super.key});

  final AuthLayout layout;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = AuthPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AuthLayout.cardInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.cardFill,
          borderRadius: BorderRadius.circular(AuthLayout.cardRadius),
          border: Border.all(color: palette.cardBorder),
          boxShadow: [
            BoxShadow(
              color: palette.cardShadow,
              blurRadius: 30,
              spreadRadius: -4,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AuthLayout.cardPaddingX,
            layout.cardPaddingTop,
            AuthLayout.cardPaddingX,
            layout.cardPaddingBottom,
          ),
          child: child,
        ),
      ),
    );
  }
}
