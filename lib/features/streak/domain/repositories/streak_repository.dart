import 'package:aura/core/error/result.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';

abstract class StreakRepository {
  Future<Result<Streak>> getOrRefresh();
  Future<Result<Streak>> registerActivityCompletion();
  Future<Result<void>> markBreakSeen();
}
