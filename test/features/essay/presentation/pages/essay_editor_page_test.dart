import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_draft.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/cubit/essay_editor_cubit.dart';
import 'package:aura/features/essay/presentation/pages/essay_editor_page.dart';

import '../../../../helpers/pump_app.dart';

class _MockEssayRepository extends Mock implements EssayRepository {}

const _theme = EssayTheme(
  id: 't1',
  title: 'Desinformação e o direito de saber',
  prompt: 'Redija um texto dissertativo-argumentativo sobre o tema.',
  origin: EssayThemeOrigin.practice(),
  supportingTexts: [
    EssaySupportingText(
      title: 'Texto I',
      body: 'Um trecho de apoio.',
      source: 'Fonte fictícia, 2026',
    ),
  ],
);

/// Past the debounce, so the autosave has really fired.
Future<void> _settleAutosave(WidgetTester tester) async {
  await tester.pump(
    EssayEditorCubit.debounce + const Duration(milliseconds: 100),
  );
  await tester.pumpAndSettle();
}

void main() {
  late EssayRepository repository;

  setUp(() async {
    await sl.reset();
    repository = _MockEssayRepository();
    sl.registerLazySingleton<EssayRepository>(() => repository);
    when(
      () => repository.getDraft('t1'),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => repository.saveDraft(any(), any()),
    ).thenAnswer((_) async => Success(DateTime(2026)));
    when(
      () => repository.deleteDraft(any()),
    ).thenAnswer((_) async => const Success(null));
  });

  group(EssayEditorPage, () {
    testWidgets('opens empty when there is no draft', (tester) async {
      await tester.pumpApp(const EssayEditorPage(theme: _theme));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text('0 palavras'), findsOneWidget);
    });

    testWidgets('restores the saved draft into the field', (tester) async {
      when(() => repository.getDraft('t1')).thenAnswer(
        (_) async => Success(
          EssayDraft(body: 'Três palavras aqui', updatedAt: DateTime(2026)),
        ),
      );
      await tester.pumpApp(const EssayEditorPage(theme: _theme));
      await tester.pumpAndSettle();

      expect(find.text('Três palavras aqui'), findsOneWidget);
      expect(find.text('3 palavras'), findsOneWidget);
    });

    testWidgets('typing autosaves and reports it', (tester) async {
      await tester.pumpApp(const EssayEditorPage(theme: _theme));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Primeiro parágrafo');
      await tester.pump();
      expect(find.text('Salvando...'), findsOneWidget);

      await _settleAutosave(tester);
      expect(find.text('Salvo'), findsOneWidget);
      verify(() => repository.saveDraft('t1', 'Primeiro parágrafo')).called(1);
    });

    testWidgets('a failed autosave keeps the text on screen', (tester) async {
      when(
        () => repository.saveDraft(any(), any()),
      ).thenAnswer((_) async => Error(ServerFailure()));

      await tester.pumpApp(const EssayEditorPage(theme: _theme));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Texto que não salvou');
      await _settleAutosave(tester);

      expect(find.text('Não foi possível salvar'), findsOneWidget);
      // The whole point: the words are still there.
      expect(find.text('Texto que não salvou'), findsOneWidget);
    });

    testWidgets('the failed status offers a retry that works', (tester) async {
      when(
        () => repository.saveDraft(any(), any()),
      ).thenAnswer((_) async => Error(ServerFailure()));

      await tester.pumpApp(const EssayEditorPage(theme: _theme));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Texto');
      await _settleAutosave(tester);

      when(
        () => repository.saveDraft(any(), any()),
      ).thenAnswer((_) async => Success(DateTime(2026)));
      await tester.tap(find.text('Tentar de novo'));
      await tester.pumpAndSettle();

      expect(find.text('Salvo'), findsOneWidget);
    });

    testWidgets('autosave does not move the cursor', (tester) async {
      await tester.pumpApp(const EssayEditorPage(theme: _theme));
      await tester.pumpAndSettle();

      final field = find.byType(TextField);
      await tester.enterText(field, 'Um texto qualquer');
      final controller = tester.widget<TextField>(field).controller!;
      // Put the caret in the middle, as if fixing a word mid-sentence.
      controller.selection = const TextSelection.collapsed(offset: 3);
      await _settleAutosave(tester);

      expect(controller.selection.baseOffset, 3);
      // And the controller itself survived the save: same instance.
      expect(
        identical(tester.widget<TextField>(field).controller, controller),
        isTrue,
      );
    });

    testWidgets('"Ver proposta" shows the prompt without leaving', (
      tester,
    ) async {
      await tester.pumpApp(const EssayEditorPage(theme: _theme));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver proposta'));
      await tester.pumpAndSettle();

      expect(find.text(_theme.prompt), findsOneWidget);
      expect(find.text('Texto I'), findsOneWidget);
      expect(find.text('Fonte fictícia, 2026'), findsOneWidget);
      // Still on the editor, behind the sheet.
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('"Salvar rascunho" flushes and confirms', (tester) async {
      await tester.pumpApp(const EssayEditorPage(theme: _theme));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Texto manual');

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar rascunho'));
      await tester.pumpAndSettle();

      verify(() => repository.saveDraft('t1', 'Texto manual')).called(1);
      expect(find.text('Rascunho salvo.'), findsOneWidget);
    });

    testWidgets('deleting is only offered when a draft exists', (tester) async {
      await tester.pumpApp(const EssayEditorPage(theme: _theme));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Apagar rascunho'), findsNothing);
    });

    testWidgets('deleting clears the editor after the server confirms', (
      tester,
    ) async {
      when(() => repository.getDraft('t1')).thenAnswer(
        (_) async => Success(
          EssayDraft(body: 'Texto antigo', updatedAt: DateTime(2026)),
        ),
      );
      await tester.pumpApp(const EssayEditorPage(theme: _theme));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apagar rascunho'));
      await tester.pumpAndSettle();

      expect(find.text('Apagar rascunho?'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Apagar rascunho'));
      await tester.pumpAndSettle();

      expect(find.text('Texto antigo'), findsNothing);
      expect(find.text('0 palavras'), findsOneWidget);
      verify(() => repository.deleteDraft('t1')).called(1);
    });

    testWidgets('cancelling the delete keeps the text', (tester) async {
      when(() => repository.getDraft('t1')).thenAnswer(
        (_) async => Success(
          EssayDraft(body: 'Texto antigo', updatedAt: DateTime(2026)),
        ),
      );
      await tester.pumpApp(const EssayEditorPage(theme: _theme));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apagar rascunho'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Texto antigo'), findsOneWidget);
      verifyNever(() => repository.deleteDraft(any()));
    });

    testWidgets('a failed delete keeps the text and says so', (tester) async {
      when(() => repository.getDraft('t1')).thenAnswer(
        (_) async => Success(
          EssayDraft(body: 'Texto antigo', updatedAt: DateTime(2026)),
        ),
      );
      when(
        () => repository.deleteDraft(any()),
      ).thenAnswer((_) async => Error(ServerFailure()));

      await tester.pumpApp(const EssayEditorPage(theme: _theme));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apagar rascunho'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Apagar rascunho'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Seu texto continua aqui'), findsOneWidget);
      await tester.tap(find.text('Entendi'));
      await tester.pumpAndSettle();
      expect(find.text('Texto antigo'), findsOneWidget);
    });

    testWidgets('leaving with everything saved just leaves', (tester) async {
      await tester.pumpApp(const _EditorHost());
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(EssayEditorPage), findsNothing);
      verifyNever(() => repository.saveDraft(any(), any()));
    });

    testWidgets('leaving with a pending change saves it first', (tester) async {
      await tester.pumpApp(const _EditorHost());
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      // Types and leaves immediately, before the debounce would fire.
      await tester.enterText(find.byType(TextField), 'Texto de última hora');
      await tester.pageBack();
      await tester.pumpAndSettle();

      verify(
        () => repository.saveDraft('t1', 'Texto de última hora'),
      ).called(1);
      expect(find.byType(EssayEditorPage), findsNothing);
    });

    testWidgets('leaving when the save fails asks instead of pretending', (
      tester,
    ) async {
      when(
        () => repository.saveDraft(any(), any()),
      ).thenAnswer((_) async => Error(ServerFailure()));

      await tester.pumpApp(const _EditorHost());
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Texto em risco');
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível salvar sua redação'), findsOneWidget);
      // Still on the editor: nothing was lost behind the person's back.
      expect(find.byType(EssayEditorPage), findsOneWidget);

      // Retrying from the sheet, now that the server answers, leaves.
      when(
        () => repository.saveDraft(any(), any()),
      ).thenAnswer((_) async => Success(DateTime(2026)));
      await tester.tap(find.text('Tentar salvar novamente'));
      await tester.pumpAndSettle();

      expect(find.byType(EssayEditorPage), findsNothing);
    });

    testWidgets('"Sair mesmo assim" leaves with the text still unsaved', (
      tester,
    ) async {
      when(
        () => repository.saveDraft(any(), any()),
      ).thenAnswer((_) async => Error(ServerFailure()));

      await tester.pumpApp(const _EditorHost());
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Texto em risco');
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sair mesmo assim'));
      await tester.pumpAndSettle();

      expect(find.byType(EssayEditorPage), findsNothing);
    });

    testWidgets('fits a 360px screen and renders on dark', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit(),
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const EssayEditorPage(theme: _theme),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Hosts the editor behind a route, so leaving it can actually be tested.
class _EditorHost extends StatelessWidget {
  const _EditorHost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EssayEditorPage(theme: _theme),
              ),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
  }
}
