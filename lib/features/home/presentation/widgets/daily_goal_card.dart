import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/home/l10n/home_strings.dart';
import 'package:aura/shared/widgets/aura/aura_animated_border.dart';

/// How many questions the user has answered today versus the daily target.
///
/// Two looks, both read straight from [DailyGoal.isComplete] (no rule of
/// its own):
/// - still to do: a band of light runs around the outline
///   ([AuraAnimatedBorder]); everything inside stays still;
/// - done: fully static, "Meta batida!", a slightly firmer border.
///
/// [goal] is null while it loads: the card shows its shell but doesn't
/// start any animation until the real state is known.
class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({required this.strings, required this.goal, super.key});

  final HomeStrings strings;
  final DailyGoal? goal;

  static const _switch = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final goal = this.goal ?? const DailyGoal(answered: 0);
    final done = this.goal != null && goal.isComplete;
    final animate = this.goal != null && !done;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final switchDuration = reduced ? Duration.zero : _switch;

    return AuraAnimatedBorder(
      active: animate,
      borderRadius: AppRadius.lg,
      child: AnimatedContainer(
        duration: switchDuration,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          // Same width in both states (no layout shift): a whisper while
          // the light runs over it, a touch firmer once it's done.
          border: Border.all(
            color: colors.primary.withValues(alpha: done ? 0.28 : 0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSwitcher(
              duration: switchDuration,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerLeft,
                children: [...previous, ?current],
              ),
              child: _Header(
                key: ValueKey(done),
                icon: done
                    ? Icons.check_circle_rounded
                    : Icons.track_changes_rounded,
                iconColor: done ? colors.success : colors.primary,
                title: done
                    ? strings.dailyGoalCompleteBadge
                    : strings.dailyGoalTitle,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Always the real count against the target, even past it
            // ("14 / 10"): nothing is capped but the bar.
            Text(
              strings.dailyGoalProgress(goal.answered, goal.target),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: colors.textPrimary,
              ),
            ),
            if (goal.isExceeded) ...[
              const SizedBox(height: 2),
              Text(
                strings.dailyGoalExceeded(goal.timesReached),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: colors.success,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                // Clamped to 1 by DailyGoal: 14 / 10 is a full bar.
                value: goal.progress,
                minHeight: 8,
                // Not colors.surface: on this card's own subtle primary
                // tint, a plain surface track was nearly invisible in both
                // themes. A stronger tint of the same primary keeps the
                // empty track visible without an unrelated gray.
                backgroundColor: colors.primary.withValues(alpha: 0.18),
                valueColor: AlwaysStoppedAnimation(colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.icon,
    required this.iconColor,
    required this.title,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
