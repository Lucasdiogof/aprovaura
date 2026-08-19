import 'package:aura/core/error/result.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';

abstract class XpRepository {
  Future<Result<UserXp>> getCurrent();
  Future<Result<UserXp>> awardActivityXp();
}
