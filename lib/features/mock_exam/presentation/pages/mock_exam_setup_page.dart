import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/l10n/mock_exam_strings.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_setup_cubit.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_setup_state.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_session_page.dart';
import 'package:aura/features/mock_exam/presentation/widgets/mock_exam_active_sheet.dart';
import 'package:aura/features/mock_exam/presentation/widgets/mock_exam_confirm_sheet.dart';
import 'package:aura/features/mock_exam/presentation/widgets/mock_exam_subject_tile.dart';
import 'package:aura/features/subjects/presentation/subject_style.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class MockExamSetupPage extends StatelessWidget {
  const MockExamSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MockExamSetupCubit(sl<MockExamRepository>()),
      child: const _MockExamSetupView(),
    );
  }
}

class _MockExamSetupView extends StatelessWidget {
  const _MockExamSetupView();

  Future<void> _start(BuildContext context, AppLanguage language) async {
    final cubit = context.read<MockExamSetupCubit>();
    if (!cubit.state.canStart) return;

    final confirmed = await showMockExamConfirmSheet(
      context,
      selections: cubit.state.orderedSelections,
      language: language,
    );
    if (!confirmed || !context.mounted) return;

    final result = await cubit.submit();
    if (!context.mounted) return;
    switch (result) {
      case MockExamCreated(:final mockExamId):
        _openSession(context, mockExamId);
      case MockExamAlreadyActive(:final active):
        final choice = await showMockExamActiveSheet(
          context,
          active: active,
          language: language,
          onDiscard: cubit.discardActive,
        );
        if (!context.mounted) return;
        switch (choice) {
          case MockExamActiveChoice.continueExam when active != null:
            _openSession(context, active.id);
          case MockExamActiveChoice.discarded:
            // Back to the config the user already built -- nothing is lost,
            // and "Iniciar simulado" now creates the new one.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(MockExamStrings(language).discardedMessage),
              ),
            );
          case _:
            break;
        }
      case MockExamSubmitFailed(:final failure):
        await AppInfoBottomSheet.showError(
          context,
          description: _failureMessage(context, failure, language),
        );
    }
  }

  void _openSession(BuildContext context, String mockExamId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => MockExamSessionPage(mockExamId: mockExamId),
      ),
    );
  }

  String _failureMessage(
    BuildContext context,
    MockExamFailure failure,
    AppLanguage language,
  ) {
    final subject = failure.subject;
    return MockExamStrings(language).failureMessage(
      failure,
      subjectLabel: subject == null
          ? null
          : subjectStyle(
              subject,
              language,
              fallbackColor: context.colors.primary,
            ).label,
      difficultyLabel: failure.difficulty?.label(language),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = MockExamStrings(language);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: BlocBuilder<MockExamSetupCubit, MockExamSetupState>(
        builder: (context, state) {
          final cubit = context.read<MockExamSetupCubit>();
          return Column(
            children: [
              ModernAppBar(title: t.setupTitle, showBackButton: true),
              Expanded(
                child: switch (state.status) {
                  MockExamSetupStatus.loading => Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                  MockExamSetupStatus.loadError => _LoadErrorView(
                    strings: t,
                    onRetry: cubit.load,
                  ),
                  MockExamSetupStatus.ready => ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.lg,
                      AppSpacing.pageHorizontal,
                      AppSpacing.xxl,
                    ),
                    children: [
                      Text(
                        t.setupDescription,
                        style: TextStyle(color: context.colors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      for (final subject in state.subjects) ...[
                        MockExamSubjectTile(
                          key: ValueKey(subject),
                          subject: subject,
                          state: state,
                          language: language,
                          onToggle: () => cubit.toggleSubject(subject),
                          onDifficultyChanged: (difficulty) =>
                              cubit.setDifficulty(subject, difficulty),
                          onIncrease: () => cubit.increase(subject),
                          onDecrease: () => cubit.decrease(subject),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ),
                },
              ),
              _SummaryBar(
                state: state,
                strings: t,
                onStart: () => _start(context, language),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Sticky footer: live "N matérias · M questões" and the start button,
/// disabled whenever the config can't be sent (nothing selected, still
/// loading, submitting, or anything out of range).
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.state,
    required this.strings,
    required this.onStart,
  });

  final MockExamSetupState state;
  final MockExamStrings strings;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final hasSelection = state.selectedSubjectCount > 0;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.md,
            AppSpacing.pageHorizontal,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hasSelection
                          ? strings.summary(
                              state.selectedSubjectCount,
                              state.totalQuestions,
                            )
                          : strings.emptySummary,
                      style: TextStyle(
                        fontWeight: hasSelection
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: hasSelection
                            ? context.colors.textPrimary
                            : context.colors.textSecondary,
                      ),
                    ),
                  ),
                  if (state.isAtGlobalLimit)
                    Text(
                      strings.globalLimitReached,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colors.warning,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: strings.startButton,
                isLoading: state.isSubmitting,
                onPressed: state.canStart ? onStart : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadErrorView extends StatelessWidget {
  const _LoadErrorView({required this.strings, required this.onRetry});

  final MockExamStrings strings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: context.colors.error,
            ),
            const SizedBox(height: 16),
            Text(
              strings.loadErrorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 20),
            AppButton(label: strings.retryButton, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
