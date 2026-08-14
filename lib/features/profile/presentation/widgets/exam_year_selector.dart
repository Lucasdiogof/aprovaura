import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/profile/domain/exam_year_options.dart';
import 'package:aura/shared/widgets/selectable_option_tile.dart';

class ExamYearSelector extends StatelessWidget {
  const ExamYearSelector({
    required this.language,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final AppLanguage language;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in examYearOptions())
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SelectableOptionTile(
              title: examYearLabel(option, language),
              selected: selected == option,
              onTap: () => onSelect(option),
            ),
          ),
      ],
    );
  }
}
