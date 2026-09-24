import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_item.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_session_info.dart';
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

MockExamSessionInfo _inProgress({int? currentPosition}) => MockExamSessionInfo(
  status: MockExamStatus.inProgress,
  currentItemPosition: currentPosition,
);

MockExamFailure _closed(String status) =>
    MockExamFailure(MockExamFailureKind.notInProgress, serverStatus: status);

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

  void stubAnswers(Future<Result<void>> Function(int selected) answer) {
    when(
      () => repository.answerItem(
        any(),
        position: any(named: 'position'),
        selectedIndex: any(named: 'selectedIndex'),
      ),
    ).thenAnswer(
      (invocation) => answer(invocation.namedArguments[#selectedIndex] as int),
    );
  }

  void stubLoad({
    required List<MockExamItem> items,
    MockExamSessionInfo? session,
  }) {
    when(
      () => repository.getSession(_examId),
    ).thenAnswer((_) async => Success(session ?? _inProgress()));
    when(
      () => repository.getItems(_examId),
    ).thenAnswer((_) async => Success(items));
  }

  Future<MockExamRunnerCubit> loaded({
    required List<MockExamItem> items,
    MockExamSessionInfo? session,
  }) async {
    stubLoad(items: items, session: session);
    final cubit = MockExamRunnerCubit(repository, mockExamId: _examId);
    await pumpEventQueue();
    return cubit;
  }

  group('opening / resuming', () {
    test('a new exam opens on its first question, all blank', () async {
      final cubit = await loaded(items: [_item(1), _item(2), _item(3)]);

      expect(cubit.state.status, MockExamRunnerStatus.ready);
      expect(cubit.state.currentIndex, 0);
      expect(cubit.state.answeredCount, 0);
    });

    test('keeps the server order of questions AND of options', () async {
      final cubit = await loaded(
        items: [
          _item(3, options: const ['z', 'y', 'x']),
          _item(5),
          _item(7),
        ],
      );
      expect(cubit.state.items.map((i) => i.position), [3, 5, 7]);
      expect(cubit.state.items.first.options, ['z', 'y', 'x']);
    });

    test('resumes on the question being viewed, even if answered', () async {
      final cubit = await loaded(
        items: [_item(1, selected: 2), _item(2, selected: 0), _item(3)],
        session: _inProgress(currentPosition: 2),
      );
      expect(cubit.state.currentIndex, 1);
      expect(cubit.state.answers, {1: 2, 2: 0});
    });

    test(
      'left before answering anything: back on the first question',
      () async {
        final cubit = await loaded(items: [_item(1), _item(2)]);
        expect(cubit.state.currentIndex, 0);
      },
    );

    test('reopening always reads the server, never an old screen', () async {
      final first = await loaded(items: [_item(1), _item(2)]);
      first.select(1);
      await first.flush();
      await first.close();

      // Meanwhile another device changed the answer to 3 and moved on.
      final reopened = await loaded(
        items: [_item(1, selected: 3), _item(2)],
        session: _inProgress(currentPosition: 2),
      );
      expect(reopened.state.answers, {1: 3});
      expect(reopened.state.currentIndex, 1);
    });

    group('resumeIndex', () {
      final items = [
        _item(1, selected: 0),
        _item(2),
        _item(4, selected: 1),
        _item(5),
      ];

      test('saved position that exists', () {
        expect(MockExamRunnerCubit.resumeIndex(items, 4), 2);
      });

      test('saved position whose question was deleted: the next one', () {
        expect(MockExamRunnerCubit.resumeIndex(items, 3), 2);
      });

      test('no saved position: first blank question', () {
        expect(MockExamRunnerCubit.resumeIndex(items, null), 1);
      });

      test('invalid saved position: first blank question', () {
        expect(MockExamRunnerCubit.resumeIndex(items, 0), 1);
        expect(MockExamRunnerCubit.resumeIndex(items, -7), 1);
        expect(MockExamRunnerCubit.resumeIndex(items, 99), 1);
      });

      test('everything answered and no usable position: the last one', () {
        final all = [_item(1, selected: 0), _item(2, selected: 1)];
        expect(MockExamRunnerCubit.resumeIndex(all, null), 1);
        expect(MockExamRunnerCubit.resumeIndex(all, 42), 1);
      });

      test('never out of range', () {
        expect(MockExamRunnerCubit.resumeIndex(const [], 5), 0);
      });
    });

    test('finished elsewhere before opening: says so, no answering', () async {
      final cubit = await loaded(
        items: [_item(1)],
        session: const MockExamSessionInfo(status: MockExamStatus.finished),
      );
      expect(cubit.state.status, MockExamRunnerStatus.finishedElsewhere);
      cubit.select(1);
      verifyNever(
        () => repository.answerItem(
          any(),
          position: any(named: 'position'),
          selectedIndex: any(named: 'selectedIndex'),
        ),
      );
    });

    test('abandoned elsewhere before opening', () async {
      final cubit = await loaded(
        items: [_item(1)],
        session: const MockExamSessionInfo(status: MockExamStatus.abandoned),
      );
      expect(cubit.state.status, MockExamRunnerStatus.abandonedElsewhere);
    });

    test('no such exam', () async {
      when(
        () => repository.getSession(_examId),
      ).thenAnswer((_) async => const Success(null));
      when(
        () => repository.getItems(_examId),
      ).thenAnswer((_) async => const Success([]));
      final cubit = MockExamRunnerCubit(repository, mockExamId: _examId);
      await pumpEventQueue();
      expect(cubit.state.status, MockExamRunnerStatus.notFound);
    });

    test('status unknown (network): never opens as answerable', () async {
      // Bug found in FASE 7: before, a failed status lookup plus a
      // successful item load opened a possibly-finished exam as ready.
      when(() => repository.getSession(_examId)).thenAnswer(
        (_) async => Error(MockExamFailure(MockExamFailureKind.network)),
      );
      when(
        () => repository.getItems(_examId),
      ).thenAnswer((_) async => Success([_item(1)]));
      final cubit = MockExamRunnerCubit(repository, mockExamId: _examId);
      await pumpEventQueue();
      expect(cubit.state.status, MockExamRunnerStatus.loadError);

      when(
        () => repository.getSession(_examId),
      ).thenAnswer((_) async => Success(_inProgress()));
      await cubit.load();
      expect(cubit.state.status, MockExamRunnerStatus.ready);
    });

    test('questions fail to load: error, retry recovers', () async {
      when(
        () => repository.getSession(_examId),
      ).thenAnswer((_) async => Success(_inProgress()));
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
    });
  });

  group('answering', () {
    test('B then C then D, fast: serialized, D wins', () async {
      final gates = {1: Completer<void>(), 2: Completer<void>()};
      final started = <int>[];
      stubAnswers((selected) async {
        started.add(selected);
        await gates[selected]?.future;
        return const Success(null);
      });
      final cubit = await loaded(items: [_item(1)]);

      cubit
        ..select(1)
        ..select(2)
        ..select(3);
      await pumpEventQueue();
      expect(started, [1], reason: 'the 2nd write waits for the 1st');

      gates[1]!.complete();
      await pumpEventQueue();
      expect(started, [1, 2]);
      gates[2]!.complete();
      await cubit.flush();

      expect(started, [1, 2, 3]);
      expect(cubit.state.currentAnswer, 3);
      expect(cubit.state.isSaving, isFalse);
    });

    test('B -> C then leave at once: C is what the server gets last', () async {
      final sent = <int>[];
      stubAnswers((selected) async {
        sent.add(selected);
        return const Success(null);
      });
      final cubit = await loaded(items: [_item(1)]);
      cubit
        ..select(1)
        ..select(2);
      // Leaving waits on flush() -- the real queue, no timer.
      await cubit.flush();
      expect(sent.last, 2);
    });

    test('B -> C -> B: the second B is the one that counts', () async {
      final gate = Completer<void>();
      var calls = 0;
      stubAnswers((selected) async {
        calls++;
        if (calls == 1) await gate.future;
        // The last write (the second B) fails.
        return calls == 3
            ? Error(MockExamFailure(MockExamFailureKind.network))
            : const Success(null);
      });
      final cubit = await loaded(items: [_item(1)]);
      cubit
        ..select(1)
        ..select(2)
        ..select(1);
      gate.complete();
      await cubit.flush();

      // Server has C (2); the screen must not keep showing B.
      expect(cubit.state.currentAnswer, 2);
      expect(cubit.state.hasSaveError, isTrue);
    });

    test('a failed save never pretends to be saved', () async {
      final cubit = await loaded(
        items: [_item(1, selected: 0)],
        session: _inProgress(currentPosition: 1),
      );
      stubAnswers(
        (_) async => Error(MockExamFailure(MockExamFailureKind.network)),
      );

      cubit.select(3);
      expect(cubit.state.currentAnswer, 3);
      await cubit.flush();

      expect(cubit.state.currentAnswer, 0);
      expect(cubit.state.hasSaveError, isTrue);
    });

    test('network back: tapping again saves it', () async {
      var fail = true;
      stubAnswers(
        (_) async => fail
            ? Error(MockExamFailure(MockExamFailureKind.network))
            : const Success(null),
      );
      final cubit = await loaded(items: [_item(1)]);
      cubit.select(2);
      await cubit.flush();
      expect(cubit.state.currentAnswer, isNull);

      fail = false;
      cubit.select(2);
      await cubit.flush();
      expect(cubit.state.currentAnswer, 2);
      expect(cubit.state.hasSaveError, isFalse);
    });

    test('a failed position save is dropped silently (not an error)', () async {
      when(() => repository.setCurrentPosition(any(), any())).thenAnswer(
        (_) async => Error(MockExamFailure(MockExamFailureKind.network)),
      );
      final cubit = await loaded(items: [_item(1), _item(2)]);
      cubit.next();
      await cubit.flush();
      expect(cubit.state.status, MockExamRunnerStatus.ready);
      expect(cubit.state.currentIndex, 1);
      expect(cubit.state.hasSaveError, isFalse);
    });
  });

  group('closed on another device while open', () {
    test('finished elsewhere: next answer switches to "já entregue"', () async {
      // Bug found in FASE 7: this used to roll back and say "tap again"
      // forever.
      final cubit = await loaded(items: [_item(1), _item(2)]);
      stubAnswers((_) async => Error(_closed('finished')));

      cubit.select(1);
      await cubit.flush();

      expect(cubit.state.status, MockExamRunnerStatus.finishedElsewhere);
      expect(cubit.state.hasSaveError, isFalse);
    });

    test('abandoned elsewhere: detected on navigation too', () async {
      final cubit = await loaded(items: [_item(1), _item(2)]);
      when(
        () => repository.setCurrentPosition(any(), any()),
      ).thenAnswer((_) async => Error(_closed('abandoned')));

      cubit.next();
      await cubit.flush();

      expect(cubit.state.status, MockExamRunnerStatus.abandonedElsewhere);
    });

    test('once closed, queued writes stop hitting the server', () async {
      var calls = 0;
      stubAnswers((_) async {
        calls++;
        return Error(_closed('finished'));
      });
      final cubit = await loaded(items: [_item(1), _item(2)]);
      cubit.select(1);
      await cubit.flush();
      cubit.select(2);
      await cubit.flush();
      expect(calls, 1);
    });

    test('unknown reason: asks the server which one it was', () async {
      final cubit = await loaded(items: [_item(1)]);
      stubAnswers(
        (_) async => Error(MockExamFailure(MockExamFailureKind.notInProgress)),
      );
      when(() => repository.getSession(_examId)).thenAnswer(
        (_) async => const Success(
          MockExamSessionInfo(status: MockExamStatus.abandoned),
        ),
      );
      cubit.select(1);
      await cubit.flush();
      expect(cubit.state.status, MockExamRunnerStatus.abandonedElsewhere);
    });
  });

  group('question removed from the bank', () {
    test(
      'removed mid-session: reloads without it, keeps the answers',
      () async {
        final cubit = await loaded(
          items: [_item(1, selected: 0), _item(2), _item(3)],
          session: _inProgress(currentPosition: 2),
        );
        // Question 2 gets deleted; answering it is refused.
        stubAnswers(
          (_) async => Error(MockExamFailure(MockExamFailureKind.itemRemoved)),
        );
        when(
          () => repository.getItems(_examId),
        ).thenAnswer((_) async => Success([_item(1, selected: 0), _item(3)]));

        cubit.select(1);
        await cubit.flush();

        expect(cubit.state.status, MockExamRunnerStatus.ready);
        expect(cubit.state.totalCount, 2);
        // Lands on the question right after the one that disappeared.
        expect(cubit.state.currentItem.position, 3);
        expect(cubit.state.answers, {1: 0});
        expect(cubit.state.hasRemovedQuestionNotice, isTrue);
        expect(cubit.state.hasSaveError, isFalse);

        cubit.dismissRemovedQuestionNotice();
        expect(cubit.state.hasRemovedQuestionNotice, isFalse);
      },
    );

    test('a pending tap on another question survives the reload', () async {
      final gate = Completer<void>();
      var call = 0;
      when(
        () => repository.answerItem(
          any(),
          position: any(named: 'position'),
          selectedIndex: any(named: 'selectedIndex'),
        ),
      ).thenAnswer((invocation) async {
        call++;
        final position = invocation.namedArguments[#position] as int;
        if (position == 2) {
          return Error(MockExamFailure(MockExamFailureKind.itemRemoved));
        }
        await gate.future;
        return const Success(null);
      });
      final cubit = await loaded(
        items: [_item(1), _item(2), _item(3)],
        session: _inProgress(currentPosition: 2),
      );
      when(
        () => repository.getItems(_examId),
      ).thenAnswer((_) async => Success([_item(1), _item(3)]));

      cubit
        ..select(0) // on question 2 (removed)
        ..next()
        ..select(3); // on question 3, still queued during the reload
      await pumpEventQueue();
      expect(cubit.state.answers[3], 3);

      gate.complete();
      await cubit.flush();
      expect(cubit.state.answers, {3: 3});
      expect(call, 2);
    });

    test('total always matches what the server returned', () async {
      final cubit = await loaded(items: [_item(1), _item(3), _item(4)]);
      expect(cubit.state.totalCount, 3);
      expect(cubit.state.unansweredCount, 3);
    });
  });

  group('handing in', () {
    test('waits for pending answers, then grades once', () async {
      final pending = Completer<void>();
      stubAnswers((_) async {
        await pending.future;
        return const Success(null);
      });
      when(
        () => repository.finishMockExam(_examId),
      ).thenAnswer((_) async => const Success(null));
      final cubit = await loaded(items: [_item(1), _item(2), _item(3)]);

      cubit.select(1);
      final finishing = cubit.finish();
      await pumpEventQueue();
      verifyNever(() => repository.finishMockExam(any()));

      pending.complete();
      expect(await finishing, isA<MockExamFinished>());
      verify(() => repository.finishMockExam(_examId)).called(1);
    });

    test('double submit grades only once and locks the screen', () async {
      final finish = Completer<Result<void>>();
      when(
        () => repository.finishMockExam(_examId),
      ).thenAnswer((_) => finish.future);
      final cubit = await loaded(items: [_item(1)]);

      final first = cubit.finish();
      expect(await cubit.finish(), isA<MockExamFinishIgnored>());
      cubit.select(2);
      expect(cubit.state.currentAnswer, isNull);

      finish.complete(const Success(null));
      expect(await first, isA<MockExamFinished>());
      verify(() => repository.finishMockExam(_examId)).called(1);
    });

    test('a failed hand-in can be retried', () async {
      var call = 0;
      when(() => repository.finishMockExam(_examId)).thenAnswer((_) async {
        call++;
        return call == 1
            ? Error(MockExamFailure(MockExamFailureKind.network))
            : const Success(null);
      });
      final cubit = await loaded(items: [_item(1)]);

      expect(await cubit.finish(), isA<MockExamFinishFailed>());
      expect(cubit.state.isFinishing, isFalse);
      expect(await cubit.finish(), isA<MockExamFinished>());
    });

    test('already handed in elsewhere: goes to the result', () async {
      // finish_mock_exam() on a finished exam returns its grade.
      when(
        () => repository.finishMockExam(_examId),
      ).thenAnswer((_) async => const Success(null));
      final cubit = await loaded(items: [_item(1)]);
      expect(await cubit.finish(), isA<MockExamFinished>());
    });

    test(
      'a pending answer found it finished: result, no finish call',
      () async {
        stubAnswers((_) async => Error(_closed('finished')));
        final cubit = await loaded(items: [_item(1)]);
        cubit.select(1);
        expect(await cubit.finish(), isA<MockExamFinished>());
        verifyNever(() => repository.finishMockExam(any()));
      },
    );

    test('abandoned elsewhere at hand-in: no result, screen says so', () async {
      when(
        () => repository.finishMockExam(_examId),
      ).thenAnswer((_) async => Error(_closed('abandoned')));
      final cubit = await loaded(items: [_item(1)]);

      expect(await cubit.finish(), isA<MockExamFinishIgnored>());
      expect(cubit.state.status, MockExamRunnerStatus.abandonedElsewhere);
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

    test(
      'abandoning one that was already handed in shows the result',
      () async {
        when(
          () => repository.abandonMockExam(_examId),
        ).thenAnswer((_) async => Error(_closed('finished')));
        final cubit = await loaded(items: [_item(1)]);

        expect(await cubit.abandon(), isNull);
        expect(cubit.state.status, MockExamRunnerStatus.finishedElsewhere);
      },
    );

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
