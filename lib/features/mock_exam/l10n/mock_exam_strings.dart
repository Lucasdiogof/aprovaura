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

  // --- Exam runner --------------------------------------------------------

  String get sessionTitle => switch (language) {
    AppLanguage.portuguese => 'Simulado',
    AppLanguage.english => 'Mock exam',
  };

  String answeredOfTotal(int answered, int total) => switch (language) {
    AppLanguage.portuguese => '$answered de $total respondidas',
    AppLanguage.english => '$answered of $total answered',
  };

  String get savingLabel => switch (language) {
    AppLanguage.portuguese => 'Salvando…',
    AppLanguage.english => 'Saving…',
  };

  String get saveErrorMessage => switch (language) {
    AppLanguage.portuguese =>
      'Não foi possível salvar sua resposta. Toque na alternativa de novo.',
    AppLanguage.english => "Couldn't save your answer. Tap the option again.",
  };

  String get previousButton => switch (language) {
    AppLanguage.portuguese => 'Anterior',
    AppLanguage.english => 'Previous',
  };

  String get nextButton => switch (language) {
    AppLanguage.portuguese => 'Próxima',
    AppLanguage.english => 'Next',
  };

  String get submitButton => switch (language) {
    AppLanguage.portuguese => 'Entregar simulado',
    AppLanguage.english => 'Hand in mock exam',
  };

  String get menuTooltip => switch (language) {
    AppLanguage.portuguese => 'Mais opções',
    AppLanguage.english => 'More options',
  };

  String get exitTitle => switch (language) {
    AppLanguage.portuguese => 'Sair do simulado?',
    AppLanguage.english => 'Leave the mock exam?',
  };

  String get exitDescription => switch (language) {
    AppLanguage.portuguese =>
      'Seu progresso está salvo e você poderá continuar depois.',
    AppLanguage.english =>
      'Your progress is saved and you can pick it up later.',
  };

  String get exitConfirmButton => switch (language) {
    AppLanguage.portuguese => 'Sair e continuar depois',
    AppLanguage.english => 'Leave and continue later',
  };

  String get abandonMenuItem => switch (language) {
    AppLanguage.portuguese => 'Abandonar simulado',
    AppLanguage.english => 'Abandon mock exam',
  };

  String get abandonTitle => switch (language) {
    AppLanguage.portuguese => 'Abandonar simulado?',
    AppLanguage.english => 'Abandon this mock exam?',
  };

  String get abandonDescription => switch (language) {
    AppLanguage.portuguese =>
      'Suas respostas desta tentativa não serão corrigidas e este simulado '
          'será encerrado.',
    AppLanguage.english =>
      "Your answers in this attempt won't be graded and this mock exam "
          'will be closed.',
  };

  String unansweredTitle(int count) => switch (language) {
    AppLanguage.portuguese =>
      count == 1
          ? 'Você deixou 1 questão sem resposta.'
          : 'Você deixou $count questões sem resposta.',
    AppLanguage.english =>
      count == 1
          ? 'You left 1 question unanswered.'
          : 'You left $count questions unanswered.',
  };

  String get unansweredDescription => switch (language) {
    AppLanguage.portuguese =>
      'Questões em branco contam como erradas e não entram em Revisar erros.',
    AppLanguage.english =>
      "Blank questions count as wrong and don't go to Review mistakes.",
  };

  String get reviewButton => switch (language) {
    AppLanguage.portuguese => 'Voltar e revisar',
    AppLanguage.english => 'Go back and review',
  };

  String get submitAnywayButton => switch (language) {
    AppLanguage.portuguese => 'Entregar assim mesmo',
    AppLanguage.english => 'Hand in anyway',
  };

  String get submitTitle => switch (language) {
    AppLanguage.portuguese => 'Entregar simulado?',
    AppLanguage.english => 'Hand in the mock exam?',
  };

  String get submitDescription => switch (language) {
    AppLanguage.portuguese =>
      'Depois de entregar, não dá mais para trocar as respostas.',
    AppLanguage.english => "Once handed in, answers can't be changed.",
  };

  String get sessionLoadError => switch (language) {
    AppLanguage.portuguese => 'Não foi possível carregar o simulado.',
    AppLanguage.english => "Couldn't load the mock exam.",
  };

  String get notInProgressMessage => switch (language) {
    AppLanguage.portuguese => 'Este simulado não está mais em andamento.',
    AppLanguage.english => 'This mock exam is no longer in progress.',
  };

  String get backButton => switch (language) {
    AppLanguage.portuguese => 'Voltar',
    AppLanguage.english => 'Back',
  };

  // --- Result (technical placeholder until FASE 6) --------------------------

  String get resultTitle => switch (language) {
    AppLanguage.portuguese => 'Simulado entregue',
    AppLanguage.english => 'Mock exam handed in',
  };

  String resultScore(int correct, int total) => switch (language) {
    AppLanguage.portuguese => 'Você acertou $correct de $total questões.',
    AppLanguage.english => 'You got $correct of $total questions right.',
  };

  String resultBlank(int count) => switch (language) {
    AppLanguage.portuguese =>
      count == 1 ? '1 ficou em branco.' : '$count ficaram em branco.',
    AppLanguage.english =>
      count == 1 ? '1 was left blank.' : '$count were left blank.',
  };

  String get resultPlaceholderNote => switch (language) {
    AppLanguage.portuguese =>
      'O resultado detalhado por matéria chega na próxima etapa.',
    AppLanguage.english => 'The per-subject breakdown comes in the next step.',
  };

  String get backHomeButton => switch (language) {
    AppLanguage.portuguese => 'Voltar ao início',
    AppLanguage.english => 'Back to home',
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
