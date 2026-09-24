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
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';
import 'package:aura/features/error_review/presentation/pages/error_review_list_page.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_availability.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_result.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_result_page.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_setup_page.dart';

import '../../../../helpers/pump_app.dart';

class _MockMockExamRepository extends Mock implements MockExamRepository {}

class _MockErrorReviewRepository extends Mock
    implements ErrorReviewRepository {}

const _examId = 'e1';

MockExamResultLine _line(
  String key,
  int total,
  int correct, {
  int blank = 0,
  required double accuracy,
}) => MockExamResultLine(
  key: key,
  questionCount: total,
  correctCount: correct,
  wrongCount: total - correct - blank,
  blankCount: blank,
  accuracyPercent: accuracy,
);

// 68 correct, 18 wrong, 4 blank out of 90; Geografia was configured as
// Misto, so its questions spread over all three real difficulties.
const _intermediate = MockExamResult(
  mockExamId: _examId,
  questionCount: 90,
  correctCount: 68,
  wrongCount: 18,
  blankCount: 4,
  accuracyPercent: 75.6,
  xpAwarded: 680,
  subjectCount: 3,
  bySubject: [
    MockExamResultLine(
      key: 'historia',
      questionCount: 30,
      correctCount: 22,
      wrongCount: 6,
      blankCount: 2,
      accuracyPercent: 73.3,
    ),
    MockExamResultLine(
      key: 'geografia',
      questionCount: 40,
      correctCount: 31,
      wrongCount: 8,
      blankCount: 1,
      accuracyPercent: 77.5,
    ),
    MockExamResultLine(
      key: 'matematica',
      questionCount: 20,
      correctCount: 15,
      wrongCount: 4,
      blankCount: 1,
      accuracyPercent: 75,
    ),
  ],
  byDifficulty: [
    MockExamResultLine(
      key: 'facil',
      questionCount: 20,
      correctCount: 18,
      wrongCount: 2,
      blankCount: 0,
      accuracyPercent: 90,
    ),
    MockExamResultLine(
      key: 'medio',
      questionCount: 30,
      correctCount: 25,
      wrongCount: 4,
      blankCount: 1,
      accuracyPercent: 83.3,
    ),
    MockExamResultLine(
      key: 'dificil',
      questionCount: 40,
      correctCount: 25,
      wrongCount: 12,
      blankCount: 3,
      accuracyPercent: 62.5,
    ),
  ],
);

MockExamResult _single({required int correct, required double accuracy}) =>
    MockExamResult(
      mockExamId: _examId,
      questionCount: 10,
      correctCount: correct,
      wrongCount: 10 - correct,
      blankCount: 0,
      accuracyPercent: accuracy,
      xpAwarded: correct * 10,
      subjectCount: 1,
      bySubject: [_line('fisica', 10, correct, accuracy: accuracy)],
      byDifficulty: [_line('medio', 10, correct, accuracy: accuracy)],
    );

