import 'package:aura/core/l10n/app_language.dart';

class OnboardingStrings {
  const OnboardingStrings(this.language);

  final AppLanguage language;

  String get goalQuestion => switch (language) {
    AppLanguage.portuguese => 'Qual é o seu objetivo?',
    AppLanguage.english => 'What is your goal?',
  };

  String get examYearQuestion => switch (language) {
    AppLanguage.portuguese => 'Quando você pretende fazer sua prova?',
    AppLanguage.english => 'When do you plan to take your exam?',
  };

  String get subjectsQuestion => switch (language) {
    AppLanguage.portuguese => 'Quais matérias você mais quer estudar?',
    AppLanguage.english => 'Which subjects do you want to study most?',
  };

  String get continueButton => switch (language) {
    AppLanguage.portuguese => 'Continuar',
    AppLanguage.english => 'Continue',
  };

  String get finishButton => switch (language) {
    AppLanguage.portuguese => 'Concluir',
    AppLanguage.english => 'Finish',
  };

  String stepOf(int current, int total) => switch (language) {
    AppLanguage.portuguese => 'Etapa $current de $total',
    AppLanguage.english => 'Step $current of $total',
  };
}
