import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/pages/essay_editor_page.dart';
import 'package:aura/features/essay/presentation/pages/essay_theme_page.dart';

import '../../../../helpers/pump_app.dart';

class _MockEssayRepository extends Mock implements EssayRepository {}

const _theme = EssayTheme(
  id: 't1',
  title: 'Desinformação e o direito de saber',
  description: 'Quando a mentira circula mais rápido que a correção.',
  prompt: 'Redija um texto dissertativo-argumentativo sobre o tema.',
  origin: EssayThemeOrigin.practice(),
  supportingTexts: [
    EssaySupportingText(
      title: 'Texto I',
      body:
          'Sete em cada dez brasileiros dizem já ter acreditado numa '
          'notícia falsa.',
      source: 'Pesquisa fictícia, 2026',
    ),
    EssaySupportingText(body: 'Um trecho sem título e sem fonte.'),
  ],
);

const _fresh = EssayThemeSummary(
  id: 't1',
  title: 'Desinformação e o direito de saber',
  origin: EssayThemeOrigin.practice(),
  hasDraft: false,
  attemptCount: 0,
);

const _withDraft = EssayThemeSummary(
  id: 't1',
  title: 'Desinformação e o direito de saber',
  origin: EssayThemeOrigin.practice(),
  hasDraft: true,
  attemptCount: 0,
);

const _graded = EssayThemeSummary(
  id: 't1',
  title: 'Desinformação e o direito de saber',
  origin: EssayThemeOrigin.practice(),
  hasDraft: false,
  attemptCount: 2,
  lastStatus: EssaySubmissionStatus.evaluated,
  lastScore: 880,
);

void main() {
  late EssayRepository repository;

  setUp(() async {
    await sl.reset();
    repository = _MockEssayRepository();
    sl.registerLazySingleton<EssayRepository>(() => repository);
    when(
      () => repository.getTheme('t1'),
    ).thenAnswer((_) async => const Success(_theme));
  });

  group(EssayThemePage, () {
    testWidgets('shows the prompt and every motivating text', (tester) async {
      await tester.pumpApp(const EssayThemePage(summary: _fresh));
      await tester.pumpAndSettle();

      expect(find.text(_theme.title), findsOneWidget);
      expect(find.text('PROPOSTA DE REDAÇÃO'), findsOneWidget);
      expect(find.text('TEXTOS MOTIVADORES'), findsOneWidget);
      expect(find.text(_theme.prompt), findsOneWidget);
      expect(find.text('Texto I'), findsOneWidget);
      expect(find.text('Pesquisa fictícia, 2026'), findsOneWidget);
      // The untitled, sourceless excerpt still renders its body.
      expect(find.text('Um trecho sem título e sem fonte.'), findsOneWidget);
    });

    testWidgets('a theme never tried offers to start and shows no stats', (
      tester,
    ) async {
      await tester.pumpApp(const EssayThemePage(summary: _fresh));
      await tester.pumpAndSettle();

      expect(find.text('Começar redação'), findsOneWidget);
      expect(find.text('Última nota'), findsNothing);
      expect(find.text('Tentativas'), findsNothing);
    });

    testWidgets('a draft turns the CTA into continuing', (tester) async {
      await tester.pumpApp(const EssayThemePage(summary: _withDraft));
      await tester.pumpAndSettle();

      expect(find.text('Continuar redação'), findsOneWidget);
    });

    testWidgets('a graded theme offers a new attempt and shows the score', (
      tester,
    ) async {
      await tester.pumpApp(const EssayThemePage(summary: _graded));
      await tester.pumpAndSettle();

      expect(find.text('Última nota'), findsOneWidget);
      expect(find.text('880'), findsOneWidget);
      expect(find.text('Tentativas'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // The CTA sits past the prompt and the motivating texts, so the list
      // has to be scrolled before it is even built.
      await tester.scrollUntilVisible(find.text('Fazer nova redação'), 300);
      expect(find.text('Fazer nova redação'), findsOneWidget);
    });

    testWidgets('the CTA opens the editor placeholder', (tester) async {
      await tester.pumpApp(const EssayThemePage(summary: _fresh));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Começar redação'));
      await tester.tap(find.text('Começar redação'));
      await tester.pumpAndSettle();

      expect(find.byType(EssayEditorPage), findsOneWidget);
      // No text field yet: the placeholder must not invite writing that
      // nothing can save.
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('a failure offers to try again', (tester) async {
      when(
        () => repository.getTheme('t1'),
      ).thenAnswer((_) async => Error(ServerFailure()));
      await tester.pumpApp(const EssayThemePage(summary: _fresh));
      await tester.pumpAndSettle();

      expect(find.textContaining('Não conseguimos carregar'), findsOneWidget);

      when(
        () => repository.getTheme('t1'),
      ).thenAnswer((_) async => const Success(_theme));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text(_theme.prompt), findsOneWidget);
    });

    testWidgets('fits a 360px screen without overflowing', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpApp(const EssayThemePage(summary: _graded));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
