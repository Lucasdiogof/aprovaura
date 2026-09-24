import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_evaluation.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/features/essay/presentation/widgets/essay_competency_tile.dart';

/// The marking, in the order someone actually reads it: the score, then
/// where it came from, then what to do next.
///
/// Every block only appears when it has content. A marking that came back
/// thin shows less instead of showing empty headings.
class EssayResultView extends StatelessWidget {
  const EssayResultView({
    required this.evaluation,
    required this.strings,
    super.key,
  });

  final EssayEvaluation evaluation;
  final EssayStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TotalScore(evaluation: evaluation, strings: strings),
        if (evaluation.insufficientText) ...[
          const SizedBox(height: AppSpacing.md),
          _Warning(message: strings.insufficientTextWarning),
        ],
        if (evaluation.possibleThemeDeviation) ...[
          const SizedBox(height: AppSpacing.md),
          _Warning(message: strings.themeDeviationWarning),
        ],
        const SizedBox(height: AppSpacing.xl),
        _Heading(label: strings.competenciesHeading),
        for (final competency in evaluation.competencies) ...[
          const SizedBox(height: AppSpacing.sm),
          EssayCompetencyTile(competency: competency, strings: strings),
        ],
        if (evaluation.generalFeedback.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          _Heading(label: strings.generalFeedbackHeading),
          const SizedBox(height: AppSpacing.sm),
          Text(
            evaluation.generalFeedback,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.55,
              color: context.colors.textPrimary,
            ),
          ),
        ],
        if (evaluation.strengths.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          _Heading(label: strings.strengthsHeading),
          const SizedBox(height: AppSpacing.sm),
          _List(items: evaluation.strengths, color: context.colors.success),
        ],
        if (evaluation.priorityImprovements.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          _Heading(label: strings.priorityHeading),
          const SizedBox(height: AppSpacing.sm),
          // Numbered, not bulleted: these are in order of how much they
          // would move the score.
          _List(
            items: evaluation.priorityImprovements,
            color: context.colors.primary,
            numbered: true,
          ),
        ],
      ],
    );
  }
}

class _TotalScore extends StatelessWidget {
  const _TotalScore({required this.evaluation, required this.strings});

  final EssayEvaluation evaluation;
  final EssayStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.estimatedScoreLabel,
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${evaluation.totalScore}',
                style: TextStyle(
                  fontSize: 40,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                strings.outOf(EssayEvaluation.maxTotalScore),
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Never sold as the real thing: this sits with the number, not
          // in fine print somewhere else.
          Text(
            strings.estimatedScoreNote,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.35,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.warning.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: colors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: context.colors.textSecondary,
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    required this.items,
    required this.color,
    this.numbered = false,
  });

  final List<String> items;
  final Color color;
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, item) in items.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (numbered)
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(right: AppSpacing.sm, top: 1),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 10),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
