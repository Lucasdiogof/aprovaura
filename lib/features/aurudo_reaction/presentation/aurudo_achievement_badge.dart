import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_secondary_achievement.dart';

/// A compact pill for one [AurudoSecondaryAchievement] -- "Level 8",
/// "Goal reached", "7-day streak" -- shown alongside a reaction's result,
/// never as its own animation. [label] is the caller's own (localized)
/// text; this widget only picks the icon from [achievement.type] and
/// draws the pill, so it carries no string/l10n ownership of its own.
class AurudoAchievementBadge extends StatelessWidget {
  const AurudoAchievementBadge({
    required this.achievement,
    required this.label,
    super.key,
  });

  final AurudoSecondaryAchievement achievement;
  final String label;

  IconData get _icon => switch (achievement.type) {
    AurudoSecondaryAchievementType.levelUp => Icons.trending_up_rounded,
    AurudoSecondaryAchievementType.streakMilestone =>
      Icons.local_fire_department_rounded,
    AurudoSecondaryAchievementType.dailyGoalComplete =>
      Icons.check_circle_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: colors.primary.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 16, color: colors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
