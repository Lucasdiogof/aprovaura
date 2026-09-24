import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/questions/l10n/multiple_choice_strings.dart';

class QuizProgress extends StatelessWidget {
  const QuizProgress({
    required this.strings,
    required this.currentIndex,
    required this.totalCount,
    super.key,
  });

  final MultipleChoiceStrings strings;
  final int currentIndex;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final fraction = totalCount == 0 ? 0.0 : (currentIndex + 1) / totalCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.questionProgress(currentIndex + 1, totalCount),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: context.colors.border,
            valueColor: AlwaysStoppedAnimation(context.colors.primary),
          ),
        ),
      ],
    );
  }
}
