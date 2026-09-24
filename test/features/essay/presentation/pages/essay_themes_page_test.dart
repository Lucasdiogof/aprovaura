import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/pages/essay_themes_page.dart';

import '../../../../helpers/pump_app.dart';

class _MockEssayRepository extends Mock implements EssayRepository {}

const _practice = EssayThemeSummary(
  id: 't1',
  title: 'Desinformação e o direito de saber',
  description: 'Quando a mentira circula mais rápido que a correção.',
  origin: EssayThemeOrigin.practice(),
  hasDraft: false,
  attemptCount: 0,
);

const _withDraft = EssayThemeSummary(
  id: 't2',
  title: 'Os limites da privacidade na era dos dados',
  origin: EssayThemeOrigin.practice(),
  hasDraft: true,
  attemptCount: 0,
);

const _graded = EssayThemeSummary(
  id: 't3',
  title: 'Água: escassez, desperdício e desigualdade',
  origin: EssayThemeOrigin.practice(),
  hasDraft: false,
  attemptCount: 2,
  lastStatus: EssaySubmissionStatus.evaluated,
  lastScore: 920,
);

// Nothing seeds official themes today; this proves the UI is ready for the
// day one is registered, without a fake one existing anywhere.
const _official = EssayThemeSummary(
  id: 't4',
  title: 'Tema de prova',
  origin: EssayThemeOrigin.official(examName: 'ENEM', examYear: 2025),
  hasDraft: false,
  attemptCount: 0,
);

void main() {
  late EssayRepository repository;

  setUp(() async {
    await sl.reset();
    repository = _MockEssayRepository();
    sl.registerLazySingleton<EssayRepository>(() => repository);
  });

  void stub(Result<List<EssayThemeSummary>> result) {
    when(() => repository.listThemes()).thenAnswer((_) async => result);
  }

  group(EssayThemesPage, () {
    testWidgets('shows a spinner while the themes are loading', (tester) async {
      when(() => repository.listThemes()).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 50),
          () => const Success([_practice]),
        ),
      );
      await tester.pumpApp(const EssayThemesPage());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('lists the themes with the subtitle above them', (
      tester,
    ) async {
      stub(const Success([_practice]));
      await tester.pumpApp(const EssayThemesPage());
      await tester.pumpAndSettle();

      expect(
        find.text('Escolha um tema e pratique sua escrita.'),
        findsOneWidget,
      );
      expect(find.text(_practice.title), findsOneWidget);
      expect(find.text(_practice.description!), findsOneWidget);
    });

    testWidgets('a practice theme says it is ours, with no exam metadata', (
      tester,
    ) async {
      stub(const Success([_practice]));
      await tester.pumpApp(const EssayThemesPage());
      await tester.pumpAndSettle();

      expect(find.text('Aura · Tema de treino'), findsOneWidget);
      expect(find.textContaining('ENEM'), findsNothing);
      expect(find.text('Oficial'), findsNothing);
    });

    testWidgets('an official theme shows its exam and year', (tester) async {
      stub(const Success([_official]));
      await tester.pumpApp(const EssayThemesPage());
      await tester.pumpAndSettle();

      expect(find.text('Oficial · ENEM 2025'), findsOneWidget);
    });

    testWidgets('a theme never tried shows no score and no zero', (
      tester,
    ) async {
      stub(const Success([_practice]));
      await tester.pumpApp(const EssayThemesPage());
      await tester.pumpAndSettle();

      expect(find.text('0'), findsNothing);
      expect(find.text('Rascunho'), findsNothing);
      expect(find.text('Começar redação'), findsOneWidget);
    });

    testWidgets('a theme with a draft is badged and offers to continue', (
      tester,
    ) async {
      stub(const Success([_withDraft]));
      await tester.pumpApp(const EssayThemesPage());
      await tester.pumpAndSettle();

      expect(find.text('Rascunho'), findsOneWidget);
      expect(find.text('Continuar redação'), findsOneWidget);
    });

    testWidgets('a graded theme shows the most recent score', (tester) async {
      stub(const Success([_graded]));
      await tester.pumpApp(const EssayThemesPage());
      await tester.pumpAndSettle();

      expect(find.text('920'), findsOneWidget);
      expect(find.text('Fazer nova redação'), findsOneWidget);
    });

    testWidgets('an empty catalog reads as a message, not an error', (
      tester,
    ) async {
      stub(const Success([]));
      await tester.pumpApp(const EssayThemesPage());
      await tester.pumpAndSettle();

      expect(find.text('Nenhum tema disponível no momento.'), findsOneWidget);
      expect(find.text('Tentar novamente'), findsNothing);
    });

    testWidgets('a failure shows a human sentence and retries on demand', (
      tester,
    ) async {
      stub(Error(ServerFailure('PostgrestException: relation does not exist')));
      await tester.pumpApp(const EssayThemesPage());
      await tester.pumpAndSettle();

      expect(find.textContaining('Não conseguimos carregar'), findsOneWidget);
      expect(find.textContaining('Postgrest'), findsNothing);

      stub(const Success([_practice]));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text(_practice.title), findsOneWidget);
    });

    testWidgets('fits a 360px screen without overflowing', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      stub(const Success([_practice, _withDraft, _graded]));

      await tester.pumpApp(const EssayThemesPage());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    // pumpApp forces the light theme, so this case builds its own host.
    // It asserts on the score, a number, so the language does not matter.
    testWidgets('renders on the dark theme', (tester) async {
      stub(const Success([_graded]));
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit(),
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const EssayThemesPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('920'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
