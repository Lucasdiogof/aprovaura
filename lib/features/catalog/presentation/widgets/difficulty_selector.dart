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
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (value, label) = items[index];
          final isActive = value == selected;
          return GestureDetector(
            onTap: () => onChanged(value),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isActive ? accentColor : context.colors.surface,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: isActive ? accentColor : context.colors.border,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? context.colors.onPrimary
                      : context.colors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
