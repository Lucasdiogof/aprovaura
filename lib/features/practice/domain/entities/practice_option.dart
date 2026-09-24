import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/mock_exam/l10n/mock_exam_strings.dart';

enum PracticeOption {
  quickPractice,
  reviewMistakes,
  favorites,
  mockExam;

  IconData get icon => switch (this) {
    PracticeOption.quickPractice => Icons.bolt_outlined,
    PracticeOption.reviewMistakes => Icons.refresh_outlined,
    PracticeOption.favorites => Icons.bookmark_outline,
    PracticeOption.mockExam => Icons.assignment_outlined,
  };

  String title(AppLanguage language) => switch (this) {
    PracticeOption.quickPractice => switch (language) {
      AppLanguage.portuguese => 'Prática rápida',
      AppLanguage.english => 'Quick practice',
    },
    PracticeOption.reviewMistakes => switch (language) {
      AppLanguage.portuguese => 'Revisar erros',
      AppLanguage.english => 'Review mistakes',
    },
    PracticeOption.favorites => switch (language) {
      AppLanguage.portuguese => 'Favoritos',
      AppLanguage.english => 'Favorites',
    },
    PracticeOption.mockExam => MockExamStrings(language).homeTitle,
  };

  String description(AppLanguage language) => switch (this) {
    PracticeOption.quickPractice => switch (language) {
      AppLanguage.portuguese =>
        'Questões variadas para estudar por alguns minutos.',
      AppLanguage.english => 'Mixed questions to study for a few minutes.',
    },
    PracticeOption.reviewMistakes => switch (language) {
      AppLanguage.portuguese => 'Pratique novamente questões que você errou.',
      AppLanguage.english => 'Practice questions you got wrong again.',
    },
    PracticeOption.favorites => switch (language) {
      AppLanguage.portuguese =>
        'Revise conteúdos e atividades que você salvou.',
      AppLanguage.english => 'Review content and activities you saved.',
    },
    PracticeOption.mockExam => MockExamStrings(language).homeDescription,
  };
}
