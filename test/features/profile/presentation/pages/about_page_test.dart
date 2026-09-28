import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/config/app_info.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/profile/presentation/pages/about_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpAbout(WidgetTester tester, AppLanguage language) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => LocaleCubit()..emit(language),
        child: MaterialApp(theme: AppTheme.light, home: const AboutPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists the privacy policy -- the stores require it to be '
      'reachable from inside the app', (tester) async {
    await pumpAbout(tester, AppLanguage.portuguese);
    expect(find.text('Política de Privacidade'), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);
  });

  testWidgets('in English', (tester) async {
    await pumpAbout(tester, AppLanguage.english);
    expect(find.text('Privacy Policy'), findsOneWidget);
  });

  testWidgets('in Spanish', (tester) async {
    await pumpAbout(tester, AppLanguage.spanish);
    expect(find.text('Política de Privacidad'), findsOneWidget);
  });

  test('points at the published policy page', () {
    expect(
      AppInfo.privacyPolicyUrl,
      'https://lucksrei.com/projects/aura/privacy/',
    );
  });
}
