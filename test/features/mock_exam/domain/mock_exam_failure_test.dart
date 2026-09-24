import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_difficulty.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';

void main() {
  group('MockExamFailure.fromServer', () {
    test('already active carries the id of the exam in progress', () {
      final failure = MockExamFailure.fromServer(
        'mock_exam_already_active',
        'e1',
      );
      expect(failure.kind, MockExamFailureKind.alreadyActive);
      expect(failure.activeMockExamId, 'e1');
    });

    test('insufficient questions parses subject:difficulty:available', () {
      final failure = MockExamFailure.fromServer(
        'mock_exam_insufficient_questions',
        'portugues:dificil:12',
      );
      expect(failure.kind, MockExamFailureKind.insufficientQuestions);
      expect(failure.subject, 'portugues');
      expect(failure.difficulty, MockExamDifficulty.dificil);
      expect(failure.available, 12);
    });

    test('insufficient questions without fields (draw race) still maps', () {
      final failure = MockExamFailure.fromServer(
        'mock_exam_insufficient_questions',
        'requested 90, drew 88',
      );
      expect(failure.kind, MockExamFailureKind.insufficientQuestions);
      expect(failure.subject, isNull);
      expect(failure.available, isNull);
    });

    test('maps config and total errors', () {
      expect(
        MockExamFailure.fromServer('mock_exam_invalid_config', 'x').kind,
        MockExamFailureKind.invalidConfig,
      );
      expect(
        MockExamFailure.fromServer('mock_exam_total_exceeded', '200').kind,
        MockExamFailureKind.totalExceeded,
      );
    });

    test('every "not in progress any more" code maps to one kind', () {
      for (final code in [
        'mock_exam_not_in_progress',
        'mock_exam_already_finished',
        'mock_exam_abandoned',
        'mock_exam_not_found',
      ]) {
        expect(
          MockExamFailure.fromServer(code, null).kind,
          MockExamFailureKind.notInProgress,
          reason: code,
        );
      }
    });

    test('an unknown server message never leaks through as-is', () {
      final failure = MockExamFailure.fromServer(
        'duplicate key value violates unique constraint',
        null,
      );
      expect(failure.kind, MockExamFailureKind.unexpected);
      expect(failure.message, isNot(contains('duplicate key')));
    });
  });
}
