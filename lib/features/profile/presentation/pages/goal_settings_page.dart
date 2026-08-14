import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/profile/domain/entities/goal.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/profile_state.dart';
import 'package:aura/features/profile/presentation/widgets/goal_selector.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class GoalSettingsPage extends StatelessWidget {
  const GoalSettingsPage({super.key});

  Future<void> _selectGoal(BuildContext context, Goal goal) async {
    final result = await context.read<ProfileCubit>().updateProfile(goal: goal);
    if (!context.mounted) return;
    if (result case Error(:final failure)) {
      await AppInfoBottomSheet.showError(context, description: failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = ProfileStrings(language);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          ModernAppBar(title: t.goalPageTitle, showBackButton: true),
          Expanded(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) => SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: GoalSelector(
                  language: language,
                  selected: state.profile?.goal,
                  onSelect: (goal) => _selectGoal(context, goal),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
