import 'package:aura/core/l10n/app_language.dart';

class MapQuizStrings {
  const MapQuizStrings(this.language);

  final AppLanguage language;

  String findPrompt(String regionName) => switch (language) {
    AppLanguage.portuguese => 'Encontre: $regionName',
    AppLanguage.english => 'Find: $regionName',
    AppLanguage.spanish => 'Encuentra: $regionName',
  };

  String get locateLabel => switch (language) {
    AppLanguage.portuguese => 'Localize no mapa',
    AppLanguage.english => 'Locate on the map',
    AppLanguage.spanish => 'Ubica en el mapa',
  };

  String get identifyFlagLabel => switch (language) {
    AppLanguage.portuguese => 'Identifique a bandeira',
    AppLanguage.english => 'Identify the flag',
    AppLanguage.spanish => 'Identifica la bandera',
  };

  String get flagPrompt => switch (language) {
    AppLanguage.portuguese => 'De qual país é essa bandeira?',
    AppLanguage.english => 'Which country does this flag belong to?',
    AppLanguage.spanish => '¿De qué país es esta bandera?',
  };

  String get revealedLabel => switch (language) {
    AppLanguage.portuguese => 'Era essa aqui',
    AppLanguage.english => 'It was this one',
    AppLanguage.spanish => 'Era esta',
  };

  String progressLabel(int correct, int total) => switch (language) {
    AppLanguage.portuguese => '$correct / $total',
    AppLanguage.english => '$correct / $total',
    AppLanguage.spanish => '$correct / $total',
  };

  String get finishedTitle => switch (language) {
    AppLanguage.portuguese => 'Você concluiu!',
    AppLanguage.english => 'You finished!',
    AppLanguage.spanish => '¡Terminaste!',
  };

  String finishedScore(int correct, int total) => switch (language) {
    AppLanguage.portuguese => 'Você acertou $correct de $total.',
    AppLanguage.english => 'You got $correct out of $total right.',
    AppLanguage.spanish => 'Acertaste $correct de $total.',
  };

  String get retryButton => switch (language) {
    AppLanguage.portuguese => 'Tentar novamente',
    AppLanguage.english => 'Try again',
    AppLanguage.spanish => 'Intentar de nuevo',
  };

  String get backButton => switch (language) {
    AppLanguage.portuguese => 'Voltar',
    AppLanguage.english => 'Back',
    AppLanguage.spanish => 'Volver',
  };
}
