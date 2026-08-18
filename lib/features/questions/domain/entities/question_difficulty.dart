import 'package:aura/core/l10n/app_language.dart';

enum QuestionDifficulty {
  facil,
  medio,
  dificil;

  String get dbValue => name;

  static QuestionDifficulty fromDb(String? value) => switch (value) {
    'facil' => QuestionDifficulty.facil,
    'dificil' => QuestionDifficulty.dificil,
    _ => QuestionDifficulty.medio,
  };

  String label(AppLanguage language) => switch (this) {
    QuestionDifficulty.facil => switch (language) {
      AppLanguage.portuguese => 'Fácil',
      AppLanguage.english => 'Easy',
    },
    QuestionDifficulty.medio => switch (language) {
      AppLanguage.portuguese => 'Médio',
      AppLanguage.english => 'Medium',
    },
    QuestionDifficulty.dificil => switch (language) {
      AppLanguage.portuguese => 'Difícil',
      AppLanguage.english => 'Hard',
    },
  };
}
