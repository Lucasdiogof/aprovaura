import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/network/connection_monitor.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/core/sync/pending_sync_queue.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';
import 'package:aura/features/xp/domain/repositories/xp_repository.dart';

class XpRepositoryImpl implements XpRepository {
  XpRepositoryImpl(this._client, this._queue, this._monitor);

  final SupabaseClient _client;
  final PendingSyncQueue _queue;
  final ConnectionMonitor _monitor;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<Result<UserXp>> getCurrent() async {
    try {
      final rows = await _client
          .from('user_xp')
          .select()
          .eq('user_id', _userId)
          .withRequestTimeout();
      if (rows.isEmpty) return const Success(UserXp.initial);
      return Success(UserXp(totalXp: rows.first['total_xp'] as int));
    } catch (error) {
      return Error(failureFromError(error));
    }
  }

  @override
  Future<Result<UserXp>> awardQuizXp({
    required String attemptId,
    required int correctCount,
  }) async {
    Future<Result<UserXp>> queue() async {
      await _queue.enqueue(
        PendingAction(
          kind: PendingKind.xp,
          key: attemptId,
          payload: {'correctCount': correctCount},
        ),
      );
      return Error(QueuedOfflineFailure());
    }

    if (!_monitor.isOnline) return queue();
    try {
      final rows = await _client
          .rpc<List<dynamic>>(
            'award_quiz_xp',
            params: {
              'p_attempt_id': attemptId,
              'p_correct_count': correctCount,
            },
          )
          .withRequestTimeout();
      final row = rows.cast<Map<String, dynamic>>().first;
      return Success(UserXp(totalXp: row['total_xp'] as int));
    } catch (error) {
      final failure = failureFromError(error);
      return isConnectionFailure(failure) ? queue() : Error(failure);
    }
  }
}
