import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/auth/l10n/auth_strings.dart';

class CreateAccountPrompt extends StatelessWidget {
  const CreateAccountPrompt({
    required this.strings,
    required this.onCreateAccount,
    super.key,
  });

  final AuthStrings strings;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          strings.createAccountQuestion,
          style: TextStyle(color: context.colors.textSecondary),
        ),
        TextButton(
          onPressed: onCreateAccount,
          child: Text(strings.createAccountAction),
        ),
      ],
    );
  }
}
