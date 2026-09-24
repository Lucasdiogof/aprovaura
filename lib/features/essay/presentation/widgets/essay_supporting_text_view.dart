import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';

/// One motivating text.
///
/// A rule down the left instead of a bordered card: several boxed cards in
/// a row read as a stack of unrelated things, when what this actually is
/// is one passage after another in the same document.
///
/// The source sits under the body in small italic -- information about the
/// excerpt, not something to act on.
class EssaySupportingTextView extends StatelessWidget {
  const EssaySupportingTextView({required this.text, super.key});

  final EssaySupportingText text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        0,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.border, width: 3)),
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
