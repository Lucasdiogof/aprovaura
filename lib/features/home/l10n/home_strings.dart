import 'package:aura/core/l10n/app_language.dart';

class HomeStrings {
  const HomeStrings(this.language);

  final AppLanguage language;

  /// "Bom dia" / "Boa tarde" / "Boa noite", by the device's current hour --
  /// the hero's context line, above the name. No name and no punctuation:
  /// the name carries its own line and weight.
  String timeGreeting({DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    return switch (hour) {
      >= 5 && < 12 => switch (language) {
        AppLanguage.portuguese => 'Bom dia',
        AppLanguage.english => 'Good morning',
        AppLanguage.spanish => 'Buenos días',
      },
      >= 12 && < 18 => switch (language) {
        AppLanguage.portuguese => 'Boa tarde',
        AppLanguage.english => 'Good afternoon',
        AppLanguage.spanish => 'Buenas tardes',
      },
      _ => switch (language) {
        AppLanguage.portuguese => 'Boa noite',
        AppLanguage.english => 'Good evening',
        AppLanguage.spanish => 'Buenas noches',
      },
    };
  }

  /// The hero's subtitle -- a low-key nudge to start, not a motivational
  /// slogan and not a repeat of [homeActionsHeading] below it.
  String get homeSubtitle => switch (language) {
    AppLanguage.portuguese => 'Pronto para avançar mais um pouco?',
    AppLanguage.english => 'Ready to make a little more progress?',
    AppLanguage.spanish => '¿Listo para avanzar un poco más?',
  };

  /// Heading right above the practice shortcuts (quick practice, review
  /// mistakes, favorites, mock exam) -- deliberately a different question
  /// from [homeSubtitle] so the two don't read as the same line twice.
  String get homeActionsHeading => switch (language) {
    AppLanguage.portuguese => 'Como você quer praticar?',
    AppLanguage.english => 'How do you want to practice?',
    AppLanguage.spanish => '¿Cómo quieres practicar?',
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
