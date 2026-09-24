import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(LocaleCubit, () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('starts from the device locale before storage loads', () async {
      final cubit = LocaleCubit();
      expect(cubit.state, AppLanguage.fromDeviceLocale());
      await pumpEventQueue();
      await cubit.close();
    });

    test('emits the saved language once storage finishes loading', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'english'});
      final cubit = LocaleCubit();

      await pumpEventQueue();

      expect(cubit.state, AppLanguage.english);
      await cubit.close();
    });

    test('emits Spanish once storage finishes loading', () async {
      SharedPreferences.setMockInitialValues({'app_language': 'spanish'});
      final cubit = LocaleCubit();

      await pumpEventQueue();

      expect(cubit.state, AppLanguage.spanish);
      await cubit.close();
    });

    test('keeps the device-locale default when nothing is saved', () async {
      final cubit = LocaleCubit();
      final initial = cubit.state;

      await pumpEventQueue();

      expect(cubit.state, initial);
      await cubit.close();
    });

    blocTest<LocaleCubit, AppLanguage>(
      'setLanguage emits the new $AppLanguage',
      build: LocaleCubit.new,
      act: (cubit) => cubit.setLanguage(AppLanguage.english),
      expect: () => [AppLanguage.english],
    );

    blocTest<LocaleCubit, AppLanguage>(
      'setLanguage emits Spanish',
      build: LocaleCubit.new,
      act: (cubit) => cubit.setLanguage(AppLanguage.spanish),
      expect: () => [AppLanguage.spanish],
    );

    test('setLanguage persists the language for the next load', () async {
      final cubit = LocaleCubit();
      await cubit.setLanguage(AppLanguage.english);
      await cubit.close();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'english');
    });

    test('setLanguage persists Spanish for the next load', () async {
      final cubit = LocaleCubit();
      await cubit.setLanguage(AppLanguage.spanish);
      await cubit.close();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'spanish');
    });
  });
}
