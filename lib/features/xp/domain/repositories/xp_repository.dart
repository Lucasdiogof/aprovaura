import 'package:aura/core/error/result.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';

abstract class XpRepository {
  Future<Result<UserXp>> getCurrent();

  /// +10 XP per correct answer, 0 for wrong ones -- see award_quiz_xp() in
  /// supabase/quiz_xp_ledger.sql. [attemptId] is a client-generated id
  /// unique to this quiz attempt (see generateAttemptId()): calling this
  /// again with the same id (a rebuild, a retried request) is a no-op
  /// that just returns the current total, so XP is never double-awarded
  /// for one attempt.
  Future<Result<UserXp>> awardQuizXp({
    required String attemptId,
    required int correctCount,
  });
}
