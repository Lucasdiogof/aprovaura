import 'package:aura/core/l10n/app_language.dart';

class AtualidadesStrings {
  const AtualidadesStrings(this.language);

  final AppLanguage language;

  String get pageTitle => switch (language) {
    AppLanguage.portuguese => 'Atualidades',
    AppLanguage.english => 'Current Affairs',
  };

  String get areasPageSubtitle => switch (language) {
    AppLanguage.portuguese => 'O que você quer revisar?',
    AppLanguage.english => 'What do you want to review?',
  };

  String readMinutesLabel(int minutes) => switch (language) {
    AppLanguage.portuguese => '$minutes min de leitura',
    AppLanguage.english => '$minutes min read',
  };

  String get sourcesLabel => switch (language) {
    AppLanguage.portuguese => 'Fontes',
    AppLanguage.english => 'Sources',
  };

  String get contextLabel => switch (language) {
    AppLanguage.portuguese => 'Contexto',
    AppLanguage.english => 'Context',
  };

  String get whatHappenedLabel => switch (language) {
    AppLanguage.portuguese => 'O que aconteceu',
    AppLanguage.english => 'What happened',
  };

  String get whyItHappenedLabel => switch (language) {
    AppLanguage.portuguese => 'Por que aconteceu',
    AppLanguage.english => 'Why it happened',
  };

  String get whoIsInvolvedLabel => switch (language) {
    AppLanguage.portuguese => 'Quem está envolvido',
    AppLanguage.english => 'Who is involved',
  };

  String get consequencesLabel => switch (language) {
    AppLanguage.portuguese => 'Consequências',
    AppLanguage.english => 'Consequences',
  };

  String get keyTakeawaysLabel => switch (language) {
    AppLanguage.portuguese => 'O que você precisa lembrar',
    AppLanguage.english => 'What you need to remember',
  };

  String get practiceButtonLabel => switch (language) {
    AppLanguage.portuguese => 'Praticar',
    AppLanguage.english => 'Practice',
  };

  String get newBadge => switch (language) {
    AppLanguage.portuguese => 'Novo',
    AppLanguage.english => 'New',
  };

  String get updatedTodayBadge => switch (language) {
    AppLanguage.portuguese => 'Atualizado hoje',
    AppLanguage.english => 'Updated today',
  };

  String updatedDaysAgoBadge(int days) => switch (language) {
    AppLanguage.portuguese =>
      days == 1 ? 'Atualizado há 1 dia' : 'Atualizado há $days dias',
    AppLanguage.english =>
      days == 1 ? 'Updated 1 day ago' : 'Updated $days days ago',
  };
}
