import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';
import 'package:aura/features/subjects/presentation/widgets/subject_tile.dart';

class SubjectCard extends StatelessWidget {
  const SubjectCard({
    required this.subject,
    required this.language,
    required this.onTap,
    super.key,
  });

  final Subject subject;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SubjectTile(
      icon: subject.icon,
      accentColor: subject.accentColor,
      label: subject.label(language),
      description: subject.description(language),
      onTap: onTap,
    );
  }
}
