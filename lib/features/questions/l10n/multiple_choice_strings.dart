import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/questions/presentation/quiz_result_tier.dart';

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

  // Four tiers, not just "did well or not": a genuine 0% needs a neutral,
  // non-celebratory tone that a middling 40% doesn't.
  String finishedTitle(QuizResultTier tier) => switch (language) {
    AppLanguage.portuguese => switch (tier) {
      QuizResultTier.zero => 'Vamos tentar de novo?',
      QuizResultTier.developing => 'Continue praticando',
      QuizResultTier.good => 'Mandou bem!',
      QuizResultTier.excellent => 'Perfeito!',
    },
    AppLanguage.english => switch (tier) {
      QuizResultTier.zero => "Let's try again?",
      QuizResultTier.developing => 'Keep practicing',
      QuizResultTier.good => 'Nice work!',
      QuizResultTier.excellent => 'Perfect!',
    },
  };

  String finishedSubtitle(QuizResultTier tier) => switch (language) {
    AppLanguage.portuguese => switch (tier) {
      QuizResultTier.zero =>
        'Essa atividade pegou pesado. Revise o conteúdo e tente novamente.',
      QuizResultTier.developing =>
        'Você acertou algumas questões. Continue praticando para evoluir.',
      QuizResultTier.good => 'Você está no caminho certo, continue assim.',
      QuizResultTier.excellent =>
        'Você acertou tudo! Atividade concluída com excelência.',
    },
    AppLanguage.english => switch (tier) {
      QuizResultTier.zero =>
        'That one was tough. Review the content and try again.',
      QuizResultTier.developing =>
        'You got some of them right. Keep practicing to improve.',
      QuizResultTier.good => "You're on the right track, keep it up.",
      QuizResultTier.excellent =>
        'You got everything right! Completed with excellence.',
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

  String get retryButton => switch (language) {
    AppLanguage.portuguese => 'Tentar novamente',
    AppLanguage.english => 'Try again',
  };

  String get backButton => switch (language) {
    AppLanguage.portuguese => 'Voltar',
    AppLanguage.english => 'Back',
  };

  String get reportQuestionTitle => switch (language) {
    AppLanguage.portuguese => 'Reportar esta questão?',
    AppLanguage.english => 'Report this question?',
  };

  String get reportQuestionDescription => switch (language) {
    AppLanguage.portuguese =>
      'Avise que algo parece errado ou confuso aqui. Vamos revisar.',
    AppLanguage.english =>
      'Let us know something looks wrong or confusing here. We\'ll take a look.',
  };

  String get reportQuestionConfirm => switch (language) {
    AppLanguage.portuguese => 'Reportar',
    AppLanguage.english => 'Report',
  };

  String get reportQuestionCancel => switch (language) {
    AppLanguage.portuguese => 'Cancelar',
    AppLanguage.english => 'Cancel',
  };

  String get reportQuestionThanks => switch (language) {
    AppLanguage.portuguese => 'Obrigado! Vamos revisar essa questão.',
    AppLanguage.english => "Thanks! We'll take a look at this question.",
  };

  String get reportQuestionFailed => switch (language) {
    AppLanguage.portuguese => 'Não deu para enviar o report agora.',
    AppLanguage.english => "Couldn't send the report right now.",
  };
}
