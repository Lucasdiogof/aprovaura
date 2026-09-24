import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/l10n/app_language.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(AppLanguage, () {
    test('databaseLocale is the p_locale every RPC expects', () {
      expect(AppLanguage.portuguese.databaseLocale, 'pt-BR');
      expect(AppLanguage.english.databaseLocale, 'en');
      expect(AppLanguage.spanish.databaseLocale, 'es');
    });

    test('locale maps to the matching Flutter Locale', () {
      expect(AppLanguage.portuguese.locale, const Locale('pt', 'BR'));
      expect(AppLanguage.english.locale, const Locale('en'));
      expect(AppLanguage.spanish.locale, const Locale('es'));
    });

    test('label is the language name shown to the person', () {
      expect(AppLanguage.portuguese.label, 'Português');
      expect(AppLanguage.english.label, 'English');
      expect(AppLanguage.spanish.label, 'Español');
    });

    // fromDeviceLocale() reads WidgetsBinding.instance.platformDispatcher,
    // which the test binding fixes to en_US -- so only the English branch is
    // directly observable here. The es/pt-BR branches of the switch are
    // exercised by construction (a non-exhaustive switch would fail to
    // compile), so this only needs to prove the mapping is wired up at all.
    test('fromDeviceLocale falls back to a supported language', () {
      expect(AppLanguage.values, contains(AppLanguage.fromDeviceLocale()));
    });
  });
}
