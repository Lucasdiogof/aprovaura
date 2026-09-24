import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/home/domain/repositories/daily_goal_repository.dart';

class DailyGoalRepositoryImpl implements DailyGoalRepository {
  DailyGoalRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<int>> getTodayAnsweredCount() async {
    try {
      final count = await _client.rpc<int>('get_daily_question_count');
      return Success(count);
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }
}
