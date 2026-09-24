import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

class SubjectCard extends StatelessWidget {
  const SubjectCard({
    required this.subject,
    required this.language,
    required this.onTap,
    super.key,
  });

  final Subject subject;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: subject.accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(subject.icon, color: subject.accentColor),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: context.colors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subject.label(language),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subject.description(language),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
