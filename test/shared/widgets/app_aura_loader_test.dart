import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/shared/widgets/app_aura_loader.dart';
import 'package:aura/shared/widgets/app_button.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    bool reducedMotion = false,
    ThemeData? theme,
    AppLanguage language = AppLanguage.portuguese,
  }) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      BlocProvider<LocaleCubit>(
        create: (_) => LocaleCubit()..emit(language),
        child: MaterialApp(
          theme: theme ?? AppTheme.light,
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(disableAnimations: reducedMotion),
              child: Scaffold(body: Center(child: child)),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group(AppAuraLoader, () {
    testWidgets('renders at its named sizes, in both themes', (tester) async {
      for (final theme in [AppTheme.light, AppTheme.dark]) {
        for (final (loader, size) in [
          (const AppAuraLoader.small(), AppAuraLoader.smallSize),
          (const AppAuraLoader.medium(), AppAuraLoader.mediumSize),
          (const AppAuraLoader.large(), AppAuraLoader.largeSize),
        ]) {
          await pump(tester, loader, theme: theme);
          expect(tester.getSize(find.byType(AppAuraLoader)), Size(size, size));
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('keeps moving on its own', (tester) async {
      await pump(tester, const AppAuraLoader.medium());
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.binding.hasScheduledFrame, isTrue);
    });

    testWidgets('reduced motion: a still composition, nothing running', (
      tester,
    ) async {
      await pump(tester, const AppAuraLoader.medium(), reducedMotion: true);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AppAuraLoader), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('leaves no ticker behind when removed', (tester) async {
      await pump(tester, const AppAuraLoader.large());
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      // A leaked ticker would keep scheduling frames (and the test
      // framework would flag an active ticker on teardown).
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('says "Carregando" in the app language, or the given line', (
      tester,
    ) async {
      await pump(tester, const AppAuraLoader.medium());
      expect(find.bySemanticsLabel('Carregando'), findsOneWidget);

      // A fresh tree: the provider above would otherwise be reused.
      await tester.pumpWidget(const SizedBox());
      await pump(
        tester,
        const AppAuraLoader.medium(),
        language: AppLanguage.english,
      );
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);

      await pump(
        tester,
        const AppAuraLoader.medium(semanticsLabel: 'Saindo...'),
      );
      expect(find.bySemanticsLabel('Saindo...'), findsOneWidget);
    });
  });

  testWidgets('a loading button keeps its exact size, with the loader inside', (
    tester,
  ) async {
    Widget button({required bool loading}) => SizedBox(
      width: 240,
      child: AppButton(label: 'Enviar', isLoading: loading, onPressed: () {}),
    );
    await pump(tester, button(loading: false));
    final idle = tester.getSize(find.byType(ElevatedButton));

    await pump(tester, button(loading: true));
    expect(tester.getSize(find.byType(ElevatedButton)), idle);
    expect(find.byType(AppAuraLoader), findsOneWidget);
    expect(find.text('Enviar'), findsNothing);
  });
}
