import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/auth/l10n/auth_strings.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_text_field.dart';
import 'package:aura/shared/widgets/password_visibility_toggle.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    required this.strings,
    required this.nameController,
    required this.nameError,
    required this.usernameController,
    required this.emailController,
    required this.emailError,
    required this.passwordController,
    required this.passwordError,
    required this.confirmPasswordController,
    required this.confirmPasswordError,
    required this.obscurePassword,
    required this.onToggleObscurePassword,
    required this.obscureConfirmPassword,
    required this.onToggleObscureConfirmPassword,
    required this.onSubmit,
    super.key,
    this.isLoading = false,
  });

  final AuthStrings strings;
  final TextEditingController nameController;
  final String? nameError;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final String? emailError;
  final TextEditingController passwordController;
  final String? passwordError;
  final TextEditingController confirmPasswordController;
  final String? confirmPasswordError;
  final bool obscurePassword;
  final VoidCallback onToggleObscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onToggleObscureConfirmPassword;
  final VoidCallback onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: nameController,
          labelText: strings.nameLabel,
          prefixIcon: Icons.person_outline_rounded,
          hintText: strings.nameHint,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          fillColor: colors.background,
          errorText: nameError,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: usernameController,
          labelText: strings.usernameLabel,
          prefixIcon: Icons.alternate_email_rounded,
          hintText: strings.usernameHint,
          textInputAction: TextInputAction.next,
          fillColor: colors.background,
        ),
        const SizedBox(height: 14),
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
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          fillColor: colors.background,
          suffixIcon: PasswordVisibilityToggle(
            obscured: obscurePassword,
            color: context.colors.textSecondary,
            onPressed: onToggleObscurePassword,
          ),
          errorText: passwordError,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: confirmPasswordController,
          labelText: strings.confirmPasswordLabel,
          prefixIcon: Icons.lock_outline_rounded,
          hintText: strings.confirmPasswordHint,
          obscureText: obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          fillColor: colors.background,
          onSubmitted: (_) => onSubmit(),
          suffixIcon: PasswordVisibilityToggle(
            obscured: obscureConfirmPassword,
            color: context.colors.textSecondary,
            onPressed: onToggleObscureConfirmPassword,
          ),
          errorText: confirmPasswordError,
        ),
        const SizedBox(height: 24),
        AppButton(
          label: strings.registerSubmitButton,
          onPressed: onSubmit,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
