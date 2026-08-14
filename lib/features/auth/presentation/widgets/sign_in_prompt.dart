import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/auth/l10n/auth_strings.dart';

class SignInPrompt extends StatelessWidget {
  const SignInPrompt({
    required this.strings,
    required this.onSignIn,
    super.key,
  });

  final AuthStrings strings;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          strings.alreadyHaveAccountQuestion,
          style: TextStyle(color: context.colors.textSecondary),
        ),
        TextButton(onPressed: onSignIn, child: Text(strings.signInAction)),
      ],
    );
  }
}
