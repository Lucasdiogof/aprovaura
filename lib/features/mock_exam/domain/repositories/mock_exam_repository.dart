import 'package:aura/core/error/result.dart';
import 'package:aura/features/mock_exam/domain/entities/active_mock_exam.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_availability.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_subject_config.dart';

/// Every Error returned here carries a MockExamFailure.
abstract class MockExamRepository {
  Future<Result<MockExamAvailability>> getAvailability();

  /// Success(null) when the user has no exam in progress.
  Future<Result<ActiveMockExam?>> getActiveMockExam();

  /// Returns the new exam's id. The server re-validates everything.
  Future<Result<String>> createMockExam(List<MockExamSubjectConfig> config);

  Future<Result<void>> abandonMockExam(String mockExamId);
}
