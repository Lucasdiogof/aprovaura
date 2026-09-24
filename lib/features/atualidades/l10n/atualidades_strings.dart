import 'package:aura/core/l10n/app_language.dart';

class AtualidadesStrings {
  const AtualidadesStrings(this.language);

  final AppLanguage language;

  String get pageTitle => switch (language) {
    AppLanguage.portuguese => 'Atualidades',
    AppLanguage.english => 'Current Affairs',
    AppLanguage.spanish => 'Actualidad',
  };

  String get areasPageSubtitle => switch (language) {
    AppLanguage.portuguese => 'O que você quer revisar?',
    AppLanguage.english => 'What do you want to review?',
    AppLanguage.spanish => '¿Qué quieres repasar?',
  };

  String readMinutesLabel(int minutes) => switch (language) {
    AppLanguage.portuguese => '$minutes min de leitura',
    AppLanguage.english => '$minutes min read',
    AppLanguage.spanish => '$minutes min de lectura',
  };

  String get sourcesLabel => switch (language) {
    AppLanguage.portuguese => 'Fontes',
    AppLanguage.english => 'Sources',
    AppLanguage.spanish => 'Fuentes',
  };

  String get contextLabel => switch (language) {
    AppLanguage.portuguese => 'Contexto',
    AppLanguage.english => 'Context',
    AppLanguage.spanish => 'Contexto',
  };

  String get whatHappenedLabel => switch (language) {
    AppLanguage.portuguese => 'O que aconteceu',
    AppLanguage.english => 'What happened',
    AppLanguage.spanish => 'Qué pasó',
  };

  String get whyItHappenedLabel => switch (language) {
    AppLanguage.portuguese => 'Por que aconteceu',
    AppLanguage.english => 'Why it happened',
    AppLanguage.spanish => 'Por qué pasó',
  };

  String get whoIsInvolvedLabel => switch (language) {
    AppLanguage.portuguese => 'Quem está envolvido',
    AppLanguage.english => 'Who is involved',
    AppLanguage.spanish => 'Quién está involucrado',
  };

  String get consequencesLabel => switch (language) {
    AppLanguage.portuguese => 'Consequências',
    AppLanguage.english => 'Consequences',
    AppLanguage.spanish => 'Consecuencias',
  };

  String get keyTakeawaysLabel => switch (language) {
    AppLanguage.portuguese => 'O que você precisa lembrar',
    AppLanguage.english => 'What you need to remember',
    AppLanguage.spanish => 'Lo que necesitas recordar',
  };

  String get practiceButtonLabel => switch (language) {
    AppLanguage.portuguese => 'Praticar',
    AppLanguage.english => 'Practice',
    AppLanguage.spanish => 'Practicar',
  };

  String get newBadge => switch (language) {
    AppLanguage.portuguese => 'Novo',
    AppLanguage.english => 'New',
    AppLanguage.spanish => 'Nuevo',
  };

  String get updatedTodayBadge => switch (language) {
    AppLanguage.portuguese => 'Atualizado hoje',
    AppLanguage.english => 'Updated today',
    AppLanguage.spanish => 'Actualizado hoy',
  };

  String updatedDaysAgoBadge(int days) => switch (language) {
    AppLanguage.portuguese =>
      days == 1 ? 'Atualizado há 1 dia' : 'Atualizado há $days dias',
    AppLanguage.english =>
      days == 1 ? 'Updated 1 day ago' : 'Updated $days days ago',
    AppLanguage.spanish =>
      days == 1 ? 'Actualizado hace 1 día' : 'Actualizado hace $days días',
  };
}
