import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/l10n/mock_exam_strings.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_runner_cubit.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_runner_state.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_result_page.dart';
import 'package:aura/features/mock_exam/presentation/widgets/mock_exam_sheet_frame.dart';
import 'package:aura/features/questions/l10n/multiple_choice_strings.dart';
import 'package:aura/features/questions/presentation/widgets/quiz_answer_option.dart';
import 'package:aura/features/questions/presentation/widgets/quiz_progress.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/subjects/presentation/subject_style.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/features/mock_exam/presentation/widgets/mock_exam_content_width.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

const _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

enum _MenuAction { abandon }

/// Taking a mock exam, in exam mode: pick, change or skip answers, move
/// back and forth, leave and come back, hand it in. Nothing on this screen
/// says whether an answer is right -- the client never even has the
/// correct answer until finish_mock_exam() grades it on the server.
class MockExamSessionPage extends StatelessWidget {
  const MockExamSessionPage({required this.mockExamId, super.key});

  final String mockExamId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MockExamRunnerCubit(sl<MockExamRepository>(), mockExamId: mockExamId),
      child: const _MockExamRunnerView(),
    );
  }
}

class _MockExamRunnerView extends StatelessWidget {
  const _MockExamRunnerView();

  /// Back/close: never abandons. Leaving waits for the real write queue
  /// (no timer): if everything is already saved it leaves at once;
  /// otherwise it shows "Salvando…" until the server answers, with an
  /// explicit "Sair sem esperar" so a hung connection can't trap anyone
  /// (writes already sent keep going in the background, and reopening
  /// always shows what the server actually has). If the last answer
  /// didn't make it, it says so instead of claiming it's saved.
  Future<void> _confirmExit(BuildContext context, MockExamStrings t) async {
    final cubit = context.read<MockExamRunnerCubit>();
    if (cubit.state.isBusy) return;
    await AppInfoBottomSheet.showInfo(
      context,
      title: t.exitTitle,
      description: t.exitDescription,
      primaryActionLabel: t.exitConfirmButton,
      onPrimaryAction: () => _leave(context, t),
      secondaryActionLabel: t.activeContinueButton,
    );
  }

