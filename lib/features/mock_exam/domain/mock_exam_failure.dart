import 'package:aura/core/error/failures.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_difficulty.dart';

/// What went wrong talking to the mock exam RPCs. The UI turns [kind] into
/// a human sentence (MockExamStrings.failureMessage) -- the raw Postgres
/// message/detail never reaches the screen.
enum MockExamFailureKind {
  /// create_mock_exam(): the user already has one in progress.
  alreadyActive,

  /// create_mock_exam(): availability dropped below what was asked
  /// between loading the screen and starting.
  insufficientQuestions,

  /// create_mock_exam(): the server rejected the config shape.
  invalidConfig,

  /// create_mock_exam(): more than 180 questions in total.
  totalExceeded,

  /// The exam isn't in progress any more (finished or abandoned, maybe on
  /// another device). [MockExamFailure.serverStatus] says which, when the
  /// server told us.
  notInProgress,

  /// The question at that position no longer exists (deleted from the
  /// bank after the exam was created) -- the session should reload.
  itemRemoved,

  /// The server never answered (no connection, timeout, ...).
  network,

  /// The server answered with something we don't recognize.
  unexpected,
}

class MockExamFailure extends Failure {
  MockExamFailure(
    this.kind, {
    this.activeMockExamId,
    this.subject,
    this.difficulty,
    this.available,
    this.serverStatus,
  }) : super(kind.name);

  /// Maps the "message"/"detail" that supabase/mock_exams.sql raises.
  factory MockExamFailure.fromServer(String message, Object? details) {
    final detail = details?.toString() ?? '';
    switch (message) {
      case 'mock_exam_already_active':
        return MockExamFailure(
          MockExamFailureKind.alreadyActive,
          activeMockExamId: detail.isEmpty ? null : detail,
        );
      case 'mock_exam_insufficient_questions':
        // "subject:difficulty:available", or free text for the
        // drew-fewer-than-asked race -- only the first shape has fields.
        final parts = detail.split(':');
        return MockExamFailure(
          MockExamFailureKind.insufficientQuestions,
          subject: parts.length == 3 ? parts[0] : null,
          difficulty: parts.length == 3
              ? MockExamDifficulty.fromDb(parts[1])
              : null,
          available: parts.length == 3 ? int.tryParse(parts[2]) : null,
        );
      case 'mock_exam_invalid_config':
        return MockExamFailure(MockExamFailureKind.invalidConfig);
      case 'mock_exam_total_exceeded':
        return MockExamFailure(MockExamFailureKind.totalExceeded);
      case 'mock_exam_not_in_progress':
        // detail is the exam's current status: 'finished' / 'abandoned'.
        return MockExamFailure(
          MockExamFailureKind.notInProgress,
          serverStatus: detail.isEmpty ? null : detail,
        );
      case 'mock_exam_already_finished':
        return MockExamFailure(
          MockExamFailureKind.notInProgress,
          serverStatus: 'finished',
        );
      case 'mock_exam_abandoned':
        return MockExamFailure(
          MockExamFailureKind.notInProgress,
          serverStatus: 'abandoned',
        );
      case 'mock_exam_not_found':
        return MockExamFailure(MockExamFailureKind.notInProgress);
      case 'mock_exam_invalid_answer':
        return MockExamFailure(MockExamFailureKind.itemRemoved);
      default:
        return MockExamFailure(MockExamFailureKind.unexpected);
    }
  }

  final MockExamFailureKind kind;
  final String? activeMockExamId;
  final String? subject;
  final MockExamDifficulty? difficulty;
  final int? available;

  /// 'finished' / 'abandoned' for [MockExamFailureKind.notInProgress],
  /// when the server said.
  final String? serverStatus;

  @override
  List<Object?> get props => [
    kind,
    activeMockExamId,
    subject,
    difficulty,
    available,
    serverStatus,
  ];
}
