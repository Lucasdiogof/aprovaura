import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_evaluation.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';
import 'package:aura/features/essay/presentation/widgets/essay_result_view.dart';

import '../../../../helpers/pump_app.dart';

const _strings = EssayStrings(AppLanguage.portuguese);

EssayCompetency _competency(
  String key, {
  int score = 160,
  String summary = '',
  List<String> strengths = const [],
  List<String> improvements = const [],
  List<String> evidence = const [],
}) => EssayCompetency(
  key: key,
  title: 'Título da competência',
  score: score,
  summary: summary,
  strengths: strengths,
  improvements: improvements,
  evidence: evidence,
);

EssayEvaluation _evaluation({
  int total = 800,
  List<EssayCompetency>? competencies,
  String generalFeedback = '',
  List<String> strengths = const [],
  List<String> priorities = const [],
  bool themeDeviation = false,
  bool insufficient = false,
}) => EssayEvaluation(
  totalScore: total,
  competencies:
      competencies ?? [for (var i = 1; i <= 5; i++) _competency('c$i')],
  generalFeedback: generalFeedback,
  strengths: strengths,
  priorityImprovements: priorities,
  possibleThemeDeviation: themeDeviation,
  insufficientText: insufficient,
);

Future<void> _pump(WidgetTester tester, EssayEvaluation evaluation) =>
    tester.pumpApp(
      Scaffold(
        body: SingleChildScrollView(
          child: EssayResultView(evaluation: evaluation, strings: _strings),
        ),
      ),
    );

void main() {
  group(EssayResultView, () {
    testWidgets('leads with the score, always called an estimate', (
      tester,
    ) async {
      await _pump(tester, _evaluation(total: 840));
      await tester.pumpAndSettle();

      expect(find.text('840'), findsOneWidget);
      expect(find.text('de 1000'), findsOneWidget);
      expect(find.text('Nota estimada'), findsOneWidget);
      // The disclaimer sits with the number, not in fine print elsewhere.
      expect(
        find.textContaining('Não é a nota oficial do ENEM'),
        findsOneWidget,
      );
    });

    testWidgets('shows the five competencies with their scores', (
      tester,
    ) async {
      await _pump(
        tester,
        _evaluation(
          competencies: [
            _competency('c1', score: 200),
            _competency('c2', score: 160),
            _competency('c3', score: 120),
            _competency('c4', score: 160),
            _competency('c5', score: 80),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Competência 1'), findsOneWidget);
      expect(find.text('Competência 5'), findsOneWidget);
      // Score and ceiling are one rich span: "200 / 200".
      expect(find.text('200 / 200', findRichText: true), findsOneWidget);
      expect(find.text('80 / 200', findRichText: true), findsOneWidget);
    });

    testWidgets('a competency opens into the reasons for its score', (
      tester,
    ) async {
      await _pump(
        tester,
        _evaluation(
          competencies: [
            _competency(
              'c1',
              summary: 'Bom domínio da norma padrão.',
              strengths: ['Períodos bem construídos'],
              improvements: ['Revisar vírgulas em apostos'],
              evidence: ['o texto argumenta com clareza'],
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Collapsed first: five open competencies would be a wall of text.
      expect(find.text('Bom domínio da norma padrão.'), findsNothing);

      await tester.tap(find.text('Competência 1'));
      await tester.pumpAndSettle();

      expect(find.text('Bom domínio da norma padrão.'), findsOneWidget);
      expect(find.text('Períodos bem construídos'), findsOneWidget);
      expect(find.text('Revisar vírgulas em apostos'), findsOneWidget);
      // Evidence is the person's own words, quoted back.
      expect(find.text('"o texto argumenta com clareza"'), findsOneWidget);
    });

    testWidgets('a competency with no commentary still shows its score', (
      tester,
    ) async {
      await _pump(
        tester,
        _evaluation(competencies: [_competency('c1', score: 120)]),
      );
      await tester.pumpAndSettle();

      expect(find.text('120 / 200', findRichText: true), findsOneWidget);
      // Nothing to expand, so no chevron pretending there is.
      expect(find.byType(ExpansionTile), findsNothing);
    });

    testWidgets('feedback blocks only appear when they have content', (
      tester,
    ) async {
      await _pump(tester, _evaluation());
      await tester.pumpAndSettle();

      expect(find.text('COMENTÁRIO GERAL'), findsNothing);
      expect(find.text('PONTOS FORTES'), findsNothing);
      expect(find.text('COMECE POR AQUI'), findsNothing);
    });

    testWidgets('priorities are numbered, in the order that matters', (
      tester,
    ) async {
      await _pump(
        tester,
        _evaluation(
          generalFeedback: 'Texto consistente.',
          strengths: ['Repertório bem usado'],
          priorities: ['Fechar a proposta de intervenção', 'Variar conectivos'],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Texto consistente.'), findsOneWidget);
      expect(find.text('Repertório bem usado'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Fechar a proposta de intervenção'), findsOneWidget);
    });

    testWidgets('a suspected theme deviation is flagged, not hidden', (
      tester,
    ) async {
      await _pump(tester, _evaluation(themeDeviation: true));
      await tester.pumpAndSettle();

      expect(find.textContaining('fugido do tema'), findsOneWidget);
    });

    testWidgets('too short a text says so', (tester) async {
      await _pump(tester, _evaluation(insufficient: true));
      await tester.pumpAndSettle();

      expect(find.textContaining('curto demais'), findsOneWidget);
    });

    testWidgets('fits 360px and renders on dark', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit(),
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              body: SingleChildScrollView(
                child: EssayResultView(
                  evaluation: _evaluation(
                    generalFeedback: 'Comentário.',
                    strengths: ['Um ponto forte'],
                    priorities: ['Uma prioridade'],
                  ),
                  strings: _strings,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
