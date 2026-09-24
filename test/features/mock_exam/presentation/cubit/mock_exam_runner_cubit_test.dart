import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/mock_exam/domain/entities/active_mock_exam.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_item.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_score.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_runner_cubit.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_runner_state.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

class _MockMockExamRepository extends Mock implements MockExamRepository {}

MockExamItem _item(int position, {int? selected, List<String>? options}) =>
    MockExamItem(
      position: position,
      questionId: 'q$position',
      subject: 'geografia',
      difficulty: QuestionDifficulty.dificil,
      prompt: 'Pergunta $position',
      options: options ?? const ['A0', 'B0', 'C0', 'D0'],
      selectedIndex: selected,
    );

const _examId = 'e1';

ActiveMockExam _active({int? currentPosition}) => ActiveMockExam(
  id: _examId,
  questionCount: 3,
  answeredCount: 0,
  currentItemPosition: currentPosition,
);

void main() {
  late MockExamRepository repository;

  setUp(() {
    repository = _MockMockExamRepository();
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

  void stubLoad({
    required List<MockExamItem> items,
    ActiveMockExam? active,
    bool activeLookupFails = false,
  }) {
    when(() => repository.getActiveMockExam()).thenAnswer(
      (_) async => activeLookupFails
          ? Error(MockExamFailure(MockExamFailureKind.network))
          : Success(active),
    );
    when(
      () => repository.getItems(_examId),
    ).thenAnswer((_) async => Success(items));
  }

  Future<MockExamRunnerCubit> loaded({
    required List<MockExamItem> items,
    ActiveMockExam? active,
  }) async {
    stubLoad(items: items, active: active ?? _active());
    final cubit = MockExamRunnerCubit(repository, mockExamId: _examId);
    await pumpEventQueue();
    return cubit;
  }

  group('loading', () {
    test('a new exam opens on its first question, all blank', () async {
      final cubit = await loaded(items: [_item(1), _item(2), _item(3)]);

      expect(cubit.state.status, MockExamRunnerStatus.ready);
      expect(cubit.state.currentIndex, 0);
      expect(cubit.state.answeredCount, 0);
      expect(cubit.state.unansweredCount, 3);
    });

    test('keeps the server order of questions AND of options', () async {
      final cubit = await loaded(
        items: [
          _item(3, options: const ['z', 'y', 'x']),
          _item(1),
          _item(7),
        ],
      );
      expect(cubit.state.items.map((i) => i.position), [3, 1, 7]);
      expect(cubit.state.items.first.options, ['z', 'y', 'x']);
    });

    test(
      'continuing restores the answers and the question being viewed',
      () async {
        final cubit = await loaded(
          items: [_item(1, selected: 2), _item(2, selected: 0), _item(3)],
          // Was looking at question 2, which is already answered -- that's
          // where it must resume, not at the first blank one.
          active: _active(currentPosition: 2),
        );
        expect(cubit.state.currentIndex, 1);
        expect(cubit.state.answers, {1: 2, 2: 0});
        expect(cubit.state.currentAnswer, 0);
      },
    );

    test(
      'without a saved position, resumes at the first blank question',
      () async {
        final cubit = await loaded(
          items: [_item(1, selected: 1), _item(2), _item(3)],
        );
        expect(cubit.state.currentIndex, 1);
      },
    );

    test(
      'a saved position whose question was deleted falls back too',
      () async {
        final cubit = await loaded(
          items: [_item(1, selected: 1), _item(3)],
          active: _active(currentPosition: 2),
        );
        expect(cubit.state.currentIndex, 1);
      },
    );

    test('an exam that is not the active one is not in progress', () async {
      stubLoad(items: [_item(1)], active: null);
      final cubit = MockExamRunnerCubit(repository, mockExamId: _examId);
      await pumpEventQueue();
      expect(cubit.state.status, MockExamRunnerStatus.notInProgress);
    });

    test(
      'failing to load the questions shows the error, retry recovers',
      () async {
        when(
          () => repository.getActiveMockExam(),
        ).thenAnswer((_) async => Success(_active()));
        when(() => repository.getItems(_examId)).thenAnswer(
          (_) async => Error(MockExamFailure(MockExamFailureKind.network)),
        );
        final cubit = MockExamRunnerCubit(repository, mockExamId: _examId);
        await pumpEventQueue();
        expect(cubit.state.status, MockExamRunnerStatus.loadError);

        when(
          () => repository.getItems(_examId),
        ).thenAnswer((_) async => Success([_item(1)]));
        await cubit.load();
        expect(cubit.state.status, MockExamRunnerStatus.ready);
      },
    );
  });

  group('answering', () {
    test('selecting shows at once and saves (position, shown index)', () async {
      final cubit = await loaded(items: [_item(1), _item(2)]);
      cubit.select(2);

      expect(cubit.state.currentAnswer, 2);
      await cubit.flush();
      verify(
        () => repository.answerItem(_examId, position: 1, selectedIndex: 2),
      ).called(1);
      expect(cubit.state.isSaving, isFalse);
    });

    test('changing the answer replaces it: B then C ends as C', () async {
      final cubit = await loaded(items: [_item(1)]);
      cubit
        ..select(1)
        ..select(2);
      await cubit.flush();

      expect(cubit.state.currentAnswer, 2);
      verifyInOrder([
        () => repository.answerItem(_examId, position: 1, selectedIndex: 1),
        () => repository.answerItem(_examId, position: 1, selectedIndex: 2),
      ]);
    });

    test(
      'a previously saved answer can be changed after coming back',
      () async {
        final cubit = await loaded(
          items: [_item(1, selected: 1), _item(2)],
          active: _active(currentPosition: 1),
        );
        cubit.select(3);
        await cubit.flush();
        expect(cubit.state.answers[1], 3);
        verify(
          () => repository.answerItem(_examId, position: 1, selectedIndex: 3),
        ).called(1);
      },
    );

    test(
      'tapping the already-chosen option does nothing (double tap)',
      () async {
        final cubit = await loaded(items: [_item(1)]);
        cubit
          ..select(1)
          ..select(1);
        await cubit.flush();
        verify(
          () => repository.answerItem(_examId, position: 1, selectedIndex: 1),
        ).called(1);
      },
    );

    test(
      'writes go out one at a time, in order (no out-of-order save)',
      () async {
        final first = Completer<Result<void>>();
        final calls = <int>[];
        when(
          () => repository.answerItem(
            any(),
            position: any(named: 'position'),
            selectedIndex: any(named: 'selectedIndex'),
          ),
        ).thenAnswer((invocation) {
          final index = invocation.namedArguments[#selectedIndex] as int;
          calls.add(index);
          return index == 1 ? first.future : Future.value(const Success(null));
        });
        final cubit = await loaded(items: [_item(1)]);

        cubit
          ..select(1)
          ..select(2);
        await pumpEventQueue();
        // The second write hasn't even started while the first is pending.
        expect(calls, [1]);

        first.complete(const Success(null));
        await cubit.flush();
        expect(calls, [1, 2]);
        expect(cubit.state.currentAnswer, 2);
      },
    );

    test(
      'a failed save rolls the screen back to what the server has',
      () async {
        final cubit = await loaded(
          items: [_item(1, selected: 0)],
          active: _active(currentPosition: 1),
        );
        when(
          () => repository.answerItem(
            any(),
            position: any(named: 'position'),
            selectedIndex: any(named: 'selectedIndex'),
          ),
        ).thenAnswer(
          (_) async => Error(MockExamFailure(MockExamFailureKind.network)),
        );

        cubit.select(3);
        expect(cubit.state.currentAnswer, 3);
        await cubit.flush();

        expect(cubit.state.currentAnswer, 0);
        expect(cubit.state.hasSaveError, isTrue);

        cubit.dismissSaveError();
        expect(cubit.state.hasSaveError, isFalse);
      },
    );

    test('a failed first answer goes back to blank', () async {
      when(
        () => repository.answerItem(
          any(),
          position: any(named: 'position'),
          selectedIndex: any(named: 'selectedIndex'),
        ),
      ).thenAnswer(
        (_) async => Error(MockExamFailure(MockExamFailureKind.network)),
      );
      final cubit = await loaded(items: [_item(1)]);
      cubit.select(2);
      await cubit.flush();
      expect(cubit.state.currentAnswer, isNull);
      expect(cubit.state.unansweredCount, 1);
    });
  });

  group('navigation', () {
    test(
      'next/previous move and remember the position on the server',
      () async {
        final cubit = await loaded(items: [_item(1), _item(2), _item(3)]);

        cubit.next();
        expect(cubit.state.currentIndex, 1);
        cubit.next();
        cubit.previous();
        await cubit.flush();

        expect(cubit.state.currentIndex, 1);
        verifyInOrder([
          () => repository.setCurrentPosition(_examId, 2),
          () => repository.setCurrentPosition(_examId, 3),
          () => repository.setCurrentPosition(_examId, 2),
        ]);
      },
    );

    test('skipping without answering leaves the question blank', () async {
      final cubit = await loaded(items: [_item(1), _item(2), _item(3)]);
      cubit
        ..next()
        ..select(0)
        ..next();
      expect(cubit.state.answers, {2: 0});
      expect(cubit.state.unansweredCount, 2);
      expect(cubit.state.firstUnansweredIndex, 0);
    });

    test('going back shows the answer chosen there', () async {
      final cubit = await loaded(items: [_item(1), _item(2)]);
      cubit
        ..select(3)
        ..next()
        ..previous();
      expect(cubit.state.currentAnswer, 3);
    });

    test('cannot move past either end', () async {
      final cubit = await loaded(items: [_item(1), _item(2)]);
      cubit.previous();
      expect(cubit.state.currentIndex, 0);
      cubit
        ..next()
        ..next();
      expect(cubit.state.currentIndex, 1);
      expect(cubit.state.isLast, isTrue);
    });
  });

  group('finishing', () {
    const score = MockExamScore(
      scoredCount: 3,
      answeredCount: 1,
      correctCount: 1,
    );

    test('waits for pending answers, then grades once', () async {
      final pending = Completer<Result<void>>();
      when(
        () => repository.answerItem(
          any(),
          position: any(named: 'position'),
          selectedIndex: any(named: 'selectedIndex'),
        ),
      ).thenAnswer((_) => pending.future);
      when(
        () => repository.finishMockExam(_examId),
      ).thenAnswer((_) async => const Success(score));
      final cubit = await loaded(items: [_item(1), _item(2), _item(3)]);

      cubit.select(1);
      final finishing = cubit.finish();
      await pumpEventQueue();
      verifyNever(() => repository.finishMockExam(any()));

      pending.complete(const Success(null));
      final result = await finishing;

      expect(result, isA<MockExamFinished>());
      expect((result as MockExamFinished).score, score);
      expect(score.blankCount, 2);
      verify(() => repository.finishMockExam(_examId)).called(1);
    });

    test('a double submit grades only once', () async {
      final finish = Completer<Result<MockExamScore>>();
      when(
        () => repository.finishMockExam(_examId),
      ).thenAnswer((_) => finish.future);
      final cubit = await loaded(items: [_item(1)]);

      final first = cubit.finish();
      final second = await cubit.finish();
      expect(second, isA<MockExamFinishIgnored>());
      expect(cubit.state.isFinishing, isTrue);

      // Nothing can be answered or navigated while it's being graded.
      cubit.select(2);
      expect(cubit.state.currentAnswer, isNull);

      finish.complete(const Success(score));
      expect(await first, isA<MockExamFinished>());
      verify(() => repository.finishMockExam(_examId)).called(1);
    });

    test('a failed finish can be retried', () async {
      var call = 0;
      when(() => repository.finishMockExam(_examId)).thenAnswer((_) async {
        call++;
        return call == 1
            ? Error(MockExamFailure(MockExamFailureKind.network))
            : const Success(score);
      });
      final cubit = await loaded(items: [_item(1)]);

      final failed = await cubit.finish();
      expect(
        (failed as MockExamFinishFailed).failure.kind,
        MockExamFailureKind.network,
      );
      expect(cubit.state.isFinishing, isFalse);
      expect(cubit.state.status, MockExamRunnerStatus.ready);

      expect(await cubit.finish(), isA<MockExamFinished>());
    });

    test('finishing an exam that was closed elsewhere says so', () async {
      when(() => repository.finishMockExam(_examId)).thenAnswer(
        (_) async => Error(MockExamFailure(MockExamFailureKind.notInProgress)),
      );
      final cubit = await loaded(items: [_item(1)]);
      await cubit.finish();
      expect(cubit.state.status, MockExamRunnerStatus.notInProgress);
    });
  });

  group('abandoning', () {
    test('calls abandon and reports success', () async {
      when(
        () => repository.abandonMockExam(_examId),
      ).thenAnswer((_) async => const Success(null));
      final cubit = await loaded(items: [_item(1)]);

      expect(await cubit.abandon(), isNull);
      verify(() => repository.abandonMockExam(_examId)).called(1);
      verifyNever(() => repository.finishMockExam(any()));
    });

    test('a failed abandon reports why and unlocks the screen', () async {
      when(() => repository.abandonMockExam(_examId)).thenAnswer(
        (_) async => Error(MockExamFailure(MockExamFailureKind.network)),
      );
      final cubit = await loaded(items: [_item(1)]);

      final failure = await cubit.abandon();
      expect(failure?.kind, MockExamFailureKind.network);
      expect(cubit.state.isAbandoning, isFalse);
    });
  });
}
