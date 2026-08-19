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

  String finishedTitle(double fraction) => switch (language) {
    AppLanguage.portuguese => switch (fraction) {
      >= 0.8 => 'Mandou bem!',
      >= 0.5 => 'Dá para melhorar!',
      _ => 'Vamos tentar de novo?',
    },
    AppLanguage.english => switch (fraction) {
      >= 0.8 => 'Nice work!',
      >= 0.5 => 'Room to improve!',
      _ => "Let's try again?",
    },
  };

  String finishedSubtitle(double fraction) => switch (language) {
    AppLanguage.portuguese => switch (fraction) {
      >= 0.8 => 'Você concluiu a atividade com sucesso.',
      >= 0.5 => 'Você está no caminho certo, continue praticando.',
      _ =>
        'Essa atividade pegou pesado. Que tal revisar o conteúdo e tentar de novo?',
    },
    AppLanguage.english => switch (fraction) {
      >= 0.8 => 'You completed the activity successfully.',
      >= 0.5 => "You're on the right track, keep practicing.",
      _ => 'That one was tough. Try reviewing the content and try again.',
    },
  };

  String get correctionTitle => switch (language) {
    AppLanguage.portuguese => 'Revisão concluída!',
    AppLanguage.english => 'Review complete!',
  };

  String correctionSubtitle(int totalCount) => switch (language) {
    AppLanguage.portuguese =>
      totalCount == 1
          ? 'Você revisou 1 questão que tinha errado antes.'
          : 'Você revisou $totalCount questões que tinha errado antes.',
    AppLanguage.english =>
      totalCount == 1
          ? 'You reviewed 1 question you had gotten wrong before.'
          : 'You reviewed $totalCount questions you had gotten wrong before.',
  };

  String get finishedCorrectLabel => switch (language) {
    AppLanguage.portuguese => 'corretas',
    AppLanguage.english => 'correct',
  };

  String get finishedScoreLabel => switch (language) {
    AppLanguage.portuguese => 'de aproveitamento',
    AppLanguage.english => 'score',
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
