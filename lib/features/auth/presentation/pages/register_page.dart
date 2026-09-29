import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
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
import 'package:aura/features/profile/presentation/cubit/username_check_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/username_check_state.dart';
import 'package:aura/shared/l10n/username_strings.dart';
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
  final _usernameFocus = FocusNode();
  final _formCubit = RegisterFormCubit();
  final _usernameCheck = UsernameCheckCubit(
    isAvailable: (username) =>
        sl<ProfileRepository>().isUsernameAvailable(username),
  );

  @override
  void initState() {
    super.initState();
    for (final controller in _fields) {
      controller.addListener(_formCubit.notifyFieldChanged);
    }
    _usernameController.addListener(_onUsernameChanged);
  }

  List<TextEditingController> get _fields => [
    _nameController,
    _usernameController,
    _emailController,
    _passwordController,
    _confirmPasswordController,
  ];

  void _onUsernameChanged() => _usernameCheck.changed(_usernameController.text);

  @override
  void dispose() {
    _usernameController.removeListener(_onUsernameChanged);
    for (final controller in _fields) {
      controller
        ..removeListener(_formCubit.notifyFieldChanged)
        ..dispose();
    }
    _usernameFocus.dispose();
    _formCubit.close();
    _usernameCheck.close();
    super.dispose();
  }

  // Validated as the person types: an empty field shows nothing (unless a
  // submit was attempted from the keyboard), a filled one shows what is
  // wrong right away, and the message goes as soon as it is right.

  String? _nameError(RegisterFormState form, AuthStrings t) {
    if (isNameProvided(_nameController.text)) return null;
    return form.submitted ? t.nameRequired : null;
  }

  String? _emailError(RegisterFormState form, AuthStrings t) {
    final value = _emailController.text;
    if (value.trim().isEmpty) return form.submitted ? t.emailRequired : null;
    return isValidEmail(value) ? null : t.emailInvalid;
  }

  String? _passwordError(RegisterFormState form, AuthStrings t) {
    final value = _passwordController.text;
    if (value.isEmpty) return form.submitted ? t.passwordRequired : null;
    return isValidNewPassword(value) ? null : t.passwordTooShort;
  }

  String? _confirmPasswordError(RegisterFormState form, AuthStrings t) {
    final value = _confirmPasswordController.text;
    if (value.isEmpty) {
      return form.submitted ? t.confirmPasswordRequired : null;
    }
    return doPasswordsMatch(_passwordController.text, value)
        ? null
        : t.passwordsDoNotMatch;
  }

  /// Everything filled in, well-formed, and the username confirmed free by
  /// the database -- the only state in which "Criar conta" is enabled.
  bool _isComplete() {
    final password = _passwordController.text;
    return isNameProvided(_nameController.text) &&
        _usernameCheck.state.confirms(_usernameController.text) &&
        isValidEmail(_emailController.text) &&
        isValidNewPassword(password) &&
        doPasswordsMatch(password, _confirmPasswordController.text);
  }

  void _submit() {
    // Busy from the first tap until the page leaves for onboarding, so a
    // second tap can never fire another sign-up.
    if (_isBusy(context.read<AuthCubit>().state)) return;
    // "Done" on the keyboard can get here with the form incomplete: then
    // it just reveals what is still missing.
    _formCubit.markSubmitted();
    if (!_isComplete()) return;
    context.read<AuthCubit>().signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
    );
  }

  bool _isBusy(AuthState state) => state is AuthLoading || state is AuthSuccess;

  void _goToSignIn() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = AuthStrings(language);
    final u = UsernameStrings(language);
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _formCubit),
        BlocProvider.value(value: _usernameCheck),
      ],
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          switch (state) {
            // The account and its profile (name + username) were created
            // together, in one database transaction.
            case AuthSuccess():
              context.go('/onboarding');
            // Someone took the username between the check and the sign-up.
            // Nothing was created (the transaction was refused): the field
            // says so and the person picks another name, right here.
            case AuthError(isUsernameTaken: true):
              _usernameCheck.markTaken(_usernameController.text);
              _usernameFocus.requestFocus();
            case AuthError(:final message, :final isEmailTaken):
              if (isEmailTaken) {
                AppInfoBottomSheet.showError(
                  context,
                  title: t.emailTakenTitle,
                  description: message,
                  secondaryActionLabel: t.signInButton,
                  onSecondaryAction: _goToSignIn,
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
          final isSubmitting = _isBusy(authState);
          return BlocBuilder<RegisterFormCubit, RegisterFormState>(
            builder: (context, formState) =>
                BlocBuilder<UsernameCheckCubit, UsernameCheckState>(
                  builder: (context, usernameState) => AuthScaffold(
                    showBackButton: true,
                    children: [
                      AuthHeader(
                        layout: RegisterForm.layout,
                        subtitle: t.registerSubtitle,
                      ),
                      AuthCard(
                        layout: RegisterForm.layout,
                        child: RegisterForm(
                          strings: t,
                          usernameStrings: u,
                          nameController: _nameController,
                          nameError: _nameError(formState, t),
                          usernameController: _usernameController,
                          usernameFocus: _usernameFocus,
                          usernameError: u.errorFor(
                            _usernameController.text,
                            usernameState,
                            submitted: formState.submitted,
                          ),
                          usernameCheck: usernameState,
                          emailController: _emailController,
                          emailError: _emailError(formState, t),
                          passwordController: _passwordController,
                          passwordError: _passwordError(formState, t),
                          confirmPasswordController: _confirmPasswordController,
                          confirmPasswordError: _confirmPasswordError(
                            formState,
                            t,
                          ),
                          obscurePassword: formState.obscurePassword,
                          onToggleObscurePassword:
                              _formCubit.toggleObscurePassword,
                          obscureConfirmPassword:
                              formState.obscureConfirmPassword,
                          onToggleObscureConfirmPassword:
                              _formCubit.toggleObscureConfirmPassword,
                          onSubmit: _submit,
                          canSubmit: !isSubmitting && _isComplete(),
                          isLoading: isSubmitting,
                        ),
                      ),
                    ],
                  ),
                ),
          );
        },
      ),
    );
  }
}
