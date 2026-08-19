import 'package:aura/core/l10n/app_language.dart';

class StreakStrings {
  const StreakStrings(this.language);

  final AppLanguage language;

  String get lostTitle => switch (language) {
    AppLanguage.portuguese => 'Sua ofensiva acabou',
    AppLanguage.english => 'Your streak ended',
  };

  String lostDescription(int days) => switch (language) {
    AppLanguage.portuguese =>
      'Você chegou a $days ${days == 1 ? 'dia seguido' : 'dias seguidos'}. '
          'Faça uma atividade hoje e comece uma nova ofensiva.',
    AppLanguage.english =>
      'You reached $days ${days == 1 ? 'day' : 'days'} in a row. '
          'Complete an activity today to start a new streak.',
  };

  String get startAgainButton => switch (language) {
    AppLanguage.portuguese => 'Começar de novo',
    AppLanguage.english => 'Start again',
  };
}
