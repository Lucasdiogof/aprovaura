import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/features/subjects/presentation/widgets/subject_tile.dart';

/// Redação in the Practice grid. It reads as one more subject, but it is
/// deliberately NOT a [Subject]: it has no catalog_nodes, no questions and
/// no percentage, and adding it to that enum would have dragged it into the
/// mock exam setup and the interested-subjects screen, where it makes no
/// sense.
class EssaySubjectCard extends StatelessWidget {
  const EssaySubjectCard({
    required this.language,
    required this.onTap,
    super.key,
  });

  /// Not one of the subject accents: Redação is its own thing, and the
  /// brand violet says so without competing with a subject's identity.
  static const accentColor = Color(0xFF8B5CF6);

  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = EssayStrings(language);
    return SubjectTile(
      icon: Icons.edit_note_rounded,
      accentColor: accentColor,
      label: t.subjectLabel,
      description: t.subjectDescription,
      onTap: onTap,
    );
  }
}
