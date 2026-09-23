import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/auth/l10n/auth_strings.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/auth_state.dart';
import 'package:aura/features/auth/presentation/cubit/login_form_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/login_form_state.dart';
import 'package:aura/features/auth/presentation/widgets/auth_header.dart';
import 'package:aura/features/auth/presentation/widgets/auth_card.dart';
import 'package:aura/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:aura/features/auth/presentation/widgets/auth_switch_prompt.dart';
import 'package:aura/features/auth/presentation/widgets/forgot_password_sheet.dart';
import 'package:aura/features/auth/presentation/widgets/login_form.dart';
import 'package:aura/shared/utils/validators.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formCubit = LoginFormCubit();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_formCubit.notifyFieldChanged);
    _passwordController.addListener(_formCubit.notifyFieldChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_formCubit.notifyFieldChanged);
    _passwordController.removeListener(_formCubit.notifyFieldChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _formCubit.close();
    super.dispose();
  }

  String? _emailError(bool submitted, AuthStrings t) {
    final value = _emailController.text;
    if (value.isEmpty) {
      return submitted ? t.emailRequired : null;
    }
    return isValidEmail(value) ? null : t.emailInvalid;
  }

  String? _passwordError(bool submitted, AuthStrings t) {
    if (!submitted) return null;
    return isPasswordProvided(_passwordController.text)
        ? null
        : t.passwordRequired;
  }

  void _submit() {
    _formCubit.markSubmitted();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!isValidEmail(email) || !isPasswordProvided(password)) return;
    context.read<AuthCubit>().signIn(email: email, password: password);
  }

  void _forgotPassword() => ForgotPasswordSheet.show(
    context,
    initialEmail: _emailController.text.trim(),
  );

  void _createAccount() => context.push('/cadastro');

  @override
  Widget build(BuildContext context) {
    final t = AuthStrings(context.watch<LocaleCubit>().state);
    return BlocProvider.value(
      value: _formCubit,
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          switch (state) {
            case AuthSuccess():
              context.go('/home');
            case AuthError(:final message, :final isInvalidCredentials):
              if (isInvalidCredentials) {
                AppInfoBottomSheet.showError(
                  context,
                  title: t.accountNotFoundTitle,
                  description: t.accountNotFoundDescription,
                  secondaryActionLabel: t.createAccountAction,
                  onSecondaryAction: _createAccount,
                );
              } else {
                AppInfoBottomSheet.showError(context, description: message);
              }
            case AuthLoading():
            case AuthInitial():
              break;
          }
        },
        builder: (context, authState) {
          final isSigningIn = authState is AuthLoading;
          return BlocBuilder<LoginFormCubit, LoginFormState>(
            builder: (context, formState) {
              return AuthScaffold(
                children: [
                  AuthHeader.brand(subtitle: t.signInSubtitle),
                  const SizedBox(height: 28),
                  AuthCard(
                    child: LoginForm(
                      strings: t,
                      emailController: _emailController,
                      emailError: _emailError(formState.submitted, t),
                      passwordController: _passwordController,
                      passwordError: _passwordError(formState.submitted, t),
                      obscurePassword: formState.obscurePassword,
                      onToggleObscure: _formCubit.toggleObscurePassword,
                      onSubmit: _submit,
                      onForgotPassword: _forgotPassword,
                      isLoading: isSigningIn,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuthSwitchPrompt(
                    question: t.createAccountQuestion,
                    action: t.createAccountAction,
                    onTap: _createAccount,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
