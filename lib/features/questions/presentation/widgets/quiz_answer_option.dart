import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

enum QuizOptionStatus {
  neutral,
  correct,
  incorrect,

  /// Chosen but not graded -- exam mode. Highlighted in the brand color
  /// only, never green/red and never with a check/cross icon, so it says
  /// "this is your answer" and nothing about whether it's right.
  selected,
}

class QuizAnswerOption extends StatelessWidget {
  const QuizAnswerOption({
    required this.letter,
    required this.text,
    required this.status,
    required this.onTap,
    super.key,
  });

  final String letter;
  final String text;
  final QuizOptionStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = switch (status) {
      QuizOptionStatus.correct => colors.success,
      QuizOptionStatus.incorrect => colors.error,
      QuizOptionStatus.neutral || QuizOptionStatus.selected => colors.primary,
    };
    final borderColor = status == QuizOptionStatus.neutral
        ? colors.border
        : accent;
    final backgroundColor = status == QuizOptionStatus.neutral
        ? colors.surface
        : accent.withValues(alpha: 0.08);

    return Semantics(
      selected: status == QuizOptionStatus.selected,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: status == QuizOptionStatus.neutral ? 1 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _LetterBadge(
                  letter: letter,
                  color: accent,
                  filled: status == QuizOptionStatus.neutral,
                  solid: status == QuizOptionStatus.selected,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                if (status == QuizOptionStatus.correct)
                  Icon(Icons.check_circle, color: colors.success, size: 26)
                else if (status == QuizOptionStatus.incorrect)
                  Icon(Icons.cancel, color: colors.error, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LetterBadge extends StatelessWidget {
  const _LetterBadge({
    required this.letter,
    required this.color,
    required this.filled,
    this.solid = false,
  });

  final String letter;
  final Color color;
  final bool filled;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: solid
            ? color
            : filled
            ? color.withValues(alpha: 0.12)
            : Colors.transparent,
        border: filled || solid ? null : Border.all(color: color, width: 1.5),
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: solid ? context.colors.onPrimary : color,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}
