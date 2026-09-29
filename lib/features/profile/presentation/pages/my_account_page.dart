import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/features/profile/presentation/cubit/account_form_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/account_form_state.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/username_check_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/username_check_state.dart';
import 'package:aura/shared/l10n/username_strings.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';
import 'package:aura/shared/widgets/app_text_field.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';
import 'package:aura/shared/widgets/username_status_indicator.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({
    required this.initialName,
    required this.initialUsername,
    required this.email,
    super.key,
  });

  final String initialName;
  final String? initialUsername;
  final String email;

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  final _formCubit = AccountFormCubit();
  late final _nameController = TextEditingController(text: widget.initialName)
    ..addListener(_formCubit.notifyFieldChanged);
  late final _usernameController = TextEditingController(
    text: widget.initialUsername ?? '',
  )..addListener(_formCubit.notifyFieldChanged);

  /// Same rule and same database check as sign-up. The person's own
  /// username is always theirs to keep (in any casing), without asking.
  late final _usernameCheck = UsernameCheckCubit(
    isAvailable: (username) =>
        sl<ProfileRepository>().isUsernameAvailable(username),
    currentUsername: widget.initialUsername,
  );

  // The database answer arrives after the typing: it has to redraw the
  // save button too, not just the field.
  late final StreamSubscription<UsernameCheckState> _checkChanges;

  @override
  void initState() {
    super.initState();
    _checkChanges = _usernameCheck.stream.listen(
      (_) => _formCubit.notifyFieldChanged(),
    );
    _usernameController.addListener(_onUsernameChanged);
    _onUsernameChanged();
  }

  void _onUsernameChanged() => _usernameCheck.changed(_usernameController.text);

  /// A name, a username confirmed free (or the person's own), and
  /// something actually changed.
  bool get _canSave {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    if (name.isEmpty) return false;
    if (!_usernameCheck.state.confirms(username)) return false;
    return name != widget.initialName.trim() ||
        username != (widget.initialUsername ?? '').trim();
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_formCubit.notifyFieldChanged)
      ..dispose();
    _usernameController
      ..removeListener(_formCubit.notifyFieldChanged)
      ..removeListener(_onUsernameChanged)
      ..dispose();
    unawaited(_checkChanges.cancel());
    _formCubit.close();
    _usernameCheck.close();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    if (_formCubit.state.saving || !_canSave) return;
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    _formCubit.setSaving(true);
    final result = await context.read<ProfileCubit>().updateProfile(
      name: name,
      username: username,
    );
    if (!context.mounted) return;
    _formCubit.setSaving(false);
    // Someone took the name after it was checked: the database refused it
    // (nobody else's profile is touched). Said on the field itself.
    if (result case Error(failure: UsernameTakenFailure())) {
      _usernameCheck.markTaken(username);
      return;
    }
    if (result case Error(:final failure)) {
      await AppInfoBottomSheet.showError(context, description: failure.message);
      return;
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = ProfileStrings(language);
    final u = UsernameStrings(language);
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _formCubit),
        BlocProvider.value(value: _usernameCheck),
      ],
      child: BlocBuilder<AccountFormCubit, AccountFormState>(
        builder: (context, formState) => Scaffold(
          backgroundColor: context.colors.background,
          body: Column(
            children: [
              ModernAppBar(
                title: t.myAccountPageTitle,
                subtitle: t.myAccountPageSubtitle,
                showBackButton: true,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _nameController,
                        prefixIcon: Icons.person_outline,
                        hintText: t.nameHint,
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<UsernameCheckCubit, UsernameCheckState>(
                        builder: (context, check) => AppTextField(
                          controller: _usernameController,
                          prefixIcon: Icons.alternate_email,
                          hintText: t.usernameHint,
                          autofillHints: const [AutofillHints.username],
                          // Empty is an error here too: the account has to
                          // keep a username.
                          errorText: u.errorFor(
                            _usernameController.text,
                            check,
                            submitted: true,
                          ),
                          suffixIcon: UsernameStatusIndicator(
                            check: check,
                            value: _usernameController.text,
                            availableLabel: u.available,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: context.colors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            // A long address overflowed this row: it is
                            // read-only here, so truncating is better than
                            // a striped overflow bar.
                            Expanded(
                              child: Text(
                                widget.email,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: t.saveButtonLabel,
                        isLoading: formState.saving,
                        onPressed: _canSave && !formState.saving
                            ? () => _save(context)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
