import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/loading/app_blocking_loading_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/aurudo_reaction/data/aurudo_reaction_ledger.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_achievement_overlay.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_stage.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/entities/essay_evaluation.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/essay_failure.dart';
import 'package:aura/features/essay/domain/essay_rules.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/cubit/essay_editor_cubit.dart';
import 'package:aura/features/essay/presentation/pages/essay_editor_page.dart';
import 'package:aura/features/essay/presentation/pages/essay_submission_page.dart';

import '../../../helpers/pump_app.dart';

class _MockEssayRepository extends Mock implements EssayRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

const _theme = EssayTheme(
  id: 't1',
  title: 'Desinformação e o direito de saber',
  prompt: 'Redija um texto dissertativo-argumentativo sobre o tema.',
  origin: EssayThemeOrigin.practice(),
  supportingTexts: [],
);

final _longEnough = List.generate(
  EssayRules.minimumWords,
  (i) => 'palavra${i + 1}',
).join(' ');

EssayEvaluation _evaluation(int total) => EssayEvaluation(
  totalScore: total,
  competencies: [
    for (var i = 1; i <= 5; i++)
      EssayCompetency(
        key: 'c$i',
        title: 'Título da competência $i',
        score: total ~/ 5,
        summary: 'Resumo da competência $i.',
      ),
  ],
  generalFeedback: 'Comentário geral da correção.',
  strengths: const ['Um ponto forte'],
  priorityImprovements: const ['Uma prioridade'],
);

EssaySubmission _submission(EssaySubmissionStatus status, {int? score}) =>
    EssaySubmission(
      id: 's1',
      themeId: 't1',
      themeTitle: 'Desinformação e o direito de saber',
      body: 'O primeiro parágrafo da redação enviada.',
      wordCount: 6,
      status: status,
      submittedAt: DateTime(2026, 9, 24),
      totalScore: score,
      evaluatedAt: score == null ? null : DateTime(2026, 9, 24),
      evaluation: score == null ? null : _evaluation(score),
    );

/// Which official pose file is on screen right now.
bool _showsPose(WidgetTester tester, String pose) => tester
    .widgetList<Image>(find.byType(Image))
    .map((image) => image.image)
    .whereType<AssetImage>()
    .any((image) => image.assetName.contains('aurudo_$pose'));

