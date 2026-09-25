import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';
import 'package:aura/features/catalog/presentation/catalog_node_icon.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

/// A subtopic row -- one level (or more) below [CatalogNodeTile]. The
/// deepest, plainest density: single-line title, no description, and a
/// hairline progress bar that only shows once the person has actually
/// started (never a bare "0%"). Depth reads through density, not through
/// indentation or extra chrome.
class CatalogLeafTile extends StatelessWidget {
  const CatalogLeafTile({
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
    final started = progress != null && progress!.completed > 0;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Icon(
                catalogNodeIcon(node.icon, subject),
                color: accentColor,
                size: 15,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      node.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (started) ...[
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: LinearProgressIndicator(
                          value: progress!.fraction,
                          minHeight: 3,
                          backgroundColor: colors.border,
                          valueColor: AlwaysStoppedAnimation(
                            progress!.isCompleted
                                ? colors.success
                                : accentColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textSecondary.withValues(alpha: 0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
