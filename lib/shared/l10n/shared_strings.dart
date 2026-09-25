import 'package:aura/core/l10n/app_language.dart';

class SharedStrings {
  const SharedStrings(this.language);

  final AppLanguage language;

  String get errorTitle => switch (language) {
    AppLanguage.portuguese => 'Não foi possível continuar',
    AppLanguage.english => "Couldn't continue",
    AppLanguage.spanish => 'No se pudo continuar',
  };

  String get successTitle => switch (language) {
    AppLanguage.portuguese => 'Tudo certo!',
    AppLanguage.english => 'All set!',
    AppLanguage.spanish => '¡Todo listo!',
  };

  String get infoTitle => switch (language) {
    AppLanguage.portuguese => 'Informação',
    AppLanguage.english => 'Information',
    AppLanguage.spanish => 'Información',
  };

  String get understood => switch (language) {
    AppLanguage.portuguese => 'Entendi',
    AppLanguage.english => 'Got it',
    AppLanguage.spanish => 'Entendido',
  };

  /// Screen-reader fallback for [AppLoadingOverlay] when the operation
  /// behind it didn't pass its own message.
  String get loadingLabel => switch (language) {
    AppLanguage.portuguese => 'Carregando',
    AppLanguage.english => 'Loading',
    AppLanguage.spanish => 'Cargando',
  };
}
