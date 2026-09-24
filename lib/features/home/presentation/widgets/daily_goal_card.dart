import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/home/l10n/home_strings.dart';

/// How many questions the user has answered today versus the daily target.
/// A tonal (not plain-white) surface gives it a bit of the Aura tint
/// without a gradient or a border -- the first thing offered on Home, so it
/// reads as a step up from the plain option cards below it.
class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({required this.strings, required this.goal, super.key});

  final HomeStrings strings;
  final DailyGoal goal;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.track_changes_rounded,
                color: colors.primary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                strings.dailyGoalTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: colors.primary,
                ),
              ),
              const Spacer(),
              if (goal.isComplete)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: colors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      strings.dailyGoalCompleteBadge,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: colors.success,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            strings.dailyGoalProgress(goal.answered, goal.target),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 8,
              backgroundColor: colors.surface,
              valueColor: AlwaysStoppedAnimation(colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
