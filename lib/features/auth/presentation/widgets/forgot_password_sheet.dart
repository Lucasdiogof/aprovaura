import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/auth/l10n/auth_strings.dart';
import 'package:aura/features/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/password_reset_state.dart';
import 'package:aura/shared/utils/validators.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_text_field.dart';

/// Password recovery, as a bottom sheet over the login screen rather than a
/// route: the person is one field away from finishing what they started, so
/// sending them to another page would lose the email they already typed.
///
/// It has two steps — the form, then the confirmation — swapped in place with
/// an [AnimatedSize] so the sheet grows into the new content instead of
/// jumping.
class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({required this.initialEmail, super.key});

  /// Pre-filled with whatever was already typed on the login form.
  final String initialEmail;

  static Future<void> show(BuildContext context, {String initialEmail = ''}) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      // Keeps the sheet from stretching edge to edge on a tablet or browser.
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (_) => BlocProvider(
        create: (_) => PasswordResetCubit(sl()),
        child: ForgotPasswordSheet(initialEmail: initialEmail),
      ),
    );
  }

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  late final TextEditingController _emailController = TextEditingController(
    text: widget.initialEmail,
  );
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _emailError(AuthStrings t) {
    if (!_submitted) return null;
    final value = _emailController.text.trim();
    if (value.isEmpty) return t.emailRequired;
    return isValidEmail(value) ? null : t.emailInvalid;
  }

  void _submit() {
    setState(() => _submitted = true);
    final email = _emailController.text.trim();
    if (!isValidEmail(email)) return;
    FocusScope.of(context).unfocus();
    context.read<PasswordResetCubit>().send(email);
  }

  @override
  Widget build(BuildContext context) {
    final t = AuthStrings(context.watch<LocaleCubit>().state);
    final colors = context.colors;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: BlocBuilder<PasswordResetCubit, PasswordResetState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SheetGrabber(onClose: () => Navigator.of(context).pop()),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: state is PasswordResetSent
                        ? _Confirmation(strings: t, state: state)
                        : _Form(
                            strings: t,
                            controller: _emailController,
                            errorText: _emailError(t),
                            serverError: state is PasswordResetIdle
                                ? state.errorMessage
                                : null,
                            isSending: state is PasswordResetSending,
                            onSubmit: _submit,
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.strings,
    required this.controller,
    required this.errorText,
    required this.serverError,
    required this.isSending,
    required this.onSubmit,
  });

  final AuthStrings strings;
  final TextEditingController controller;
  final String? errorText;
  final String? serverError;
  final bool isSending;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      key: const ValueKey('form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHeader(
          icon: Icons.lock_reset_rounded,
          title: strings.forgotPasswordTitle,
          description: strings.forgotPasswordDescription,
        ),
        const SizedBox(height: 24),
        if (serverError != null) ...[
          _ErrorBanner(message: serverError!),
          const SizedBox(height: 14),
        ],
        AppTextField(
          controller: controller,
          hintText: strings.emailHint,
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          fillColor: colors.background,
          errorText: errorText,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 20),
        AppButton(
          label: strings.forgotPasswordSubmit,
          onPressed: onSubmit,
          isLoading: isSending,
        ),
      ],
    );
  }
}

class _Confirmation extends StatelessWidget {
  const _Confirmation({required this.strings, required this.state});

  final AuthStrings strings;
  final PasswordResetSent state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      key: const ValueKey('confirmation'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SheetHeader(
          icon: Icons.mark_email_read_rounded,
          title: strings.forgotPasswordSentTitle,
          description: strings.forgotPasswordSentDescription,
        ),
        const SizedBox(height: 8),
        Text(
          state.email,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: strings.closeAction,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 12),
        _ResendAction(strings: strings, status: state.resend),
      ],
    );
  }
}

/// Icon in a tinted circle, title, support text — the same shape the app's
/// info sheets already use, so every sheet opens onto a familiar layout.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: colors.primary.withValues(alpha: 0.16)),
          ),
          child: Icon(icon, color: colors.primary, size: 30),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ResendAction extends StatelessWidget {
  const _ResendAction({required this.strings, required this.status});

  final AuthStrings strings;
  final ResendStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const style = TextStyle(fontSize: 13.5);
    return switch (status) {
      ResendStatus.sending => Text(
        strings.forgotPasswordResending,
        textAlign: TextAlign.center,
        style: style.copyWith(color: colors.textSecondary),
      ),
      ResendStatus.sent => Text(
        strings.forgotPasswordResent,
        textAlign: TextAlign.center,
        style: style.copyWith(
          color: colors.success,
          fontWeight: FontWeight.w600,
        ),
      ),
      ResendStatus.failed => Text(
        strings.forgotPasswordResendFailed,
        textAlign: TextAlign.center,
        style: style.copyWith(color: colors.error),
      ),
      ResendStatus.idle => TextButton(
        onPressed: () => context.read<PasswordResetCubit>().resend(),
        style: TextButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${strings.forgotPasswordNotReceived} ',
                style: style.copyWith(color: colors.textSecondary),
              ),
              TextSpan(
                text: strings.forgotPasswordResend,
                style: style.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    };
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.error.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: colors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13.5, color: colors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Drag handle plus an explicit close button: on the web the sheet has no
/// drag gesture, so the handle alone would leave tapping the barrier as the
/// only way out.
class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Positioned(
            right: -8,
            child: IconButton(
              onPressed: onClose,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
