import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/entities/essay_evaluation.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/pages/essay_editor_page.dart';
import 'package:aura/features/essay/presentation/pages/essay_submission_page.dart';
import 'package:aura/features/essay/presentation/pages/essay_theme_page.dart';

import '../../../helpers/pump_app.dart';

class _MockEssayRepository extends Mock implements EssayRepository {}

const _theme = EssayTheme(
  id: 't1',
  title: 'Desinformação e o direito de saber',
  description: 'Quando a mentira circula mais rápido que a correção.',
  prompt: 'Redija um texto dissertativo-argumentativo sobre o tema.',
  origin: EssayThemeOrigin.practice(),
  supportingTexts: [EssaySupportingText(body: 'Um trecho motivador.')],
);

const _summary = EssayThemeSummary(
  id: 't1',
  title: 'Desinformação e o direito de saber',
  origin: EssayThemeOrigin.practice(),
  hasDraft: false,
  attemptCount: 2,
  lastStatus: EssaySubmissionStatus.evaluated,
  lastScore: 880,
);

final _older = EssayAttempt(
  id: 's1',
  status: EssaySubmissionStatus.evaluated,
  wordCount: 280,
  submittedAt: DateTime(2026, 9, 18),
  totalScore: 880,
  evaluatedAt: DateTime(2026, 9, 18),
);

EssaySubmission _submission(String id) => EssaySubmission(
  id: id,
  themeId: 't1',
  themeTitle: 'Desinformação e o direito de saber',
  body: 'O texto exatamente como foi enviado.',
  wordCount: 280,
  status: EssaySubmissionStatus.evaluated,
  submittedAt: DateTime(2026, 9, 18),
  totalScore: 880,
  evaluatedAt: DateTime(2026, 9, 18),
  evaluation: EssayEvaluation(
    totalScore: 880,
    competencies: [
      for (var i = 1; i <= 5; i++)
        EssayCompetency(key: 'c$i', title: 'Competência $i', score: 176),
    ],
  ),
);

/// The transitions between screens, which each page's own tests cannot
/// see: opening an old attempt out of the history, and starting another
/// essay from a marked one.
void main() {
  late EssayRepository repository;

  setUp(() async {
    await sl.reset();
    repository = _MockEssayRepository();
    sl.registerLazySingleton<EssayRepository>(() => repository);
    when(
      () => repository.getTheme('t1'),
    ).thenAnswer((_) async => const Success(_theme));
    when(
      () => repository.listAttempts('t1'),
    ).thenAnswer((_) async => Success([_older]));
    when(() => repository.getSubmission(any())).thenAnswer((invocation) async {
      return Success(
        _submission(invocation.positionalArguments.first as String),
      );
    });
    when(
      () => repository.getDraft(any()),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => repository.requestEvaluation(any()),
    ).thenAnswer((_) async => const Success(null));
  });

  testWidgets('an old attempt opens read-only from the history', (
    tester,
  ) async {
    await tester.pumpApp(const EssayThemePage(summary: _summary));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('880 pontos'), 300);
    await tester.tap(find.text('880 pontos'));
    await tester.pumpAndSettle();

    expect(find.byType(EssaySubmissionPage), findsOneWidget);
    // The attempt it opened is the one that was tapped, and it is not an
    // editor: a sent essay has nothing to type into.
    expect(find.text('880'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    // Opening a finished attempt must never ask for another marking: that
    // would spend one of the day's three on something already done.
    verifyNever(() => repository.requestEvaluation(any()));
  });

  testWidgets('another go at the theme opens an empty editor', (tester) async {
    await tester.pumpApp(const EssaySubmissionPage(submissionId: 's1'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Fazer nova redação'),
      300,
      // The page's own list: the sent text has a scroll view of its own.
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Fazer nova redação'));
    await tester.pumpAndSettle();

    // A new attempt starts from the theme, in a fresh editor -- the marked
    // one is untouched behind it.
    expect(find.byType(EssayEditorPage), findsOneWidget);
    verify(() => repository.getTheme('t1')).called(1);
    verify(() => repository.getDraft('t1')).called(1);
    verifyNever(() => repository.deleteDraft(any()));
    verifyNever(
      () => repository.submitDraft(
        themeId: any(named: 'themeId'),
        clientRequestId: any(named: 'clientRequestId'),
      ),
    );
  });
}
