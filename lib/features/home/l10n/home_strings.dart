import 'package:aura/core/l10n/app_language.dart';

class HomeStrings {
  const HomeStrings(this.language);

  final AppLanguage language;

  String greeting(String name) => switch (language) {
    AppLanguage.portuguese => 'Olá, $name! 👋',
    AppLanguage.english => 'Hi, $name! 👋',
  };

  String get homeSubtitle => switch (language) {
    AppLanguage.portuguese => 'O que vamos estudar hoje?',
    AppLanguage.english => 'What shall we study today?',
  };

  String get streakLabel => switch (language) {
    AppLanguage.portuguese => 'Ofensiva',
    AppLanguage.english => 'Streak',
  };

  String streakDaysCount(int days) => switch (language) {
    AppLanguage.portuguese => '$days ${days == 1 ? 'dia' : 'dias'}',
    AppLanguage.english => '$days ${days == 1 ? 'day' : 'days'}',
  };

  String get streakSubtitle => switch (language) {
    AppLanguage.portuguese =>
      'Faça uma atividade hoje para manter sua sequência!',
    AppLanguage.english => 'Complete an activity today to keep your streak!',
  };

  String get chooseSubjectHeading => switch (language) {
    AppLanguage.portuguese => 'Escolha uma matéria',
    AppLanguage.english => 'Choose a subject',
  };

  String get navHome => switch (language) {
    AppLanguage.portuguese => 'Início',
    AppLanguage.english => 'Home',
  };

  String get navPractice => switch (language) {
    AppLanguage.portuguese => 'Praticar',
    AppLanguage.english => 'Practice',
  };

  String get navProfile => switch (language) {
    AppLanguage.portuguese => 'Perfil',
    AppLanguage.english => 'Profile',
  };
}
