import 'package:flutter/material.dart';
import 'package:aura/core/l10n/app_language.dart';

class ProfileStrings {
  const ProfileStrings(this.language);

  final AppLanguage language;

  String get profilePageTitle => switch (language) {
    AppLanguage.portuguese => 'Perfil',
    AppLanguage.english => 'Profile',
    AppLanguage.spanish => 'Perfil',
  };

  String get notInformedLabel => switch (language) {
    AppLanguage.portuguese => 'Não informado',
    AppLanguage.english => 'Not informed',
    AppLanguage.spanish => 'No informado',
  };

  // Shown in place of the name specifically when it's empty -- unlike
  // notInformedLabel (goal, subjects), a blank name up top reads like the
  // profile is broken, not just "no preference set yet".
  String get namePlaceholder => switch (language) {
    AppLanguage.portuguese => 'Estudante',
    AppLanguage.english => 'Student',
    AppLanguage.spanish => 'Estudiante',
  };

  String get streakStatLabel => switch (language) {
    AppLanguage.portuguese => 'dias seguidos',
    AppLanguage.english => 'day streak',
    AppLanguage.spanish => 'días seguidos',
  };

  String get questionsStatLabel => switch (language) {
    AppLanguage.portuguese => 'questões',
    AppLanguage.english => 'questions',
    AppLanguage.spanish => 'preguntas',
  };

  String get accuracyStatLabel => switch (language) {
    AppLanguage.portuguese => 'de acerto',
    AppLanguage.english => 'accuracy',
    AppLanguage.spanish => 'de aciertos',
  };

  String get goalRowLabel => switch (language) {
    AppLanguage.portuguese => 'Meu objetivo',
    AppLanguage.english => 'My goal',
    AppLanguage.spanish => 'Mi objetivo',
  };

  String get interestedSubjectsRowLabel => switch (language) {
    AppLanguage.portuguese => 'Matérias de interesse',
    AppLanguage.english => 'Subjects of interest',
    AppLanguage.spanish => 'Materias de interés',
  };

  String interestedSubjectsCount(int count) => switch (language) {
    AppLanguage.portuguese =>
      count == 1 ? '1 matéria selecionada' : '$count matérias selecionadas',
    AppLanguage.english =>
      count == 1 ? '1 subject selected' : '$count subjects selected',
    AppLanguage.spanish =>
      count == 1 ? '1 materia seleccionada' : '$count materias seleccionadas',
  };

  String get myAccountRowLabel => switch (language) {
    AppLanguage.portuguese => 'Minha conta',
    AppLanguage.english => 'My account',
    AppLanguage.spanish => 'Mi cuenta',
  };

  String get settingsRowLabel => switch (language) {
    AppLanguage.portuguese => 'Configurações',
    AppLanguage.english => 'Settings',
    AppLanguage.spanish => 'Configuración',
  };

  String get signOutButtonLabel => switch (language) {
    AppLanguage.portuguese => 'Sair',
    AppLanguage.english => 'Sign out',
    AppLanguage.spanish => 'Cerrar sesión',
  };

  String get studiesSectionLabel => switch (language) {
    AppLanguage.portuguese => 'Estudos',
    AppLanguage.english => 'Studies',
    AppLanguage.spanish => 'Estudios',
  };

  String get accountSectionLabel => switch (language) {
    AppLanguage.portuguese => 'Conta',
    AppLanguage.english => 'Account',
    AppLanguage.spanish => 'Cuenta',
  };

  /// What is behind the row, so the list answers itself without being
  /// opened.
  String get myAccountRowSubtitle => switch (language) {
    AppLanguage.portuguese => 'Nome, usuário e e-mail',
    AppLanguage.english => 'Name, username and email',
    AppLanguage.spanish => 'Nombre, usuario y correo electrónico',
  };

  String get settingsRowSubtitle => switch (language) {
    AppLanguage.portuguese => 'Tema, idioma e preferências',
    AppLanguage.english => 'Theme, language and preferences',
    AppLanguage.spanish => 'Tema, idioma y preferencias',
  };

  String get signOutConfirmTitle => switch (language) {
    AppLanguage.portuguese => 'Sair da sua conta?',
    AppLanguage.english => 'Sign out of your account?',
    AppLanguage.spanish => '¿Cerrar sesión de tu cuenta?',
  };

  /// Says what signing out is *not*, because it sits next to a row that
  /// does exactly that and cannot be undone.
  String get signOutConfirmDescription => switch (language) {
    AppLanguage.portuguese =>
      'Seu progresso continua salvo. Você vai precisar entrar de novo para '
          'voltar a estudar.',
    AppLanguage.english =>
      'Your progress stays saved. You will need to sign in again to keep '
          'studying.',
    AppLanguage.spanish =>
      'Tu progreso sigue guardado. Deberás iniciar sesión de nuevo para '
          'seguir estudiando.',
  };

  String get signOutConfirmButton => switch (language) {
    AppLanguage.portuguese => 'Sair',
    AppLanguage.english => 'Sign out',
    AppLanguage.spanish => 'Cerrar sesión',
  };