void main() {
  late MockExamRepository repository;

  setUp(() async {
    await sl.reset();
    repository = _MockMockExamRepository();
    sl.registerLazySingleton<MockExamRepository>(() => repository);
  });

  void stubResult(MockExamResult result) {
    when(
      () => repository.getResult(_examId),
    ).thenAnswer((_) async => Success(result));
  }

  // Tall enough that the whole result is built at once (a ListView only
  // builds what's on screen), for tests that check everything on it.
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpResult(WidgetTester tester) async {
    await tester.pumpApp(const MockExamResultPage(mockExamId: _examId));
    await tester.pumpAndSettle();
  }

  testWidgets('intermediate result: score, split counts, XP, breakdowns', (
    tester,
  ) async {
    useTallScreen(tester);
    stubResult(_intermediate);
    await pumpResult(tester);

    expect(find.text('Resultado do simulado'), findsOneWidget);
    expect(find.text('75,6%'), findsOneWidget);
    expect(find.text('75,6% de aproveitamento'), findsOneWidget);
    expect(find.text('Bom desempenho'), findsOneWidget);
    // Correct / wrong / blank never mixed, XP exactly as the server says.
    expect(find.text('68'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Em branco'), findsOneWidget);
    expect(find.text('+680'), findsOneWidget);
    expect(find.text('90 questões · 3 matérias · Modo prova'), findsOneWidget);

    // Subjects in app order, each with its own numbers.
    expect(find.text('Por matéria'), findsOneWidget);
    final mat = tester.getTopLeft(find.text('Matemática')).dy;
    final geo = tester.getTopLeft(find.text('Geografia')).dy;
    final his = tester.getTopLeft(find.text('História')).dy;
    expect(mat < geo && geo < his, isTrue);
    expect(find.text('31 / 40'), findsOneWidget);
    expect(find.text('77,5%'), findsOneWidget);

    // Real difficulties only -- a Misto config never shows as "Misto".
    expect(find.text('Por dificuldade'), findsOneWidget);
    expect(find.text('Fácil'), findsOneWidget);
    expect(find.text('Médio'), findsOneWidget);
    expect(find.text('Difícil'), findsOneWidget);
    expect(find.text('Misto'), findsNothing);

    // Reading the result never grades or awards anything.
    verifyNever(() => repository.finishMockExam(any()));
  });

  testWidgets('0% gets the review tone and offers Revisar erros first', (
    tester,
  ) async {
    useTallScreen(tester);
    stubResult(_single(correct: 0, accuracy: 0));
    await pumpResult(tester);

    expect(find.text('Vale revisar alguns pontos'), findsOneWidget);
    expect(find.text('Revisar erros'), findsOneWidget);
    expect(find.text('Fazer outro simulado'), findsOneWidget);
    expect(find.text('Voltar para o início'), findsOneWidget);
  });

  testWidgets('100%: excellent, no review button (nothing to review)', (
    tester,
  ) async {
    useTallScreen(tester);
    stubResult(_single(correct: 10, accuracy: 100));
    await pumpResult(tester);

    expect(find.text('Excelente resultado'), findsOneWidget);
    expect(find.text('100%'), findsWidgets);
    expect(find.text('Revisar erros'), findsNothing);
    expect(find.text('Fazer outro simulado'), findsOneWidget);
    // Single subject.
    expect(find.text('Física'), findsOneWidget);
  });

  testWidgets('a load error offers retry, which reads again (never finish)', (
    tester,
  ) async {
    var call = 0;
    when(() => repository.getResult(_examId)).thenAnswer((_) async {
      call++;
      return call == 1
          ? Error(MockExamFailure(MockExamFailureKind.network))
          : const Success(_intermediate);
    });
    await pumpResult(tester);

    expect(find.text('Não foi possível carregar o resultado.'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('75,6%'), findsOneWidget);
    verify(() => repository.getResult(_examId)).called(2);
    verifyNever(() => repository.finishMockExam(any()));
  });

  testWidgets('Revisar erros opens the regular error review', (tester) async {
    final errorReview = _MockErrorReviewRepository();
    when(
      () => errorReview.listPendingTopics(),
    ).thenAnswer((_) async => const Success([]));
    sl.registerLazySingleton<ErrorReviewRepository>(() => errorReview);
    stubResult(_intermediate);
    await pumpResult(tester);

    await tester.scrollUntilVisible(find.text('Revisar erros'), 200);
    await tester.tap(find.text('Revisar erros'));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorReviewListPage), findsOneWidget);
  });

  testWidgets('Fazer outro simulado opens the setup screen', (tester) async {
    when(
      () => repository.getAvailability(),
    ).thenAnswer((_) async => const Success(MockExamAvailability.empty()));
    stubResult(_intermediate);
    await pumpResult(tester);

    await tester.scrollUntilVisible(find.text('Fazer outro simulado'), 200);
    await tester.tap(find.text('Fazer outro simulado'));
    await tester.pumpAndSettle();
    expect(find.byType(MockExamSetupPage), findsOneWidget);
  });

  testWidgets('Voltar para o início leaves the result', (tester) async {
    stubResult(_intermediate);
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const MockExamResultPage(mockExamId: _examId),
            ),
          ),
          child: const Text('home'),
        ),
      ),
    );
    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Voltar para o início'), 200);
    await tester.tap(find.text('Voltar para o início'));
    await tester.pumpAndSettle();
    expect(find.byType(MockExamResultPage), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('7 subjects fit 360px in dark mode (and in English)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    stubResult(
      MockExamResult(
        mockExamId: _examId,
        questionCount: 180,
        correctCount: 99,
        wrongCount: 80,
        blankCount: 1,
        accuracyPercent: 55,
        xpAwarded: 1800,
        subjectCount: 7,
        bySubject: [
          for (final key in [
            'matematica',
            'geografia',
            'historia',
            'portugues',
            'biologia',
            'fisica',
            'quimica',
          ])
            _line(key, 25, 14, accuracy: 56),
        ],
        byDifficulty: [
          _line('facil', 60, 40, accuracy: 66.7),
          _line('medio', 60, 35, accuracy: 58.3),
          _line('dificil', 60, 24, blank: 1, accuracy: 40),
        ],
      ),
    );

    for (final language in AppLanguage.values) {
      await tester.pumpWidget(
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit()..emit(language),
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const MockExamResultPage(mockExamId: _examId),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Scroll through the whole list so every row gets laid out.
      await tester.drag(find.byType(ListView), const Offset(0, -4000));
      await tester.pumpAndSettle();
      expect(
        find.text('Voltar para o início').evaluate().isNotEmpty ||
            find.text('Back to home').evaluate().isNotEmpty,
        isTrue,
      );
      expect(tester.takeException(), isNull, reason: language.name);
    }
  });
}
