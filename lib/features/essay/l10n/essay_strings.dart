import 'package:aura/core/l10n/app_language.dart';

class EssayStrings {
  const EssayStrings(this.language);

  final AppLanguage language;

  String get subjectLabel => switch (language) {
    AppLanguage.portuguese => 'Redação',
    AppLanguage.english => 'Essay',
  };

  /// On the Practice grid, under the title.
  String get subjectDescription => switch (language) {
    AppLanguage.portuguese => 'Escreva e receba uma correção.',
    AppLanguage.english => 'Write one and get it marked.',
  };

  String get themesSubtitle => switch (language) {
    AppLanguage.portuguese => 'Escolha um tema e pratique sua escrita.',
    AppLanguage.english => 'Pick a theme and practise your writing.',
  };

  /// Practice themes are ours and say so. The middle dot keeps the brand
  /// and the qualifier in one badge without pretending to be an exam.
  String get practiceBadge => switch (language) {
    AppLanguage.portuguese => 'Aura · Tema de treino',
    AppLanguage.english => 'Aura · Practice theme',
  };

  String get officialBadge => switch (language) {
    AppLanguage.portuguese => 'Oficial',
    AppLanguage.english => 'Official',
  };

  String get draftBadge => switch (language) {
    AppLanguage.portuguese => 'Rascunho',
    AppLanguage.english => 'Draft',
  };

  /// Shown while the server is still marking an attempt.
  String get evaluatingBadge => switch (language) {
    AppLanguage.portuguese => 'Corrigindo',
    AppLanguage.english => 'Marking',
  };

  String get startButton => switch (language) {
    AppLanguage.portuguese => 'Começar redação',
    AppLanguage.english => 'Start writing',
  };

  String get continueButton => switch (language) {
    AppLanguage.portuguese => 'Continuar redação',
    AppLanguage.english => 'Continue writing',
  };

  String get newAttemptButton => switch (language) {
    AppLanguage.portuguese => 'Fazer nova redação',
    AppLanguage.english => 'Write a new one',
  };

  String get proposalHeading => switch (language) {
    AppLanguage.portuguese => 'Proposta de redação',
    AppLanguage.english => 'Writing prompt',
  };

  String get supportingTextsHeading => switch (language) {
    AppLanguage.portuguese => 'Textos motivadores',
    AppLanguage.english => 'Motivating texts',
  };

  String get lastScoreLabel => switch (language) {
    AppLanguage.portuguese => 'Última nota',
    AppLanguage.english => 'Last score',
  };

  String get attemptsLabel => switch (language) {
    AppLanguage.portuguese => 'Tentativas',
    AppLanguage.english => 'Attempts',
  };

  String get emptyTitle => switch (language) {
    AppLanguage.portuguese => 'Nenhum tema disponível no momento.',
    AppLanguage.english => 'No themes available right now.',
  };

  String get errorMessage => switch (language) {
    AppLanguage.portuguese =>
      'Não conseguimos carregar os temas agora. Verifique sua conexão e '
          'tente de novo.',
    AppLanguage.english =>
      "We couldn't load the themes right now. Check your connection and "
          'try again.',
  };

  String get themeErrorMessage => switch (language) {
    AppLanguage.portuguese =>
      'Não conseguimos carregar este tema agora. Tente de novo.',
    AppLanguage.english => "We couldn't load this theme right now. Try again.",
  };

  String get retryButton => switch (language) {
    AppLanguage.portuguese => 'Tentar novamente',
    AppLanguage.english => 'Try again',
  };

  String get backButton => switch (language) {
    AppLanguage.portuguese => 'Voltar',
    AppLanguage.english => 'Back',
  };

  String get editorHint => switch (language) {
    AppLanguage.portuguese => 'Comece a escrever sua redação...',
    AppLanguage.english => 'Start writing your essay...',
  };

  String wordCount(int count) => switch (language) {
    AppLanguage.portuguese => '$count ${count == 1 ? 'palavra' : 'palavras'}',
    AppLanguage.english => '$count ${count == 1 ? 'word' : 'words'}',
  };

  String get savingStatus => switch (language) {
    AppLanguage.portuguese => 'Salvando...',
    AppLanguage.english => 'Saving...',
  };

  String get savedStatus => switch (language) {
    AppLanguage.portuguese => 'Salvo',
    AppLanguage.english => 'Saved',
  };

