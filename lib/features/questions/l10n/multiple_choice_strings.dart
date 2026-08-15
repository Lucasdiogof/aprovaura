import 'package:aura/core/l10n/app_language.dart';

class MultipleChoiceStrings {
  const MultipleChoiceStrings(this.language);

  final AppLanguage language;

  String questionProgress(int current, int total) => switch (language) {
    AppLanguage.portuguese => 'Pergunta $current de $total',
    AppLanguage.english => 'Question $current of $total',
  };

  String get nextButton => switch (language) {
    AppLanguage.portuguese => 'Próxima',
    AppLanguage.english => 'Next',
  };

  String get seeResultButton => switch (language) {
    AppLanguage.portuguese => 'Ver resultado',
    AppLanguage.english => 'See result',
  };

  String get finishedTitle => switch (language) {
    AppLanguage.portuguese => 'Você concluiu!',
    AppLanguage.english => 'You finished!',
  };

  String finishedScore(int correct, int total) => switch (language) {
    AppLanguage.portuguese => 'Você acertou $correct de $total.',
    AppLanguage.english => 'You got $correct out of $total right.',
  };

  String get retryButton => switch (language) {
    AppLanguage.portuguese => 'Tentar novamente',
    AppLanguage.english => 'Try again',
  };

  String get backButton => switch (language) {
    AppLanguage.portuguese => 'Voltar',
    AppLanguage.english => 'Back',
  };
}
