import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/profile/domain/entities/goal.dart';
import 'package:aura/shared/widgets/selectable_option_tile.dart';

class GoalSelector extends StatelessWidget {
  const GoalSelector({
    required this.language,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final AppLanguage language;
  final Goal? selected;
  final ValueChanged<Goal> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final goal in Goal.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SelectableOptionTile(
              title: goal.label(language),
              selected: selected == goal,
              onTap: () => onSelect(goal),
            ),
          ),
      ],
    );
  }
}
