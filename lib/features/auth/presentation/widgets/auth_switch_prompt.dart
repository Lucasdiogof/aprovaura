import 'package:flutter/material.dart';
import 'package:aura/features/auth/presentation/widgets/auth_layout.dart';
import 'package:aura/features/auth/presentation/widgets/auth_palette.dart';

/// "Ainda não tem uma conta? Criar conta" and its counterpart on sign-up:
/// one centred line, with the action as the only emphasised words.
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
    final palette = AuthPalette.of(context);
    return Center(
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          overlayColor: palette.link,
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$question ',
                style: TextStyle(
                  color: palette.promptText,
                  fontWeight: FontWeight.w400,
                ),
              ),
              TextSpan(
                text: action,
                style: TextStyle(
                  color: palette.link,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: AuthLayout.promptSize, height: 1.2),
        ),
      ),
    );
  }
}
