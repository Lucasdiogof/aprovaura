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

  /// Placeholder for the editor, which lands in the next phase. Deliberately
  /// plain: an empty box that looked like an editor would invite writing
  /// that nothing can save yet.
  String get editorComingTitle => switch (language) {
    AppLanguage.portuguese => 'O editor chega na próxima etapa',
    AppLanguage.english => 'The editor arrives in the next step',
  };

  String get editorComingDescription => switch (language) {
    AppLanguage.portuguese =>
      'Por enquanto dá para ler a proposta e os textos motivadores. Escrever '
          'e enviar vem em seguida.',
    AppLanguage.english =>
      'For now you can read the prompt and the motivating texts. Writing and '
          'submitting come next.',
  };

  String get backButton => switch (language) {
    AppLanguage.portuguese => 'Voltar',
    AppLanguage.english => 'Back',
  };
}
