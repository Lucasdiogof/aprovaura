import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_item.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/presentation/pages/mock_exam_review_page.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

import '../../../../helpers/pump_app.dart';

class _MockMockExamRepository extends Mock implements MockExamRepository {}

const _examId = 'e1';

void main() {
  late MockExamRepository repository;

  setUp(() async {
    await sl.reset();
    repository = _MockMockExamRepository();
    sl.registerLazySingleton<MockExamRepository>(() => repository);
  });

  void stubItems(List<MockExamItem> items) {
    when(
      () => repository.getItems(_examId),
    ).thenAnswer((_) async => Success(items));
  }

  Future<void> pumpReview(WidgetTester tester) async {
    await tester.pumpApp(const MockExamReviewPage(mockExamId: _examId));
    await tester.pumpAndSettle();
  }

  const wrongItem = MockExamItem(
    position: 1,
    questionId: 'q1',
    subject: 'geografia',
    difficulty: QuestionDifficulty.medio,
    prompt: 'Qual a capital da França?',
    options: ['Londres', 'Paris', 'Roma', 'Berlim'],
    selectedIndex: 0,
    correctIndex: 1,
    isCorrect: false,
    explanation: 'Paris é a capital da França.',
  );

  const blankItem = MockExamItem(
    position: 2,
    questionId: 'q2',
    subject: 'matematica',
    difficulty: QuestionDifficulty.facil,
    prompt: 'Quanto é 2 + 2?',
    options: ['3', '4', '5', '6'],
    correctIndex: 1,
    isCorrect: false,
  );

  const correctItem = MockExamItem(
    position: 3,
    questionId: 'q3',
    subject: 'fisica',
    difficulty: QuestionDifficulty.dificil,
    prompt: 'Nunca deveria aparecer.',
    options: ['a', 'b'],
    selectedIndex: 0,
    correctIndex: 0,
    isCorrect: true,
  );

  testWidgets('shows a wrong question with the correct answer, what was '
      'picked, and the explanation', (tester) async {
    stubItems([wrongItem]);
    await pumpReview(tester);

    expect(find.text('Revisão do simulado'), findsOneWidget);
    expect(find.text('Qual a capital da França?'), findsOneWidget);
    expect(find.text('Paris'), findsOneWidget);
    expect(find.text('Paris é a capital da França.'), findsOneWidget);
    // Correct highlighted, the wrong pick highlighted too, in the exam's
    // own frozen option order (not sorted alphabetically or by index).
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsOneWidget);
  });

  testWidgets('a blank question shows the correct answer but no wrong pick', (
    tester,
  ) async {
    stubItems([blankItem]);
    await pumpReview(tester);

    expect(find.text('Em branco'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.cancel), findsNothing);
  });

  testWidgets('a correct question never shows up here', (tester) async {
    stubItems([correctItem, wrongItem]);
    await pumpReview(tester);

    expect(find.text('Nunca deveria aparecer.'), findsNothing);
    expect(find.text('Qual a capital da França?'), findsOneWidget);
  });

  testWidgets('a load error offers retry', (tester) async {
    var call = 0;
    when(() => repository.getItems(_examId)).thenAnswer((_) async {
      call++;
      return call == 1
          ? Error(MockExamFailure(MockExamFailureKind.network))
          : const Success([wrongItem]);
    });
    await pumpReview(tester);

    expect(find.text('Não foi possível carregar as questões.'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Qual a capital da França?'), findsOneWidget);
  });
}
