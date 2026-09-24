import 'package:aura/core/error/result.dart';

abstract class DailyGoalRepository {
  /// How many questions the user has answered today (Brasília time),
  /// right or wrong.
  Future<Result<int>> getTodayAnsweredCount();
}
