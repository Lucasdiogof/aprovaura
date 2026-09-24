import 'package:aura/core/l10n/app_language.dart';

class FavoritesStrings {
  const FavoritesStrings(this.language);

  final AppLanguage language;

  String get pageTitle => switch (language) {
    AppLanguage.portuguese => 'Favoritos',
    AppLanguage.english => 'Favorites',
    AppLanguage.spanish => 'Favoritos',
  };

  String favoritedQuestions(int count) => switch (language) {
    AppLanguage.portuguese =>
      count == 1 ? '1 questão favoritada' : '$count questões favoritadas',
    AppLanguage.english =>
      count == 1 ? '1 favorited question' : '$count favorited questions',
    AppLanguage.spanish =>
      count == 1
          ? '1 pregunta marcada como favorita'
          : '$count preguntas marcadas como favoritas',
  };

  String get emptyTitle => switch (language) {
    AppLanguage.portuguese => 'Nenhum favorito ainda',
    AppLanguage.english => 'No favorites yet',
    AppLanguage.spanish => 'Todavía no hay favoritos',
  };

  String get emptyDescription => switch (language) {
    AppLanguage.portuguese =>
      'Toque no marcador em uma questão para salvá-la aqui.',
    AppLanguage.english => 'Tap the bookmark on a question to save it here.',
    AppLanguage.spanish =>
      'Toca el marcador en una pregunta para guardarla aquí.',
  };

  String get sectionEmptyTitle => switch (language) {
    AppLanguage.portuguese => 'Nenhum favorito aqui',
    AppLanguage.english => 'No favorites here',
    AppLanguage.spanish => 'No hay favoritos aquí',
  };

  String get sectionEmptyDescription => switch (language) {
    AppLanguage.portuguese => 'Os favoritos desta seção foram removidos.',
    AppLanguage.english => 'The favorites in this section were removed.',
    AppLanguage.spanish => 'Los favoritos de esta sección fueron eliminados.',
  };

  String get practiceAllButton => switch (language) {
    AppLanguage.portuguese => 'Praticar todas',
    AppLanguage.english => 'Practice all',
    AppLanguage.spanish => 'Practicar todas',
  };

  String get statusUnanswered => switch (language) {
    AppLanguage.portuguese => 'Não respondida',
    AppLanguage.english => 'Not answered',
    AppLanguage.spanish => 'Sin responder',
  };

  String get statusCorrect => switch (language) {
    AppLanguage.portuguese => 'Acertou',
    AppLanguage.english => 'Correct',
    AppLanguage.spanish => 'Correcta',
  };

  String get statusNeedsReview => switch (language) {
    AppLanguage.portuguese => 'Precisa revisar',
    AppLanguage.english => 'Needs review',
    AppLanguage.spanish => 'Necesita repaso',
  };

  String get retryButton => switch (language) {
    AppLanguage.portuguese => 'Tentar novamente',
    AppLanguage.english => 'Try again',
    AppLanguage.spanish => 'Intentar de nuevo',
  };
}
