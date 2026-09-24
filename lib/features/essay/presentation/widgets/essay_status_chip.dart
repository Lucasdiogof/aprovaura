import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';

/// Where the user stands on a theme: the last score, a draft, or a marking
/// in progress.
///
/// Returns nothing at all for a theme never tried. There is deliberately no
/// "0", no "not done" and no progress bar: an essay either has a score or
/// has no story to tell yet.
class EssayStatusChip extends StatelessWidget {
  const EssayStatusChip({
    required this.summary,
    required this.strings,
    super.key,
  });

  final EssayThemeSummary summary;
  final EssayStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (summary.lastScore != null) {
      return _Chip(
        label: '${summary.lastScore}',
        foreground: colors.primary,
        emphasized: true,
      );
    }
    if (summary.lastStatus?.isInProgress ?? false) {
      return _Chip(
        label: strings.evaluatingBadge,
        foreground: colors.textSecondary,
      );
    }
    if (summary.hasDraft) {
      return _Chip(label: strings.draftBadge, foreground: colors.warning);
    }
    return const SizedBox.shrink();
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.foreground,
    this.emphasized = false,
  });

  final String label;
  final Color foreground;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: emphasized ? 14 : 12,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}
