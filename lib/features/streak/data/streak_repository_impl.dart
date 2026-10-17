import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/network/connection_monitor.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/streak/domain/repositories/streak_repository.dart';

class StreakRepositoryImpl implements StreakRepository {
  StreakRepositoryImpl(this._client, this._monitor);

  final SupabaseClient _client;
  final ConnectionMonitor _monitor;

  @override
  Future<Result<Streak>> getOrRefresh() =>
      _callAndParse('get_or_refresh_user_streak');

  @override
  Future<Result<Streak>> registerActivityCompletion() =>
      _callAndParse('register_activity_completion');

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
    // Streak completion is deliberately not queued: the server dates it
    // with now(), so replaying it later would credit a day not studied.
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
