import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/network/connection_monitor.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/core/sync/pending_sync_queue.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/streak/domain/repositories/streak_repository.dart';

class StreakRepositoryImpl implements StreakRepository {
  StreakRepositoryImpl(this._client, this._monitor, this._queue);

  final SupabaseClient _client;
  final ConnectionMonitor _monitor;
  final PendingSyncQueue _queue;

  @override
  Future<Result<Streak>> getOrRefresh() =>
      _callAndParse('get_or_refresh_user_streak');

  // Offline, the completion is kept with its Sao Paulo calendar day and sent
  // later; register_activity_completion(p_activity_date) credits that day,
  // never the day it syncs (supabase/offline_sync_dates.sql).
  @override
  Future<Result<Streak>> registerActivityCompletion() async {
    Future<Result<Streak>> queue() async {
      final brasilia = DateTime.now().toUtc().subtract(
        const Duration(hours: 3),
      );
      final day =
          '${brasilia.year.toString().padLeft(4, '0')}-'
          '${brasilia.month.toString().padLeft(2, '0')}-'
          '${brasilia.day.toString().padLeft(2, '0')}';
      await _queue.enqueue(
        PendingAction(kind: PendingKind.streak, key: day, payload: const {}),
      );
      return Error(QueuedOfflineFailure());
    }

    if (!_monitor.isOnline) return queue();
    final result = await _callAndParse('register_activity_completion');
    if (result case Error(:final failure) when isConnectionFailure(failure)) {
      return queue();
    }
    return result;
  }

  @override
  Future<Result<void>> markBreakSeen() async {
    if (!_monitor.isOnline) return Error(NetworkFailure());
    try {
      await _client.rpc<void>('mark_streak_break_seen').withRequestTimeout();
      return const Success(null);
    } catch (error) {
      return Error(failureFromError(error));
    }
  }

  Future<Result<Streak>> _callAndParse(String function) async {
    if (!_monitor.isOnline) return Error(NetworkFailure());
    try {
      final rows = await _client
          .rpc<List<dynamic>>(function)
          .withRequestTimeout();
      final row = rows.cast<Map<String, dynamic>>().first;
      return Success(_fromJson(row));
    } catch (error) {
      return Error(failureFromError(error));
    }
  }

  Streak _fromJson(Map<String, dynamic> json) => Streak(
    currentStreak: json['current_streak'] as int,
    longestStreak: json['longest_streak'] as int,
    lastActivityDate: json['last_activity_date'] == null
        ? null
        : DateTime.parse(json['last_activity_date'] as String),
    lastBrokenStreak: json['last_broken_streak'] as int?,
    streakBreakVersion: json['streak_break_version'] as int,
    seenStreakBreakVersion: json['seen_streak_break_version'] as int,
  );
}
