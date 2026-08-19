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
    AppLanguage.portuguese => 'Tudo certo por aqui!',
    AppLanguage.english => 'All clear!',
  };

  String get emptyDescription => switch (language) {
    AppLanguage.portuguese => 'Você não tem questões pendentes para revisar.',
    AppLanguage.english => 'You have no pending questions to review.',
  };

  String get retryButton => switch (language) {
    AppLanguage.portuguese => 'Tentar novamente',
    AppLanguage.english => 'Try again',
  };
}
