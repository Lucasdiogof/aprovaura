import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/catalog/l10n/catalog_strings.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

class DifficultySelector extends StatelessWidget {
  const DifficultySelector({
    required this.selected,
    required this.accentColor,
    required this.onChanged,
    super.key,
  });

  final QuestionDifficulty? selected;
  final Color accentColor;
  final ValueChanged<QuestionDifficulty?> onChanged;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = CatalogStrings(language);
    final items = <(QuestionDifficulty?, String)>[
      (null, t.difficultyAll),
      (QuestionDifficulty.facil, QuestionDifficulty.facil.label(language)),
      (QuestionDifficulty.medio, QuestionDifficulty.medio.label(language)),
      (QuestionDifficulty.dificil, QuestionDifficulty.dificil.label(language)),
    ];
    final selectedIndex = items.indexWhere((item) => item.$1 == selected);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.colors.secondary,
          borderRadius: BorderRadius.circular(22),
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
                    color: accentColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
      ),
    );
  }
}
