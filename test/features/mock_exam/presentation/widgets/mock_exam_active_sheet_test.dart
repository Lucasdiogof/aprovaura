import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/loading/app_blocking_loading_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_stage.dart';
import 'package:aura/features/mock_exam/domain/entities/active_mock_exam.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/presentation/widgets/mock_exam_active_sheet.dart';
import 'package:aura/shared/widgets/app_loading_overlay.dart';

/// "Descartar e montar outro": remote and destructive, so it goes through
/// the app's blocking overlay -- and the sheet only closes once the server
/// confirmed.
void main() {
  late AppBlockingLoadingCubit loading;
  late List<String> discardCalls;
  late Completer<MockExamFailure?> discard;
  MockExamActiveChoice? choice;
  var sheetReturned = false;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    loading = AppBlockingLoadingCubit();
    discardCalls = [];
    choice = null;
    sheetReturned = false;
  });

  tearDown(() => loading.close());

  /// Explicit time, never pumpAndSettle: an Aura loader on screen keeps
  /// moving, so the tree never "settles" while one is up.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> openSheet(WidgetTester tester) async {
    // Created here, inside the test's fake-async zone: a completer made in
    // setUp would schedule its completion outside it, and no pump would
    // ever deliver it.
    discard = Completer();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<LocaleCubit>(
            create: (_) => LocaleCubit()..emit(AppLanguage.portuguese),
          ),
          BlocProvider<AppBlockingLoadingCubit>.value(value: loading),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) =>
              Stack(children: [child!, const AppLoadingOverlay()]),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    choice = await showMockExamActiveSheet(
                      context,
                      active: const ActiveMockExam(
                        id: 'e1',
                        questionCount: 10,
                        answeredCount: 4,
                      ),
                      language: AppLanguage.portuguese,
                      onDiscard: (id) {
                        discardCalls.add(id);
                        return discard.future;
                      },
                    );
                    sheetReturned = true;
                  },
                  child: const Text('montar simulado'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('montar simulado'));
    await settle(tester);
  }

  testWidgets('discarding: the overlay at once, with its line; one call '
      'only; back does not close anything', (tester) async {
    await openSheet(tester);
    await tester.tap(find.text('Descartar e montar outro'));
    await tester.pump();

    expect(loading.state.isVisible, isTrue);
    expect(find.text('Descartando simulado...'), findsOneWidget);

    await tester.tap(
      find.text('Descartar e montar outro'),
      warnIfMissed: false,
    );
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(discardCalls, ['e1']);
    expect(sheetReturned, isFalse);

    discard.complete(null);
    await settle(tester);
  });

  testWidgets('success: the overlay leaves and the sheet closes as '
      '"discarded" -- no Aurudo', (tester) async {
    await openSheet(tester);
    await tester.tap(find.text('Descartar e montar outro'));
    await tester.pump();
    discard.complete(null);
    await settle(tester);

    expect(loading.state.isVisible, isFalse);
    expect(sheetReturned, isTrue);
    expect(choice, MockExamActiveChoice.discarded);
    expect(find.byType(AurudoReactionStage), findsNothing);
  });

  testWidgets('failure: the overlay leaves, the sheet stays with the reason, '
      'and discarding again works', (tester) async {
    await openSheet(tester);
    await tester.tap(find.text('Descartar e montar outro'));
    await tester.pump();
    discard.complete(MockExamFailure(MockExamFailureKind.network));
    await settle(tester);

    expect(loading.state.isVisible, isFalse);
    expect(sheetReturned, isFalse);
    expect(find.text('Descartar e montar outro'), findsOneWidget);

    discard = Completer()..complete(null);
    await tester.tap(find.text('Descartar e montar outro'));
    await settle(tester);
    expect(discardCalls, ['e1', 'e1']);
    expect(choice, MockExamActiveChoice.discarded);
  });
}
