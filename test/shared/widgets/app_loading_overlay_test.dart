import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/loading/app_blocking_loading_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/shared/widgets/app_loading_indicator.dart';
import 'package:aura/shared/widgets/app_loading_overlay.dart';

class _TestLocaleCubit extends LocaleCubit {
  _TestLocaleCubit() {
    emit(AppLanguage.portuguese);
  }
}

void main() {
  Future<AppBlockingLoadingCubit> pumpHost(
    WidgetTester tester, {
    bool reducedMotion = false,
  }) async {
    final loadingCubit = AppBlockingLoadingCubit();
    var tapped = 0;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reducedMotion),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<LocaleCubit>(create: (_) => _TestLocaleCubit()),
            BlocProvider<AppBlockingLoadingCubit>.value(value: loadingCubit),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Stack(
                children: [
                  Center(
                    child: TextButton(
                      onPressed: () => tapped++,
                      child: const Text('behind the overlay'),
                    ),
                  ),
                  const AppLoadingOverlay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    addTearDown(loadingCubit.close);
    return loadingCubit;
  }

  group(AppLoadingOverlay, () {
    testWidgets('invisible and non-blocking when nothing is loading', (
      tester,
    ) async {
      await pumpHost(tester);
      await tester.pumpAndSettle();

      expect(find.byType(AppLoadingIndicator), findsNothing);
      await tester.tap(find.text('behind the overlay'));
      // No exception, no barrier in the way.
      expect(tester.takeException(), isNull);
    });

    testWidgets('blocks taps on whatever is behind it while visible', (
      tester,
    ) async {
      final loading = await pumpHost(tester);
      final completer = Completer<void>();
      unawaited(loading.run(() => completer.future));
      await tester.pump();

      expect(find.byType(AppLoadingIndicator), findsOneWidget);
      await tester.tap(find.text('behind the overlay'), warnIfMissed: false);
      await tester.pump();

      // The ModalBarrier absorbed it -- nothing behind reacted.
      expect(find.byType(ModalBarrier), findsWidgets);

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('shows the message when the operation has one', (tester) async {
      final loading = await pumpHost(tester);
      final completer = Completer<void>();
      unawaited(loading.run(() => completer.future, message: 'Saindo...'));
      await tester.pump();

      expect(find.text('Saindo...'), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('fades in immediately, no delay before the first frame', (
      tester,
    ) async {
      final loading = await pumpHost(tester);
      final completer = Completer<void>();
      unawaited(loading.run(() => completer.future));
      await tester.pump();

      // Already in the tree on the very first pump after the state change.
      expect(find.byType(AppLoadingIndicator), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();
    });
  });
}
