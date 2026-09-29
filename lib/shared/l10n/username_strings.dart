import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/profile/presentation/cubit/username_check_state.dart';
import 'package:aura/shared/utils/validators.dart';

/// The username messages, shared by sign-up and "Minha conta" so both say
/// exactly the same thing about the same rule.
class UsernameStrings {
  const UsernameStrings(this.language);

  final AppLanguage language;

  String get required => switch (language) {
    AppLanguage.portuguese => 'Escolha um nome de usuário.',
    AppLanguage.english => 'Choose a username.',
    AppLanguage.spanish => 'Elige un nombre de usuario.',
  };

  String get length => switch (language) {
    AppLanguage.portuguese => 'Use de 3 a 20 caracteres.',
    AppLanguage.english => 'Use 3 to 20 characters.',
    AppLanguage.spanish => 'Usa de 3 a 20 caracteres.',
  };

  String get characters => switch (language) {
    AppLanguage.portuguese =>
      'Use só letras, números, ponto e _ (sem espaços).',
    AppLanguage.english => 'Use only letters, numbers, dots and _ (no spaces).',
    AppLanguage.spanish =>
      'Usa solo letras, números, punto y _ (sin espacios).',
  };

  String get taken => switch (language) {
    AppLanguage.portuguese => 'Esse nome de usuário já está em uso.',
    AppLanguage.english => 'That username is already taken.',
    AppLanguage.spanish => 'Ese nombre de usuario ya está en uso.',
  };

  String get checkFailed => switch (language) {
    AppLanguage.portuguese =>
      'Não deu para verificar o nome de usuário agora. Tente de novo.',
    AppLanguage.english => "Couldn't check the username right now. Try again.",
    AppLanguage.spanish =>
      'No se pudo verificar el nombre de usuario ahora. Inténtalo de nuevo.',
  };

  String get available => switch (language) {
    AppLanguage.portuguese => 'Nome de usuário disponível',
    AppLanguage.english => 'Username available',
    AppLanguage.spanish => 'Nombre de usuario disponible',
  };

  /// The message under the field for [value]: nothing while it is empty
  /// (unless a submit was attempted), the rule it breaks while typing,
  /// then what the database said about it.
  String? errorFor(
    String value,
    UsernameCheckState check, {
    bool submitted = false,
  }) {
    switch (usernameProblem(value)) {
      case UsernameProblem.empty:
        return submitted ? required : null;
      case UsernameProblem.length:
        return length;
      case UsernameProblem.characters:
        return characters;
      case null:
        if (!check.isAbout(value)) return null;
        return switch (check.status) {
          UsernameCheck.taken => taken,
          UsernameCheck.failed => checkFailed,
          _ => null,
        };
    }
  }
}
