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

  /// The room an ExpansionTile keeps for its chevron. A competency with
  /// nothing to expand borrows the same gutter, so the scores and the bars
  /// line up down the column whether or not there is detail behind them.
  static const _chevronGutter = 40.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasDetail =
        competency.summary.isNotEmpty ||
        competency.strengths.isNotEmpty ||
        competency.improvements.isNotEmpty ||
        competency.evidence.isNotEmpty;

    // One line for label and score, so the numbers line up down the
    // column and the lowest competency is findable at a glance. The title
    // gets a single line under it -- five wrapped titles turned the list
    // into a wall.
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                strings.competencyLabel(competency.key),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${competency.score}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                  TextSpan(
                    text: ' / ${EssayCompetency.maxScore}',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (competency.title.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            competency.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        _ScoreBar(fraction: competency.fraction),
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
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md + _chevronGutter,
                  AppSpacing.md,
                ),
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
                  if (!quoted)
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
                    child: quoted
                        // A tonal strip with a rule on the left: these are
                        // the person's own words coming back, not the
                        // marker's prose.
                        ? Container(
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border(
                                left: BorderSide(
                                  color: colors.border,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Text(
                              '"$item"',
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.45,
                                fontStyle: FontStyle.italic,
                                color: colors.textPrimary,
                              ),
                            ),
                          )
                        : Text(
                            item,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.45,
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
