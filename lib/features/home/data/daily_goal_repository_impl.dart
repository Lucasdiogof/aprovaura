import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/network/connection_monitor.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/home/domain/repositories/daily_goal_repository.dart';

class DailyGoalRepositoryImpl implements DailyGoalRepository {
  DailyGoalRepositoryImpl(this._client, this._monitor);

  final SupabaseClient _client;
  final ConnectionMonitor _monitor;

  @override
  Future<Result<int>> getTodayAnsweredCount() async {
    if (!_monitor.isOnline) return Error(NetworkFailure());
    try {
      final count = await _client
          .rpc<int>('get_daily_question_count')
          .withRequestTimeout();
      return Success(count);
    } catch (error) {
      return Error(failureFromError(error));
    }
  }
}
