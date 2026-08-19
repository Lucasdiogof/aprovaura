import 'package:aura/core/l10n/app_language.dart';

class MultipleChoiceStrings {
  const MultipleChoiceStrings(this.language);

  final AppLanguage language;

  String questionProgress(int current, int total) => switch (language) {
    AppLanguage.portuguese => 'Questão $current de $total',
    AppLanguage.english => 'Question $current of $total',
  };

  String get correctFeedbackTitle => switch (language) {
    AppLanguage.portuguese => 'Muito bem!',
    AppLanguage.english => 'Well done!',
  };

  String get incorrectFeedbackTitle => switch (language) {
    AppLanguage.portuguese => 'Não foi dessa vez',
    AppLanguage.english => 'Not quite',
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
    AppLanguage.portuguese => 'Mandou bem!',
    AppLanguage.english => 'Nice work!',
  };

  String get finishedSubtitle => switch (language) {
    AppLanguage.portuguese => 'Você concluiu a atividade com sucesso.',
    AppLanguage.english => 'You completed the activity successfully.',
  };

  String get finishedCorrectLabel => switch (language) {
    AppLanguage.portuguese => 'corretas',
    AppLanguage.english => 'correct',
  };

  String get finishedScoreLabel => switch (language) {
    AppLanguage.portuguese => 'de aproveitamento',
    AppLanguage.english => 'score',
  };

  String get finishedStreakLabel => switch (language) {
    AppLanguage.portuguese => 'Ofensiva',
    AppLanguage.english => 'Streak',
  };

  String get continueButton => switch (language) {
    AppLanguage.portuguese => 'Continuar',
    AppLanguage.english => 'Continue',
  };

  String get finishedRetryButton => switch (language) {
    AppLanguage.portuguese => 'Refazer atividade',
    AppLanguage.english => 'Redo activity',
  };

  String get backToTrailButton => switch (language) {
    AppLanguage.portuguese => 'Voltar para trilha',
    AppLanguage.english => 'Back to path',
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
