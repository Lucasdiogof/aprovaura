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
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/pages/essay_submission_page.dart';

import '../../../../helpers/pump_app.dart';

class _MockEssayRepository extends Mock implements EssayRepository {}

EssaySubmission _submission({
  required EssaySubmissionStatus status,
  int? totalScore,
}) => EssaySubmission(
  id: 's1',
  themeTitle: 'Desinformação e o direito de saber',
  body: 'O primeiro parágrafo da redação enviada.',
  wordCount: 6,
  status: status,
  submittedAt: DateTime(2026, 9, 24),
  totalScore: totalScore,
  evaluatedAt: totalScore == null ? null : DateTime(2026, 9, 24),
);

void main() {
  late EssayRepository repository;

  setUp(() async {
    await sl.reset();
    repository = _MockEssayRepository();
    sl.registerLazySingleton<EssayRepository>(() => repository);
  });

  void stub(EssaySubmissionStatus status, {int? totalScore}) {
    when(() => repository.getSubmission('s1')).thenAnswer(
      (_) async => Success(_submission(status: status, totalScore: totalScore)),
    );
  }

  group(EssaySubmissionPage, () {
    testWidgets('shows the text exactly as it was sent, and no editor', (
      tester,
    ) async {
      stub(EssaySubmissionStatus.submitted);
      await tester.pumpApp(const EssaySubmissionPage(submissionId: 's1'));
      await tester.pumpAndSettle();

      expect(find.text('Desinformação e o direito de saber'), findsOneWidget);
      expect(
        find.text('O primeiro parágrafo da redação enviada.'),
        findsOneWidget,
      );
      expect(find.text('6 palavras'), findsOneWidget);
      // Read-only: there is nothing here to type into.
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('a waiting attempt says so and shows no score', (tester) async {
      stub(EssaySubmissionStatus.submitted);
      await tester.pumpApp(const EssaySubmissionPage(submissionId: 's1'));
      await tester.pumpAndSettle();

      expect(find.text('Aguardando correção'), findsOneWidget);
      expect(find.text('Nota'), findsNothing);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('an attempt being marked says "Corrigindo"', (tester) async {
      stub(EssaySubmissionStatus.evaluating);
      await tester.pumpApp(const EssaySubmissionPage(submissionId: 's1'));
      await tester.pumpAndSettle();

      expect(find.text('Corrigindo'), findsOneWidget);
      expect(find.text('Nota'), findsNothing);
    });

    testWidgets('a marked attempt shows its score', (tester) async {
      stub(EssaySubmissionStatus.evaluated, totalScore: 920);
      await tester.pumpApp(const EssaySubmissionPage(submissionId: 's1'));
      await tester.pumpAndSettle();

      expect(find.text('Corrigida'), findsOneWidget);
      expect(find.text('Nota'), findsOneWidget);
      expect(find.text('920'), findsOneWidget);
    });

    testWidgets('a failed marking says what happened, in full', (tester) async {
      stub(EssaySubmissionStatus.failed);
      await tester.pumpApp(const EssaySubmissionPage(submissionId: 's1'));
      await tester.pumpAndSettle();

      expect(
        find.text('Não foi possível concluir a correção.'),
        findsOneWidget,
      );
      // The text survives a failed marking -- that is the whole promise.
      expect(
        find.text('O primeiro parágrafo da redação enviada.'),
        findsOneWidget,
      );
    });

    testWidgets('a load failure offers to try again', (tester) async {
      when(
        () => repository.getSubmission('s1'),
      ).thenAnswer((_) async => Error(ServerFailure()));
      await tester.pumpApp(const EssaySubmissionPage(submissionId: 's1'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Não conseguimos abrir'), findsOneWidget);

      stub(EssaySubmissionStatus.submitted);
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Aguardando correção'), findsOneWidget);
    });

    testWidgets('fits a 360px screen and renders on dark', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      stub(EssaySubmissionStatus.evaluated, totalScore: 920);
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit(),
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const EssaySubmissionPage(submissionId: 's1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('920'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