  String get saveFailedStatus => switch (language) {
    AppLanguage.portuguese => 'Não foi possível salvar',
    AppLanguage.english => "Couldn't save",
  };

  String get retrySaveAction => switch (language) {
    AppLanguage.portuguese => 'Tentar de novo',
    AppLanguage.english => 'Try again',
  };

  String get saveDraftAction => switch (language) {
    AppLanguage.portuguese => 'Salvar rascunho',
    AppLanguage.english => 'Save draft',
  };

  String get draftSavedFeedback => switch (language) {
    AppLanguage.portuguese => 'Rascunho salvo.',
    AppLanguage.english => 'Draft saved.',
  };

  String get deleteDraftAction => switch (language) {
    AppLanguage.portuguese => 'Apagar rascunho',
    AppLanguage.english => 'Delete draft',
  };

  String get deleteDraftTitle => switch (language) {
    AppLanguage.portuguese => 'Apagar rascunho?',
    AppLanguage.english => 'Delete draft?',
  };

  String get deleteDraftDescription => switch (language) {
    AppLanguage.portuguese =>
      'Todo o texto desta redação será apagado. Esta ação não pode ser '
          'desfeita.',
    AppLanguage.english =>
      'All the text of this essay will be deleted. This cannot be undone.',
  };

  String get deleteDraftFailed => switch (language) {
    AppLanguage.portuguese =>
      'Não conseguimos apagar seu rascunho. Seu texto continua aqui.',
    AppLanguage.english =>
      "We couldn't delete your draft. Your text is still here.",
  };

  String get cancelAction => switch (language) {
    AppLanguage.portuguese => 'Cancelar',
    AppLanguage.english => 'Cancel',
  };

  String get unsavedTitle => switch (language) {
    AppLanguage.portuguese => 'Não foi possível salvar sua redação',
    AppLanguage.english => "We couldn't save your essay",
  };

  String get unsavedDescription => switch (language) {
    AppLanguage.portuguese => 'Seu texto ainda não foi salvo.',
    AppLanguage.english => 'Your text has not been saved yet.',
  };

  String get trySavingAgain => switch (language) {
    AppLanguage.portuguese => 'Tentar salvar novamente',
    AppLanguage.english => 'Try saving again',
  };

  String get leaveAnyway => switch (language) {
    AppLanguage.portuguese => 'Sair mesmo assim',
    AppLanguage.english => 'Leave anyway',
  };

  String get viewPromptAction => switch (language) {
    AppLanguage.portuguese => 'Ver proposta',
    AppLanguage.english => 'View prompt',
  };

  String get editorLoadFailed => switch (language) {
    AppLanguage.portuguese =>
      'Não conseguimos abrir sua redação agora. Tente de novo.',
    AppLanguage.english => "We couldn't open your essay now. Try again.",
  };

  String get submitAction => switch (language) {
    AppLanguage.portuguese => 'Enviar para correção',
    AppLanguage.english => 'Send for marking',
  };

  String get submitConfirmTitle => switch (language) {
    AppLanguage.portuguese => 'Enviar redação para correção?',
    AppLanguage.english => 'Send this essay for marking?',
  };

  String get submitConfirmDescription => switch (language) {
    AppLanguage.portuguese =>
      'Depois de enviada, esta versão da redação não poderá mais ser '
          'alterada. Você pode escrever uma nova tentativa depois.',
    AppLanguage.english =>
      'Once sent, this version cannot be changed. You can write another '
          'attempt later.',
  };

  String get submitConfirmAction => switch (language) {
    AppLanguage.portuguese => 'Enviar redação',
    AppLanguage.english => 'Send essay',
  };

  String get submitReviewAction => switch (language) {
    AppLanguage.portuguese => 'Voltar e revisar',
    AppLanguage.english => 'Back to review',
  };

  String get submitFailed => switch (language) {
    AppLanguage.portuguese =>
      'Não conseguimos enviar sua redação. Seu texto continua salvo aqui.',
    AppLanguage.english =>
      "We couldn't send your essay. Your text is still saved here.",
  };

  String get submitSaveFailed => switch (language) {
    AppLanguage.portuguese =>
      'Não conseguimos salvar a última versão do seu texto, então não '
          'enviamos nada. Tente de novo.',
    AppLanguage.english =>
      "We couldn't save your latest text, so nothing was sent. Try again.",
  };

