import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

class QuizFeedback extends StatelessWidget {
  const QuizFeedback({
    required this.isCorrect,
    required this.title,
    super.key,
    this.explanation,
  });

  final bool isCorrect;
  final String title;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isCorrect ? colors.success : colors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCorrect
                  ? Icons.celebration_rounded
                  : Icons.info_outline_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                if (explanation != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    explanation!,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
