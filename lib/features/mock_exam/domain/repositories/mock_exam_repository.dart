import 'package:aura/core/error/result.dart';
import 'package:aura/features/mock_exam/domain/entities/active_mock_exam.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_availability.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_item.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_score.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_subject_config.dart';

/// Every Error returned here carries a MockExamFailure.
abstract class MockExamRepository {
  Future<Result<MockExamAvailability>> getAvailability();

  /// Success(null) when the user has no exam in progress.
  Future<Result<ActiveMockExam?>> getActiveMockExam();

  /// Returns the new exam's id. The server re-validates everything.
  Future<Result<String>> createMockExam(List<MockExamSubjectConfig> config);

  Future<Result<void>> abandonMockExam(String mockExamId);

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
  /// finished exam just returns the grade it already has.
  Future<Result<MockExamScore>> finishMockExam(String mockExamId);
}
