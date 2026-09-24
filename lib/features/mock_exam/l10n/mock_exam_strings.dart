import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';

class MockExamStrings {
  const MockExamStrings(this.language);

  final AppLanguage language;

  // --- Home entry -----------------------------------------------------------

  String get homeTitle => switch (language) {
    AppLanguage.portuguese => 'Montar simulado',
    AppLanguage.english => 'Build a mock exam',
  };

  String get homeDescription => switch (language) {
    AppLanguage.portuguese =>
      'Escolha matérias, níveis e quantidade de questões.',
    AppLanguage.english => 'Pick subjects, levels and how many questions.',
  };

  String get continueTitle => switch (language) {
    AppLanguage.portuguese => 'Continuar simulado',
    AppLanguage.english => 'Continue mock exam',
  };

  String answeredProgress(int answered, int total) => switch (language) {
    AppLanguage.portuguese =>
      total == 1
          ? '$answered de 1 questão respondida'
          : '$answered de $total questões respondidas',
    AppLanguage.english =>
      total == 1
          ? '$answered of 1 question answered'
          : '$answered of $total questions answered',
  };

  String get buildAnotherButton => switch (language) {
    AppLanguage.portuguese => 'Montar outro',
    AppLanguage.english => 'Build another',
  };

  // --- Setup screen ---------------------------------------------------------

  String get setupTitle => homeTitle;

  String get setupDescription => switch (language) {
    AppLanguage.portuguese =>
      'Escolha as matérias, o nível e quantas questões deseja.',
    AppLanguage.english =>
      'Choose the subjects, the level and how many questions you want.',
  };

  String get difficultyLabel => switch (language) {
    AppLanguage.portuguese => 'Nível',
    AppLanguage.english => 'Level',
  };

  String get quantityLabel => switch (language) {
    AppLanguage.portuguese => 'Quantidade',
    AppLanguage.english => 'Questions',
  };

  String availableCount(int count) => switch (language) {
    AppLanguage.portuguese => 'Questões disponíveis: $count',
    AppLanguage.english => 'Available questions: $count',
  };

  String get decreaseTooltip => switch (language) {
    AppLanguage.portuguese => 'Menos questões',
    AppLanguage.english => 'Fewer questions',
  };

  String get increaseTooltip => switch (language) {
    AppLanguage.portuguese => 'Mais questões',
    AppLanguage.english => 'More questions',
  };

  String subjectCount(int count) => switch (language) {
    AppLanguage.portuguese => count == 1 ? '1 matéria' : '$count matérias',
    AppLanguage.english => count == 1 ? '1 subject' : '$count subjects',
  };

  String questionCount(int count) => switch (language) {
    AppLanguage.portuguese => count == 1 ? '1 questão' : '$count questões',
    AppLanguage.english => count == 1 ? '1 question' : '$count questions',
  };

  String summary(int subjects, int questions) =>
      '${subjectCount(subjects)} · ${questionCount(questions)}';

  String get emptySummary => switch (language) {
    AppLanguage.portuguese => 'Selecione ao menos uma matéria',
    AppLanguage.english => 'Select at least one subject',
  };

  String get globalLimitReached => switch (language) {
    AppLanguage.portuguese => 'Limite de 180 questões atingido',
    AppLanguage.english => '180-question limit reached',
  };

  String get startButton => switch (language) {
    AppLanguage.portuguese => 'Iniciar simulado',
    AppLanguage.english => 'Start mock exam',
  };

  String get loadErrorMessage => switch (language) {
    AppLanguage.portuguese =>
      'Não foi possível carregar as questões disponíveis.',
    AppLanguage.english => "Couldn't load the available questions.",
  };

  String get retryButton => switch (language) {
    AppLanguage.portuguese => 'Tentar novamente',
    AppLanguage.english => 'Try again',
  };

  // --- Confirmation sheet ---------------------------------------------------

  String get confirmTitle => switch (language) {
    AppLanguage.portuguese => 'Seu simulado',
    AppLanguage.english => 'Your mock exam',
  };

  String get totalLabel => switch (language) {
    AppLanguage.portuguese => 'Total',
    AppLanguage.english => 'Total',
  };

  String get examModeTitle => switch (language) {
    AppLanguage.portuguese => 'Modo prova',
    AppLanguage.english => 'Exam mode',
  };

  String get examModeDescription => switch (language) {
    AppLanguage.portuguese => 'O resultado será mostrado somente ao finalizar.',
    AppLanguage.english => 'Your result is only shown when you finish.',
  };

