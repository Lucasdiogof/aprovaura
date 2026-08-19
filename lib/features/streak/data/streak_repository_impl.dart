import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/streak/domain/repositories/streak_repository.dart';

class StreakRepositoryImpl implements StreakRepository {
  StreakRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<Streak>> getOrRefresh() =>
      _callAndParse('get_or_refresh_user_streak');

  @override
  Future<Result<Streak>> registerActivityCompletion() =>
      _callAndParse('register_activity_completion');

  @override
  Future<Result<void>> markBreakSeen() async {
    try {
      await _client.rpc<void>('mark_streak_break_seen');
      return const Success(null);
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  Future<Result<Streak>> _callAndParse(String function) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(function);
      final row = rows.cast<Map<String, dynamic>>().first;
      return Success(_fromJson(row));
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
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
