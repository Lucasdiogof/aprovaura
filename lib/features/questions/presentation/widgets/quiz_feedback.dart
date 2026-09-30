import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

/// The card shown under the options once the question is answered.
///
/// It carries only the explanation. The icon and the "Muito bem!" /
/// "Não foi dessa vez" headline were dropped: the answered options already
/// say, in green and red, whether the person got it right, so the headline
/// repeated that and pushed the one thing worth reading further down.
///
/// The tint stays, since it is what ties the card to the answer above it;
/// with no explanation to show there is nothing left to render.
class QuizFeedback extends StatelessWidget {
  const QuizFeedback({required this.isCorrect, super.key, this.explanation});

  final bool isCorrect;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final explanation = this.explanation;
    if (explanation == null || explanation.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final color = isCorrect ? colors.success : colors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        explanation,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }
}
