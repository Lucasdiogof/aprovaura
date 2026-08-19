import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';

// Same questions table/shape as QuestionRepositoryImpl, sourced from
// get_favorite_questions_for_node() -- only the caller's favorited
// questions for that topic. difficulty is accepted to satisfy the
// interface but unused.
class FavoriteQuestionRepositoryImpl implements QuestionRepository {
  FavoriteQuestionRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<Question>>> getQuestions(
    String catalogNodeId, {
    QuestionDifficulty? difficulty,
  }) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'get_favorite_questions_for_node',
        params: {'p_catalog_node_id': catalogNodeId},
      );
      final questions = rows
          .cast<Map<String, dynamic>>()
          .map(_fromJson)
          .toList(growable: false);
      return Success(questions);
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  Question _fromJson(Map<String, dynamic> json) => Question(
    id: json['id'] as String,
    prompt: json['prompt'] as String,
    options: (json['options'] as List<dynamic>).cast<String>(),
    correctIndex: json['correct_index'] as int,
    explanation: json['explanation'] as String?,
    difficulty: QuestionDifficulty.fromDb(json['difficulty'] as String?),
  );
}
