import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

/// "Ainda não tem uma conta? Criar conta" and its counterpart on sign-up.
///
/// One centred line with the action as the only emphasised word: as two
/// separate widgets (label + `TextButton`) the pair used to sit off-centre
/// and read as loudly as the CTA above it.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    required this.question,
    required this.action,
    required this.onTap,
    super.key,
  });

  final String question;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // The default grey overlay draws a heavy pill behind the whole line
          // on hover, which reads louder than the CTA above it.
          overlayColor: colors.primary,
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$question ',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: action,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14.5),
        ),
      ),
    );
  }
}
