import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/shared/widgets/app_button.dart';
import 'package:aura/shared/widgets/app_loading_indicator.dart';

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
      expect(find.byType(AppLoadingIndicator), findsNothing);
      await tester.tap(find.byType(AppButton));
      expect(taps, 1);
    });

    testWidgets('shows the spinner and refuses taps while loading', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(host(isLoading: true, onPressed: () => taps++));

      expect(find.text('Entrar'), findsNothing);
      expect(find.byType(AppLoadingIndicator), findsOneWidget);
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
  });
}
