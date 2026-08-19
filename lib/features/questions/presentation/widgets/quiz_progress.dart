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
    return Text(
      'Questão ${currentIndex + 1} de $totalCount',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: context.colors.textPrimary,
      ),
    );
  }
}
