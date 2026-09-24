import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/features/progress/domain/entities/profile_stats.dart';
import 'package:aura/shared/widgets/stat_cell.dart';

/// Lifetime snapshot under the level card: streak, total questions
/// answered, accuracy. Same StatCell used by the quiz result screen.
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    required this.strings,
    required this.streakDays,
    required this.stats,
    super.key,
  });

  final ProfileStrings strings;
  final int streakDays;
  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: StatCell(
                icon: Icons.local_fire_department,
                iconColor: const Color(0xFFE8763D),
                value: '$streakDays',
                label: strings.streakStatLabel,
              ),
            ),
            VerticalDivider(color: colors.border, width: 1),
            Expanded(
              child: StatCell(
                icon: Icons.quiz_outlined,
                iconColor: colors.primary,
                value: '${stats.totalAnswered}',
                label: strings.questionsStatLabel,
              ),
            ),
            VerticalDivider(color: colors.border, width: 1),
            Expanded(
              child: StatCell(
                icon: Icons.track_changes_rounded,
                iconColor: colors.primary,
                value: '${stats.accuracyPercent}%',
                label: strings.accuracyStatLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
