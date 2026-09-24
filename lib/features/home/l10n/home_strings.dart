import 'package:aura/core/l10n/app_language.dart';

class HomeStrings {
  const HomeStrings(this.language);

  final AppLanguage language;

  String greeting(String name) => switch (language) {
    AppLanguage.portuguese => 'Olá, $name! 👋',
    AppLanguage.english => 'Hi, $name! 👋',
    AppLanguage.spanish => '¡Hola, $name! 👋',
  };

  String get homeSubtitle => switch (language) {
    AppLanguage.portuguese => 'O que vamos estudar hoje?',
    AppLanguage.english => 'What shall we study today?',
    AppLanguage.spanish => '¿Qué vamos a estudiar hoy?',
  };

  String streakDaysCount(int days) => switch (language) {
    AppLanguage.portuguese => '$days ${days == 1 ? 'dia' : 'dias'}',
    AppLanguage.english => '$days ${days == 1 ? 'day' : 'days'}',
    AppLanguage.spanish => '$days ${days == 1 ? 'día' : 'días'}',
  };

  String get streakSubtitle => switch (language) {
    AppLanguage.portuguese =>
      'Faça uma atividade hoje para manter sua sequência!',
    AppLanguage.english => 'Complete an activity today to keep your streak!',
    AppLanguage.spanish =>
      '¡Completa una actividad hoy para mantener tu racha!',
  };

  String get chooseSubjectHeading => switch (language) {
    AppLanguage.portuguese => 'Escolha uma matéria',
    AppLanguage.english => 'Choose a subject',
    AppLanguage.spanish => 'Elige una materia',
  };

  String get dailyGoalTitle => switch (language) {
    AppLanguage.portuguese => 'Meta de hoje',
    AppLanguage.english => "Today's goal",
    AppLanguage.spanish => 'Meta de hoy',
  };

  String dailyGoalProgress(int answered, int target) => switch (language) {
    AppLanguage.portuguese => '$answered / $target questões',
    AppLanguage.english => '$answered / $target questions',
    AppLanguage.spanish => '$answered / $target preguntas',
  };

  String get dailyGoalCompleteBadge => switch (language) {
    AppLanguage.portuguese => 'Meta batida!',
    AppLanguage.english => 'Goal reached!',
    AppLanguage.spanish => '¡Meta cumplida!',
  };

  String get navHome => switch (language) {
    AppLanguage.portuguese => 'Início',
    AppLanguage.english => 'Home',
    AppLanguage.spanish => 'Inicio',
  };

  String get navPractice => switch (language) {
    AppLanguage.portuguese => 'Praticar',
    AppLanguage.english => 'Practice',
    AppLanguage.spanish => 'Practicar',
  };

  String get navProfile => switch (language) {
    AppLanguage.portuguese => 'Perfil',
    AppLanguage.english => 'Profile',
    AppLanguage.spanish => 'Perfil',
  };
}
