import 'package:aura/core/l10n/app_language.dart';

class PracticeStrings {
  const PracticeStrings(this.language);

  final AppLanguage language;

  String get pageTitle => switch (language) {
    AppLanguage.portuguese => 'Praticar',
    AppLanguage.english => 'Practice',
    AppLanguage.spanish => 'Practicar',
  };

  String get pageSubtitle => switch (language) {
    AppLanguage.portuguese => 'O que você quer fazer?',
    AppLanguage.english => 'What do you want to do?',
    AppLanguage.spanish => '¿Qué quieres hacer?',
  };

  String get quickPracticeTitle => switch (language) {
    AppLanguage.portuguese => 'Prática rápida',
    AppLanguage.english => 'Quick practice',
    AppLanguage.spanish => 'Práctica rápida',
  };

  String get quickPracticeEmptyTitle => switch (language) {
    AppLanguage.portuguese => 'Você já respondeu tudo!',
    AppLanguage.english => "You've answered everything!",
    AppLanguage.spanish => '¡Ya respondiste todo!',
  };

  String get quickPracticeEmptyDescription => switch (language) {
    AppLanguage.portuguese =>
      'Não sobrou nenhuma questão inédita no banco. Que tal revisar seus '
          'erros ou escolher uma matéria?',
    AppLanguage.english =>
      'There are no unseen questions left. How about reviewing your '
          'mistakes or picking a subject?',
    AppLanguage.spanish =>
      'No queda ninguna pregunta inédita en el banco. ¿Qué tal revisar '
          'tus errores o elegir una materia?',
  };

  String get quickPracticeMoreTitle => switch (language) {
    AppLanguage.portuguese => 'Quer mais questões?',
    AppLanguage.english => 'Want more questions?',
    AppLanguage.spanish => '¿Quieres más preguntas?',
  };

  String get quickPracticeMoreDescription => switch (language) {
    AppLanguage.portuguese =>
      'Podemos seguir com uma nova rodada, sorteando de novo uma questão '
          'inédita de cada matéria.',
    AppLanguage.english =>
      'We can deal another round, drawing one unseen question from each '
          'subject again.',
    AppLanguage.spanish =>
      'Podemos seguir con una nueva ronda, sorteando de nuevo una '
          'pregunta inédita de cada materia.',
  };

  String get quickPracticeMoreConfirm => switch (language) {
    AppLanguage.portuguese => 'Mais questões',
    AppLanguage.english => 'More questions',
    AppLanguage.spanish => 'Más preguntas',
  };

  String get quickPracticeMoreDismiss => switch (language) {
    AppLanguage.portuguese => 'Encerrar por aqui',
    AppLanguage.english => 'Finish for now',
    AppLanguage.spanish => 'Terminar por ahora',
  };

  String get quickPracticeReviewErrorsButton => switch (language) {
    AppLanguage.portuguese => 'Revisar meus erros',
    AppLanguage.english => 'Review my mistakes',
    AppLanguage.spanish => 'Revisar mis errores',
  };

  String get quickPracticeGoToPracticeButton => switch (language) {
    AppLanguage.portuguese => 'Ir para Praticar',
    AppLanguage.english => 'Go to Practice',
    AppLanguage.spanish => 'Ir a Practicar',
  };

  // Overrides the option's static description once the real count is
  // known -- e.g. "6 questões para revisar" instead of the generic blurb.
  String pendingReviewCount(int count) => switch (language) {
    AppLanguage.portuguese => switch (count) {
      0 => 'Nenhuma pendência por aqui',
      1 => '1 questão para revisar',
      _ => '$count questões para revisar',
    },
    AppLanguage.english => switch (count) {
      0 => 'Nothing pending here',
      1 => '1 question to review',
      _ => '$count questions to review',
    },
    AppLanguage.spanish => switch (count) {
      0 => 'Nada pendiente por aquí',
      1 => '1 pregunta para revisar',
      _ => '$count preguntas para revisar',
    },
  };

  String savedFavoritesCount(int count) => switch (language) {
    AppLanguage.portuguese => switch (count) {
      0 => 'Nenhuma questão salva ainda',
      1 => '1 questão salva',
      _ => '$count questões salvas',
    },
    AppLanguage.english => switch (count) {
      0 => 'No saved questions yet',
      1 => '1 saved question',
      _ => '$count saved questions',
    },
    AppLanguage.spanish => switch (count) {
      0 => 'Ninguna pregunta guardada todavía',
      1 => '1 pregunta guardada',
      _ => '$count preguntas guardadas',
    },
  };
}
