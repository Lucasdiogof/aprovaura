import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/l10n/auth_strings.dart';
import 'package:aura/features/auth/l10n/email_verification_strings.dart';
import 'package:aura/features/auth/presentation/cubit/email_verification_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/email_verification_state.dart';
import 'package:aura/features/auth/presentation/widgets/auth_card.dart';
import 'package:aura/features/auth/presentation/widgets/auth_field.dart';
import 'package:aura/features/auth/presentation/widgets/auth_header.dart';
import 'package:aura/features/auth/presentation/widgets/auth_layout.dart';
import 'package:aura/features/auth/presentation/widgets/auth_palette.dart';
import 'package:aura/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:aura/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:aura/shared/utils/validators.dart';

/// Confirms the account's e-mail with the 6-digit code typed in the app (no
/// link). [fromSignUp] is true right after creating the account (then the
/// onboarding follows) and false when resuming from login / app restart,
/// where a fresh code is sent on arrival.
class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({
    required this.email,
    required this.fromSignUp,
    super.key,
  });

  final String email;
  final bool fromSignUp;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = EmailVerificationCubit(sl<AuthRepository>(), email);
        if (!fromSignUp) cubit.sendFresh();
        return cubit;
      },
      child: _View(fromSignUp: fromSignUp),
    );
  }
}

class _View extends StatefulWidget {
  const _View({required this.fromSignUp});

  final bool fromSignUp;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  static const _codeLength = 6;
  final _code = TextEditingController();

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  bool get _complete => _code.text.length == _codeLength;

  void _submit() {
    if (!_complete) return;
    FocusScope.of(context).unfocus();
    context.read<EmailVerificationCubit>().verify(_code.text);
  }

  Future<void> _backToLogin() async {
    await sl<AuthRepository>().clearPendingSignup();
    if (mounted) context.go('/login');
  }

  Future<void> _fixEmail(EmailVerificationStrings v, AuthStrings t) async {
    final cubit = context.read<EmailVerificationCubit>();
    final pending = await sl<AuthRepository>().pendingSignup();
    if (!mounted) return;
    if (pending?.name == null || pending?.username == null) {
      // Resumed from login: the sign-up data is not on this device.
      await sl<AuthRepository>().clearPendingSignup();
      if (!mounted) return;
      context.go('/cadastro');
      return;
    }
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _FixEmailDialog(
        strings: v,
        auth: t,
        currentEmail: cubit.state.email,
      ),
    );
    if (result != null) cubit.changeEmail(result);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = AuthStrings(language);
    final v = EmailVerificationStrings(language);
    final palette = AuthPalette.of(context);
    return BlocConsumer<EmailVerificationCubit, EmailVerificationState>(
      listener: (context, s) {
        if (s.verified) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(v.verified)));
          context.go(widget.fromSignUp ? '/onboarding' : '/home');
        }
      },
      builder: (context, s) {
        final cubit = context.read<EmailVerificationCubit>();
        return AuthScaffold(
          children: [
            AuthHeader(layout: AuthLayout.regular, subtitle: v.subtitle),
            AuthCard(
              layout: AuthLayout.regular,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    v.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: palette.label,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    v.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: palette.subtitle),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: palette.label,
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (s.errorMessage != null || s.isLocked) ...[
                    Text(
                      s.isLocked ? v.locked : s.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  AuthField(
                    layout: AuthLayout.regular,
                    controller: _code,
                    label: t.recoveryCodeLabel,
                    hintText: t.recoveryCodeHint,
                    icon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(_codeLength),
                    ],
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 20),
                  AuthSubmitButton(
                    layout: AuthLayout.regular,
                    label: s.isLocked ? v.lockedIn(s.lockedFor) : v.submit,
                    onPressed: _complete && !s.isLocked ? _submit : null,
                    isLoading: s.isVerifying,
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: s.cooldown > 0
                        ? Text(
                            t.resendInSeconds(s.cooldown),
                            style: TextStyle(color: palette.subtitle),
                          )
                        : TextButton(
                            onPressed: s.resend == EmailResendStatus.sending
                                ? null
                                : cubit.resend,
                            child: Text(
                              s.resend == EmailResendStatus.sending
                                  ? t.forgotPasswordResending
                                  : '${t.forgotPasswordNotReceived} ${t.forgotPasswordResend}',
                            ),
                          ),
                  ),
                  if (s.resend == EmailResendStatus.sent)
                    Text(
                      t.forgotPasswordResent,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: palette.subtitle),
                    ),
                  if (s.resend == EmailResendStatus.failed)
                    Text(
                      t.forgotPasswordResendFailed,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    v.spamHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: palette.subtitle),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _fixEmail(v, t),
                    child: Text(v.fixEmail),
                  ),
                  TextButton(
                    onPressed: _backToLogin,
                    child: Text(v.backToSignIn),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// New e-mail + the password chosen at sign-up (proves the pending account
/// is theirs). Pops with the new address once the sign-up was redone.
class _FixEmailDialog extends StatefulWidget {
  const _FixEmailDialog({
    required this.strings,
    required this.auth,
    required this.currentEmail,
  });

  final EmailVerificationStrings strings;
  final AuthStrings auth;
  final String currentEmail;

  @override
  State<_FixEmailDialog> createState() => _FixEmailDialogState();
}

class _FixEmailDialogState extends State<_FixEmailDialog> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newEmail = _email.text.trim();
    if (!isValidEmail(newEmail) || _password.text.isEmpty) {
      setState(() => _error = widget.auth.emailInvalid);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = sl<AuthRepository>();
    final pending = await repo.pendingSignup();
    final discarded = await repo.discardUnconfirmedSignup(
      email: widget.currentEmail,
      password: _password.text,
    );
    if (discarded is Error<void> || pending == null) {
      return _fail(widget.strings.fixEmailFailed);
    }
    final signUp = await repo.signUp(
      email: newEmail,
      password: _password.text,
      name: pending.name!,
      username: pending.username!,
      referralPartnerId: pending.referralPartnerId,
      legalAccept: pending.legalAccept,
    );
    // Expected: the new account waits for its own confirmation code.
    if (signUp case Error(:final failure)
        when failure is AuthFailure && failure.needsEmailConfirmation) {
      if (mounted) Navigator.of(context).pop(newEmail);
    } else {
      _fail(widget.strings.fixEmailFailed);
    }
  }

  void _fail(String message) {
    if (mounted) {
      setState(() {
        _busy = false;
        _error = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.strings;
    return AlertDialog(
      title: Text(v.fixEmailTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(v.fixEmailDescription),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(labelText: v.fixEmailNewLabel),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(labelText: widget.auth.passwordLabel),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(widget.auth.closeAction),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(v.fixEmailSubmit),
        ),
      ],
    );
  }
}
