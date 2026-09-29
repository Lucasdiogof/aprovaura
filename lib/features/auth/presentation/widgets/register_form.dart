import 'package:flutter/material.dart';
import 'package:aura/features/auth/l10n/auth_strings.dart';
import 'package:aura/features/auth/presentation/widgets/auth_field.dart';
import 'package:aura/features/auth/presentation/widgets/auth_layout.dart';
import 'package:aura/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:aura/features/profile/presentation/cubit/username_check_state.dart';
import 'package:aura/shared/l10n/username_strings.dart';
import 'package:aura/shared/widgets/username_status_indicator.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    required this.strings,
    required this.usernameStrings,
    required this.nameController,
    required this.nameError,
    required this.usernameController,
    required this.usernameFocus,
    required this.usernameError,
    required this.usernameCheck,
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
    required this.canSubmit,
    super.key,
    this.isLoading = false,
  });

  static const layout = AuthLayout.compact;

  final AuthStrings strings;
  final UsernameStrings usernameStrings;
  final TextEditingController nameController;
  final String? nameError;
  final TextEditingController usernameController;
  final FocusNode usernameFocus;
  final String? usernameError;
  final UsernameCheckState usernameCheck;
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

  /// Every field valid and the username confirmed free.
  final bool canSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: layout.fieldToNextLabel);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthField(
          layout: layout,
          controller: nameController,
          label: strings.nameLabel,
          icon: Icons.person_outline_rounded,
          hintText: strings.nameHint,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          errorText: nameError,
        ),
        gap,
        AuthField(
          layout: layout,
          controller: usernameController,
          focusNode: usernameFocus,
          label: strings.usernameLabel,
          icon: Icons.alternate_email_rounded,
          hintText: strings.usernameHint,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newUsername],
          errorText: usernameError,
          trailing: UsernameStatusIndicator(
            check: usernameCheck,
            value: usernameController.text,
            availableLabel: usernameStrings.available,
          ),
        ),
        gap,
        AuthField(
          layout: layout,
          controller: emailController,
          label: strings.emailLabel,
          icon: Icons.mail_outline_rounded,
          hintText: strings.emailHint,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          errorText: emailError,
        ),
        gap,
        AuthField(
          layout: layout,
          controller: passwordController,
          label: strings.passwordLabel,
          icon: Icons.lock_outline_rounded,
          hintText: strings.passwordHint,
          obscured: obscurePassword,
          onToggleObscured: onToggleObscurePassword,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          errorText: passwordError,
        ),
        gap,
        AuthField(
          layout: layout,
          controller: confirmPasswordController,
          label: strings.confirmPasswordLabel,
          icon: Icons.lock_outline_rounded,
          hintText: strings.confirmPasswordHint,
          obscured: obscureConfirmPassword,
          onToggleObscured: onToggleObscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
          errorText: confirmPasswordError,
        ),
        SizedBox(height: layout.lastFieldToButton),
        AuthSubmitButton(
          layout: layout,
          label: strings.registerSubmitButton,
          onPressed: canSubmit ? onSubmit : null,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
