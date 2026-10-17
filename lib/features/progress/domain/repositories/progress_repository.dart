import 'package:aura/core/error/result.dart';
import 'package:aura/features/progress/domain/entities/profile_stats.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

abstract class ProgressRepository {
  Future<Result<Map<String, TopicProgress>>> getBatchProgress(
    List<String> catalogNodeIds, {
    QuestionDifficulty? difficulty,
  });

  /// Last progress saved for this account for the same nodes, or null.
  /// Personal data: only ever returns what the signed-in user fetched.
  Future<Map<String, TopicProgress>?> cachedBatchProgress(
    List<String> catalogNodeIds, {
    QuestionDifficulty? difficulty,
  }) async => null;

  Future<Result<void>> registerQuestionAnswered({
    required String questionId,
    required bool isCorrect,
  });

  Future<Result<void>> registerRegionFound({
    required String catalogNodeId,
    required String regionId,
  });

  /// Lifetime totals for the Profile progress summary -- see
  /// get_profile_stats() in supabase/profile_stats.sql.
  Future<Result<ProfileStats>> getProfileStats();
}
