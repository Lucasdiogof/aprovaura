import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/profile/presentation/pages/language_settings_page.dart';

import '../../../../helpers/pump_app.dart';

/// The three languages the app supports, and the runtime switch itself --
/// the strings for each screen are each l10n class's own job, not this
/// page's.
void main() {
  group(LanguageSettingsPage, () {
    testWidgets('shows all three languages, current one selected', (
      tester,
    ) async {
      await tester.pumpApp(const LanguageSettingsPage());
      await tester.pumpAndSettle();

      expect(find.text('Português'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
    });

    testWidgets('picking Español switches the app language at runtime', (
      tester,
    ) async {
      await tester.pumpApp(const LanguageSettingsPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();

      final cubit = tester
          .element(find.byType(LanguageSettingsPage))
          .read<LocaleCubit>();
      expect(cubit.state, AppLanguage.spanish);
      // The page itself re-renders in the language just picked -- no
      // restart, no separate confirmation step. ("Idioma" is the title in
      // both Portuguese and Spanish, so the subtitle is what proves it.)
      expect(find.text('Elige el idioma de la app'), findsOneWidget);
    });

    testWidgets('picking English then Português switches back and forth', (
      tester,
    ) async {
      await tester.pumpApp(const LanguageSettingsPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      final cubit = tester
          .element(find.byType(LanguageSettingsPage))
          .read<LocaleCubit>();
      expect(cubit.state, AppLanguage.english);

      await tester.tap(find.text('Português'));
      await tester.pumpAndSettle();
      expect(cubit.state, AppLanguage.portuguese);
    });
  });
}
