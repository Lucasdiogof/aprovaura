import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/shared/widgets/selectable_option_tile.dart';

class SubjectMultiSelector extends StatelessWidget {
  const SubjectMultiSelector({
    required this.language,
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final AppLanguage language;
  final Set<Subject> selected;
  final ValueChanged<Subject> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final subject in Subject.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SelectableOptionTile(
              title: subject.label(language),
              icon: subject.icon,
              selected: selected.contains(subject),
              multiSelect: true,
              onTap: () => onToggle(subject),
            ),
          ),
      ],
    );
  }
}
