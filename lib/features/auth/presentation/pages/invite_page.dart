import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/l10n/auth_strings.dart';
import 'package:aura/features/auth/presentation/widgets/auth_backdrop.dart';
import 'package:aura/features/auth/presentation/widgets/auth_field.dart';
import 'package:aura/features/auth/presentation/widgets/auth_layout.dart';
import 'package:aura/features/auth/presentation/widgets/auth_palette.dart';
import 'package:aura/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:aura/shared/utils/validators.dart';
import 'package:aura/shared/widgets/app_logo.dart';

/// Botão do e-mail de convite (/convite?th=...): encerra a sessão de quem estiver
/// logado, abre a sessão do convidado, pede a senha nova e entra no portal já logado.
class InvitePage extends StatefulWidget {
  const InvitePage({required this.tokenHash, super.key});
  final String? tokenHash;

  @override
  State<InvitePage> createState() => _InvitePageState();
}

enum _Step { opening, password, invalid }

class _InvitePageState extends State<InvitePage> {
  final _repo = sl<AuthRepository>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  _Step _step = _Step.opening;
  bool _obscured = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
    _confirm.addListener(() => setState(() {}));
    _open();
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final th = widget.tokenHash;
    if (th == null || th.isEmpty) return _set(_Step.invalid);
    // Outra conta aberta neste aparelho: sai dela antes de abrir a do convite.
    if (_repo.currentUser != null) await _repo.signOut();
    final r = await _repo.verifyRecoveryToken(tokenHash: th);
    _set(r is Success ? _Step.password : _Step.invalid);
  }

  void _set(_Step s) {
    if (mounted) setState(() => _step = s);
  }

  bool get _valid => isValidNewPassword(_password.text) && doPasswordsMatch(_password.text, _confirm.text);

  Future<void> _save() async {
    if (!_valid || _saving) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    final r = await _repo.updatePassword(newPassword: _password.text);
    if (!mounted) return;
    switch (r) {
      case Success():
        context.go('/partners'); // a sessão do convite continua aberta: já entra logado
      case Error(:final failure):
        setState(() {
          _saving = false;
          _error = failure.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AuthStrings(context.watch<LocaleCubit>().state);
    final palette = AuthPalette.of(context);
    final text = Theme.of(context).textTheme;
    final title = switch (_step) {
      _Step.opening => t.inviteOpening,
      _Step.password => t.inviteTitle,
      _Step.invalid => t.inviteInvalidTitle,
    };
    final desc = switch (_step) {
      _Step.opening => '',
      _Step.password => t.inviteDescription,
      _Step.invalid => t.inviteInvalidDescription,
    };
    return Scaffold(
      body: AuthBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo.mark(size: 84)),
                    const SizedBox(height: 16),
                    Text(title,
                        textAlign: TextAlign.center,
                        style: text.titleLarge?.copyWith(color: palette.label, fontWeight: FontWeight.w700)),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(desc,
                          textAlign: TextAlign.center,
                          style: text.bodyMedium?.copyWith(color: palette.subtitle, height: 1.4)),
                    ],
                    const SizedBox(height: 24),
                    if (_step == _Step.opening) const Center(child: CircularProgressIndicator()),
                    if (_step == _Step.invalid)
                      AuthSubmitButton(
                        layout: AuthLayout.regular,
                        label: t.inviteGoToLogin,
                        onPressed: () => context.go('/login?next=/partners'),
                      ),
                    if (_step == _Step.password) ...[
                      if (_error != null) ...[
                        Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: palette.label)),
                        const SizedBox(height: 14),
                      ],
                      AuthField(
                        layout: AuthLayout.regular,
                        controller: _password,
                        label: t.passwordLabel,
                        hintText: t.passwordHint,
                        icon: Icons.lock_outline_rounded,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        obscured: _obscured,
                        onToggleObscured: () => setState(() => _obscured = !_obscured),
                        errorText: _password.text.isNotEmpty && !isValidNewPassword(_password.text) ? t.passwordTooShort : null,
                      ),
                      const SizedBox(height: 14),
                      AuthField(
                        layout: AuthLayout.regular,
                        controller: _confirm,
                        label: t.confirmPasswordLabel,
                        hintText: t.confirmPasswordHint,
                        icon: Icons.lock_outline_rounded,
                        textInputAction: TextInputAction.done,
                        obscured: _obscured,
                        onToggleObscured: () => setState(() => _obscured = !_obscured),
                        onSubmitted: (_) => _save(),
                        errorText: _confirm.text.isNotEmpty && !doPasswordsMatch(_password.text, _confirm.text)
                            ? t.passwordsDoNotMatch
                            : null,
                      ),
                      const SizedBox(height: 22),
                      AuthSubmitButton(
                        layout: AuthLayout.regular,
                        label: t.inviteSubmit,
                        onPressed: _valid ? _save : null,
                        isLoading: _saving,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
