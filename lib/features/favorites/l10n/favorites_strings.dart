import 'package:aura/core/l10n/app_language.dart';

class FavoritesStrings {
  const FavoritesStrings(this.language);

  final AppLanguage language;

  String get pageTitle => switch (language) {
    AppLanguage.portuguese => 'Favoritos',
    AppLanguage.english => 'Favorites',
  };

  String favoritedQuestions(int count) => switch (language) {
    AppLanguage.portuguese =>
      count == 1 ? '1 questão favoritada' : '$count questões favoritadas',
    AppLanguage.english =>
      count == 1 ? '1 favorited question' : '$count favorited questions',
  };

  String get emptyTitle => switch (language) {
    AppLanguage.portuguese => 'Nenhum favorito ainda',
    AppLanguage.english => 'No favorites yet',
  };

  String get emptyDescription => switch (language) {
    AppLanguage.portuguese =>
      'Toque no marcador em uma questão para salvá-la aqui.',
    AppLanguage.english => 'Tap the bookmark on a question to save it here.',
  };

  String get retryButton => switch (language) {
    AppLanguage.portuguese => 'Tentar novamente',
    AppLanguage.english => 'Try again',
  };
}
