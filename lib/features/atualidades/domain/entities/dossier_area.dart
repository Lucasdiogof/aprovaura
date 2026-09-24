import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';

enum DossierArea {
  brasil,
  mundoGeopolitica,
  economia,
  meioAmbiente,
  cienciaTecnologia,
  sociedade,
  saude;

  IconData get icon => switch (this) {
    DossierArea.brasil => Icons.flag_outlined,
    DossierArea.mundoGeopolitica => Icons.public_outlined,
    DossierArea.economia => Icons.attach_money_outlined,
    DossierArea.meioAmbiente => Icons.eco_outlined,
    DossierArea.cienciaTecnologia => Icons.memory_outlined,
    DossierArea.sociedade => Icons.groups_outlined,
    DossierArea.saude => Icons.local_hospital_outlined,
  };

  String label(AppLanguage language) => switch (this) {
    DossierArea.brasil => switch (language) {
      AppLanguage.portuguese => 'Brasil',
      AppLanguage.english => 'Brazil',
      AppLanguage.spanish => 'Brasil',
    },
    DossierArea.mundoGeopolitica => switch (language) {
      AppLanguage.portuguese => 'Mundo e Geopolítica',
      AppLanguage.english => 'World & Geopolitics',
      AppLanguage.spanish => 'Mundo y Geopolítica',
    },
    DossierArea.economia => switch (language) {
      AppLanguage.portuguese => 'Economia',
      AppLanguage.english => 'Economy',
      AppLanguage.spanish => 'Economía',
    },
    DossierArea.meioAmbiente => switch (language) {
      AppLanguage.portuguese => 'Meio Ambiente',
      AppLanguage.english => 'Environment',
      AppLanguage.spanish => 'Medio Ambiente',
    },
    DossierArea.cienciaTecnologia => switch (language) {
      AppLanguage.portuguese => 'Ciência e Tecnologia',
      AppLanguage.english => 'Science & Technology',
      AppLanguage.spanish => 'Ciencia y Tecnología',
    },
    DossierArea.sociedade => switch (language) {
      AppLanguage.portuguese => 'Sociedade',
      AppLanguage.english => 'Society',
      AppLanguage.spanish => 'Sociedad',
    },
    DossierArea.saude => switch (language) {
      AppLanguage.portuguese => 'Saúde',
      AppLanguage.english => 'Health',
      AppLanguage.spanish => 'Salud',
    },
  };

  String description(AppLanguage language) => switch (this) {
    DossierArea.brasil => switch (language) {
      AppLanguage.portuguese =>
        'Política, economia, sociedade e acontecimentos nacionais',
      AppLanguage.english => 'Politics, economy, society and national events',
      AppLanguage.spanish =>
        'Política, economía, sociedad y acontecimientos nacionales',
    },
    DossierArea.mundoGeopolitica => switch (language) {
      AppLanguage.portuguese =>
        'Conflitos, relações internacionais e organizações',
      AppLanguage.english =>
        'Conflicts, international relations and organizations',
      AppLanguage.spanish =>
        'Conflictos, relaciones internacionales y organizaciones',
    },
    DossierArea.economia => switch (language) {
      AppLanguage.portuguese =>
        'Inflação, juros, comércio, trabalho e economia mundial',
      AppLanguage.english =>
        'Inflation, interest rates, trade, labor and world economy',
      AppLanguage.spanish =>
        'Inflación, tasas de interés, comercio, trabajo y economía '
            'mundial',
    },
    DossierArea.meioAmbiente => switch (language) {
      AppLanguage.portuguese => 'Clima, energia, desastres e sustentabilidade',
      AppLanguage.english => 'Climate, energy, disasters and sustainability',
      AppLanguage.spanish => 'Clima, energía, desastres y sostenibilidad',
    },
    DossierArea.cienciaTecnologia => switch (language) {
      AppLanguage.portuguese => 'IA, espaço, pesquisas e novas tecnologias',
      AppLanguage.english => 'AI, space, research and new technologies',
      AppLanguage.spanish =>
        'IA, espacio, investigaciones y nuevas tecnologías',
    },
    DossierArea.sociedade => switch (language) {
      AppLanguage.portuguese =>
        'Demografia, educação, direitos e questões sociais',
      AppLanguage.english =>
        'Demographics, education, rights and social issues',
      AppLanguage.spanish => 'Demografía, educación, derechos y temas sociales',
    },
    DossierArea.saude => switch (language) {
      AppLanguage.portuguese => 'Epidemias, saúde pública e descobertas',
      AppLanguage.english => 'Epidemics, public health and discoveries',
      AppLanguage.spanish => 'Epidemias, salud pública y descubrimientos',
    },
  };
}
