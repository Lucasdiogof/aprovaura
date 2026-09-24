import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/favorites/domain/entities/favorite_question.dart';
import 'package:aura/features/favorites/l10n/favorites_strings.dart';

class FavoriteQuestionTile extends StatelessWidget {
  const FavoriteQuestionTile({
    required this.favorite,
    required this.language,
    required this.onTap,
    super.key,
  });

  final FavoriteQuestion favorite;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = FavoritesStrings(language);
    final (statusLabel, statusColor, statusIcon) = switch (favorite.status) {
      FavoriteQuestionStatus.unanswered => (
        strings.statusUnanswered,
        context.colors.textSecondary,
        Icons.radio_button_unchecked_rounded,
      ),
      FavoriteQuestionStatus.correct => (
        strings.statusCorrect,
        context.colors.success,
        Icons.check_circle_rounded,
      ),
      FavoriteQuestionStatus.needsReview => (
        strings.statusNeedsReview,
        context.colors.error,
        Icons.replay_rounded,
      ),
    };
    // Prompts can carry line breaks meant for the full quiz layout; a
    // two-line excerpt reads better with them collapsed.
    final excerpt = favorite.question.prompt
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                excerpt,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  _Chip(
                    label: favorite.question.difficulty.label(language),
                    color: context.colors.textSecondary,
                  ),
                  _Chip(
                    label: statusLabel,
                    color: statusColor,
                    icon: statusIcon,
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
