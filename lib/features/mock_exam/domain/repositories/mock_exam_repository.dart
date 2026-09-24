import 'package:aura/core/error/result.dart';
import 'package:aura/features/mock_exam/domain/entities/active_mock_exam.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_availability.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_item.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_result.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_session_info.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_subject_config.dart';

/// Every Error returned here carries a MockExamFailure.
abstract class MockExamRepository {
  Future<Result<MockExamAvailability>> getAvailability();

  /// Success(null) when the user has no exam in progress.
  Future<Result<ActiveMockExam?>> getActiveMockExam();

  /// Returns the new exam's id. The server re-validates everything.
  Future<Result<String>> createMockExam(List<MockExamSubjectConfig> config);

  Future<Result<void>> abandonMockExam(String mockExamId);

  /// Status + resume position of one exam (any status). Success(null) when
  /// there is no such exam for this user.
  Future<Result<MockExamSessionInfo?>> getSession(String mockExamId);

  /// The exam's questions in their frozen order, with the answers given so
  /// far. Never includes the correct answer while the exam is in progress.
  Future<Result<List<MockExamItem>>> getItems(String mockExamId);

  /// Records (or replaces) the option picked for [position]. [selectedIndex]
  /// is the index as shown -- the server maps it back through option_order.
  Future<Result<void>> answerItem(
    String mockExamId, {
    required int position,
    required int selectedIndex,
  });

  /// Remembers which question the user is looking at, for resuming.
  Future<Result<void>> setCurrentPosition(String mockExamId, int position);

  /// Grades on the server and applies the result. Safe to call again: a
  /// finished exam just succeeds again with no new effect. The grade itself
  /// is read afterwards by id (getResult), never carried from here.
  Future<Result<void>> finishMockExam(String mockExamId);

  /// The finished exam's result, read from the server by id. Success(null)
  /// when there is no finished exam with that id for this user. Reading is
  /// side-effect free: it never grades or awards anything.
  Future<Result<MockExamResult?>> getResult(String mockExamId);
}
