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

  /// Permanently deletes the signed-in user's account: the server-side
  /// `delete-account` Edge Function removes them from Supabase Auth, which
  /// cascades through every one of their rows (profile, XP, streak,
  /// progress, favorites, reports -- see supabase/DELETE_ACCOUNT.md for the
  /// full audit). Signs the local session out on success; on failure the
  /// account and the current session are both untouched.
  Future<Result<void>> deleteAccount();

  AppUser? get currentUser;
}
