import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/questions/domain/repositories/question_report_repository.dart';

class QuestionReportRepositoryImpl implements QuestionReportRepository {
  QuestionReportRepositoryImpl(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<Result<void>> reportQuestion({
    required String questionId,
    required String questionPrompt,
  }) async {
    try {
      await _client.from('question_reports').insert({
        'user_id': _userId,
        'question_id': questionId,
        'question_prompt': questionPrompt,
      });
      return const Success(null);
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }
}
