import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';

class DossierQuestionRepositoryImpl implements QuestionRepository {
  DossierQuestionRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<Question>>> getQuestions(
    String dossierId, {
    QuestionDifficulty? difficulty,
  }) async {
    try {
      final rows = await _client
          .from('dossier_questions')
          .select()
          .eq('dossier_id', dossierId)
          .order('order_index', ascending: true);
      return Success(rows.map((row) => _fromJson(row)).toList(growable: false));
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
  );
}
