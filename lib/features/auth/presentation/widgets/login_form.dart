import 'package:flutter/material.dart';
import 'package:aura/features/auth/l10n/auth_strings.dart';
import 'package:aura/features/auth/presentation/widgets/auth_field.dart';
import 'package:aura/features/auth/presentation/widgets/auth_layout.dart';
import 'package:aura/features/auth/presentation/widgets/auth_palette.dart';
import 'package:aura/features/auth/presentation/widgets/auth_submit_button.dart';

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
    required this.canSubmit,
    super.key,
    this.isLoading = false,
  });

  static const layout = AuthLayout.regular;

  final AuthStrings strings;
  final TextEditingController emailController;
  final String? emailError;
  final TextEditingController passwordController;
  final String? passwordError;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  /// A valid e-mail and a password typed in.
  final bool canSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final palette = AuthPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        SizedBox(height: layout.fieldToNextLabel),
        AuthField(
          layout: layout,
          controller: passwordController,
          label: strings.passwordLabel,
          icon: Icons.lock_outline_rounded,
          hintText: strings.passwordHint,
          obscured: obscurePassword,
          onToggleObscured: onToggleObscure,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) => onSubmit(),
          errorText: passwordError,
        ),
        const SizedBox(height: AuthLayout.fieldToForgot),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: onForgotPassword,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AuthLayout.forgotTapPadding,
              ),
              child: Text(
                strings.forgotPasswordLabel,
                style: TextStyle(
                  fontSize: AuthLayout.forgotSize,
                  height: 1.2,
                  color: palette.link,
                  decoration: TextDecoration.underline,
                  decorationColor: palette.link,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AuthLayout.forgotToButton),
        AuthSubmitButton(
          layout: layout,
          label: strings.signInButton,
          onPressed: canSubmit ? onSubmit : null,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