  String get submittedTitle => switch (language) {
    AppLanguage.portuguese => 'Redação enviada',
    AppLanguage.english => 'Essay sent',
  };

  /// Status of an attempt nobody has started marking yet. Deliberately not
  /// "corrigindo": no evaluation has begun.
  String get statusSubmitted => switch (language) {
    AppLanguage.portuguese => 'Aguardando correção',
    AppLanguage.english => 'Waiting for marking',
  };

  String get statusEvaluating => switch (language) {
    AppLanguage.portuguese => 'Corrigindo',
    AppLanguage.english => 'Marking',
  };

  String get statusEvaluated => switch (language) {
    AppLanguage.portuguese => 'Corrigida',
    AppLanguage.english => 'Marked',
  };

  String get statusFailed => switch (language) {
    AppLanguage.portuguese => 'Não foi possível concluir a correção.',
    AppLanguage.english => "We couldn't finish the marking.",
  };

  /// Short form of the failed status, for the theme card.
  String get statusFailedShort => switch (language) {
    AppLanguage.portuguese => 'Correção pendente',
    AppLanguage.english => 'Marking pending',
  };

  String get statusSubmittedShort => switch (language) {
    AppLanguage.portuguese => 'Enviada',
    AppLanguage.english => 'Sent',
  };

  String get attemptsHeading => switch (language) {
    AppLanguage.portuguese => 'Tentativas',
    AppLanguage.english => 'Attempts',
  };

  String scorePoints(int score) => switch (language) {
    AppLanguage.portuguese => '$score pontos',
    AppLanguage.english => '$score points',
  };

  String get submittedTextHeading => switch (language) {
    AppLanguage.portuguese => 'Texto enviado',
    AppLanguage.english => 'Text sent',
  };

  String get scoreLabel => switch (language) {
    AppLanguage.portuguese => 'Nota',
    AppLanguage.english => 'Score',
  };

  String get continueNewAttemptButton => switch (language) {
    AppLanguage.portuguese => 'Continuar nova redação',
    AppLanguage.english => 'Continue the new one',
  };

  String get submissionLoadFailed => switch (language) {
    AppLanguage.portuguese =>
      'Não conseguimos abrir esta tentativa agora. Tente de novo.',
    AppLanguage.english => "We couldn't open this attempt now. Try again.",
  };

  String get evaluatingHint => switch (language) {
    AppLanguage.portuguese =>
      'Estamos corrigindo sua redação. Pode sair do app: quando voltar, o '
          'resultado estará aqui.',
    AppLanguage.english =>
      "We're marking your essay. You can leave the app -- the result will "
          'be here when you come back.',
  };

  String get stillEvaluatingHint => switch (language) {
    AppLanguage.portuguese =>
      'A correção está demorando mais que o normal. Volte daqui a pouco '
          'para ver o resultado.',
    AppLanguage.english =>
      'The marking is taking longer than usual. Come back in a bit to see '
          'the result.',
  };

  String get retryEvaluationAction => switch (language) {
    AppLanguage.portuguese => 'Tentar corrigir de novo',
    AppLanguage.english => 'Try marking again',
  };

  String get evaluationDailyLimit => switch (language) {
    AppLanguage.portuguese =>
      'Você atingiu o limite de correções de hoje. Tente novamente amanhã.',
    AppLanguage.english =>
      "You've reached today's marking limit. Try again tomorrow.",
  };

  String get evaluationUnavailable => switch (language) {
    AppLanguage.portuguese =>
      'A correção está indisponível no momento. Seu texto está salvo — '
          'tente de novo daqui a pouco.',
    AppLanguage.english =>
      'Marking is unavailable right now. Your text is saved -- try again '
          'in a little while.',
  };

  String get evaluationInvalidOutput => switch (language) {
    AppLanguage.portuguese =>
      'Não conseguimos concluir esta correção. Você pode tentar de novo.',
    AppLanguage.english =>
      "We couldn't finish this marking. You can try again.",
  };

  String get evaluationNotConfigured => switch (language) {
    AppLanguage.portuguese =>
      'A correção automática ainda não está disponível. Seu texto está '
          'salvo.',
    AppLanguage.english =>
      'Automatic marking is not available yet. Your text is saved.',
  };
}
