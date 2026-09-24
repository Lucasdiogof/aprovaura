import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/entities/essay_draft.dart';
import 'package:aura/features/essay/domain/entities/essay_evaluation.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/pages/essay_editor_page.dart';
import 'package:aura/features/essay/presentation/pages/essay_submission_page.dart';
import 'package:aura/features/essay/presentation/pages/essay_theme_page.dart';
import 'package:aura/features/essay/presentation/pages/essay_themes_page.dart';

class _MockEssayRepository extends Mock implements EssayRepository {}

/// The worst realistic case for a layout: an ENEM theme title runs long,
/// and it is exactly the kind of string that gets truncated or overflows.
const _longTitle =
    'Os limites da privacidade na era dos dados pessoais e da vigilância '
    'algorítmica no Brasil contemporâneo';

const _longBody =
    'Sete em cada dez brasileiros dizem já ter aceitado termos de uso sem '
    'ler, segundo levantamento fictício usado aqui apenas como exemplo de '
    'um bloco motivador com várias linhas de extensão, do tipo que aparece '
    'numa prova real e empurra o resto da página para baixo.';

const _theme = EssayTheme(
  id: 't1',
  title: _longTitle,
  description:
      'Até onde vai o direito de não ser rastreado por quem oferece um '
      'serviço gratuito em troca de dados.',
  prompt:
      'A partir da leitura dos textos motivadores e com base nos '
      'conhecimentos construídos ao longo de sua formação, redija um texto '
      'dissertativo-argumentativo em modalidade escrita formal da língua '
      'portuguesa sobre o tema, apresentando proposta de intervenção que '
      'respeite os direitos humanos.',
  origin: EssayThemeOrigin.official(examName: 'ENEM', examYear: 2025),
  supportingTexts: [
    EssaySupportingText(title: 'Texto I', body: _longBody, source: 'Fictícia'),
    EssaySupportingText(title: 'Texto II', body: _longBody),
    EssaySupportingText(body: _longBody),
  ],
);

const _summary = EssayThemeSummary(
  id: 't1',
  title: _longTitle,
  description: 'Até onde vai o direito de não ser rastreado.',
  origin: EssayThemeOrigin.official(examName: 'ENEM', examYear: 2025),
  hasDraft: false,
  attemptCount: 6,
  lastStatus: EssaySubmissionStatus.evaluated,
  lastScore: 920,
);

/// Six attempts: enough that the history is a list, not a footnote.
final _manyAttempts = [
  for (var i = 0; i < 6; i++)
    EssayAttempt(
      id: 's$i',
      status: EssaySubmissionStatus.evaluated,
      wordCount: 280 + i,
      submittedAt: DateTime(2026, 9, 24 - i),
      totalScore: 700 + i * 20,
      evaluatedAt: DateTime(2026, 9, 24 - i),
    ),
];

final _evaluation = EssayEvaluation(
  totalScore: 840,
  competencies: [
    for (var i = 1; i <= 5; i++)
      EssayCompetency(
        key: 'c$i',
        title:
            'Título longo da competência $i, do tipo que não cabe numa '
            'linha só em tela pequena',
        score: i == 5 ? 120 : 180,
        summary:
            'Um comentário de algumas linhas sobre a competência $i, '
            'explicando de onde veio a nota e o que faria ela subir.',
        strengths: const ['Um ponto forte descrito por extenso'],
        improvements: const ['Uma coisa a melhorar, também por extenso'],
        evidence: const [
          'um trecho citado da própria redação, que costuma ser comprido',
        ],
      ),
  ],
  generalFeedback:
      'Texto consistente, com tese clara e boa progressão entre os '
      'parágrafos. O que mais separa esta redação da nota máxima hoje é a '
      'proposta de intervenção.',
  strengths: const ['Tese clara desde a introdução'],
  priorityImprovements: const [
    'Detalhar agente e meio na proposta de intervenção',
  ],
);

final _submission = EssaySubmission(
  id: 's1',
  themeId: 't1',
  themeTitle: _longTitle,
  body: List.generate(6, (i) => 'Parágrafo ${i + 1}. $_longBody').join('\n\n'),
  wordCount: 312,
  status: EssaySubmissionStatus.evaluated,
  submittedAt: DateTime(2026, 9, 18),
  totalScore: 840,
  evaluatedAt: DateTime(2026, 9, 18),
  evaluation: _evaluation,
);

