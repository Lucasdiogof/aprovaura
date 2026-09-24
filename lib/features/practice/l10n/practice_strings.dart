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

  String get quickPracticeTitle => switch (language) {
    AppLanguage.portuguese => 'Prática rápida',
    AppLanguage.english => 'Quick practice',
  };

  String get quickPracticeEmptyTitle => switch (language) {
    AppLanguage.portuguese => 'Você já respondeu tudo!',
    AppLanguage.english => "You've answered everything!",
  };

  String get quickPracticeEmptyDescription => switch (language) {
    AppLanguage.portuguese =>
      'Não sobrou nenhuma questão inédita no banco. Que tal revisar seus '
          'erros ou escolher uma matéria?',
    AppLanguage.english =>
      'There are no unseen questions left. How about reviewing your '
          'mistakes or picking a subject?',
  };

  String get quickPracticeMoreTitle => switch (language) {
    AppLanguage.portuguese => 'Quer mais questões?',
    AppLanguage.english => 'Want more questions?',
  };

  String get quickPracticeMoreDescription => switch (language) {
    AppLanguage.portuguese =>
      'Podemos seguir com uma nova rodada, sorteando de novo uma questão '
          'inédita de cada matéria.',
    AppLanguage.english =>
      'We can deal another round, drawing one unseen question from each '
          'subject again.',
  };

  String get quickPracticeMoreConfirm => switch (language) {
    AppLanguage.portuguese => 'Mais questões',
    AppLanguage.english => 'More questions',
  };

  String get quickPracticeMoreDismiss => switch (language) {
    AppLanguage.portuguese => 'Encerrar por aqui',
    AppLanguage.english => 'Finish for now',
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
  };
}
