import 'package:aura/core/l10n/app_language.dart';

class CatalogStrings {
  const CatalogStrings(this.language);

  final AppLanguage language;

  String get comingSoonTitle => switch (language) {
    AppLanguage.portuguese => 'Em breve',
    AppLanguage.english => 'Coming soon',
    AppLanguage.spanish => 'Próximamente',
  };

  String get comingSoonDescription => switch (language) {
    AppLanguage.portuguese =>
      'Esse conteúdo ainda está sendo construído. Volte mais tarde!',
    AppLanguage.english =>
      'This content is still being built. Check back soon!',
    AppLanguage.spanish =>
      'Este contenido todavía está en construcción. ¡Vuelve más tarde!',
  };

  String get retryButton => switch (language) {
    AppLanguage.portuguese => 'Tentar novamente',
    AppLanguage.english => 'Try again',
    AppLanguage.spanish => 'Intentar de nuevo',
  };

  String get difficultyAll => switch (language) {
    AppLanguage.portuguese => 'Todos',
    AppLanguage.english => 'All',
    AppLanguage.spanish => 'Todos',
  };

  String get difficultyEmptyDescription => switch (language) {
    AppLanguage.portuguese =>
      'Nenhum tópico neste nível de dificuldade ainda. Tente outro nível.',
    AppLanguage.english =>
      'No topics at this difficulty level yet. Try another level.',
    AppLanguage.spanish =>
      'Todavía no hay temas en este nivel de dificultad. Prueba otro '
          'nivel.',
  };

  /// Replaces the progress bar once a topic's questions are all answered
  /// correctly -- a discreet done state instead of a "100%" bar.
  String get topicCompletedLabel => switch (language) {
    AppLanguage.portuguese => 'Concluído',
    AppLanguage.english => 'Completed',
    AppLanguage.spanish => 'Completado',
  };
}
