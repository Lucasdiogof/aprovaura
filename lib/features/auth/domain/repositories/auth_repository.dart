import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/entities/pending_signup.dart';
import 'package:aura/features/auth/domain/entities/public_app_config.dart';

abstract class AuthRepository {
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  /// Creates the account and, in the same database transaction (the
  /// `on_auth_user_created_claim_username` trigger), its profile with
  /// [name] and [username]. If someone already has the username the whole
  /// sign-up is refused -- no account is left behind -- and the failure is
  /// an [AuthFailure] with `isUsernameTaken`.
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String name,
    required String username,
    String? referralPartnerId,
    Map<String, String> legalAccept = const {},
  });

  /// Confirms the account's e-mail with the 6-digit [code] from the signup
  /// e-mail. On success Supabase opens the session. Only the server can mark
  /// an e-mail as confirmed: the client just types the code back.
  Future<Result<void>> verifySignupCode({
    required String email,
    required String code,
  });

  /// Sends a fresh confirmation code (the server rate-limits it).
  Future<Result<void>> resendSignupCode({required String email});

  /// "Corrigir e-mail": deletes the still-unconfirmed account (the password
  /// proves it is theirs) so the sign-up can be redone with another address.
  Future<Result<void>> discardUnconfirmedSignup({
    required String email,
    required String password,
  });

  /// Pre-login configuration (legal documents to accept, commercial state).
  /// null when it could not be fetched: callers must NOT assume "nothing to
  /// accept" then -- sign-up waits for a retry.
  Future<PublicAppConfig?> publicConfig();

  /// The interrupted e-mail confirmation, if any.
  Future<PendingSignup?> pendingSignup();

  Future<void> clearPendingSignup();

  /// Asks Supabase to email a 6-digit password-recovery code. Succeeds even when no
  /// account uses that address: Supabase deliberately doesn't tell the caller
  /// which emails are registered, and neither should the UI.
  Future<Result<void>> sendPasswordReset({required String email});

  /// Exchanges the emailed recovery [code] for a session (the second step of
  /// the recovery). A wrong or expired code is an [AuthFailure] with a
  /// message the screen can show as is.
  Future<Result<void>> verifyRecoveryCode({
    required String email,
    required String code,
  });

  /// Opens the session of an invite e-mail button (token hash, no code typed).
  Future<Result<void>> verifyRecoveryToken({required String tokenHash});

  /// Sets the password of the session [verifyRecoveryCode] opened.
  Future<Result<void>> updatePassword({required String newPassword});

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
