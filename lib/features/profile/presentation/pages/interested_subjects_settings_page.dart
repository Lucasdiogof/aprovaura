import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/features/profile/presentation/cubit/interested_subjects_form_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/features/subjects/presentation/widgets/subject_multi_selector.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class InterestedSubjectsSettingsPage extends StatelessWidget {
  const InterestedSubjectsSettingsPage({
    required this.initialSelection,
    super.key,
  });

  final Set<Subject> initialSelection;

  Future<void> _save(BuildContext context) async {
    final selected = context.read<InterestedSubjectsFormCubit>().state;
    await context.read<ProfileCubit>().updateProfile(
      interestedSubjects: selected.toList(),
    );
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = ProfileStrings(language);
    return BlocProvider(
      create: (_) => InterestedSubjectsFormCubit(initialSelection),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Column(
          children: [
            ModernAppBar(
              title: t.interestedSubjectsPageTitle,
              showBackButton: true,
            ),
            Expanded(
              child: BlocBuilder<InterestedSubjectsFormCubit, Set<Subject>>(
                builder: (context, selected) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: SubjectMultiSelector(
                    language: language,
                    selected: selected,
                    onToggle: context
                        .read<InterestedSubjectsFormCubit>()
                        .toggle,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: AppButton(
                label: t.saveButtonLabel,
                onPressed: () => _save(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
