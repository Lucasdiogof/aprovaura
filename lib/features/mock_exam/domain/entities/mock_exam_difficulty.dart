import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

/// Difficulty choice for one subject of a mock exam. The first three map
/// 1:1 to questions.difficulty; [misto] draws from that subject's whole
/// pool (fácil + médio + difícil), with no quota per level.
enum MockExamDifficulty {
  facil,
  medio,
  dificil,
  misto;

  /// Same strings create_mock_exam() / get_mock_exam_availability() use.
  String get dbValue => name;

  static MockExamDifficulty? fromDb(String? value) {
    for (final difficulty in values) {
      if (difficulty.dbValue == value) return difficulty;
    }
    return null;
  }

  String label(AppLanguage language) => switch (this) {
    MockExamDifficulty.facil => QuestionDifficulty.facil.label(language),
    MockExamDifficulty.medio => QuestionDifficulty.medio.label(language),
    MockExamDifficulty.dificil => QuestionDifficulty.dificil.label(language),
    MockExamDifficulty.misto => switch (language) {
      AppLanguage.portuguese => 'Misto',
      AppLanguage.english => 'Mixed',
      AppLanguage.spanish => 'Mixto',
    },
  };
}
