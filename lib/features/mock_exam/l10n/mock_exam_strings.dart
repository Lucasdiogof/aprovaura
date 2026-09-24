import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/shared/l10n/aura_strings.dart';
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

  String get finishedElsewhereMessage => switch (language) {
    AppLanguage.portuguese =>
      'Este simulado já foi entregue. Seu resultado está pronto.',
    AppLanguage.english =>
      'This mock exam was already handed in. Your result is ready.',
  };

  String get seeResultButton => switch (language) {
    AppLanguage.portuguese => 'Ver resultado',
    AppLanguage.english => 'See result',
  };

  String get abandonedElsewhereMessage => switch (language) {
    AppLanguage.portuguese =>
      'Este simulado foi abandonado e não pode mais ser respondido.',
    AppLanguage.english =>
      'This mock exam was abandoned and can no longer be answered.',
  };

  String get removedQuestionNotice => switch (language) {
    AppLanguage.portuguese =>
      'Uma questão foi retirada do banco e saiu deste simulado.',
    AppLanguage.english =>
      'A question was removed from the bank and left this mock exam.',
  };

  String get savingBeforeExit => switch (language) {
    AppLanguage.portuguese => 'Salvando suas respostas…',
    AppLanguage.english => 'Saving your answers…',
  };

  String get leaveWithoutWaitingButton => switch (language) {
    AppLanguage.portuguese => 'Sair sem esperar',
    AppLanguage.english => 'Leave without waiting',
  };

  String get unsavedTitle => switch (language) {
    AppLanguage.portuguese => 'Sua última resposta não foi salva',
    AppLanguage.english => "Your last answer wasn't saved",
  };

  String get unsavedDescription => switch (language) {
    AppLanguage.portuguese =>
      'Ela não chegou ao servidor. Você pode ficar e marcar de novo, ou sair '
          'assim mesmo -- as outras respostas estão salvas.',
    AppLanguage.english =>
      "It didn't reach the server. Stay and pick it again, or leave anyway "
          '-- your other answers are saved.',
  };

  String get stayButton => switch (language) {
    AppLanguage.portuguese => 'Ficar e marcar de novo',
    AppLanguage.english => 'Stay and pick again',
  };

  String get leaveAnywayButton => switch (language) {
    AppLanguage.portuguese => 'Sair assim mesmo',
    AppLanguage.english => 'Leave anyway',
  };

  String get sessionLoadError => switch (language) {
    AppLanguage.portuguese => 'Não foi possível carregar o simulado.',
    AppLanguage.english => "Couldn't load the mock exam.",
  };

  String get notFoundMessage => switch (language) {
    AppLanguage.portuguese => 'Este simulado não está mais disponível.',
    AppLanguage.english => 'This mock exam is no longer available.',
  };

  // --- Result ---------------------------------------------------------------

  String get resultPageTitle => switch (language) {
    AppLanguage.portuguese => 'Resultado do simulado',
    AppLanguage.english => 'Mock exam result',
  };

  /// "75,6%" / "75.6%", and "75%" when there is no decimal part. The value
  /// itself always comes from the server; this only formats it.
  String percent(double value) {
    final fixed = value.toStringAsFixed(1);
    final trimmed = fixed.endsWith('.0')
        ? fixed.substring(0, fixed.length - 2)
        : fixed;
    return switch (language) {
      AppLanguage.portuguese => '${trimmed.replaceAll('.', ',')}%',
      AppLanguage.english => '$trimmed%',
    };
  }

  String score(int correct, int total) => '$correct / $total';

  String get correctSuffix => switch (language) {
    AppLanguage.portuguese => 'corretas',
    AppLanguage.english => 'correct',
  };

  String get accuracyWord => switch (language) {
    AppLanguage.portuguese => 'aproveitamento',
    AppLanguage.english => 'accuracy',
  };

  String get tierReviewTitle => switch (language) {
    AppLanguage.portuguese => 'Vale revisar alguns pontos',
    AppLanguage.english => 'Worth reviewing a few topics',
  };

  String get tierReviewDescription => switch (language) {
    AppLanguage.portuguese =>
      'Seus erros já estão em Revisar erros — é um bom próximo passo.',
    AppLanguage.english =>
      'Your mistakes are already in Review mistakes — a good next step.',
  };

  String get tierAdvancingTitle => switch (language) {
    AppLanguage.portuguese => 'Você está avançando',
    AppLanguage.english => "You're making progress",
  };

  String get tierAdvancingDescription => switch (language) {
    AppLanguage.portuguese =>
      'Revisar os erros é o que mais faz essa nota subir.',
    AppLanguage.english =>
      'Reviewing your mistakes is what moves this score the most.',
  };

  String get tierGoodTitle => switch (language) {
    AppLanguage.portuguese => 'Bom desempenho',
    AppLanguage.english => 'Good performance',
  };

  String get tierGoodDescription => switch (language) {
    AppLanguage.portuguese =>
      'Poucos pontos separam você de um resultado excelente.',
    AppLanguage.english => "You're a few points away from an excellent result.",
  };

  String get tierExcellentTitle => switch (language) {
    AppLanguage.portuguese => 'Excelente resultado',
    AppLanguage.english => 'Excellent result',
  };

  String get tierExcellentDescription => switch (language) {
    AppLanguage.portuguese => 'Domínio consistente. Continue nesse ritmo.',
    AppLanguage.english => 'Consistent mastery. Keep this pace.',
  };

  String get statWrong => switch (language) {
    AppLanguage.portuguese => 'Erradas',
    AppLanguage.english => 'Wrong',
  };

  String get statBlank => switch (language) {
    AppLanguage.portuguese => 'Em branco',
    AppLanguage.english => 'Blank',
  };

  String get statAura => AuraStrings.unit;

  String resultMeta(int questions, int subjects) =>
      '${questionCount(questions)} · ${subjectCount(subjects)} · '
      '$examModeTitle';

  String get bySubjectTitle => switch (language) {
    AppLanguage.portuguese => 'Por matéria',
    AppLanguage.english => 'By subject',
  };

  String get byDifficultyTitle => switch (language) {
    AppLanguage.portuguese => 'Por dificuldade',
    AppLanguage.english => 'By difficulty',
  };

  String get reviewErrorsButton => switch (language) {
    AppLanguage.portuguese => 'Revisar erros',
    AppLanguage.english => 'Review mistakes',
  };

  String get anotherExamButton => switch (language) {
    AppLanguage.portuguese => 'Fazer outro simulado',
    AppLanguage.english => 'Take another mock exam',
  };

  String get backHomeButton => switch (language) {
    AppLanguage.portuguese => 'Voltar para o início',
    AppLanguage.english => 'Back to home',
  };

  String get resultLoadError => switch (language) {
    AppLanguage.portuguese => 'Não foi possível carregar o resultado.',
    AppLanguage.english => "Couldn't load the result.",
  };

  String get resultNotFound => switch (language) {
    AppLanguage.portuguese => 'Resultado não encontrado.',
    AppLanguage.english => 'Result not found.',
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
    MockExamFailureKind.itemRemoved => removedQuestionNotice,
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
