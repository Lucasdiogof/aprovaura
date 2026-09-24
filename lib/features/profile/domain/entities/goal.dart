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
      AppLanguage.spanish => 'ENEM',
    },
    Goal.vestibular => switch (language) {
      AppLanguage.portuguese => 'Vestibular',
      AppLanguage.english => 'College entrance exam',
      AppLanguage.spanish => 'Examen de admisión',
    },
    Goal.concurso => switch (language) {
      AppLanguage.portuguese => 'Concurso',
      AppLanguage.english => 'Civil service exam',
      AppLanguage.spanish => 'Oposición',
    },
    Goal.escola => switch (language) {
      AppLanguage.portuguese => 'Escola',
      AppLanguage.english => 'School',
      AppLanguage.spanish => 'Escuela',
    },
    Goal.contaPropria => switch (language) {
      AppLanguage.portuguese => 'Estudar por conta própria',
      AppLanguage.english => 'Self-study',
      AppLanguage.spanish => 'Estudiar por mi cuenta',
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
