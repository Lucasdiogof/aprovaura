import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/features/essay/presentation/widgets/essay_origin_badge.dart';
import 'package:aura/features/essay/presentation/widgets/essay_status_chip.dart';

/// A theme in the list: provenance, title, a line of description, and the
/// action that matches where the user stands on it.
///
/// Reading comes first -- the title is the biggest thing on the card and
/// the chrome around it stays quiet, because choosing a theme means reading
/// the titles, not scanning badges.
class EssayThemeCard extends StatelessWidget {
  const EssayThemeCard({
    required this.summary,
    required this.strings,
    required this.onTap,
    super.key,
  });

  final EssayThemeSummary summary;
  final EssayStrings strings;
  final VoidCallback onTap;

  String get _actionLabel {
    if (summary.hasDraft) return strings.continueButton;
    if (summary.hasBeenTried) return strings.newAttemptButton;
    return strings.startButton;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: EssayOriginBadge(
                      origin: summary.origin,
                      strings: strings,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  EssayStatusChip(summary: summary, strings: strings),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                summary.title,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              if (summary.description case final description?) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: colors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    _actionLabel,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: colors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
