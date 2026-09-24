import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/mock_exam/domain/entities/active_mock_exam.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_availability.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_difficulty.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_subject_config.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_setup_cubit.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_setup_state.dart';

class _MockMockExamRepository extends Mock implements MockExamRepository {}

const _f = MockExamDifficulty.facil;
const _m = MockExamDifficulty.medio;
const _d = MockExamDifficulty.dificil;
const _x = MockExamDifficulty.misto;

Map<MockExamDifficulty, int> _counts(int facil, int medio, int dificil) => {
  _f: facil,
  _m: medio,
  _d: dificil,
  _x: facil + medio + dificil,
};

// The real numbers in the database when this feature was built, plus
// Atualidades (must never be offered) and a subject with a level at 0.
final _availability = MockExamAvailability({
  'geografia': _counts(142, 178, 63),
  'historia': _counts(79, 46, 21),
  'portugues': _counts(59, 61, 18),
  'biologia': _counts(70, 199, 53),
  'fisica': _counts(58, 95, 42),
  'matematica': _counts(82, 66, 22),
  'quimica': _counts(3, 0, 0),
  'atualidades': _counts(10, 10, 10),
});

void main() {
  late MockExamRepository repository;

  setUpAll(() {
    registerFallbackValue(<MockExamSubjectConfig>[]);
  });

  setUp(() {
    repository = _MockMockExamRepository();
    when(
      () => repository.getAvailability(),
    ).thenAnswer((_) async => Success(_availability));
  });

  Future<MockExamSetupCubit> loadedCubit() async {
    final cubit = MockExamSetupCubit(repository);
    await pumpEventQueue();
    return cubit;
  }

  List<int> climb(MockExamSetupCubit cubit, String subject) {
    final values = <int>[cubit.state.selections[subject]!.questionCount];
    while (cubit.state.canIncrease(subject)) {
      cubit.increase(subject);
      values.add(cubit.state.selections[subject]!.questionCount);
    }
    return values;
  }

  group('loading', () {
    test(
      'starts loading, then offers the real subjects in app order',
      () async {
        final cubit = MockExamSetupCubit(repository);
        expect(cubit.state.status, MockExamSetupStatus.loading);
        expect(cubit.state.canStart, isFalse);

        await pumpEventQueue();

        expect(cubit.state.status, MockExamSetupStatus.ready);
        expect(cubit.state.subjects, [
          'matematica',
          'geografia',
          'historia',
          'portugues',
          'biologia',
          'fisica',
          'quimica',
        ]);
        expect(cubit.state.subjects, isNot(contains('atualidades')));
        expect(cubit.state.available('geografia', _d), 63);
      },
    );

    test('a failed load shows the error state, and retry recovers', () async {
      when(() => repository.getAvailability()).thenAnswer(
        (_) async => Error(MockExamFailure(MockExamFailureKind.network)),
      );
      final cubit = await loadedCubit();
      expect(cubit.state.status, MockExamSetupStatus.loadError);

      when(
        () => repository.getAvailability(),
      ).thenAnswer((_) async => Success(_availability));
      await cubit.load();
      expect(cubit.state.status, MockExamSetupStatus.ready);
    });
  });

  group('selection', () {
    test('selecting starts at Misto with the first valid count', () async {
      final cubit = await loadedCubit();
      cubit.toggleSubject('geografia');

      expect(
        cubit.state.selections['geografia'],
        const MockExamSubjectConfig(
          subject: 'geografia',
          difficulty: _x,
          questionCount: 5,
        ),
      );
      expect(cubit.state.canStart, isTrue);
    });

    test('a subject with fewer than 5 questions starts at its total', () async {
      final cubit = await loadedCubit();
      cubit.toggleSubject('quimica');
      expect(cubit.state.selections['quimica']!.questionCount, 3);
      expect(cubit.state.canIncrease('quimica'), isFalse);
      expect(cubit.state.canDecrease('quimica'), isFalse);
    });

    test('deselecting drops the count; reselecting starts fresh', () async {
      final cubit = await loadedCubit();
      cubit
        ..toggleSubject('geografia')
        ..setDifficulty('geografia', _d)
        ..increase('geografia')
        ..increase('geografia');
      expect(cubit.state.totalQuestions, 15);

      cubit.toggleSubject('geografia');
      expect(cubit.state.isSelected('geografia'), isFalse);
      expect(cubit.state.totalQuestions, 0);
      expect(cubit.state.canStart, isFalse);

      cubit.toggleSubject('geografia');
      expect(
        cubit.state.selections['geografia'],
        const MockExamSubjectConfig(
          subject: 'geografia',
          difficulty: _x,
          questionCount: 5,
        ),
      );
    });

    test('total and subject count add up across subjects', () async {
      final cubit = await loadedCubit();
      cubit
        ..toggleSubject('geografia')
        ..toggleSubject('historia')
        ..increase('historia');
      expect(cubit.state.selectedSubjectCount, 2);
      expect(cubit.state.totalQuestions, 15);
      expect(cubit.state.orderedSelections.map((e) => e.subject), [
        'geografia',
        'historia',
      ]);
    });
  });

  group('difficulty', () {
    test('switching level shows that level\'s real availability', () async {
      final cubit = await loadedCubit();
      cubit
        ..toggleSubject('geografia')
        ..setDifficulty('geografia', _f);
      final entry = cubit.state.selections['geografia']!;
      expect(entry.difficulty, _f);
      expect(cubit.state.available('geografia', entry.difficulty), 142);
    });

    test('Misto 100 -> Difícil lowers the count to the new max 63', () async {
      final cubit = await loadedCubit();
      cubit.toggleSubject('geografia');
      while (cubit.state.selections['geografia']!.questionCount < 100) {
        cubit.increase('geografia');
      }
      expect(cubit.state.selections['geografia']!.questionCount, 100);

      cubit.setDifficulty('geografia', _d);
      expect(cubit.state.selections['geografia']!.questionCount, 63);
      expect(cubit.state.canIncrease('geografia'), isFalse);
    });

    test('a level with 0 questions cannot be picked', () async {
      final cubit = await loadedCubit();
      cubit
        ..toggleSubject('quimica')
        ..setDifficulty('quimica', _m);
      expect(cubit.state.selections['quimica']!.difficulty, _x);
    });
  });

  group('quantity', () {
    test('História difícil (21): 5, 10, 15, 20, 21', () async {
      final cubit = await loadedCubit();
      cubit
        ..toggleSubject('historia')
        ..setDifficulty('historia', _d);
      expect(climb(cubit, 'historia'), [5, 10, 15, 20, 21]);
    });

    test('Português difícil (18): 5, 10, 15, 18 -- and back down', () async {
      final cubit = await loadedCubit();
      cubit
        ..toggleSubject('portugues')
        ..setDifficulty('portugues', _d);
      expect(climb(cubit, 'portugues'), [5, 10, 15, 18]);

      final down = <int>[];
      while (cubit.state.canDecrease('portugues')) {
        cubit.decrease('portugues');
        down.add(cubit.state.selections['portugues']!.questionCount);
      }
      expect(down, [15, 10, 5]);
    });

    test('never goes above the level\'s availability', () async {
      final cubit = await loadedCubit();
      cubit
        ..toggleSubject('matematica')
        ..setDifficulty('matematica', _d);
      for (var i = 0; i < 20; i++) {
        cubit.increase('matematica');
      }
      expect(cubit.state.selections['matematica']!.questionCount, 22);
    });
  });

  group('180 global limit', () {
    Future<MockExamSetupCubit> cubitAt173() async {
      final cubit = await loadedCubit();
      // biologia misto 322 -> 170, then quimica 3 = 173.
      cubit.toggleSubject('biologia');
      while (cubit.state.selections['biologia']!.questionCount < 170) {
        cubit.increase('biologia');
      }
      cubit.toggleSubject('quimica');
      expect(cubit.state.totalQuestions, 173);
      return cubit;
    }

    test('a new subject can only take what is left (7)', () async {
      final cubit = await cubitAt173();
      cubit.toggleSubject('fisica');
      expect(climb(cubit, 'fisica'), [5, 7]);
      expect(cubit.state.totalQuestions, 180);
      expect(cubit.state.isAtGlobalLimit, isTrue);
      expect(cubit.state.canStart, isTrue);
    });

    test('at 180, no subject can be added or increased', () async {
      final cubit = await cubitAt173();
      cubit
        ..toggleSubject('fisica')
        ..increase('fisica');
      expect(cubit.state.totalQuestions, 180);

      expect(cubit.state.canSelect('geografia'), isFalse);
      cubit.toggleSubject('geografia');
      expect(cubit.state.isSelected('geografia'), isFalse);
      expect(cubit.state.canIncrease('biologia'), isFalse);
      cubit.increase('biologia');
      expect(cubit.state.totalQuestions, 180);
    });

    test('switching level never pushes the total past 180', () async {
      final cubit = await cubitAt173();
      cubit
        ..toggleSubject('fisica')
        ..increase('fisica')
        ..setDifficulty('fisica', _f);
      expect(cubit.state.totalQuestions, lessThanOrEqualTo(180));
    });
  });

  group('submit', () {
    test('sends the selection and returns the new exam id', () async {
      when(
        () => repository.createMockExam(any()),
      ).thenAnswer((_) async => const Success('e1'));
      final cubit = await loadedCubit();
      cubit
        ..toggleSubject('geografia')
        ..setDifficulty('geografia', _d);

      final result = await cubit.submit();

      expect(result, isA<MockExamCreated>());
      expect((result as MockExamCreated).mockExamId, 'e1');
      verify(
        () => repository.createMockExam(const [
          MockExamSubjectConfig(
            subject: 'geografia',
            difficulty: _d,
            questionCount: 5,
          ),
        ]),
      ).called(1);
      expect(cubit.state.isSubmitting, isFalse);
    });

    test('the button is disabled while creating', () async {
      when(() => repository.createMockExam(any())).thenAnswer((_) async {
        await Future<void>.delayed(Duration.zero);
        return const Success('e1');
      });
      final cubit = await loadedCubit();
      cubit.toggleSubject('geografia');

      final pending = cubit.submit();
      expect(cubit.state.isSubmitting, isTrue);
      expect(cubit.state.canStart, isFalse);
      await pending;
      expect(cubit.state.canStart, isTrue);
    });

    test('with nothing selected, never calls the server', () async {
      final cubit = await loadedCubit();
      final result = await cubit.submit();
      expect(result, isA<MockExamSubmitFailed>());
      verifyNever(() => repository.createMockExam(any()));
    });

    test('an exam already in progress comes back with its progress', () async {
      when(() => repository.createMockExam(any())).thenAnswer(
        (_) async => Error(
          MockExamFailure(
            MockExamFailureKind.alreadyActive,
            activeMockExamId: 'e0',
          ),
        ),
      );
      when(() => repository.getActiveMockExam()).thenAnswer(
        (_) async => const Success(
          ActiveMockExam(id: 'e0', questionCount: 90, answeredCount: 37),
        ),
      );
      final cubit = await loadedCubit();
      cubit.toggleSubject('geografia');

      final result = await cubit.submit();

      expect(result, isA<MockExamAlreadyActive>());
      expect(
        (result as MockExamAlreadyActive).active,
        const ActiveMockExam(id: 'e0', questionCount: 90, answeredCount: 37),
      );
      // Nothing was discarded on the user's behalf.
      verifyNever(() => repository.abandonMockExam(any()));
      expect(cubit.state.isSelected('geografia'), isTrue);
    });

    test(
      'discarding the active exam calls abandon and reports success',
      () async {
        when(
          () => repository.abandonMockExam('e0'),
        ).thenAnswer((_) async => const Success(null));
        final cubit = await loadedCubit();

        expect(await cubit.discardActive('e0'), isNull);
        verify(() => repository.abandonMockExam('e0')).called(1);
      },
    );

    test('a failed discard reports why', () async {
      when(() => repository.abandonMockExam('e0')).thenAnswer(
        (_) async => Error(MockExamFailure(MockExamFailureKind.network)),
      );
      final cubit = await loadedCubit();

      final failure = await cubit.discardActive('e0');
      expect(failure?.kind, MockExamFailureKind.network);
    });

    test(
      'availability dropped: reloads and pulls the selection back in',
      () async {
        when(() => repository.createMockExam(any())).thenAnswer(
          (_) async => Error(
            MockExamFailure(
              MockExamFailureKind.insufficientQuestions,
              subject: 'portugues',
              difficulty: _d,
              available: 12,
            ),
          ),
        );
        final cubit = await loadedCubit();
        cubit
          ..toggleSubject('portugues')
          ..setDifficulty('portugues', _d);
        climb(cubit, 'portugues');
        expect(cubit.state.selections['portugues']!.questionCount, 18);

        when(() => repository.getAvailability()).thenAnswer(
          (_) async => Success(
            MockExamAvailability({
              ..._availabilityMap(),
              'portugues': _counts(59, 61, 12),
            }),
          ),
        );
        final result = await cubit.submit();

        expect(result, isA<MockExamSubmitFailed>());
        expect(
          (result as MockExamSubmitFailed).failure.kind,
          MockExamFailureKind.insufficientQuestions,
        );
        expect(cubit.state.available('portugues', _d), 12);
        expect(cubit.state.selections['portugues']!.questionCount, 12);
        expect(cubit.state.isSubmitting, isFalse);
      },
    );

    test('network / unexpected errors come back as failures', () async {
      when(() => repository.createMockExam(any())).thenAnswer(
        (_) async => Error(MockExamFailure(MockExamFailureKind.network)),
      );
      final cubit = await loadedCubit();
      cubit.toggleSubject('geografia');

      final result = await cubit.submit();
      expect(
        (result as MockExamSubmitFailed).failure.kind,
        MockExamFailureKind.network,
      );
      expect(cubit.state.canStart, isTrue);
    });
  });
}

Map<String, Map<MockExamDifficulty, int>> _availabilityMap() => {
  'geografia': _counts(142, 178, 63),
  'historia': _counts(79, 46, 21),
  'biologia': _counts(70, 199, 53),
  'fisica': _counts(58, 95, 42),
  'matematica': _counts(82, 66, 22),
  'quimica': _counts(3, 0, 0),
};
