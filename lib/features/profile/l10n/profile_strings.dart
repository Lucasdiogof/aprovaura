import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';

class ProfileStrings {
  const ProfileStrings(this.language);

  final AppLanguage language;

  String get profilePageTitle => switch (language) {
    AppLanguage.portuguese => 'Perfil',
    AppLanguage.english => 'Profile',
  };

  String get notInformedLabel => switch (language) {
    AppLanguage.portuguese => 'Não informado',
    AppLanguage.english => 'Not informed',
  };

  // Shown in place of the name specifically when it's empty -- unlike
  // notInformedLabel (goal, subjects), a blank name up top reads like the
  // profile is broken, not just "no preference set yet".
  String get namePlaceholder => switch (language) {
    AppLanguage.portuguese => 'Estudante',
    AppLanguage.english => 'Student',
  };

  String get streakStatLabel => switch (language) {
    AppLanguage.portuguese => 'dias seguidos',
    AppLanguage.english => 'day streak',
  };

  String get questionsStatLabel => switch (language) {
    AppLanguage.portuguese => 'questões',
    AppLanguage.english => 'questions',
  };

  String get accuracyStatLabel => switch (language) {
    AppLanguage.portuguese => 'de acerto',
    AppLanguage.english => 'accuracy',
  };

  String get goalRowLabel => switch (language) {
    AppLanguage.portuguese => 'Meu objetivo',
    AppLanguage.english => 'My goal',
  };

  String get interestedSubjectsRowLabel => switch (language) {
    AppLanguage.portuguese => 'Matérias de interesse',
    AppLanguage.english => 'Subjects of interest',
  };

  String interestedSubjectsCount(int count) => switch (language) {
    AppLanguage.portuguese =>
      count == 1 ? '1 matéria selecionada' : '$count matérias selecionadas',
    AppLanguage.english =>
      count == 1 ? '1 subject selected' : '$count subjects selected',
  };

  String get myAccountRowLabel => switch (language) {
    AppLanguage.portuguese => 'Minha conta',
    AppLanguage.english => 'My account',
  };

  String get settingsRowLabel => switch (language) {
    AppLanguage.portuguese => 'Configurações',
    AppLanguage.english => 'Settings',
  };

  String get signOutButtonLabel => switch (language) {
    AppLanguage.portuguese => 'Sair',
    AppLanguage.english => 'Sign out',
  };

  String get myAccountPageTitle => switch (language) {
    AppLanguage.portuguese => 'Minha conta',
    AppLanguage.english => 'My account',
  };

  String get myAccountPageSubtitle => switch (language) {
    AppLanguage.portuguese => 'Atualize seus dados',
    AppLanguage.english => 'Update your details',
  };

  String get nameHint => switch (language) {
    AppLanguage.portuguese => 'Nome completo',
    AppLanguage.english => 'Full name',
  };

  String get nameRequired => switch (language) {
    AppLanguage.portuguese => 'Informe seu nome.',
    AppLanguage.english => 'Enter your name.',
  };

  String get usernameHint => switch (language) {
    AppLanguage.portuguese => 'Nome de usuário (opcional)',
    AppLanguage.english => 'Username (optional)',
  };

  String get saveButtonLabel => switch (language) {
    AppLanguage.portuguese => 'Salvar',
    AppLanguage.english => 'Save',
  };

  String get settingsPageTitle => switch (language) {
    AppLanguage.portuguese => 'Configurações',
    AppLanguage.english => 'Settings',
  };

  String get settingsPageSubtitle => switch (language) {
    AppLanguage.portuguese => 'Aparência e idioma do app',
    AppLanguage.english => 'App appearance and language',
  };

  String get themeRowLabel => switch (language) {
    AppLanguage.portuguese => 'Tema',
    AppLanguage.english => 'Theme',
  };

  String get languageRowLabel => switch (language) {
    AppLanguage.portuguese => 'Idioma',
    AppLanguage.english => 'Language',
  };

