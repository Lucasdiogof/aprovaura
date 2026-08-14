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
  atualidades;

  IconData get icon => switch (this) {
    Subject.matematica => Icons.calculate_outlined,
    Subject.geografia => Icons.travel_explore_outlined,
    Subject.historia => Icons.account_balance_outlined,
    Subject.portugues => Icons.menu_book_outlined,
    Subject.biologia => Icons.eco_outlined,
    Subject.fisica => Icons.bolt_outlined,
    Subject.quimica => Icons.science_outlined,
    Subject.atualidades => Icons.newspaper_outlined,
  };

  Color get accentColor => switch (this) {
    Subject.matematica => const Color(0xFFE8A23D),
    Subject.geografia => const Color(0xFF7C6FE0),
    Subject.historia => const Color(0xFF4CAF83),
    Subject.portugues => const Color(0xFFE0708A),
    Subject.biologia => const Color(0xFF2DBE91),
    Subject.fisica => const Color(0xFF4C7CD1),
    Subject.quimica => const Color(0xFF9C6FE0),
    Subject.atualidades => const Color(0xFF6B7B8C),
  };

  String label(AppLanguage language) => switch (this) {
    Subject.matematica => switch (language) {
      AppLanguage.portuguese => 'Matemática',
      AppLanguage.english => 'Math',
    },
    Subject.geografia => switch (language) {
      AppLanguage.portuguese => 'Geografia',
      AppLanguage.english => 'Geography',
    },
    Subject.historia => switch (language) {
      AppLanguage.portuguese => 'História',
      AppLanguage.english => 'History',
    },
    Subject.portugues => switch (language) {
      AppLanguage.portuguese => 'Português',
      AppLanguage.english => 'Portuguese',
    },
    Subject.biologia => switch (language) {
      AppLanguage.portuguese => 'Biologia',
      AppLanguage.english => 'Biology',
    },
    Subject.fisica => switch (language) {
      AppLanguage.portuguese => 'Física',
      AppLanguage.english => 'Physics',
    },
    Subject.quimica => switch (language) {
      AppLanguage.portuguese => 'Química',
      AppLanguage.english => 'Chemistry',
    },
    Subject.atualidades => switch (language) {
      AppLanguage.portuguese => 'Atualidades',
      AppLanguage.english => 'Current events',
    },
  };

  String description(AppLanguage language) => switch (this) {
    Subject.matematica => switch (language) {
      AppLanguage.portuguese => 'Exercícios e desafios para todos os níveis.',
      AppLanguage.english => 'Exercises and challenges for every level.',
    },
    Subject.geografia => switch (language) {
      AppLanguage.portuguese => 'Explore países, capitais, rios e muito mais.',
      AppLanguage.english => 'Explore countries, capitals, rivers and more.',
    },
    Subject.historia => switch (language) {
      AppLanguage.portuguese =>
        'Viaje no tempo e aprenda os fatos que marcaram o mundo.',
      AppLanguage.english =>
        'Travel through time and learn the facts that shaped the world.',
    },
    Subject.portugues => switch (language) {
      AppLanguage.portuguese =>
        'Gramática, interpretação de texto e muito mais.',
      AppLanguage.english => 'Grammar, reading comprehension and more.',
    },
    Subject.biologia => switch (language) {
      AppLanguage.portuguese => 'Estude os seres vivos e seus processos.',
      AppLanguage.english => 'Study living things and their processes.',
    },
    Subject.fisica => switch (language) {
      AppLanguage.portuguese => 'Entenda as leis da natureza de forma prática.',
      AppLanguage.english => 'Understand the laws of nature in practice.',
    },
    Subject.quimica => switch (language) {
      AppLanguage.portuguese => 'Reações, elementos e transformações.',
      AppLanguage.english => 'Reactions, elements and transformations.',
    },
    Subject.atualidades => switch (language) {
      AppLanguage.portuguese =>
        'Fique por dentro dos principais acontecimentos.',
      AppLanguage.english => 'Stay on top of major current events.',
    },
  };
}
