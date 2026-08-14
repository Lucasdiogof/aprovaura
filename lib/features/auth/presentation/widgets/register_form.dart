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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: nameController,
          prefixIcon: Icons.person_outline,
          hintText: strings.nameHint,
          errorText: nameError,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: usernameController,
          prefixIcon: Icons.alternate_email,
          hintText: strings.usernameHint,
        ),
        const SizedBox(height: 16),
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
            onPressed: onToggleObscurePassword,
          ),
          errorText: passwordError,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: confirmPasswordController,
          prefixIcon: Icons.lock_outline,
          hintText: strings.confirmPasswordHint,
          obscureText: obscureConfirmPassword,
          suffixIcon: PasswordVisibilityToggle(
            obscured: obscureConfirmPassword,
            color: context.colors.textSecondary,
            onPressed: onToggleObscureConfirmPassword,
          ),
          errorText: confirmPasswordError,
        ),
        const SizedBox(height: 20),
        AppButton(
          label: strings.registerSubmitButton,
          onPressed: onSubmit,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
