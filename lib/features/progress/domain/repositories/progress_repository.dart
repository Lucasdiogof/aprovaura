import 'package:aura/core/error/result.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

abstract class ProgressRepository {
  Future<Result<Map<String, TopicProgress>>> getBatchProgress(
    List<String> catalogNodeIds, {
    QuestionDifficulty? difficulty,
  });

  Future<Result<void>> registerQuestionAnswered({
    required String questionId,
    required bool isCorrect,
  });
}