  String get myAccountPageTitle => switch (language) {
    AppLanguage.portuguese => 'Minha conta',
    AppLanguage.english => 'My account',
    AppLanguage.spanish => 'Mi cuenta',
  };

  String get myAccountPageSubtitle => switch (language) {
    AppLanguage.portuguese => 'Atualize seus dados',
    AppLanguage.english => 'Update your details',
    AppLanguage.spanish => 'Actualiza tus datos',
  };

  String get nameHint => switch (language) {
    AppLanguage.portuguese => 'Nome completo',
    AppLanguage.english => 'Full name',
    AppLanguage.spanish => 'Nombre completo',
  };

  String get nameRequired => switch (language) {
    AppLanguage.portuguese => 'Informe seu nome.',
    AppLanguage.english => 'Enter your name.',
    AppLanguage.spanish => 'Ingresa tu nombre.',
  };

  String get usernameHint => switch (language) {
    AppLanguage.portuguese => 'Nome de usuário (opcional)',
    AppLanguage.english => 'Username (optional)',
    AppLanguage.spanish => 'Nombre de usuario (opcional)',
  };

  String get saveButtonLabel => switch (language) {
    AppLanguage.portuguese => 'Salvar',
    AppLanguage.english => 'Save',
    AppLanguage.spanish => 'Guardar',
  };

  String get deleteAccountRowLabel => switch (language) {
    AppLanguage.portuguese => 'Excluir minha conta',
    AppLanguage.english => 'Delete my account',
    AppLanguage.spanish => 'Eliminar mi cuenta',
  };

  String get deleteAccountConfirmTitle => switch (language) {
    AppLanguage.portuguese => 'Excluir sua conta?',
    AppLanguage.english => 'Delete your account?',
    AppLanguage.spanish => '¿Eliminar tu cuenta?',
  };

  String get deleteAccountConfirmDescription => switch (language) {
    AppLanguage.portuguese =>
      'Todos os seus dados, progresso, favoritos e histórico serão '
          'permanentemente removidos. Essa ação não pode ser desfeita.',
    AppLanguage.english =>
      'All your data, progress, favorites and history will be permanently '
          'removed. This action cannot be undone.',
    AppLanguage.spanish =>
      'Todos tus datos, progreso, favoritos e historial se eliminarán '
          'permanentemente. Esta acción no se puede deshacer.',
  };

  String get deleteAccountConfirmButton => switch (language) {
    AppLanguage.portuguese => 'Excluir conta',
    AppLanguage.english => 'Delete account',
    AppLanguage.spanish => 'Eliminar cuenta',
  };

  String get cancelButtonLabel => switch (language) {
    AppLanguage.portuguese => 'Cancelar',
    AppLanguage.english => 'Cancel',
    AppLanguage.spanish => 'Cancelar',
  };

  String get deleteAccountFailedMessage => switch (language) {
    AppLanguage.portuguese =>
      'Não deu para excluir sua conta agora. Tente novamente em instantes.',
    AppLanguage.english =>
      "Couldn't delete your account right now. Please try again shortly.",
    AppLanguage.spanish =>
      'No se pudo eliminar tu cuenta ahora. Intenta de nuevo en unos '
          'momentos.',
  };

  String get settingsPageTitle => switch (language) {
    AppLanguage.portuguese => 'Configurações',
    AppLanguage.english => 'Settings',
    AppLanguage.spanish => 'Configuración',
  };

  String get settingsPageSubtitle => switch (language) {
    AppLanguage.portuguese => 'Aparência e idioma do app',
    AppLanguage.english => 'App appearance and language',
    AppLanguage.spanish => 'Apariencia e idioma de la app',
  };

  String get themeRowLabel => switch (language) {
    AppLanguage.portuguese => 'Tema',
    AppLanguage.english => 'Theme',
    AppLanguage.spanish => 'Tema',
  };

  String get languageRowLabel => switch (language) {
    AppLanguage.portuguese => 'Idioma',
    AppLanguage.english => 'Language',
    AppLanguage.spanish => 'Idioma',
  };

  String get appearanceSectionLabel => switch (language) {
    AppLanguage.portuguese => 'Aparência',
    AppLanguage.english => 'Appearance',
    AppLanguage.spanish => 'Apariencia',
  };

  String get languageSectionLabel => switch (language) {
    AppLanguage.portuguese => 'Idioma',
    AppLanguage.english => 'Language',
    AppLanguage.spanish => 'Idioma',
  };

  String get aboutSectionLabel => switch (language) {
    AppLanguage.portuguese => 'Sobre',
    AppLanguage.english => 'About',
    AppLanguage.spanish => 'Acerca de',
  };

  String get aboutRowLabel => switch (language) {
    AppLanguage.portuguese => 'Sobre a Aprovaura',
    AppLanguage.english => 'About Aprovaura',
    AppLanguage.spanish => 'Acerca de Aprovaura',
  };

  String get aboutPageTitle => switch (language) {
    AppLanguage.portuguese => 'Sobre a Aprovaura',
    AppLanguage.english => 'About Aprovaura',
    AppLanguage.spanish => 'Acerca de Aprovaura',
  };

