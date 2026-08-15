import 'package:aura/core/l10n/app_language.dart';

class MapQuizStrings {
  const MapQuizStrings(this.language);

  final AppLanguage language;

  String findPrompt(String regionName) => switch (language) {
    AppLanguage.portuguese => 'Encontre: $regionName',
    AppLanguage.english => 'Find: $regionName',
  };

  String get flagPrompt => switch (language) {
    AppLanguage.portuguese => 'De qual país é essa bandeira?',
    AppLanguage.english => 'Which country does this flag belong to?',
  };

  String progressLabel(int correct, int total) => switch (language) {
    AppLanguage.portuguese => '$correct de $total',
    AppLanguage.english => '$correct of $total',
  };

  String get finishedTitle => switch (language) {
    AppLanguage.portuguese => 'Você concluiu!',
    AppLanguage.english => 'You finished!',
  };

  String finishedScore(int correct, int total) => switch (language) {
    AppLanguage.portuguese => 'Você acertou $correct de $total.',
    AppLanguage.english => 'You got $correct out of $total right.',
  };

  String get retryButton => switch (language) {
    AppLanguage.portuguese => 'Tentar novamente',
    AppLanguage.english => 'Try again',
  };

  String get backButton => switch (language) {
    AppLanguage.portuguese => 'Voltar',
    AppLanguage.english => 'Back',
  };
}
