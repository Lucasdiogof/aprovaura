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
    this.isLoading = false,
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
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: emailController,
          labelText: strings.emailLabel,
          prefixIcon: Icons.mail_outline_rounded,
          hintText: strings.emailHint,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          fillColor: colors.background,
          errorText: emailError,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: passwordController,
          labelText: strings.passwordLabel,
          prefixIcon: Icons.lock_outline_rounded,
          hintText: strings.passwordHint,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          fillColor: colors.background,
          onSubmitted: (_) => onSubmit(),
          suffixIcon: PasswordVisibilityToggle(
            obscured: obscurePassword,
            color: context.colors.textSecondary,
            onPressed: onToggleObscure,
          ),
          errorText: passwordError,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onForgotPassword,
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(strings.forgotPasswordLabel),
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: strings.signInButton,
          onPressed: onSubmit,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