void main() {
  late EssayRepository repository;
  late AuthRepository auth;
  late SharedPreferences prefs;

  AurudoReactionLedger ledger([String userId = 'user-1']) =>
      AurudoReactionLedger(prefs, userId: userId);

  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = _MockEssayRepository();
    auth = _MockAuthRepository();
    when(
      () => auth.currentUser,
    ).thenReturn(const AppUser(id: 'user-1', email: 'a@b.com'));
    sl.registerLazySingleton<EssayRepository>(() => repository);
    sl.registerLazySingleton<AuthRepository>(() => auth);
    sl.registerSingleton<SharedPreferences>(prefs);
    when(
      () => repository.requestEvaluation(any()),
    ).thenAnswer((_) async => const Success(null));
  });

  void stubSubmission(EssaySubmissionStatus status, {int? score}) {
    when(
      () => repository.getSubmission('s1'),
    ).thenAnswer((_) async => Success(_submission(status, score: score)));
  }

  /// Tall enough for the whole report: a ListView only builds what is on
  /// screen.
  void useTallScreen(WidgetTester tester, {double width = 800}) {
    tester.view.physicalSize = Size(width, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpPage(
    WidgetTester tester, {
    bool justSubmitted = false,
    bool reducedMotion = false,
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      BlocProvider<LocaleCubit>(
        create: (_) => LocaleCubit()..emit(AppLanguage.portuguese),
        child: MaterialApp(
          theme: theme ?? AppTheme.light,
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(disableAnimations: reducedMotion),
              child: EssaySubmissionPage(
                submissionId: 's1',
                justSubmitted: justSubmitted,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  /// Past the whole scene and the report's fade.
  Future<void> finishScene(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('sending', () {
    setUp(() {
      when(
        () => repository.getDraft('t1'),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => repository.saveDraft(any(), any()),
      ).thenAnswer((_) async => Success(DateTime(2026)));
      stubSubmission(EssaySubmissionStatus.submitted);
    });

    Future<AppBlockingLoadingCubit> openEditorAndSend(
      WidgetTester tester,
    ) async {
      final loading = AppBlockingLoadingCubit();
      await tester.pumpApp(
        const EssayEditorPage(theme: _theme),
        providers: [
          BlocProvider<AppBlockingLoadingCubit>.value(value: loading),
        ],
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), _longEnough);
      await tester.pump(
        EssayEditorCubit.debounce + const Duration(milliseconds: 100),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enviar para correção'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enviar redação'));
      await tester.pump();
      return loading;
    }

    testWidgets('while the send is in flight: the blocking overlay, and no '
        'Aurudo yet', (tester) async {
      final accepted = Completer<Result<EssayAttempt>>();
      when(
        () => repository.submitDraft(
          themeId: any(named: 'themeId'),
          clientRequestId: any(named: 'clientRequestId'),
        ),
      ).thenAnswer((_) => accepted.future);

      final loading = await openEditorAndSend(tester);

      expect(loading.state.isVisible, isTrue);
      expect(loading.state.message, 'Enviando redação...');
      expect(find.text('Deixa comigo.'), findsNothing);
      expect(ledger().hasCelebratedEssayWriting('s1'), isFalse);

      accepted.complete(
        Success(
          EssayAttempt(
            id: 's1',
            status: EssaySubmissionStatus.submitted,
            wordCount: 2,
            submittedAt: DateTime(2026, 9, 24),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Accepted: the overlay is gone -- it never waits for the marking --
      // and Aurudo takes over, studying, never frustrated.
      expect(loading.state.isVisible, isFalse);
      expect(find.text('Deixa comigo.'), findsOneWidget);
      expect(find.text('Vou analisar sua redação.'), findsOneWidget);
      expect(_showsPose(tester, 'studying'), isTrue);
      expect(_showsPose(tester, 'frustrated'), isFalse);
      expect(ledger().hasCelebratedEssayWriting('s1'), isTrue);

      // Short, then the waiting state.
      await tester.pump(AurudoAchievementOverlay.visibleDuration);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Deixa comigo.'), findsNothing);
      expect(find.text('Aguardando correção'), findsOneWidget);
    });

    testWidgets(
      'a failed send: no Aurudo, nothing spent, still in the editor',
      (tester) async {
        when(
          () => repository.submitDraft(
            themeId: any(named: 'themeId'),
            clientRequestId: any(named: 'clientRequestId'),
          ),
        ).thenAnswer(
          (_) async => const Error(
            EssaySubmitFailure(EssaySubmitFailureKind.unexpected),
          ),
        );

        final loading = await openEditorAndSend(tester);
        await tester.pumpAndSettle();

        expect(loading.state.isVisible, isFalse);
        expect(find.text('Deixa comigo.'), findsNothing);
        expect(find.byType(EssayEditorPage), findsOneWidget);
        expect(find.textContaining('continua salvo aqui'), findsOneWidget);
        expect(ledger().hasCelebratedEssayWriting('s1'), isFalse);
      },
    );
  });

  group('"Deixa comigo" on the attempt screen', () {
    testWidgets(
      'plays once per submission: a second visit does not replay it',
      (tester) async {
        stubSubmission(EssaySubmissionStatus.evaluating);
        await pumpPage(tester, justSubmitted: true);
        expect(find.text('Deixa comigo.'), findsOneWidget);
        await tester.pump(AurudoAchievementOverlay.visibleDuration);
        await tester.pump(const Duration(milliseconds: 300));

        await tester.pumpWidget(const SizedBox());
        await pumpPage(tester, justSubmitted: true);
        expect(find.text('Deixa comigo.'), findsNothing);
        expect(find.text('Corrigindo'), findsOneWidget);
      },
    );

    testWidgets('a rebuild (theme change) does not replay it', (tester) async {
      stubSubmission(EssaySubmissionStatus.evaluating);
      await pumpPage(tester, justSubmitted: true);
      await tester.pump(AurudoAchievementOverlay.visibleDuration);
      await tester.pump(const Duration(milliseconds: 300));

      await pumpPage(tester, justSubmitted: true, theme: AppTheme.dark);
      expect(find.text('Deixa comigo.'), findsNothing);
    });

    testWidgets('opened from the history, it never plays', (tester) async {
      stubSubmission(EssaySubmissionStatus.evaluating);
      await pumpPage(tester);
      expect(find.text('Deixa comigo.'), findsNothing);
      expect(ledger().hasCelebratedEssayWriting('s1'), isFalse);
    });

    testWidgets('after it, the waiting state: no Aurudo left animating', (
      tester,
    ) async {
      stubSubmission(EssaySubmissionStatus.evaluating);
      await pumpPage(tester, justSubmitted: true);
      await tester.pump(AurudoAchievementOverlay.visibleDuration);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Corrigindo'), findsOneWidget);
      expect(find.byType(AurudoAchievementOverlay), findsNothing);
      expect(find.byType(AurudoReactionStage), findsNothing);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('reduced motion: the static pose, then out of the way fast', (
      tester,
    ) async {
      stubSubmission(EssaySubmissionStatus.evaluating);
      await pumpPage(tester, justSubmitted: true, reducedMotion: true);
      expect(find.text('Deixa comigo.'), findsOneWidget);
      await tester.pump(EssaySubmissionPage.reducedWritingDuration);
      await tester.pump();
      expect(find.text('Deixa comigo.'), findsNothing);
    });

    testWidgets('writing seen does not block the correction later', (
      tester,
    ) async {
      useTallScreen(tester);
      ledger().markEssayWritingCelebrated('s1');
      stubSubmission(EssaySubmissionStatus.evaluated, score: 800);
      await pumpPage(tester);

      // Plays (not instant): the report is still waiting on the scene.
      expect(find.byType(AurudoReactionStage), findsOneWidget);
      expect(find.text('COMPETÊNCIAS'), findsNothing);
      expect(ledger().hasCelebratedEssayCorrection('s1'), isTrue);
      await finishScene(tester);
    });

    testWidgets('a correction landing during "Deixa comigo" does not start a '
        'second scene: it opens in its final state', (tester) async {
      useTallScreen(tester);
      stubSubmission(EssaySubmissionStatus.evaluated, score: 920);
      await pumpPage(tester, justSubmitted: true);

      expect(find.text('Deixa comigo.'), findsOneWidget);
      // The report is already there under it -- no scene waiting to play.
      expect(find.text('COMPETÊNCIAS'), findsOneWidget);
      expect(ledger().hasCelebratedEssayCorrection('s1'), isTrue);
      await tester.pump(AurudoAchievementOverlay.visibleDuration);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });

  group('the correction arriving', () {
    testWidgets(
      'while the waiting screen is open, it turns into the reaction',
      (tester) async {
        useTallScreen(tester);
        var calls = 0;
        when(() => repository.getSubmission('s1')).thenAnswer((_) async {
          calls++;
          return Success(
            calls == 1
                ? _submission(EssaySubmissionStatus.evaluating)
                : _submission(EssaySubmissionStatus.evaluated, score: 920),
          );
        });
        await pumpPage(tester);
        expect(find.text('Corrigindo'), findsOneWidget);
        expect(find.byType(AurudoReactionStage), findsNothing);

        // The next poll brings the evaluation in.
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();

        expect(find.byType(AurudoReactionStage), findsOneWidget);
        expect(find.text('COMPETÊNCIAS'), findsNothing);
        await finishScene(tester);
        expect(find.text('Excelente redação!'), findsOneWidget);
        expect(find.text('COMPETÊNCIAS'), findsOneWidget);
      },
    );

    testWidgets(
      'it arrived with the app closed and was never seen: plays once',
      (tester) async {
        useTallScreen(tester);
        stubSubmission(EssaySubmissionStatus.evaluated, score: 700);
        await pumpPage(tester);
        expect(find.text('COMPETÊNCIAS'), findsNothing);
        await finishScene(tester);
        expect(find.text('COMPETÊNCIAS'), findsOneWidget);
      },
    );
  });

  group('score band picks the pose -- never frustrated', () {
    for (final (score, pose, headline) in [
      (1000, 'celebrating', 'Excelente redação!'),
      (920, 'celebrating', 'Excelente redação!'),
      (800, 'celebrating', 'Mandou muito bem!'),
      (600, 'neutral', 'Boa evolução'),
      (400, 'studying', 'Vamos evoluir juntos'),
    ]) {
      testWidgets('$score -> $pose, "$headline"', (tester) async {
        useTallScreen(tester);
        stubSubmission(EssaySubmissionStatus.evaluated, score: score);
        await pumpPage(tester);
        await finishScene(tester);

        expect(_showsPose(tester, pose), isTrue);
        expect(_showsPose(tester, 'frustrated'), isFalse);
        expect(find.text(headline), findsOneWidget);
        // The real number, still called an estimate.
        expect(find.text('$score'), findsOneWidget);
        expect(find.text('Nota estimada'), findsOneWidget);
      });
    }
  });

  group('the ledger decides replay', () {
    testWidgets('first open plays; reopening is instant', (tester) async {
      useTallScreen(tester);
      stubSubmission(EssaySubmissionStatus.evaluated, score: 800);
      await pumpPage(tester);
      expect(find.text('COMPETÊNCIAS'), findsNothing);
      await finishScene(tester);

      await tester.pumpWidget(const SizedBox());
      await pumpPage(tester);
      // Final state from the first frame: headline, score and report.
      expect(find.text('Mandou muito bem!'), findsOneWidget);
      expect(find.text('COMPETÊNCIAS'), findsOneWidget);
    });

    testWidgets('after a restart (same storage) it does not replay', (
      tester,
    ) async {
      useTallScreen(tester);
      ledger().markEssayCorrectionCelebrated('s1');
      stubSubmission(EssaySubmissionStatus.evaluated, score: 800);
      await pumpPage(tester);
      expect(find.text('COMPETÊNCIAS'), findsOneWidget);
    });

    testWidgets('another account keeps its own ledger', (tester) async {
      useTallScreen(tester);
      ledger().markEssayCorrectionCelebrated('s1');
      when(
        () => auth.currentUser,
      ).thenReturn(const AppUser(id: 'user-2', email: 'b@c.com'));
      stubSubmission(EssaySubmissionStatus.evaluated, score: 800);
      await pumpPage(tester);

      expect(find.text('COMPETÊNCIAS'), findsNothing);
      expect(ledger('user-2').hasCelebratedEssayCorrection('s1'), isTrue);
      await finishScene(tester);
    });

    testWidgets('reduced motion: final pose and the report right away', (
      tester,
    ) async {
      useTallScreen(tester);
      stubSubmission(EssaySubmissionStatus.evaluated, score: 600);
      await pumpPage(tester, reducedMotion: true);
      await tester.pump(const Duration(milliseconds: 300));

      expect(_showsPose(tester, 'neutral'), isTrue);
      expect(find.text('COMPETÊNCIAS'), findsOneWidget);
    });
  });

  group('the report stays whole', () {
    testWidgets('score, C1-C5, feedback, estimate note and actions', (
      tester,
    ) async {
      useTallScreen(tester);
      stubSubmission(EssaySubmissionStatus.evaluated, score: 880);
      await pumpPage(tester);
      await finishScene(tester);

      expect(find.text('880'), findsOneWidget);
      expect(find.text('Nota estimada'), findsOneWidget);
      for (var i = 1; i <= 5; i++) {
        expect(find.text('Competência $i'), findsOneWidget);
      }
      expect(find.text('Comentário geral da correção.'), findsOneWidget);
      expect(find.text('Um ponto forte'), findsOneWidget);
      expect(find.text('Uma prioridade'), findsOneWidget);
      expect(
        find.text('O primeiro parágrafo da redação enviada.'),
        findsOneWidget,
      );
      expect(find.text('Fazer nova redação'), findsOneWidget);
    });

    testWidgets('the score reads as one sentence to a screen reader', (
      tester,
    ) async {
      useTallScreen(tester);
      stubSubmission(EssaySubmissionStatus.evaluated, score: 800);
      await pumpPage(tester);
      await finishScene(tester);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == 'Nota estimada: 800 de 1000',
        ),
        findsOneWidget,
      );
    });

    for (final (label, width, theme) in [
      ('360px light', 360.0, AppTheme.light),
      ('360px dark', 360.0, AppTheme.dark),
      ('tablet', 1024.0, AppTheme.light),
    ]) {
      testWidgets('$label: no overflow', (tester) async {
        useTallScreen(tester, width: width);
        stubSubmission(EssaySubmissionStatus.evaluated, score: 920);
        await pumpPage(tester, theme: theme);
        await finishScene(tester);
        expect(tester.takeException(), isNull);
        expect(find.text('COMPETÊNCIAS'), findsOneWidget);
      });
    }
  });

  group('technical failure is not an emotion', () {
    testWidgets('failed: no Aurudo, the retry is there, nothing spent', (
      tester,
    ) async {
      stubSubmission(EssaySubmissionStatus.failed);
      await pumpPage(tester);

      expect(find.byType(AurudoReactionStage), findsNothing);
      expect(find.byType(Image), findsNothing);
      expect(find.text('Tentar corrigir de novo'), findsOneWidget);
      expect(ledger().hasCelebratedEssayCorrection('s1'), isFalse);
    });

    testWidgets('a retry that finally marks it gets its one reveal', (
      tester,
    ) async {
      useTallScreen(tester);
      stubSubmission(EssaySubmissionStatus.failed);
      await pumpPage(tester);
      stubSubmission(EssaySubmissionStatus.evaluated, score: 760);

      await tester.tap(find.text('Tentar corrigir de novo'));
      await tester.pump();
      await tester.pump();

      verify(() => repository.requestEvaluation('s1')).called(1);
      expect(find.byType(AurudoReactionStage), findsOneWidget);
      expect(ledger().hasCelebratedEssayCorrection('s1'), isTrue);
      await finishScene(tester);
      expect(find.text('760'), findsOneWidget);
    });
  });
}
