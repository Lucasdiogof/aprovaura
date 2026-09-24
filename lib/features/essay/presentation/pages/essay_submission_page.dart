import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/features/essay/presentation/cubit/essay_submission_cubit.dart';
import 'package:aura/features/essay/presentation/cubit/essay_submission_state.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/presentation/pages/essay_editor_page.dart';
import 'package:aura/features/essay/presentation/widgets/essay_attempt_status_label.dart';
import 'package:aura/features/essay/presentation/widgets/essay_result_view.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// One attempt, exactly as it was sent. Read-only by construction: nothing
/// in the app can change a submission, because the server has no update or
/// delete policy for one.
///
/// While an attempt is still waiting there are no empty competency blocks
/// to look at -- the full result screen belongs to the evaluation phase.
class EssaySubmissionPage extends StatelessWidget {
  const EssaySubmissionPage({required this.submissionId, super.key});

  final String submissionId;

  @override
  Widget build(BuildContext context) {
    final t = EssayStrings(context.watch<LocaleCubit>().state);
    return BlocProvider(
      create: (_) => EssaySubmissionCubit(sl<EssayRepository>(), submissionId),
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Column(
          children: [
            ModernAppBar(title: t.subjectLabel, showBackButton: true),
            Expanded(
              child: BlocBuilder<EssaySubmissionCubit, EssaySubmissionState>(
                builder: (context, state) => switch (state) {
                  EssaySubmissionLoading() => Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                  EssaySubmissionError() => _ErrorView(strings: t),
                  EssaySubmissionLoaded(
                    :final submission,
                    :final isRequesting,
                    :final failure,
                  ) =>
                    _SubmissionView(
                      submission: submission,
                      strings: t,
                      isRequesting: isRequesting,
                      failure: failure,
                      gaveUpWaiting: context
                          .read<EssaySubmissionCubit>()
                          .gaveUpWaiting,
                    ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmissionView extends StatelessWidget {
  const _SubmissionView({
    required this.submission,
    required this.strings,
    required this.isRequesting,
    required this.failure,
    required this.gaveUpWaiting,
  });

  final EssaySubmission submission;
  final EssayStrings strings;
  final bool isRequesting;
  final EssayEvaluationFailure? failure;
  final bool gaveUpWaiting;

  String _failureMessage() => switch (failure) {
    EssayEvaluationFailure.dailyLimitReached => strings.evaluationDailyLimit,
    EssayEvaluationFailure.providerUnavailable => strings.evaluationUnavailable,
    EssayEvaluationFailure.invalidOutput => strings.evaluationInvalidOutput,
    EssayEvaluationFailure.notConfigured => strings.evaluationNotConfigured,
    _ => strings.evaluationUnavailable,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
      ),
      children: [
        Text(
          submission.themeTitle,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          // Formatted here from the server's timestamp -- the database
          // never stores a formatted string. MaterialLocalizations already
          // follows the app's locale, so this needs no date package.
          MaterialLocalizations.of(
            context,
          ).formatMediumDate(submission.submittedAt.toLocal()),
          style: TextStyle(fontSize: 12.5, color: colors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        EssayAttemptStatusLabel(
          status: submission.status,
          strings: strings,
          expanded: true,
        ),
        if (submission.evaluation case final evaluation?) ...[
          const SizedBox(height: AppSpacing.lg),
          EssayResultView(evaluation: evaluation, strings: strings),
        ],
        if (submission.status.isInProgress || isRequesting) ...[
          const SizedBox(height: AppSpacing.md),
          _WaitingNote(
            // Says "come back later" only after the screen stopped
            // watching -- the marking may well still finish on the server.
            message: gaveUpWaiting && !isRequesting
                ? strings.stillEvaluatingHint
                : strings.evaluatingHint,
          ),
        ],
        if (failure != null) ...[
          const SizedBox(height: AppSpacing.md),
          _FailureNote(message: _failureMessage()),
        ],
        // Offered whenever nothing is running and the attempt has no
        // result: a failed marking, or one the daily limit turned away.
        // "submitted" counts here -- it only looks in progress; with a
        // refusal recorded, nothing is actually being marked.
        if (!isRequesting &&
            (submission.status == EssaySubmissionStatus.failed ||
                (submission.status == EssaySubmissionStatus.submitted &&
                    failure != null))) ...[
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: strings.retryEvaluationAction,
            onPressed: () =>
                context.read<EssaySubmissionCubit>().requestEvaluation(),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(
          strings.submittedTextHeading.toUpperCase(),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SelectableText(
          submission.body,
          style: TextStyle(
            fontSize: 15.5,
            height: 1.7,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          strings.wordCount(submission.wordCount),
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
        if (submission.status == EssaySubmissionStatus.evaluated) ...[
          const SizedBox(height: AppSpacing.xxl),
          // The attempt is frozen; the way forward is another one, which
          // never touches this one.
          _WriteAnotherButton(themeId: submission.themeId, strings: strings),
        ],
      ],
    );
  }
}

/// Reassurance while the server works, not a spinner that traps the
/// person on the screen: leaving is explicitly fine.
class _WaitingNote extends StatelessWidget {
  const _WaitingNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _FailureNote extends StatelessWidget {
  const _FailureNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.error.withValues(alpha: 0.24)),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 13.5, height: 1.4, color: colors.error),
      ),
    );
  }
}

/// Opens the editor for the same proposal. The theme has to be fetched
/// first because a submission only carries its id -- one call, and then
/// straight into writing.
class _WriteAnotherButton extends StatefulWidget {
  const _WriteAnotherButton({required this.themeId, required this.strings});

  final String themeId;
  final EssayStrings strings;

  @override
  State<_WriteAnotherButton> createState() => _WriteAnotherButtonState();
}

class _WriteAnotherButtonState extends State<_WriteAnotherButton> {
  bool _loading = false;

  Future<void> _open() async {
    if (_loading) return;
    setState(() => _loading = true);
    final result = await sl<EssayRepository>().getTheme(widget.themeId);
    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case Success(:final EssayTheme data):
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => EssayEditorPage(theme: data)),
        );
      case Error():
        await AppInfoBottomSheet.showError(
          context,
          description: widget.strings.themeLoadFailed,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: widget.strings.writeAnotherAction,
      isLoading: _loading,
      onPressed: _open,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.strings});

  final EssayStrings strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              strings.submissionLoadFailed,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: strings.retryButton,
              onPressed: () => context.read<EssaySubmissionCubit>().load(),
            ),
          ],
        ),
      ),
    );
  }
}
