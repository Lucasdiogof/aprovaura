import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/cache/offline_cache.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/progress/domain/entities/profile_stats.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._client, this._cache);

  final SupabaseClient _client;
  final OfflineCache _cache;

  // Personal data: keyed by the signed-in user and wiped on sign-out.
  String? _progressKey(List<String> ids, QuestionDifficulty? difficulty) {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final sorted = [...ids]..sort();
    return _cache.userKey(
      uid,
      'progress.${difficulty?.dbValue ?? 'all'}.${sorted.join(',').hashCode}',
    );
  }

  @override
  Future<Map<String, TopicProgress>?> cachedBatchProgress(
    List<String> catalogNodeIds, {
    QuestionDifficulty? difficulty,
  }) async {
    final key = _progressKey(catalogNodeIds, difficulty);
    if (key == null) return null;
    final raw = _cache.read(key);
    if (raw is! Map) return null;
    try {
      return {
        for (final entry in raw.entries)
          entry.key as String: TopicProgress(
            completed: (entry.value as Map)['completed'] as int,
            total: (entry.value as Map)['total'] as int,
          ),
      };
    } catch (_) {
      return null;
    }
  }

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
      ).withRequestTimeout();
      final progress = <String, TopicProgress>{
        for (final row in rows.cast<Map<String, dynamic>>())
          row['node_id'] as String: TopicProgress(
            completed: row['completed'] as int,
            total: row['total'] as int,
          ),
      };
      final key = _progressKey(catalogNodeIds, difficulty);
      if (key != null) {
        await _cache.write(key, {
          for (final e in progress.entries)
            e.key: {'completed': e.value.completed, 'total': e.value.total},
        });
      }
      return Success(progress);
    } catch (error) {
      return Error(failureFromError(error));
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
      ).withRequestTimeout();
      return const Success(null);
    } catch (error) {
      return Error(failureFromError(error));
    }
  }

  @override
  Future<Result<ProfileStats>> getProfileStats() async {
    try {
      final rows = await _client.rpc<List<dynamic>>('get_profile_stats');
      final row = rows.cast<Map<String, dynamic>>().first;
      return Success(
        ProfileStats(
          totalAnswered: row['total_answered'] as int,
          correctAnswered: row['correct_answered'] as int,
        ),
      );
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> registerRegionFound({
    required String catalogNodeId,
    required String regionId,
  }) async {
    try {
      await _client.rpc<void>(
        'register_region_found',
        params: {'p_catalog_node_id': catalogNodeId, 'p_region_id': regionId},
      );
      return const Success(null);
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }
}
