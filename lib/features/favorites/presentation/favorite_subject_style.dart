import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

/// Icon, color and label for a catalog_nodes.subject key. Falls back to
/// the raw key and the app's primary color for a subject the client
/// doesn't know yet, instead of failing to render the row.
({IconData icon, Color color, String label}) favoriteSubjectStyle(
  String subjectKey,
  AppLanguage language, {
  required Color fallbackColor,
}) {
  final matches = Subject.values.where((s) => s.name == subjectKey);
  if (matches.isEmpty) {
    return (
      icon: Icons.bookmark_rounded,
      color: fallbackColor,
      label: subjectKey,
    );
  }
  final subject = matches.first;
  return (
    icon: subject.icon,
    color: subject.accentColor,
    label: subject.label(language),
  );
}
