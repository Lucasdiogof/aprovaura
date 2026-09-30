import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';

enum Subject {
  matematica,
  geografia,
  historia,
  portugues,
  biologia,
  fisica,
  quimica,
  filosofia,
  sociologia,
  atualidades,

  /// Not a question bank: the essay feature (themes, writing, AI marking).
  /// It is a subject so it can be picked as "em foco" and ordered with the
  /// others; the Practice grid opens the essay screen for it, and the mock
  /// exam leaves it out.
  redacao;

  /// Has catalog_nodes and questions (everything but Redação).
  bool get hasQuestions => this != Subject.redacao;

  IconData get icon => switch (this) {
    Subject.matematica => Icons.calculate_outlined,
    Subject.geografia => Icons.travel_explore_outlined,
    Subject.historia => Icons.account_balance_outlined,
    Subject.portugues => Icons.menu_book_outlined,
    Subject.biologia => Icons.eco_outlined,
    Subject.fisica => Icons.bolt_outlined,
    Subject.quimica => Icons.science_outlined,
    Subject.filosofia => Icons.psychology_outlined,
    Subject.sociologia => Icons.groups_outlined,
    Subject.atualidades => Icons.newspaper_outlined,
    Subject.redacao => Icons.edit_note_rounded,
  };

  Color get accentColor => switch (this) {
    Subject.matematica => const Color(0xFFE8A23D),
    Subject.geografia => const Color(0xFF7C6FE0),
    Subject.historia => const Color(0xFF4CAF83),
    Subject.portugues => const Color(0xFFE0708A),
    Subject.biologia => const Color(0xFF2DBE91),
    Subject.fisica => const Color(0xFF4C7CD1),
    Subject.quimica => const Color(0xFF9C6FE0),
    Subject.filosofia => const Color(0xFFC77B4A),
    Subject.sociologia => const Color(0xFF3FA7B5),
    Subject.atualidades => const Color(0xFF6B7B8C),
    // The brand violet: Redação is its own thing, not a subject accent.
    Subject.redacao => const Color(0xFF8B5CF6),
  };

  String label(AppLanguage language) => switch (this) {
    Subject.matematica => switch (language) {
      AppLanguage.portuguese => 'Matemática',
      AppLanguage.english => 'Math',
      AppLanguage.spanish => 'Matemáticas',
    },
    Subject.geografia => switch (language) {
      AppLanguage.portuguese => 'Geografia',
      AppLanguage.english => 'Geography',
      AppLanguage.spanish => 'Geografía',
    },
    Subject.historia => switch (language) {
      AppLanguage.portuguese => 'História',
      AppLanguage.english => 'History',
      AppLanguage.spanish => 'Historia',
    },
    Subject.portugues => switch (language) {
      AppLanguage.portuguese => 'Português',
      AppLanguage.english => 'Portuguese',
      AppLanguage.spanish => 'Portugués',
    },
    Subject.biologia => switch (language) {
      AppLanguage.portuguese => 'Biologia',
      AppLanguage.english => 'Biology',
      AppLanguage.spanish => 'Biología',
    },
    Subject.fisica => switch (language) {
      AppLanguage.portuguese => 'Física',
      AppLanguage.english => 'Physics',
      AppLanguage.spanish => 'Física',
    },
    Subject.quimica => switch (language) {
      AppLanguage.portuguese => 'Química',
      AppLanguage.english => 'Chemistry',
      AppLanguage.spanish => 'Química',
    },
    Subject.filosofia => switch (language) {
      AppLanguage.portuguese => 'Filosofia',
      AppLanguage.english => 'Philosophy',
      AppLanguage.spanish => 'Filosofía',
    },
    Subject.sociologia => switch (language) {
      AppLanguage.portuguese => 'Sociologia',
      AppLanguage.english => 'Sociology',
      AppLanguage.spanish => 'Sociología',
    },
    Subject.atualidades => switch (language) {
      AppLanguage.portuguese => 'Atualidades',
      AppLanguage.english => 'Current events',
      AppLanguage.spanish => 'Actualidad',
    },
    Subject.redacao => switch (language) {
      AppLanguage.portuguese => 'Redação',
      AppLanguage.english => 'Essay',
      AppLanguage.spanish => 'Redacción',
    },
  };

  String description(AppLanguage language) => switch (this) {
    Subject.matematica => switch (language) {
      AppLanguage.portuguese => 'Exercícios e desafios para todos os níveis.',
      AppLanguage.english => 'Exercises and challenges for every level.',
      AppLanguage.spanish => 'Ejercicios y desafíos para todos los niveles.',
    },
    Subject.geografia => switch (language) {
      AppLanguage.portuguese => 'Explore países, capitais, rios e muito mais.',
      AppLanguage.english => 'Explore countries, capitals, rivers and more.',
      AppLanguage.spanish => 'Explora países, capitales, ríos y mucho más.',
    },
    Subject.historia => switch (language) {
      AppLanguage.portuguese =>
        'Viaje no tempo e aprenda os fatos que marcaram o mundo.',
      AppLanguage.english =>
        'Travel through time and learn the facts that shaped the world.',
      AppLanguage.spanish =>
        'Viaja en el tiempo y aprende los hechos que marcaron el mundo.',
    },
    Subject.portugues => switch (language) {
      AppLanguage.portuguese =>
        'Gramática, interpretação de texto e muito mais.',
      AppLanguage.english => 'Grammar, reading comprehension and more.',
      AppLanguage.spanish => 'Gramática, comprensión de textos y mucho más.',
    },
    Subject.biologia => switch (language) {
      AppLanguage.portuguese => 'Estude os seres vivos e seus processos.',
      AppLanguage.english => 'Study living things and their processes.',
      AppLanguage.spanish => 'Estudia los seres vivos y sus procesos.',
    },
    Subject.fisica => switch (language) {
      AppLanguage.portuguese => 'Entenda as leis da natureza de forma prática.',
      AppLanguage.english => 'Understand the laws of nature in practice.',
      AppLanguage.spanish =>
        'Comprende las leyes de la naturaleza de forma práctica.',
    },
    Subject.quimica => switch (language) {
      AppLanguage.portuguese => 'Reações, elementos e transformações.',
      AppLanguage.english => 'Reactions, elements and transformations.',
      AppLanguage.spanish => 'Reacciones, elementos y transformaciones.',
    },
    Subject.filosofia => switch (language) {
      AppLanguage.portuguese =>
        'Grandes pensadores, ética, política e conhecimento.',
      AppLanguage.english => 'Great thinkers, ethics, politics and knowledge.',
      AppLanguage.spanish =>
        'Grandes pensadores, ética, política y conocimiento.',
    },
    Subject.sociologia => switch (language) {
      AppLanguage.portuguese =>
        'Sociedade, cultura, trabalho, poder e desigualdades.',
      AppLanguage.english => 'Society, culture, work, power and inequality.',
      AppLanguage.spanish =>
        'Sociedad, cultura, trabajo, poder y desigualdades.',
    },
    Subject.atualidades => switch (language) {
      AppLanguage.portuguese =>
        'Fique por dentro dos principais acontecimentos.',
      AppLanguage.english => 'Stay on top of major current events.',
      AppLanguage.spanish =>
        'Mantente al día de los principales acontecimientos.',
    },
    Subject.redacao => switch (language) {
      AppLanguage.portuguese => 'Escreva e receba uma correção.',
      AppLanguage.english => 'Write one and get it marked.',
      AppLanguage.spanish => 'Escribe una y recibe una corrección.',
    },
  };
}
