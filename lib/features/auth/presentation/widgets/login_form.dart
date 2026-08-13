import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/auth/l10n/auth_strings.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_text_field.dart';
import 'package:aura/shared/widgets/password_visibility_toggle.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    required this.strings,
    required this.emailController,
    required this.emailError,
    required this.passwordController,
    required this.passwordError,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onForgotPassword,
    super.key,
  });

  final AuthStrings strings;
  final TextEditingController emailController;
  final String? emailError;
  final TextEditingController passwordController;
  final String? passwordError;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: emailController,
          prefixIcon: Icons.email_outlined,
          hintText: strings.emailHint,
          keyboardType: TextInputType.emailAddress,
          errorText: emailError,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: passwordController,
          prefixIcon: Icons.lock_outline,
          hintText: strings.passwordHint,
          obscureText: obscurePassword,
          suffixIcon: PasswordVisibilityToggle(
            obscured: obscurePassword,
            color: context.colors.textSecondary,
            onPressed: onToggleObscure,
          ),
          errorText: passwordError,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onForgotPassword,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(vertical: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(strings.forgotPasswordLabel),
          ),
        ),
        const SizedBox(height: 8),
        AppButton(label: strings.signInButton, onPressed: onSubmit),
      ],
    );
  }
}
