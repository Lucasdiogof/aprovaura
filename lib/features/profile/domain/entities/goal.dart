import 'package:aura/core/l10n/app_language.dart';

enum Goal {
  enem,
  vestibular,
  concurso,
  escola,
  contaPropria;

  String label(AppLanguage language) => switch (this) {
    Goal.enem => switch (language) {
      AppLanguage.portuguese => 'ENEM',
      AppLanguage.english => 'ENEM',
    },
    Goal.vestibular => switch (language) {
      AppLanguage.portuguese => 'Vestibular',
      AppLanguage.english => 'College entrance exam',
    },
    Goal.concurso => switch (language) {
      AppLanguage.portuguese => 'Concurso',
      AppLanguage.english => 'Civil service exam',
    },
    Goal.escola => switch (language) {
      AppLanguage.portuguese => 'Escola',
      AppLanguage.english => 'School',
    },
    Goal.contaPropria => switch (language) {
      AppLanguage.portuguese => 'Estudar por conta própria',
      AppLanguage.english => 'Self-study',
    },
  };

  static Goal? fromName(String? name) {
    if (name == null) return null;
    for (final goal in Goal.values) {
      if (goal.name == name) return goal;
    }
    return null;
  }
}
