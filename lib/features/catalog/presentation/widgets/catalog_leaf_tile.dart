import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';
import 'package:aura/features/catalog/presentation/catalog_node_icon.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

/// A subtopic row -- one level (or more) below [CatalogNodeTile]. Same
/// comfortable size as that row, without the description: the title is
/// always shown in full (wrapping onto more lines when it is long, never
/// cut with an ellipsis), and a progress bar only shows once the person has
/// actually started (never a bare "0%").
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
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  catalogNodeIcon(node.icon, subject),
                  color: accentColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      node.title,
                      style: TextStyle(
                        fontSize: 15.5,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (started) ...[
                      const SizedBox(height: AppSpacing.xs + 2),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: LinearProgressIndicator(
                          value: progress!.fraction,
                          minHeight: 4,
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
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textSecondary.withValues(alpha: 0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