  String get aboutAppDescription => switch (language) {
    AppLanguage.portuguese =>
      'Estude. Acerte. Ganhe Aura. Um app de estudos gamificado para o ENEM, '
          'vestibulares e concursos — cada acerto vira Aura, a sua pontuação.',
    AppLanguage.english =>
      'Study. Get it right. Earn Aura. A gamified study app for the ENEM, '
          'university entrance exams and civil service exams — every right '
          'answer turns into Aura, your score.',
    AppLanguage.spanish =>
      'Estudia. Acierta. Gana Aura. Una app de estudio gamificada para el '
          'ENEM, exámenes de admisión y oposiciones — cada acierto se '
          'convierte en Aura, tu puntuación.',
  };

  String get versionRowLabel => switch (language) {
    AppLanguage.portuguese => 'Versão do app',
    AppLanguage.english => 'App version',
    AppLanguage.spanish => 'Versión de la app',
  };

  String get themePageTitle => switch (language) {
    AppLanguage.portuguese => 'Tema',
    AppLanguage.english => 'Theme',
    AppLanguage.spanish => 'Tema',
  };

  String get themePageSubtitle => switch (language) {
    AppLanguage.portuguese => 'Escolha a aparência do app',
    AppLanguage.english => 'Choose the app appearance',
    AppLanguage.spanish => 'Elige la apariencia de la app',
  };

  String themeOptionDescription(ThemeMode mode) => switch (mode) {
    ThemeMode.system => switch (language) {
      AppLanguage.portuguese => 'Segue a configuração do seu aparelho',
      AppLanguage.english => 'Follows your device settings',
      AppLanguage.spanish => 'Sigue la configuración de tu dispositivo',
    },
    ThemeMode.light => switch (language) {
      AppLanguage.portuguese => 'Fundo claro em todas as telas',
      AppLanguage.english => 'Light background on every screen',
      AppLanguage.spanish => 'Fondo claro en todas las pantallas',
    },
    ThemeMode.dark => switch (language) {
      AppLanguage.portuguese => 'Fundo escuro em todas as telas',
      AppLanguage.english => 'Dark background on every screen',
      AppLanguage.spanish => 'Fondo oscuro en todas las pantallas',
    },
  };

  String get languagePageTitle => switch (language) {
    AppLanguage.portuguese => 'Idioma',
    AppLanguage.english => 'Language',
    AppLanguage.spanish => 'Idioma',
  };

  String get languagePageSubtitle => switch (language) {
    AppLanguage.portuguese => 'Escolha o idioma do app',
    AppLanguage.english => 'Choose the app language',
    AppLanguage.spanish => 'Elige el idioma de la app',
  };

  String languageOptionDescription(AppLanguage option) => switch (option) {
    AppLanguage.portuguese => switch (language) {
      AppLanguage.portuguese => 'Textos do app em português',
      AppLanguage.english => 'App text in Portuguese',
      AppLanguage.spanish => 'Textos de la app en portugués',
    },
    AppLanguage.english => switch (language) {
      AppLanguage.portuguese => 'Textos do app em inglês',
      AppLanguage.english => 'App text in English',
      AppLanguage.spanish => 'Textos de la app en inglés',
    },
    AppLanguage.spanish => switch (language) {
      AppLanguage.portuguese => 'Textos do app em espanhol',
      AppLanguage.english => 'App text in Spanish',
      AppLanguage.spanish => 'Textos de la app en español',
    },
  };

  String get goalPageTitle => switch (language) {
    AppLanguage.portuguese => 'Meu objetivo',
    AppLanguage.english => 'My goal',
    AppLanguage.spanish => 'Mi objetivo',
  };

  String get interestedSubjectsPageTitle => switch (language) {
    AppLanguage.portuguese => 'Matérias de interesse',
    AppLanguage.english => 'Subjects of interest',
    AppLanguage.spanish => 'Materias de interés',
  };

  String interestedSubjectsSelectedCount(int selected, int total) =>
      switch (language) {
        AppLanguage.portuguese => '$selected de $total selecionadas',
        AppLanguage.english => '$selected of $total selected',
        AppLanguage.spanish => '$selected de $total seleccionadas',
      };

  String levelLabel(int level) => switch (language) {
    AppLanguage.portuguese => 'Nível $level',
    AppLanguage.english => 'Level $level',
    AppLanguage.spanish => 'Nivel $level',
  };

  String auraTotal(int total) => switch (language) {
    AppLanguage.portuguese => '$total Aura no total',
    AppLanguage.english => '$total Aura in total',
    AppLanguage.spanish => '$total Aura en total',
  };

  String auraToNextLevel(
    int current,
    int total,
    int nextLevel,
  ) => switch (language) {
    AppLanguage.portuguese => '$current / $total Aura para o nível $nextLevel',
    AppLanguage.english => '$current / $total Aura to level $nextLevel',
    AppLanguage.spanish => '$current / $total Aura para el nivel $nextLevel',
  };
}
