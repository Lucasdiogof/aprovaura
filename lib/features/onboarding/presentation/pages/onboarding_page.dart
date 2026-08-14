import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/onboarding/l10n/onboarding_strings.dart';
import 'package:aura/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:aura/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:aura/features/profile/domain/entities/goal.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/profile/presentation/widgets/exam_year_selector.dart';
import 'package:aura/features/profile/presentation/widgets/goal_selector.dart';
import 'package:aura/features/subjects/presentation/widgets/subject_multi_selector.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({required this.user, super.key});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(sl<ProfileRepository>()),
      child: _OnboardingView(user: user),
    );
  }
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView({required this.user});

  final AppUser user;

  Future<void> _finish(BuildContext context) async {
    final result = await context.read<OnboardingCubit>().submit();
    if (!context.mounted) return;
    switch (result) {
      case Success():
        context.go('/home', extra: user);
      case Error(:final failure):
        await AppInfoBottomSheet.showError(
          context,
          description: failure.message,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = OnboardingStrings(language);
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final skipsExamYear = state.goal == Goal.contaPropria;
        final totalSteps = skipsExamYear ? 2 : 3;
        final displayStep = state.step == 0
            ? 1
            : (skipsExamYear ? 2 : state.step + 1);
        final canContinue = switch (state.step) {
          0 => state.goal != null,
          1 => state.examYear != null,
          _ => true,
        };
        final isLastStep = state.step == 2;

        return Scaffold(
          backgroundColor: context.colors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (state.step > 0)
                        IconButton(
                          onPressed: context.read<OnboardingCubit>().back,
                          icon: Icon(
                            Icons.arrow_back,
                            color: context.colors.primary,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          t.stepOf(displayStep, totalSteps),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: context.colors.textSecondary),
                        ),
                      ),
                      if (state.step > 0) const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    switch (state.step) {
                      0 => t.goalQuestion,
                      1 => t.examYearQuestion,
                      _ => t.subjectsQuestion,
                    },
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: switch (state.step) {
                        0 => GoalSelector(
                          language: language,
                          selected: state.goal,
                          onSelect: context.read<OnboardingCubit>().selectGoal,
                        ),
                        1 => ExamYearSelector(
                          language: language,
                          selected: state.examYear,
                          onSelect: context
                              .read<OnboardingCubit>()
                              .selectExamYear,
                        ),
                        _ => SubjectMultiSelector(
                          language: language,
                          selected: state.selectedSubjects,
                          onToggle: context
                              .read<OnboardingCubit>()
                              .toggleSubject,
                        ),
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: isLastStep ? t.finishButton : t.continueButton,
                    isLoading: state.saving,
                    onPressed: !canContinue
                        ? null
                        : isLastStep
                        ? () => _finish(context)
                        : context.read<OnboardingCubit>().next,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
