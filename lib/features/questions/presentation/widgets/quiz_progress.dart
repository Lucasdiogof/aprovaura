import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

class QuizProgress extends StatelessWidget {
  const QuizProgress({
    required this.currentIndex,
    required this.totalCount,
    super.key,
  });

  final int currentIndex;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final current = currentIndex + 1;
    final progress = totalCount == 0 ? 0.0 : current / totalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Questão $current de $totalCount',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: colors.secondary,
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
        ),
      ],
    );
  }
}
