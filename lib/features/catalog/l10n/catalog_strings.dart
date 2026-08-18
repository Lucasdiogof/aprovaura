import 'package:aura/core/l10n/app_language.dart';

class CatalogStrings {
  const CatalogStrings(this.language);

  final AppLanguage language;

  String get comingSoonTitle => switch (language) {
    AppLanguage.portuguese => 'Em breve',
    AppLanguage.english => 'Coming soon',
  };

  String get comingSoonDescription => switch (language) {
    AppLanguage.portuguese =>
      'Esse conteúdo ainda está sendo construído. Volte mais tarde!',
    AppLanguage.english =>
      'This content is still being built. Check back soon!',
  };

  String get retryButton => switch (language) {
    AppLanguage.portuguese => 'Tentar novamente',
    AppLanguage.english => 'Try again',
  };

  String get difficultyAll => switch (language) {
    AppLanguage.portuguese => 'Todos',
    AppLanguage.english => 'All',
  };

  String get difficultyEmptyDescription => switch (language) {
    AppLanguage.portuguese =>
      'Nenhum tópico neste nível de dificuldade ainda. Tente outro nível.',
    AppLanguage.english =>
      'No topics at this difficulty level yet. Try another level.',
  };
}
