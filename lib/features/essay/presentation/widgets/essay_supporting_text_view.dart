import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';

/// One motivating text. The source sits under the body in small italic: it
/// is information about the excerpt, not something to act on.
class EssaySupportingTextView extends StatelessWidget {
  const EssaySupportingTextView({required this.text, super.key});

  final EssaySupportingText text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (text.title case final title?) ...[
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(
            text.body,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.6,
              color: colors.textPrimary,
            ),
          ),
          if (text.source case final source?) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              source,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