void main() {
  late EssayRepository repository;

  setUp(() async {
    await sl.reset();
    repository = _MockEssayRepository();
    sl.registerLazySingleton<EssayRepository>(() => repository);
    SharedPreferences.setMockInitialValues({});
    when(
      () => repository.listThemes(),
    ).thenAnswer((_) async => const Success([_summary]));
    when(
      () => repository.getTheme(any()),
    ).thenAnswer((_) async => const Success(_theme));
    when(
      () => repository.listAttempts(any()),
    ).thenAnswer((_) async => Success(_manyAttempts));
    when(() => repository.getDraft(any())).thenAnswer(
      (_) async => Success(
        EssayDraft(
          body: List.generate(
            8,
            (i) => 'Parágrafo ${i + 1}. $_longBody',
          ).join('\n\n'),
          updatedAt: DateTime(2026, 9, 24),
        ),
      ),
    );
    when(
      () => repository.getSubmission(any()),
    ).thenAnswer((_) async => Success(_submission));
    when(
      () => repository.requestEvaluation(any()),
    ).thenAnswer((_) async => const Success(null));
  });

  /// Renders [page] on a small screen, in a given theme, at a given text
  /// size. An overflow is reported as an exception during layout, so
  /// takeException is what actually asserts "this fits".
  Future<void> pumpTight(
    WidgetTester tester,
    Widget page, {
    required bool dark,
    double textScale = 1,
    Size size = const Size(360, 640),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      BlocProvider<LocaleCubit>(
        create: (_) => LocaleCubit()..emit(AppLanguage.portuguese),
        child: MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
            child: page,
          ),
        ),
      ),
    );
    // pump, not pumpAndSettle: some states keep a timer armed.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  // Every essay screen, on the narrowest phone worth supporting, in both
  // themes, with the longest copy the feature can produce.
  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';

    testWidgets('the theme list fits 360px on $mode', (tester) async {
      await pumpTight(tester, const EssayThemesPage(), dark: dark);
      expect(find.byType(EssayThemesPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a theme with long texts fits 360px on $mode', (tester) async {
      await pumpTight(
        tester,
        const EssayThemePage(summary: _summary),
        dark: dark,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the editor fits 360px with a long draft on $mode', (
      tester,
    ) async {
      await pumpTight(tester, const EssayEditorPage(theme: _theme), dark: dark);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a full result fits 360px on $mode', (tester) async {
      await pumpTight(
        tester,
        const EssaySubmissionPage(submissionId: 's1'),
        dark: dark,
      );
      await tester.pumpAndSettle();
      expect(find.text('840'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  // 1.5x is roughly the largest system font size someone reads the app
  // with day to day; anything that breaks here breaks for them.
  group('at 1.5x text size', () {
    testWidgets('the theme list still fits', (tester) async {
      await pumpTight(
        tester,
        const EssayThemesPage(),
        dark: false,
        textScale: 1.5,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a theme with a long title and six attempts still fits', (
      tester,
    ) async {
      await pumpTight(
        tester,
        const EssayThemePage(summary: _summary),
        dark: false,
        textScale: 1.5,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the editor footer still fits under the writing area', (
      tester,
    ) async {
      await pumpTight(
        tester,
        const EssayEditorPage(theme: _theme),
        dark: false,
        textScale: 1.5,
      );
      // The counter and the send button share the bottom bar: this is the
      // row that overflowed when they were side by side.
      expect(find.text('Enviar para correção'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the result still fits, competencies and all', (tester) async {
      await pumpTight(
        tester,
        const EssaySubmissionPage(submissionId: 's1'),
        dark: false,
        textScale: 1.5,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('every competency can be open at once without overflowing', (
    tester,
  ) async {
    await pumpTight(
      tester,
      const EssaySubmissionPage(submissionId: 's1'),
      dark: true,
    );
    await tester.pumpAndSettle();

    for (var i = 1; i <= 5; i++) {
      final tile = find.text('Competência $i');
      await tester.scrollUntilVisible(tile, 200);
      // scrollUntilVisible stops as soon as the tile is on screen, which
      // can still leave its centre under the fold and the tap missing it.
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
    }

    // Five open competencies is the tallest this screen ever gets.
    expect(find.textContaining('explicando de onde veio a nota'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
