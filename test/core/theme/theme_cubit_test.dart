import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/theme/theme_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(ThemeCubit, () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('starts in ${ThemeMode.system} before storage loads', () async {
      final cubit = ThemeCubit();
      expect(cubit.state, ThemeMode.system);
      await pumpEventQueue();
      await cubit.close();
    });

    test('emits the saved mode once storage finishes loading', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final cubit = ThemeCubit();

      await pumpEventQueue();

      expect(cubit.state, ThemeMode.dark);
      await cubit.close();
    });

    blocTest<ThemeCubit, ThemeMode>(
      'setMode emits the new $ThemeMode',
      build: ThemeCubit.new,
      act: (cubit) => cubit.setMode(ThemeMode.light),
      expect: () => [ThemeMode.light],
    );

    test('setMode persists the mode for the next load', () async {
      final cubit = ThemeCubit();
      await cubit.setMode(ThemeMode.dark);
      await cubit.close();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'dark');
    });
  });
}
