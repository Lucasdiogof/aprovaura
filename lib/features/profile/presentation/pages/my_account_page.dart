import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/features/profile/presentation/cubit/account_form_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/account_form_state.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';
import 'package:aura/shared/widgets/app_text_field.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

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

  bool get _canSave {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    if (name.isEmpty) return false;
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
      ..dispose();
    _formCubit.close();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final username = _usernameController.text.trim();
    _formCubit.setSaving(true);
    final result = await context.read<ProfileCubit>().updateProfile(
      name: name,
      username: username.isEmpty ? null : username,
    );
    if (!context.mounted) return;
    _formCubit.setSaving(false);
    if (result case Error(:final failure)) {
      await AppInfoBottomSheet.showError(context, description: failure.message);
      return;
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = ProfileStrings(context.watch<LocaleCubit>().state);
    return BlocProvider.value(
      value: _formCubit,
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
                      AppTextField(
                        controller: _usernameController,
                        prefixIcon: Icons.alternate_email,
                        hintText: t.usernameHint,
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
                            Text(
                              widget.email,
                              style: TextStyle(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: t.saveButtonLabel,
                        isLoading: formState.saving,
                        onPressed: _canSave ? () => _save(context) : null,
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