  String get confirmStartButton => switch (language) {
    AppLanguage.portuguese => 'Começar simulado',
    AppLanguage.english => 'Begin mock exam',
  };

  String get confirmBackButton => switch (language) {
    AppLanguage.portuguese => 'Voltar e editar',
    AppLanguage.english => 'Go back and edit',
  };

  // --- Active exam sheet ----------------------------------------------------

  String get activeTitle => switch (language) {
    AppLanguage.portuguese => 'Você já tem um simulado em andamento',
    AppLanguage.english => 'You already have a mock exam in progress',
  };

  String get activeFallbackDescription => switch (language) {
    AppLanguage.portuguese =>
      'Continue de onde parou ou descarte para montar outro.',
    AppLanguage.english => 'Pick up where you left off or discard it.',
  };

  String get activeContinueButton => continueTitle;

  String get activeDiscardButton => switch (language) {
    AppLanguage.portuguese => 'Descartar e montar outro',
    AppLanguage.english => 'Discard and build another',
  };

  String get cancelButton => switch (language) {
    AppLanguage.portuguese => 'Cancelar',
    AppLanguage.english => 'Cancel',
  };

  String get discardedMessage => switch (language) {
    AppLanguage.portuguese => 'Simulado descartado. Já pode montar outro.',
    AppLanguage.english => 'Mock exam discarded. You can build another now.',
  };

  // --- Placeholder until the exam runner exists (FASE 4/5) ------------------

  String get sessionTitle => switch (language) {
    AppLanguage.portuguese => 'Simulado',
    AppLanguage.english => 'Mock exam',
  };

  String get sessionPlaceholderTitle => switch (language) {
    AppLanguage.portuguese => 'Simulado salvo',
    AppLanguage.english => 'Mock exam saved',
  };

  String get sessionPlaceholderDescription => switch (language) {
    AppLanguage.portuguese =>
      'Suas questões já estão sorteadas e guardadas. A resolução da prova '
          'chega na próxima etapa.',
    AppLanguage.english =>
      'Your questions are drawn and saved. Taking the exam comes in the '
          'next step.',
  };

  // --- Errors ---------------------------------------------------------------

  /// Human sentence for a backend failure. [subjectLabel] and
  /// [difficultyLabel] are already localized by the caller (they need the
  /// Subject/Difficulty enums, which this class doesn't resolve).
  String failureMessage(
    MockExamFailure failure, {
    String? subjectLabel,
    String? difficultyLabel,
  }) => switch (failure.kind) {
    MockExamFailureKind.insufficientQuestions =>
      subjectLabel != null &&
              difficultyLabel != null &&
              failure.available != null
          ? switch (language) {
              AppLanguage.portuguese =>
                'As questões disponíveis mudaram: $subjectLabel · '
                    '$difficultyLabel agora tem ${failure.available}. '
                    'Ajustamos sua seleção — confira e tente de novo.',
              AppLanguage.english =>
                'Available questions changed: $subjectLabel · '
                    '$difficultyLabel now has ${failure.available}. We '
                    'adjusted your selection — check it and try again.',
            }
          : switch (language) {
              AppLanguage.portuguese =>
                'As questões disponíveis mudaram. Ajustamos sua seleção — '
                    'confira e tente de novo.',
              AppLanguage.english =>
                'Available questions changed. We adjusted your selection — '
                    'check it and try again.',
            },
    MockExamFailureKind.invalidConfig => switch (language) {
      AppLanguage.portuguese =>
        'Não foi possível montar esse simulado. Revise a seleção e tente '
            'de novo.',
      AppLanguage.english =>
        "Couldn't build this mock exam. Review your selection and try again.",
    },
    MockExamFailureKind.totalExceeded => switch (language) {
      AppLanguage.portuguese => 'Um simulado pode ter no máximo 180 questões.',
      AppLanguage.english => 'A mock exam can have at most 180 questions.',
    },
    MockExamFailureKind.alreadyActive => activeTitle,
    MockExamFailureKind.notInProgress => switch (language) {
      AppLanguage.portuguese => 'Esse simulado não está mais em andamento.',
      AppLanguage.english => 'That mock exam is no longer in progress.',
    },
    MockExamFailureKind.network => switch (language) {
      AppLanguage.portuguese =>
        'Sem conexão com o servidor. Verifique sua internet e tente de novo.',
      AppLanguage.english =>
        "Can't reach the server. Check your connection and try again.",
    },
    MockExamFailureKind.unexpected => switch (language) {
      AppLanguage.portuguese => 'Algo deu errado. Tente de novo.',
      AppLanguage.english => 'Something went wrong. Please try again.',
    },
  };
}
