import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/l10n/auth_strings.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/auth_state.dart';
import 'package:aura/features/auth/presentation/cubit/register_form_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/register_form_state.dart';
import 'package:aura/features/auth/presentation/widgets/auth_card.dart';
import 'package:aura/features/auth/presentation/widgets/auth_header.dart';
import 'package:aura/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:aura/features/auth/presentation/widgets/register_form.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/shared/utils/validators.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formCubit = RegisterFormCubit();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_formCubit.notifyFieldChanged);
    _emailController.addListener(_formCubit.notifyFieldChanged);
    _passwordController.addListener(_formCubit.notifyFieldChanged);
    _confirmPasswordController.addListener(_formCubit.notifyFieldChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_formCubit.notifyFieldChanged);
    _emailController.removeListener(_formCubit.notifyFieldChanged);
    _passwordController.removeListener(_formCubit.notifyFieldChanged);
    _confirmPasswordController.removeListener(_formCubit.notifyFieldChanged);
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _formCubit.close();
    super.dispose();
  }

  String? _nameError(bool submitted, AuthStrings t) {
    if (!submitted) return null;
    return isNameProvided(_nameController.text) ? null : t.nameRequired;
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

  String? _confirmPasswordError(bool submitted, AuthStrings t) {
    if (!submitted) return null;
    final value = _confirmPasswordController.text;
    if (value.isEmpty) return t.confirmPasswordRequired;
    return doPasswordsMatch(_passwordController.text, value)
        ? null
        : t.passwordsDoNotMatch;
  }

  void _submit() {
    _formCubit.markSubmitted();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (!isNameProvided(name) ||
        !isValidEmail(email) ||
        !isPasswordProvided(password) ||
        !doPasswordsMatch(password, confirmPassword)) {
      return;
    }
    context.read<AuthCubit>().signUp(email: email, password: password);
  }

  Future<void> _onSignedUp(BuildContext context, AppUser user) async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    await sl<ProfileRepository>().createProfile(
      id: user.id,
      name: name,
      username: username.isEmpty ? null : username,
    );
    if (!context.mounted) return;
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final t = AuthStrings(context.watch<LocaleCubit>().state);
    return BlocProvider.value(
      value: _formCubit,
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          switch (state) {
            case AuthSuccess(:final user):
              unawaited(_onSignedUp(context, user));
            case AuthError(:final message):
              AppInfoBottomSheet.showError(context, description: message);
            case AuthLoading():
            case AuthInitial():
              break;
          }
        },
        builder: (context, authState) {
          final isSubmitting = authState is AuthLoading;
          return BlocBuilder<RegisterFormCubit, RegisterFormState>(
            builder: (context, formState) {
              return AuthScaffold(
                showBackButton: true,
                children: [
                  AuthHeader.page(
                    title: t.registerHeading,
                    subtitle: t.registerSubtitle,
                  ),
                  const SizedBox(height: 28),
                  AuthCard(
                    child: RegisterForm(
                      strings: t,
                      nameController: _nameController,
                      nameError: _nameError(formState.submitted, t),
                      usernameController: _usernameController,
                      emailController: _emailController,
                      emailError: _emailError(formState.submitted, t),
                      passwordController: _passwordController,
                      passwordError: _passwordError(formState.submitted, t),
                      confirmPasswordController: _confirmPasswordController,
                      confirmPasswordError: _confirmPasswordError(
                        formState.submitted,
                        t,
                      ),
                      obscurePassword: formState.obscurePassword,
                      onToggleObscurePassword: _formCubit.toggleObscurePassword,
                      obscureConfirmPassword: formState.obscureConfirmPassword,
                      onToggleObscureConfirmPassword:
                          _formCubit.toggleObscureConfirmPassword,
                      onSubmit: _submit,
                      isLoading: isSubmitting,
                    ),
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
