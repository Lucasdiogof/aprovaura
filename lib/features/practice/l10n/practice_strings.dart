import 'package:aura/core/l10n/app_language.dart';

class PracticeStrings {
  const PracticeStrings(this.language);

  final AppLanguage language;

  String get pageTitle => switch (language) {
    AppLanguage.portuguese => 'Praticar',
    AppLanguage.english => 'Practice',
  };

  String get pageSubtitle => switch (language) {
    AppLanguage.portuguese => 'O que você quer fazer?',
    AppLanguage.english => 'What do you want to do?',
  };
}
