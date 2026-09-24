import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/mock_exam/domain/entities/active_mock_exam.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_availability.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_difficulty.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_subject_config.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';

/// Talks to the RPCs in supabase/mock_exams.sql. A PostgrestException means
/// the server answered (and its message is one of the known codes, mapped
/// by MockExamFailure.fromServer); anything else thrown while calling an
/// RPC is treated as the request never getting through.
class MockExamRepositoryImpl implements MockExamRepository {
  MockExamRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<MockExamAvailability>> getAvailability() => _guard(() async {
    final rows = await _client.rpc<List<dynamic>>('get_mock_exam_availability');
    final counts = <String, Map<MockExamDifficulty, int>>{};
    for (final row in rows.cast<Map<String, dynamic>>()) {
      final difficulty = MockExamDifficulty.fromDb(
        row['difficulty'] as String?,
      );
      if (difficulty == null) continue;
      counts.putIfAbsent(row['subject'] as String, () => {})[difficulty] =
          row['available_count'] as int;
    }
    return MockExamAvailability(counts);
  });

  @override
  Future<Result<ActiveMockExam?>> getActiveMockExam() => _guard(() async {
    final rows = await _client.rpc<List<dynamic>>('get_active_mock_exam');
    if (rows.isEmpty) return null;
    final row = rows.first as Map<String, dynamic>;
    return ActiveMockExam(
      id: row['id'] as String,
      questionCount: row['question_count'] as int,
      answeredCount: row['answered_count'] as int,
    );
  });

  @override
  Future<Result<String>> createMockExam(List<MockExamSubjectConfig> config) =>
      _guard(
        () => _client.rpc<String>(
          'create_mock_exam',
          params: {
            'p_config': [for (final entry in config) entry.toJson()],
          },
        ),
      );

  @override
  Future<Result<void>> abandonMockExam(String mockExamId) => _guard(
    () => _client.rpc<void>(
      'abandon_mock_exam',
      params: {'p_mock_exam_id': mockExamId},
    ),
  );

  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Success(await call());
    } on PostgrestException catch (e) {
      return Error(MockExamFailure.fromServer(e.message, e.details));
    } catch (_) {
      return Error(MockExamFailure(MockExamFailureKind.network));
    }
  }
}
