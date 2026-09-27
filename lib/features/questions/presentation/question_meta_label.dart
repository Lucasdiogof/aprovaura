import 'package:flutter/painting.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/subjects/presentation/subject_style.dart';

/// "Geografia · Difícil" for a question that knows its subject, null
/// otherwise. A deck that mixes subjects (quick practice) has no breadcrumb
/// of its own, so each question says where it's from -- the same line a
/// mock exam shows.
String? questionMetaLabel(Question question, AppLanguage language) {
  final subjectKey = question.subject;
  if (subjectKey == null) return null;
  final subject = subjectStyle(
    subjectKey,
    language,
    fallbackColor: const Color(0x00000000),
  ).label;
  return '$subject · ${question.difficulty.label(language)}';
}