  String get appearanceSectionLabel => switch (language) {
    AppLanguage.portuguese => 'Aparência',
    AppLanguage.english => 'Appearance',
  };

  String get languageSectionLabel => switch (language) {
    AppLanguage.portuguese => 'Idioma',
    AppLanguage.english => 'Language',
  };

  String get aboutSectionLabel => switch (language) {
    AppLanguage.portuguese => 'Sobre',
    AppLanguage.english => 'About',
  };

  String get aboutRowLabel => switch (language) {
    AppLanguage.portuguese => 'Sobre o Aura',
    AppLanguage.english => 'About Aura',
  };

  String get aboutPageTitle => switch (language) {
    AppLanguage.portuguese => 'Sobre o Aura',
    AppLanguage.english => 'About Aura',
  };

  String get aboutAppDescription => switch (language) {
    AppLanguage.portuguese =>
      'Um app gamificado de estudos para o ENEM, vestibulares e concursos. '
          'Aprenda, pratique e evolua.',
    AppLanguage.english =>
      'A gamified study app for the ENEM, university entrance exams and '
          'civil service exams. Learn, practice and evolve.',
  };

  String get versionRowLabel => switch (language) {
    AppLanguage.portuguese => 'Versão do app',
    AppLanguage.english => 'App version',
  };

  String get themePageTitle => switch (language) {
    AppLanguage.portuguese => 'Tema',
    AppLanguage.english => 'Theme',
  };

  String get themePageSubtitle => switch (language) {
    AppLanguage.portuguese => 'Escolha a aparência do app',
    AppLanguage.english => 'Choose the app appearance',
  };

  String themeOptionDescription(ThemeMode mode) => switch (mode) {
    ThemeMode.system => switch (language) {
      AppLanguage.portuguese => 'Segue a configuração do seu aparelho',
      AppLanguage.english => 'Follows your device settings',
    },
    ThemeMode.light => switch (language) {
      AppLanguage.portuguese => 'Fundo claro em todas as telas',
      AppLanguage.english => 'Light background on every screen',
    },
    ThemeMode.dark => switch (language) {
      AppLanguage.portuguese => 'Fundo escuro em todas as telas',
      AppLanguage.english => 'Dark background on every screen',
    },
  };

  String get languagePageTitle => switch (language) {
    AppLanguage.portuguese => 'Idioma',
    AppLanguage.english => 'Language',
  };

  String get languagePageSubtitle => switch (language) {
    AppLanguage.portuguese => 'Escolha o idioma do app',
    AppLanguage.english => 'Choose the app language',
  };

  String languageOptionDescription(AppLanguage option) => switch (option) {
    AppLanguage.portuguese => switch (language) {
      AppLanguage.portuguese => 'Textos do app em português',
      AppLanguage.english => 'App text in Portuguese',
    },
    AppLanguage.english => switch (language) {
      AppLanguage.portuguese => 'Textos do app em inglês',
      AppLanguage.english => 'App text in English',
    },
  };

  String get goalPageTitle => switch (language) {
    AppLanguage.portuguese => 'Meu objetivo',
    AppLanguage.english => 'My goal',
  };

  String get interestedSubjectsPageTitle => switch (language) {
    AppLanguage.portuguese => 'Matérias de interesse',
    AppLanguage.english => 'Subjects of interest',
  };

  String interestedSubjectsSelectedCount(int selected, int total) =>
      switch (language) {
        AppLanguage.portuguese => '$selected de $total selecionadas',
        AppLanguage.english => '$selected of $total selected',
      };

  String levelLabel(int level) => switch (language) {
    AppLanguage.portuguese => 'Nível $level',
    AppLanguage.english => 'Level $level',
  };

  String xpToNextLevel(int current, int total) => switch (language) {
    AppLanguage.portuguese => '$current / $total XP para o próximo nível',
    AppLanguage.english => '$current / $total XP to next level',
  };
}
