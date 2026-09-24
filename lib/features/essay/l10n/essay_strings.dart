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
}
