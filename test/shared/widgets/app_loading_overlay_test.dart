import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/shared/widgets/app_aura_loader.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/loading/app_blocking_loading_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
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

      expect(find.byType(AppAuraLoader), findsNothing);
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

      expect(find.byType(AppAuraLoader), findsOneWidget);
      await tester.tap(find.text('behind the overlay'), warnIfMissed: false);
      await tester.pump();

      // The ModalBarrier absorbed it -- nothing behind reacted.
      expect(find.byType(ModalBarrier), findsWidgets);

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('shows the action short line under the loader', (tester) async {
      final loading = await pumpHost(tester);
      final completer = Completer<void>();
      unawaited(loading.run(() => completer.future, message: 'Saindo...'));
      await tester.pump();

      expect(find.byType(AppAuraLoader), findsOneWidget);
      expect(find.text('Saindo...'), findsOneWidget);
      // Said once, as the overlay's label -- not again per element.
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Saindo...',
        ),
        findsOneWidget,
      );

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('without a message, only the loader', (tester) async {
      final loading = await pumpHost(tester);
      final completer = Completer<void>();
      unawaited(loading.run(() => completer.future));
      await tester.pump();

      expect(find.byType(AppAuraLoader), findsOneWidget);
      expect(
        find.byType(Text).evaluate().where((e) {
          final w = e.widget as Text;
          return w.data != 'behind the overlay';
        }),
        isEmpty,
      );

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
      expect(find.byType(AppAuraLoader), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();
    });
  });

  /// What a screen reader can actually reach: the published semantics
  /// tree, walked from the app's root node.
  bool reachable(WidgetTester tester, String label) {
    var found = false;
    void visit(SemanticsNode node) {
      if (node.label.contains(label)) found = true;
      node.visitChildren((child) {
        visit(child);
        return true;
      });
    }

    visit(tester.getSemantics(find.byType(MaterialApp)));
    return found;
  }

  group(AppLoadingOverlayHost, () {
    testWidgets('while up, the app behind is out of reach for screen readers '
        'and keyboard focus; afterwards it is back, state intact', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final loading = AppBlockingLoadingCubit();
      addTearDown(loading.close);
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<LocaleCubit>(create: (_) => _TestLocaleCubit()),
            BlocProvider<AppBlockingLoadingCubit>.value(value: loading),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => AppLoadingOverlayHost(child: child),
            home: Scaffold(
              body: Column(
                children: [
                  TextButton(
                    focusNode: focus,
                    onPressed: () {},
                    child: const Text('ação atrás'),
                  ),
                  const SizedBox(width: 200, child: TextField()),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'digitado antes');
      expect(reachable(tester, 'ação atrás'), isTrue);

      final completer = Completer<void>();
      unawaited(loading.run(() => completer.future, message: 'Saindo...'));
      await tester.pump(const Duration(milliseconds: 200));

      // Not listed, not focusable -- only the overlay's own line is.
      expect(reachable(tester, 'ação atrás'), isFalse);
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isFalse);
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Saindo...',
        ),
        findsOneWidget,
      );

      completer.complete();
      await tester.pump(const Duration(milliseconds: 400));

      expect(reachable(tester, 'ação atrás'), isTrue);
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      // The screen behind was never rebuilt from scratch.
      expect(find.text('digitado antes'), findsOneWidget);
      semantics.dispose();
    });
  });
}