  Future<void> _leave(BuildContext context, MockExamStrings t) async {
    final cubit = context.read<MockExamRunnerCubit>();
    if (cubit.state.isSaving) {
      final waited = await MockExamSheetFrame.show<bool>(
        context,
        (_) => _SavingBeforeExitSheet(cubit: cubit, strings: t),
      );
      if (!context.mounted) return;
      // Dismissed some other way, or "Sair sem esperar".
      if (waited != true) {
        Navigator.of(context).pop();
        return;
      }
    }
    if (!context.mounted) return;
    if (cubit.state.hasSaveError) {
      await AppInfoBottomSheet.showError(
        context,
        title: t.unsavedTitle,
        description: t.unsavedDescription,
        primaryActionLabel: t.stayButton,
        secondaryActionLabel: t.leaveAnywayButton,
        onSecondaryAction: () {
          if (context.mounted) Navigator.of(context).pop();
        },
      );
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmAbandon(BuildContext context, MockExamStrings t) async {
    final cubit = context.read<MockExamRunnerCubit>();
    await AppInfoBottomSheet.showError(
      context,
      title: t.abandonTitle,
      description: t.abandonDescription,
      primaryActionLabel: t.abandonMenuItem,
      onPrimaryAction: () async {
        final failure = await cubit.abandon();
        if (!context.mounted) return;
        if (failure == null) {
          // Unless it turned out to be already handed in -- then the screen
          // now says so and offers the result instead.
          if (cubit.state.status != MockExamRunnerStatus.finishedElsewhere) {
            Navigator.of(context).pop();
          }
          return;
        }
        await AppInfoBottomSheet.showError(
          context,
          description: t.failureMessage(failure),
        );
      },
      secondaryActionLabel: t.cancelButton,
    );
  }

  /// "Entregar simulado": warns about blanks first (with a way back to the
  /// first one), otherwise a plain confirmation. Only a confirmed choice
  /// reaches finish_mock_exam().
  Future<void> _confirmSubmit(BuildContext context, MockExamStrings t) async {
    final cubit = context.read<MockExamRunnerCubit>();
    if (cubit.state.isBusy) return;
    final unanswered = cubit.state.unansweredCount;
    if (unanswered > 0) {
      await AppInfoBottomSheet.showInfo(
        context,
        title: t.unansweredTitle(unanswered),
        description: t.unansweredDescription,
        primaryActionLabel: t.reviewButton,
        onPrimaryAction: () {
          final index = cubit.state.firstUnansweredIndex;
          if (index != null) cubit.goTo(index);
        },
        secondaryActionLabel: t.submitAnywayButton,
        onSecondaryAction: () => _submit(context, t),
      );
    } else {
      await AppInfoBottomSheet.showInfo(
        context,
        title: t.submitTitle,
        description: t.submitDescription,
        primaryActionLabel: t.submitButton,
        onPrimaryAction: () => _submit(context, t),
        secondaryActionLabel: t.reviewButton,
      );
    }
  }

  Future<void> _submit(BuildContext context, MockExamStrings t) async {
    final cubit = context.read<MockExamRunnerCubit>();
    final result = await cubit.finish();
    if (!context.mounted) return;
    switch (result) {
      case MockExamFinished():
        // XP was already credited on the server inside finish_mock_exam();
        // this only refreshes the on-screen total. The streak counts a
        // handed-in exam like any other finished activity.
        unawaited(context.read<XpCubit>().load());
        unawaited(context.read<StreakCubit>().registerActivityCompletion());
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => MockExamResultPage(mockExamId: cubit.mockExamId),
          ),
        );
      case MockExamFinishFailed(:final failure):
        await AppInfoBottomSheet.showError(
          context,
          description: t.failureMessage(failure),
        );
      case MockExamFinishIgnored():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = MockExamStrings(language);
    return BlocBuilder<MockExamRunnerCubit, MockExamRunnerState>(
      builder: (context, state) {
        final isReady = state.status == MockExamRunnerStatus.ready;
        return PopScope(
          canPop: !isReady,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _confirmExit(context, t);
          },
          child: Scaffold(
            backgroundColor: context.colors.background,
            body: Column(
              children: [
                ModernAppBar(
                  title: t.sessionTitle,
                  showBackButton: true,
                  trailing: isReady
                      ? PopupMenuButton<_MenuAction>(
                          tooltip: t.menuTooltip,
                          enabled: !state.isBusy,
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: context.colors.textSecondary,
                          ),
                          // onSelected (not the item's onTap) runs after the
                          // menu route is gone, so the sheet it opens can't
                          // be popped by the menu closing.
                          onSelected: (_) => _confirmAbandon(context, t),
                          itemBuilder: (_) => [
                            PopupMenuItem<_MenuAction>(
                              value: _MenuAction.abandon,
                              child: Text(
                                t.abandonMenuItem,
                                style: TextStyle(color: context.colors.error),
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
                Expanded(
                  child: switch (state.status) {
                    MockExamRunnerStatus.loading => Center(
                      child: CircularProgressIndicator(
                        color: context.colors.primary,
                      ),
                    ),
                    MockExamRunnerStatus.loadError => _MessageView(
                      icon: Icons.error_outline_rounded,
                      iconColor: context.colors.error,
                      message: t.sessionLoadError,
                      actionLabel: t.retryButton,
                      onAction: context.read<MockExamRunnerCubit>().load,
                    ),
                    MockExamRunnerStatus.finishedElsewhere => _MessageView(
                      icon: Icons.assignment_turned_in_outlined,
                      iconColor: context.colors.primary,
                      message: t.finishedElsewhereMessage,
                      actionLabel: t.seeResultButton,
                      onAction: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => MockExamResultPage(
                            mockExamId: context
                                .read<MockExamRunnerCubit>()
                                .mockExamId,
                          ),
                        ),
                      ),
                    ),
                    MockExamRunnerStatus.abandonedElsewhere => _MessageView(
                      icon: Icons.assignment_late_outlined,
                      iconColor: context.colors.textSecondary,
                      message: t.abandonedElsewhereMessage,
                      actionLabel: t.backHomeButton,
                      onAction: () => Navigator.of(context).pop(),
                    ),
                    MockExamRunnerStatus.notFound => _MessageView(
                      icon: Icons.assignment_late_outlined,
                      iconColor: context.colors.textSecondary,
                      message: t.notFoundMessage,
                      actionLabel: t.backHomeButton,
                      onAction: () => Navigator.of(context).pop(),
                    ),
                    MockExamRunnerStatus.ready => _QuestionView(
                      state: state,
                      strings: t,
                      language: language,
                      onSubmit: () => _confirmSubmit(context, t),
                    ),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.state,
    required this.strings,
    required this.language,
    required this.onSubmit,
  });

  final MockExamRunnerState state;
  final MockExamStrings strings;
  final AppLanguage language;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MockExamRunnerCubit>();
    final item = state.currentItem;
    final selected = state.currentAnswer;
    final subjectLabel = subjectStyle(
      item.subject,
      language,
      fallbackColor: context.colors.primary,
    ).label;

    return Column(
      children: [
        // Abandoning locks the whole screen; this is the visible "working
        // on it" (finishing shows it on the hand-in button instead).
        if (state.isAbandoning)
          LinearProgressIndicator(
            minHeight: 2,
            color: context.colors.primary,
            backgroundColor: Colors.transparent,
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            mockExamHorizontalPadding(context),
            AppSpacing.lg,
            mockExamHorizontalPadding(context),
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuizProgress(
                strings: MultipleChoiceStrings(language),
                currentIndex: state.currentIndex,
                totalCount: state.totalCount,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$subjectLabel · ${item.difficulty.label(language)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _AnsweredCounter(state: state, strings: strings),
                ],
              ),
              if (state.hasSaveError) ...[
                const SizedBox(height: AppSpacing.sm),
                _NoticeBanner(
                  icon: Icons.cloud_off_rounded,
                  color: context.colors.error,
                  message: strings.saveErrorMessage,
                  onDismiss: cubit.dismissSaveError,
                ),
              ],
              if (state.hasRemovedQuestionNotice) ...[
                const SizedBox(height: AppSpacing.sm),
                _NoticeBanner(
                  icon: Icons.info_outline_rounded,
                  color: context.colors.textSecondary,
                  message: strings.removedQuestionNotice,
                  onDismiss: cubit.dismissRemovedQuestionNotice,
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            key: ValueKey(item.position),
            padding: EdgeInsets.fromLTRB(
              mockExamHorizontalPadding(context),
              AppSpacing.xl,
              mockExamHorizontalPadding(context),
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.prompt,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                for (var i = 0; i < item.options.length; i++) ...[
                  QuizAnswerOption(
                    letter: i < _letters.length ? _letters[i] : '${i + 1}',
                    text: item.options[i],
                    status: selected == i
                        ? QuizOptionStatus.selected
                        : QuizOptionStatus.neutral,
                    onTap: state.isBusy ? null : () => cubit.select(i),
                  ),
                  if (i != item.options.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border(top: BorderSide(color: context.colors.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                mockExamHorizontalPadding(context),
                AppSpacing.md,
                mockExamHorizontalPadding(context),
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: state.isFirst || state.isBusy
                          ? null
                          : cubit.previous,
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: Text(strings.previousButton),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: state.isLast
                          ? strings.submitButton
                          : strings.nextButton,
                      isLoading: state.isFinishing,
                      onPressed: state.isBusy
                          ? null
                          : state.isLast
                          ? onSubmit
                          : cubit.next,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Neutral progress only -- how many are answered, never how many are
/// right. Swaps to "Salvando…" while a write is in flight.
class _AnsweredCounter extends StatelessWidget {
  const _AnsweredCounter({required this.state, required this.strings});

  final MockExamRunnerState state;
  final MockExamStrings strings;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 12, color: context.colors.textSecondary);
    if (state.isSaving) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          Text(strings.savingLabel, style: style),
        ],
      );
    }
    final currentAnswered = state.currentAnswer != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          currentAnswered ? Icons.circle : Icons.circle_outlined,
          size: 9,
          color: currentAnswered
              ? context.colors.primary
              : context.colors.textHint,
        ),
        const SizedBox(width: 6),
        Text(
          strings.answeredOfTotal(state.answeredCount, state.totalCount),
          style: style,
        ),
      ],
    );
  }
}

class _NoticeBanner extends StatelessWidget {
  const _NoticeBanner({
    required this.icon,
    required this.color,
    required this.message,
    required this.onDismiss,
  });

  final IconData icon;
  final Color color;
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 12, color: color)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDismiss,
            icon: Icon(Icons.close_rounded, size: 18, color: color),
          ),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 20),
            AppButton(label: actionLabel, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}

/// "Salvando suas respostas…" while the write queue drains. Closes itself
/// with true as soon as the server has answered every queued write; "Sair
/// sem esperar" closes it with false.
class _SavingBeforeExitSheet extends StatefulWidget {
  const _SavingBeforeExitSheet({required this.cubit, required this.strings});

  final MockExamRunnerCubit cubit;
  final MockExamStrings strings;

  @override
  State<_SavingBeforeExitSheet> createState() => _SavingBeforeExitSheetState();
}

class _SavingBeforeExitSheetState extends State<_SavingBeforeExitSheet> {
  @override
  void initState() {
    super.initState();
    widget.cubit.flush().then((_) {
      if (mounted) Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          widget.strings.savingBeforeExit,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(widget.strings.leaveWithoutWaitingButton),
        ),
      ],
    );
  }
}
