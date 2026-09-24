import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/features/essay/presentation/cubit/essay_submission_cubit.dart';
import 'package:aura/features/essay/presentation/cubit/essay_submission_state.dart';
import 'package:aura/features/essay/presentation/widgets/essay_attempt_status_label.dart';
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
                  EssaySubmissionLoaded(:final submission) => _SubmissionView(
                    submission: submission,
                    strings: t,
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
  const _SubmissionView({required this.submission, required this.strings});

  final EssaySubmission submission;
  final EssayStrings strings;

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
        if (submission.totalScore case final score?) ...[
          const SizedBox(height: AppSpacing.lg),
          _Score(score: score, strings: strings),
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
      ],
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.score, required this.strings});

  final int score;
  final EssayStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.scoreLabel,
          style: TextStyle(fontSize: 12, color: colors.textSecondary),
        ),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: colors.primary,
          ),
        ),
      ],
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
