import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/theme/app_colors.dart';
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
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: subject.accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
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
              const SizedBox(height: 12),
              Text(
                subject.label(language),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
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
