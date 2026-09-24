import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/features/profile/presentation/cubit/interested_subjects_form_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/interested_subjects_form_state.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/features/subjects/presentation/widgets/subject_multi_selector.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class InterestedSubjectsSettingsPage extends StatefulWidget {
  const InterestedSubjectsSettingsPage({
    required this.initialSelection,
    super.key,
  });

  final Set<Subject> initialSelection;

  @override
  State<InterestedSubjectsSettingsPage> createState() =>
      _InterestedSubjectsSettingsPageState();
}

class _InterestedSubjectsSettingsPageState
    extends State<InterestedSubjectsSettingsPage> {
  late final _formCubit = InterestedSubjectsFormCubit(widget.initialSelection);

  @override
  void dispose() {
    _formCubit.close();
    super.dispose();
  }

  Future<void> _save(BuildContext context) async {
    final profileCubit = context.read<ProfileCubit>();
    _formCubit.setSaving(true);
    final result = await profileCubit.updateProfile(
      interestedSubjects: _formCubit.state.selected.toList(),
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
    final language = context.watch<LocaleCubit>().state;
    final t = ProfileStrings(language);
    return BlocProvider.value(
      value: _formCubit,
      child:
          BlocBuilder<InterestedSubjectsFormCubit, InterestedSubjectsFormState>(
            builder: (context, formState) => Scaffold(
              backgroundColor: context.colors.background,
              body: Column(
                children: [
                  ModernAppBar(
                    title: t.interestedSubjectsPageTitle,
                    subtitle: t.interestedSubjectsSelectedCount(
                      formState.selected.length,
                      Subject.values.length,
                    ),
                    showBackButton: true,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: SubjectMultiSelector(
                        language: language,
                        selected: formState.selected,
                        onToggle: _formCubit.toggle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: AppButton(
                      label: t.saveButtonLabel,
                      isLoading: formState.saving,
                      onPressed: () => _save(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
