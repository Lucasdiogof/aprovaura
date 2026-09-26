import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/error_review/l10n/error_review_strings.dart';

/// Same sliding-pill shape as DifficultySelector, for a different axis:
/// which kind of attempt a pending error came from (null = every one,
/// 'practice', or 'mock_exam') -- mock-exam mistakes were showing up
/// mixed in with regular practice ones, with no way to tell them apart.
class ErrorSourceSelector extends StatelessWidget {
  const ErrorSourceSelector({
    required this.selected,
    required this.strings,
    required this.onChanged,
    super.key,
  });

  final String? selected;
  final ErrorReviewStrings strings;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <(String?, String)>[
      (null, strings.sourceAll),
      ('practice', strings.sourcePractice),
      ('mock_exam', strings.sourceMockExam),
    ];
    final selectedIndex = items.indexWhere((item) => item.$1 == selected);

    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment(
              -1 + selectedIndex * (2 / (items.length - 1)),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / items.length,
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final (index, item) in items.indexed)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(item.$1),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: index == selectedIndex
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: index == selectedIndex
                              ? context.colors.onPrimary
                              : context.colors.textSecondary,
                        ),
                        child: Text(item.$2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
