import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/error_review/domain/entities/error_topic.dart';
import 'package:aura/features/error_review/l10n/error_review_strings.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

class ErrorTopicCard extends StatelessWidget {
  const ErrorTopicCard({
    required this.topic,
    required this.language,
    required this.onTap,
    super.key,
  });

  final ErrorTopic topic;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = ErrorReviewStrings(language);
    final subject = Subject.values.where((s) => s.name == topic.subject);
    final accentColor = subject.isEmpty
        ? context.colors.primary
        : subject.first.accentColor;
    final subjectLabel = subject.isEmpty
        ? topic.subject
        : subject.first.label(language);
    final breadcrumb = topic.parentTitle == null
        ? subjectLabel
        : '$subjectLabel • ${topic.parentTitle}';

    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.refresh_rounded, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      breadcrumb,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      topic.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      strings.questionsToReview(topic.wrongCount),
                      style: TextStyle(
                        fontSize: 12,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
