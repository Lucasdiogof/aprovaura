import 'package:aura/core/l10n/app_language.dart';

class OnboardingStrings {
  const OnboardingStrings(this.language);

  final AppLanguage language;

  String get goalQuestion => switch (language) {
    AppLanguage.portuguese => 'Qual é o seu objetivo?',
    AppLanguage.english => 'What is your goal?',
    AppLanguage.spanish => '¿Cuál es tu objetivo?',
  };

  String get examYearQuestion => switch (language) {
    AppLanguage.portuguese => 'Quando você pretende fazer sua prova?',
    AppLanguage.english => 'When do you plan to take your exam?',
    AppLanguage.spanish => '¿Cuándo piensas presentar tu examen?',
  };

  String get subjectsQuestion => switch (language) {
    AppLanguage.portuguese => 'Quais matérias você mais quer estudar?',
    AppLanguage.english => 'Which subjects do you want to study most?',
    AppLanguage.spanish => '¿Qué materias quieres estudiar más?',
  };

  String get continueButton => switch (language) {
    AppLanguage.portuguese => 'Continuar',
    AppLanguage.english => 'Continue',
    AppLanguage.spanish => 'Continuar',
  };

  String get finishButton => switch (language) {
    AppLanguage.portuguese => 'Concluir',
    AppLanguage.english => 'Finish',
    AppLanguage.spanish => 'Finalizar',
  };

  String stepOf(int current, int total) => switch (language) {
    AppLanguage.portuguese => 'Etapa $current de $total',
    AppLanguage.english => 'Step $current of $total',
    AppLanguage.spanish => 'Paso $current de $total',
  };
}
