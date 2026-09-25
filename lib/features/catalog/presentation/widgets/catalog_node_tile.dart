import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';
import 'package:aura/features/catalog/l10n/catalog_strings.dart';
import 'package:aura/features/catalog/presentation/catalog_node_icon.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

/// A category row -- one level below the subject grid. Denser than
/// [SubjectTile] (no card-in-a-grid, just a row), still roomy enough for a
/// two-line description and a progress bar; [CatalogLeafTile] is the even
/// tighter row for the levels under this one.
class CatalogNodeTile extends StatelessWidget {
  const CatalogNodeTile({
    required this.node,
    required this.subject,
    required this.onTap,
    super.key,
    this.progress,
  });

  final CatalogNode node;
  final Subject subject;
  final VoidCallback onTap;
  final TopicProgress? progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accentColor = subject.accentColor;
    final language = context.watch<LocaleCubit>().state;
    final t = CatalogStrings(language);
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  catalogNodeIcon(node.icon, subject),
                  color: accentColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (node.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        node.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                    // No bar at all for an unstarted topic -- a hollow "0%"
                    // on nearly every row was exactly the noise this
                    // redesign was asked to remove. Done gets a discreet
                    // label instead of a full bar too.
                    if (progress != null && progress!.completed > 0) ...[
                      const SizedBox(height: AppSpacing.xs + 2),
                      if (progress!.isCompleted)
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: colors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              t.topicCompletedLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colors.success,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                child: LinearProgressIndicator(
                                  value: progress!.fraction,
                                  minHeight: 4,
                                  backgroundColor: colors.border,
                                  valueColor: AlwaysStoppedAnimation(
                                    accentColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '${(progress!.fraction * 100).round()}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textSecondary.withValues(alpha: 0.7),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
