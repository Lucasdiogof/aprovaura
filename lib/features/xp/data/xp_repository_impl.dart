import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';
import 'package:aura/features/xp/domain/repositories/xp_repository.dart';

class XpRepositoryImpl implements XpRepository {
  XpRepositoryImpl(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<Result<UserXp>> getCurrent() async {
    try {
      final rows = await _client
          .from('user_xp')
          .select()
          .eq('user_id', _userId);
      if (rows.isEmpty) return const Success(UserXp.initial);
      return Success(UserXp(totalXp: rows.first['total_xp'] as int));
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<UserXp>> awardQuizXp({
    required String attemptId,
    required int correctCount,
  }) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'award_quiz_xp',
        params: {'p_attempt_id': attemptId, 'p_correct_count': correctCount},
      );
      final row = rows.cast<Map<String, dynamic>>().first;
      return Success(UserXp(totalXp: row['total_xp'] as int));
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }
}
