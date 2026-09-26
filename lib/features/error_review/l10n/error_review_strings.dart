import 'package:aura/core/l10n/app_language.dart';

class ErrorReviewStrings {
  const ErrorReviewStrings(this.language);

  final AppLanguage language;

  String get pageTitle => switch (language) {
    AppLanguage.portuguese => 'Revisar erros',
    AppLanguage.english => 'Review mistakes',
    AppLanguage.spanish => 'Revisar errores',
  };

  String questionsToReview(int count) => switch (language) {
    AppLanguage.portuguese =>
      count == 1 ? '1 questão para revisar' : '$count questões para revisar',
    AppLanguage.english =>
      count == 1 ? '1 question to review' : '$count questions to review',
    AppLanguage.spanish =>
      count == 1 ? '1 pregunta para revisar' : '$count preguntas para revisar',
  };

  String get emptyTitle => switch (language) {
    AppLanguage.portuguese => 'Nenhum erro para revisar',
    AppLanguage.english => 'No mistakes to review',
    AppLanguage.spanish => 'No hay errores para revisar',
  };

  String get emptyDescription => switch (language) {
    AppLanguage.portuguese =>
      'Quando você errar uma questão em alguma atividade, ela aparece aqui para você praticar de novo.',
    AppLanguage.english =>
      'When you get a question wrong in an activity, it shows up here so you can practice it again.',
    AppLanguage.spanish =>
      'Cuando erras una pregunta en alguna actividad, aparece aquí para '
          'que la practiques de nuevo.',
  };

  String get retryButton => switch (language) {
    AppLanguage.portuguese => 'Tentar novamente',
    AppLanguage.english => 'Try again',
    AppLanguage.spanish => 'Intentar de nuevo',
  };

  String get sourceAll => switch (language) {
    AppLanguage.portuguese => 'Tudo',
    AppLanguage.english => 'All',
    AppLanguage.spanish => 'Todo',
  };

  String get sourcePractice => switch (language) {
    AppLanguage.portuguese => 'Prática',
    AppLanguage.english => 'Practice',
    AppLanguage.spanish => 'Práctica',
  };

  String get sourceMockExam => switch (language) {
    AppLanguage.portuguese => 'Simulados',
    AppLanguage.english => 'Mock exams',
    AppLanguage.spanish => 'Simulacros',
  };
}
