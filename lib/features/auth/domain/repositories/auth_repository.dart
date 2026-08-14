import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
