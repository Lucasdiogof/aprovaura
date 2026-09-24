import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_evaluation.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';

/// One competency, collapsed to its score and expandable into the reasons.
///
/// Collapsed by default: five competencies opened at once is a wall of
/// text, and the first thing anyone wants is the shape of the result --
/// which one pulled the score down.
class EssayCompetencyTile extends StatelessWidget {
  const EssayCompetencyTile({
    required this.competency,
    required this.strings,
    super.key,
  });

  final EssayCompetency competency;
  final EssayStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasDetail =
        competency.summary.isNotEmpty ||
        competency.strengths.isNotEmpty ||
        competency.improvements.isNotEmpty ||
        competency.evidence.isNotEmpty;

    final header = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.competencyLabel(competency.key),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              if (competency.title.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  competency.title,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: colors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              _ScoreBar(fraction: competency.fraction),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          '${competency.score}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.primary,
          ),
        ),
      ],
    );

    // Material paints the background, not the Container: an ExpansionTile
    // is a ListTile underneath, and a coloured box above it would swallow
    // its ink splash (the framework asserts on exactly this).
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.border),
        ),
        child: hasDetail
            ? Theme(
                // The divider the ExpansionTile draws by default fights the
                // card's own border.
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  title: header,
                  iconColor: colors.textSecondary,
                  collapsedIconColor: colors.textSecondary,
                  children: [_Detail(competency: competency, strings: strings)],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: header,
              ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.competency, required this.strings});

  final EssayCompetency competency;
  final EssayStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (competency.summary.isNotEmpty)
          Text(
            competency.summary,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: colors.textPrimary,
            ),
          ),
        if (competency.strengths.isNotEmpty)
          _Bullets(
            heading: strings.whatWentWellHeading,
            items: competency.strengths,
            color: colors.success,
          ),
        if (competency.improvements.isNotEmpty)
          _Bullets(
            heading: strings.whatToImproveHeading,
            items: competency.improvements,
            color: colors.warning,
          ),
        if (competency.evidence.isNotEmpty)
          _Bullets(
            heading: strings.evidenceHeading,
            items: competency.evidence,
            color: colors.textSecondary,
            quoted: true,
          ),
      ],
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({
    required this.heading,
    required this.items,
    required this.color,
    this.quoted = false,
  });

  final String heading;
  final List<String> items;
  final Color color;

  /// Evidence is shown in italics: it is the person's own words being
  /// quoted back, not the marker talking.
  final bool quoted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 8),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      quoted ? '"$item"' : item,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        fontStyle: quoted ? FontStyle.italic : null,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: LinearProgressIndicator(
        value: fraction.clamp(0, 1),
        minHeight: 6,
        backgroundColor: colors.border,
        valueColor: AlwaysStoppedAnimation(colors.primary),
      ),
    );
  }
}
