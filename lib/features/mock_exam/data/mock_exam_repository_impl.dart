import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/mock_exam/domain/entities/active_mock_exam.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_availability.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_difficulty.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_item.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_result.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_score.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_subject_config.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

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
      currentItemPosition: row['current_item_position'] as int?,
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

  @override
  Future<Result<List<MockExamItem>>> getItems(String mockExamId) => _guard(
    () async {
      final rows = await _client.rpc<List<dynamic>>(
        'get_mock_exam_items',
        params: {'p_mock_exam_id': mockExamId},
      );
      return [
        for (final row in rows.cast<Map<String, dynamic>>())
          MockExamItem(
            position: row['item_position'] as int,
            questionId: row['question_id'] as String,
            subject: row['subject'] as String,
            difficulty: QuestionDifficulty.fromDb(row['difficulty'] as String?),
            prompt: row['prompt'] as String,
            options: (row['options'] as List<dynamic>).cast<String>(),
            selectedIndex: row['selected_index'] as int?,
          ),
      ];
    },
  );

  @override
  Future<Result<void>> answerItem(
    String mockExamId, {
    required int position,
    required int selectedIndex,
  }) => _guard(
    () => _client.rpc<void>(
      'answer_mock_exam_item',
      params: {
        'p_mock_exam_id': mockExamId,
        'p_position': position,
        'p_selected_index': selectedIndex,
      },
    ),
  );

  @override
  Future<Result<void>> setCurrentPosition(String mockExamId, int position) =>
      _guard(
        () => _client.rpc<void>(
          'set_mock_exam_position',
          params: {'p_mock_exam_id': mockExamId, 'p_position': position},
        ),
      );

  @override
  Future<Result<MockExamScore>> finishMockExam(String mockExamId) =>
      _guard(() async {
        final rows = await _client.rpc<List<dynamic>>(
          'finish_mock_exam',
          params: {'p_mock_exam_id': mockExamId},
        );
        final row = rows.first as Map<String, dynamic>;
        return MockExamScore(
          scoredCount: row['scored_count'] as int,
          answeredCount: row['answered_count'] as int,
          correctCount: row['correct_count'] as int,
        );
      });

  @override
  Future<Result<MockExamResult?>> getResult(String mockExamId) =>
      _guard(() async {
        final params = {'p_mock_exam_id': mockExamId};
        final (summaryRows, lineRows) = await (
          _client.rpc<List<dynamic>>('get_mock_exam_summary', params: params),
          _client.rpc<List<dynamic>>('get_mock_exam_result', params: params),
        ).wait;
        if (summaryRows.isEmpty) return null;
        final summary = summaryRows.first as Map<String, dynamic>;
        final lines = lineRows.cast<Map<String, dynamic>>();
        List<MockExamResultLine> linesFor(String dimension) => [
          for (final row in lines)
            if (row['dimension'] == dimension)
              MockExamResultLine(
                key: row['key'] as String,
                questionCount: row['question_count'] as int,
                correctCount: row['correct_count'] as int,
                wrongCount: row['wrong_count'] as int,
                blankCount: row['blank_count'] as int,
                accuracyPercent: (row['accuracy_percent'] as num).toDouble(),
              ),
        ];
        return MockExamResult(
          mockExamId: mockExamId,
          questionCount: summary['question_count'] as int,
          correctCount: summary['correct_count'] as int,
          wrongCount: summary['wrong_count'] as int,
          blankCount: summary['blank_count'] as int,
          accuracyPercent: (summary['accuracy_percent'] as num).toDouble(),
          xpAwarded: summary['xp_awarded'] as int,
          subjectCount: summary['subject_count'] as int,
          bySubject: linesFor('subject'),
          byDifficulty: linesFor('difficulty'),
        );
      });

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
