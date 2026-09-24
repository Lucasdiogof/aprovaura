import 'package:aura/core/error/result.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';

/// Hands MultipleChoiceView a deck the caller already has in memory, so a
/// screen that just listed questions can open one of them (or all of them,
/// in the same order) in the regular quiz engine without a second fetch.
/// catalogNodeId and difficulty are accepted to satisfy the interface but
/// unused -- the deck is exactly what was passed in.
class PreloadedQuestionRepository implements QuestionRepository {
  const PreloadedQuestionRepository(this._questions);

  final List<Question> _questions;

  @override
  Future<Result<List<Question>>> getQuestions(
    String catalogNodeId, {
    QuestionDifficulty? difficulty,
  }) async => Success(_questions);
}
