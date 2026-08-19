import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<Map<String, TopicProgress>>> getBatchProgress(
    List<String> catalogNodeIds, {
    QuestionDifficulty? difficulty,
  }) async {
    if (catalogNodeIds.isEmpty) return const Success({});
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'catalog_node_progress',
        params: {
          'p_node_ids': catalogNodeIds,
          'p_difficulty': difficulty?.dbValue,
        },
      );
      final progress = <String, TopicProgress>{
        for (final row in rows.cast<Map<String, dynamic>>())
          row['node_id'] as String: TopicProgress(
            completed: row['completed'] as int,
            total: row['total'] as int,
          ),
      };
      return Success(progress);
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> registerQuestionAnswered({
    required String questionId,
    required bool isCorrect,
  }) async {
    try {
      await _client.rpc<void>(
        'register_question_answered',
        params: {'p_question_id': questionId, 'p_is_correct': isCorrect},
      );
      return const Success(null);
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }
}
