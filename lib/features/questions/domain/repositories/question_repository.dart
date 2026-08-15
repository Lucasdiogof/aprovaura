import 'package:aura/core/error/result.dart';
import 'package:aura/features/questions/domain/entities/question.dart';

abstract class QuestionRepository {
  Future<Result<List<Question>>> getQuestions(String catalogNodeId);
}
