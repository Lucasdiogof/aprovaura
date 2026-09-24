import 'package:flutter/widgets.dart';

enum AppLanguage {
  portuguese,
  english,
  spanish;

  static AppLanguage fromDeviceLocale() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return switch (deviceLocale.languageCode) {
      'en' => AppLanguage.english,
      'es' => AppLanguage.spanish,
      _ => AppLanguage.portuguese,
    };
  }

  Locale get locale => switch (this) {
    AppLanguage.portuguese => const Locale('pt', 'BR'),
    AppLanguage.english => const Locale('en'),
    AppLanguage.spanish => const Locale('es'),
  };

  String get label => switch (this) {
    AppLanguage.portuguese => 'Português',
    AppLanguage.english => 'English',
    AppLanguage.spanish => 'Español',
  };

  String get appName => 'Aprovaura';

  /// The `p_locale` value every locale-aware RPC expects (see
  /// supabase/i18n_translations_schema.sql). Centralized here so no
  /// repository has to know the app's language enum shape -- one place maps
  /// UI language to database locale.
  String get databaseLocale => switch (this) {
    AppLanguage.portuguese => 'pt-BR',
    AppLanguage.english => 'en',
    AppLanguage.spanish => 'es',
  };
}
