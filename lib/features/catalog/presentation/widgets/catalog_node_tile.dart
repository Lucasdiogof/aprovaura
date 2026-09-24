import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';
import 'package:aura/features/catalog/presentation/catalog_node_icon.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

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
    final accentColor = subject.accentColor;
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
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
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
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                    if (progress != null && progress!.total > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                              child: LinearProgressIndicator(
                                value: progress!.fraction,
                                minHeight: 5,
                                backgroundColor: context.colors.border,
                                valueColor: AlwaysStoppedAnimation(accentColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${(progress!.fraction * 100).round()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.colors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
