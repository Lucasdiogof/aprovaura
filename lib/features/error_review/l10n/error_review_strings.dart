import 'package:aura/core/l10n/app_language.dart';

class ErrorReviewStrings {
  const ErrorReviewStrings(this.language);

  final AppLanguage language;

  String get pageTitle => switch (language) {
    AppLanguage.portuguese => 'Revisar erros',
    AppLanguage.english => 'Review mistakes',
  };

  String questionsToReview(int count) => switch (language) {
    AppLanguage.portuguese =>
      count == 1 ? '1 questão para revisar' : '$count questões para revisar',
    AppLanguage.english =>
      count == 1 ? '1 question to review' : '$count questions to review',
  };

  String get emptyTitle => switch (language) {
    AppLanguage.portuguese => 'Nenhum erro para revisar',
    AppLanguage.english => 'No mistakes to review',
  };

  String get emptyDescription => switch (language) {
    AppLanguage.portuguese =>
      'Quando você errar uma questão em alguma atividade, ela aparece aqui para você praticar de novo.',
    AppLanguage.english =>
      'When you get a question wrong in an activity, it shows up here so you can practice it again.',
  };

  String get retryButton => switch (language) {
    AppLanguage.portuguese => 'Tentar novamente',
    AppLanguage.english => 'Try again',
  };
}
