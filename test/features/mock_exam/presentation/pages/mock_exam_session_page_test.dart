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
import 'package:aura/features/mock_exam/domain/entities/active_mock_exam.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_item.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_session_page.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

import '../../../../helpers/pump_app.dart';

class _MockMockExamRepository extends Mock implements MockExamRepository {}

const _examId = 'e1';

MockExamItem _item(int position, {String? prompt, List<String>? options}) =>
    MockExamItem(
      position: position,
      questionId: 'q$position',
      subject: 'geografia',
      difficulty: QuestionDifficulty.dificil,
      prompt: prompt ?? 'Qual é a capital da região $position?',
      options: options ?? const ['Opção um', 'Opção dois', 'Opção três'],
    );

void main() {
  late MockExamRepository repository;

  setUp(() async {
    await sl.reset();
    repository = _MockMockExamRepository();
    sl.registerLazySingleton<MockExamRepository>(() => repository);
    when(() => repository.getActiveMockExam()).thenAnswer(
      (_) async => const Success(
        ActiveMockExam(id: _examId, questionCount: 3, answeredCount: 0),
      ),
    );
    when(
      () => repository.getItems(_examId),
    ).thenAnswer((_) async => Success([_item(1), _item(2), _item(3)]));
    when(
      () => repository.answerItem(
        any(),
        position: any(named: 'position'),
        selectedIndex: any(named: 'selectedIndex'),
      ),
    ).thenAnswer((_) async => const Success(null));
    when(
      () => repository.setCurrentPosition(any(), any()),
    ).thenAnswer((_) async => const Success(null));
  });

  Future<void> pumpSession(WidgetTester tester) async {
    await tester.pumpApp(const MockExamSessionPage(mockExamId: _examId));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the question with progress and no grading at all', (
    tester,
  ) async {
    await pumpSession(tester);

    expect(find.text('Questão 1 de 3'), findsOneWidget);
    expect(find.text('Geografia · Difícil'), findsOneWidget);
    expect(find.text('0 de 3 respondidas'), findsOneWidget);
    expect(find.text('Anterior'), findsOneWidget);
    expect(find.text('Próxima'), findsOneWidget);

    await tester.tap(find.text('Opção dois'));
    await tester.pumpAndSettle();

    expect(find.text('1 de 3 respondidas'), findsOneWidget);
    // Exam mode: selecting never reveals right/wrong.
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.cancel), findsNothing);
    verify(
      () => repository.answerItem(_examId, position: 1, selectedIndex: 1),
    ).called(1);
  });

  testWidgets('back asks before leaving and never abandons', (tester) async {
    await pumpSession(tester);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Sair do simulado?'), findsOneWidget);
    expect(
      find.text('Seu progresso está salvo e você poderá continuar depois.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Continuar simulado'));
    await tester.pumpAndSettle();
    expect(find.text('Questão 1 de 3'), findsOneWidget);
    verifyNever(() => repository.abandonMockExam(any()));
  });

  testWidgets('abandoning is a separate, confirmed action', (tester) async {
    await pumpSession(tester);

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abandonar simulado'));
    await tester.pumpAndSettle();

    expect(find.text('Abandonar simulado?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    verifyNever(() => repository.abandonMockExam(any()));
  });

  testWidgets(
    'the last question hands in; blanks are flagged with a way back',
    (tester) async {
      await pumpSession(tester);

      await tester.tap(find.text('Próxima'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Opção um'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Próxima'));
      await tester.pumpAndSettle();

      expect(find.text('Questão 3 de 3'), findsOneWidget);
      expect(find.text('Entregar simulado'), findsOneWidget);

      await tester.tap(find.text('Entregar simulado'));
      await tester.pumpAndSettle();
      expect(find.text('Você deixou 2 questões sem resposta.'), findsOneWidget);
      expect(find.text('Entregar assim mesmo'), findsOneWidget);

      // "Voltar e revisar" jumps to the first blank one, nothing is graded.
      await tester.tap(find.text('Voltar e revisar'));
      await tester.pumpAndSettle();
      expect(find.text('Questão 1 de 3'), findsOneWidget);
      verifyNever(() => repository.finishMockExam(any()));
    },
  );

  testWidgets('an exam finished elsewhere shows a clear message', (
    tester,
  ) async {
    when(
      () => repository.getActiveMockExam(),
    ).thenAnswer((_) async => const Success(null));
    await pumpSession(tester);

    expect(
      find.text('Este simulado não está mais em andamento.'),
      findsOneWidget,
    );
  });

  testWidgets('long prompt and options fit 360px in dark mode', (tester) async {
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final longText = List.filled(40, 'palavra comprida').join(' ');
    when(() => repository.getItems(_examId)).thenAnswer(
      (_) async => Success([
        _item(
          1,
          prompt: longText,
          options: [longText, longText, 'curta', longText, longText],
        ),
      ]),
    );

    await tester.pumpWidget(
      BlocProvider<LocaleCubit>(
        create: (_) => LocaleCubit()..emit(AppLanguage.portuguese),
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const MockExamSessionPage(mockExamId: _examId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('curta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('curta'));
    await tester.pumpAndSettle();
    expect(find.text('Entregar simulado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
