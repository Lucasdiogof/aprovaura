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

  /// Asks Supabase to email a password-recovery link. Succeeds even when no
  /// account uses that address: Supabase deliberately doesn't tell the caller
  /// which emails are registered, and neither should the UI.
  Future<Result<void>> sendPasswordReset({required String email});

  Future<void> signOut();

  AppUser? get currentUser;
}
