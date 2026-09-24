import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';

/// Where one attempt stands, in words.
///
/// "Aguardando correção" and "Corrigindo" are deliberately different: the
/// first means nothing has started yet, and saying otherwise would be a
/// lie the person could catch.
class EssayAttemptStatusLabel extends StatelessWidget {
  const EssayAttemptStatusLabel({
    required this.status,
    required this.strings,
    this.expanded = false,
    super.key,
  });

  final EssaySubmissionStatus status;
  final EssayStrings strings;

  /// True on the attempt screen, where the failed case gets its full
  /// sentence instead of the short form used in lists.
  final bool expanded;

  String label() => switch (status) {
    EssaySubmissionStatus.submitted => strings.statusSubmitted,
    EssaySubmissionStatus.evaluating => strings.statusEvaluating,
    EssaySubmissionStatus.evaluated => strings.statusEvaluated,
    EssaySubmissionStatus.failed =>
      expanded ? strings.statusFailed : strings.statusFailedShort,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = switch (status) {
      EssaySubmissionStatus.evaluated => colors.success,
      EssaySubmissionStatus.failed => colors.error,
      _ => colors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
