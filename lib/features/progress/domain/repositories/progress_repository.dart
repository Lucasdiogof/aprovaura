import 'package:aura/core/error/result.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';

abstract class ProgressRepository {
  Future<Result<Map<String, TopicProgress>>> getBatchProgress(
    List<String> catalogNodeIds,
  );

  Future<Result<void>> registerQuestionAnswered({
    required String questionId,
    required bool isCorrect,
  });
}
