import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/shared/widgets/app_aura_loader.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/shared/widgets/app_button.dart';

void main() {
  Widget host({required bool isLoading, required VoidCallback onPressed}) =>
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppButton(
            label: 'Entrar',
            isLoading: isLoading,
            onPressed: onPressed,
          ),
        ),
      );

  group(AppButton, () {
    testWidgets('shows its label and responds to taps normally', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(host(isLoading: false, onPressed: () => taps++));

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.byType(AppAuraLoader), findsNothing);
      await tester.tap(find.byType(AppButton));
      expect(taps, 1);
    });

    testWidgets('shows the spinner and refuses taps while loading', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(host(isLoading: true, onPressed: () => taps++));

      expect(find.text('Entrar'), findsNothing);
      expect(find.byType(AppAuraLoader), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(taps, 0);
    });

    testWidgets('the button keeps the same height in both states', (
      tester,
    ) async {
      await tester.pumpWidget(host(isLoading: false, onPressed: () {}));
      final idleHeight = tester.getSize(find.byType(ElevatedButton)).height;

      await tester.pumpWidget(host(isLoading: true, onPressed: () {}));
      final loadingHeight = tester.getSize(find.byType(ElevatedButton)).height;

      expect(loadingHeight, idleHeight);
    });

    for (final (name, theme, colors) in [
      ('light', AppTheme.light, AppColors.light),
      ('dark', AppTheme.dark, AppColors.dark),
    ]) {
      testWidgets('$name: loading keeps the active violet, not the disabled '
          'fade; a really disabled button keeps its disabled look', (
        tester,
      ) async {
        Future<Color?> fillOf({
          required bool isLoading,
          VoidCallback? onPressed,
        }) async {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: AppButton(
                  label: 'Entrar',
                  isLoading: isLoading,
                  onPressed: onPressed,
                ),
              ),
            ),
          );
          await tester.pump();
          return tester
              .widget<Material>(
                find.descendant(
                  of: find.byType(ElevatedButton),
                  matching: find.byType(Material),
                ),
              )
              .color;
        }

        final loading = await fillOf(isLoading: true, onPressed: () {});
        final disabled = await fillOf(isLoading: false);

        expect(
          loading,
          colors.primaryFill.withValues(alpha: AppButton.loadingFillOpacity),
        );
        expect(disabled, colors.primaryFill.withValues(alpha: 0.45));
        expect(loading, isNot(disabled));
      });
    }
  });
}
