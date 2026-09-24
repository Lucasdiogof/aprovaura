import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/features/essay/presentation/pages/essay_submission_page.dart';
import 'package:aura/features/essay/presentation/widgets/essay_attempt_status_label.dart';

/// One line of a theme's history: when it was sent, and where it stands.
///
/// A graded attempt shows its score; one still waiting shows its status and
/// no number at all -- a zero would read as "you scored nothing".
class EssayAttemptRow extends StatelessWidget {
  const EssayAttemptRow({
    required this.attempt,
    required this.strings,
    super.key,
  });

  final EssayAttempt attempt;
  final EssayStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => EssaySubmissionPage(submissionId: attempt.id),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(attempt.submittedAt.toLocal()),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    EssayAttemptStatusLabel(
                      status: attempt.status,
                      strings: strings,
                    ),
                  ],
                ),
              ),
              if (attempt.status == EssaySubmissionStatus.evaluated &&
                  attempt.totalScore != null)
                Text(
                  strings.scorePoints(attempt.totalScore!),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
