import 'package:aura/core/cache/offline_cache.dart';
import 'package:aura/core/sync/pending_sync_queue.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/auth/data/auth_error_messages.dart';
import 'package:aura/features/auth/data/pending_signup_store.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/entities/legal_document.dart';
import 'package:aura/features/auth/domain/entities/public_app_config.dart';
import 'package:aura/features/auth/domain/entities/pending_signup.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client, [this._cache, this._queue]);

  // Personal cached data (progress bars) must not outlive the session.
  final OfflineCache? _cache;

  // Answers kept on the device while offline. Sent before signing out when
  // possible; whatever is left stays under this account's id only.
  final PendingSyncQueue? _queue;

  final SupabaseClient _client;
  final _pending = PendingSignupStore();

  String get _langCode => switch (GetIt.instance.isRegistered<LocaleCubit>()
      ? GetIt.instance<LocaleCubit>().state
      : AppLanguage.portuguese) {
    AppLanguage.portuguese => 'pt',
    AppLanguage.english => 'en',
    AppLanguage.spanish => 'es',
  };

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) return Error(AuthFailure());
      return Success(_toAppUser(user));
    } on AuthException catch (e) {
      if (classifyAuthError(e) == AuthErrorKind.emailNotConfirmed) {
        // Resumes the confirmation: the screen sends a fresh code.
        final known = await _pending.read();
        if (known == null || known.email != email) {
          await _pending.save(PendingSignup(email: email));
        }
        return Error(
          AuthFailure(
            _pendingConfirmationMessage(),
            false,
            false,
            false,
            true,
          ),
        );
      }
      return Error(_failureFrom(e));
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String name,
    required String username,
    String? referralPartnerId,
    Map<String, String> legalAccept = const {},
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        // Read by the on_auth_user_created_claim_username trigger, which
        // writes the profile in the same transaction as the account. The
        // rest stays in user_metadata until the e-mail is confirmed, when
        // the server links the teacher and records the legal acceptance.
        data: {
          'name': name,
          'username': username,
          'lang': _langCode,
          'referral_partner_id': ?referralPartnerId,
          if (legalAccept.isNotEmpty) 'legal_accept': legalAccept,
        },
      );
      final user = response.user;
      if (user == null) return Error(AuthFailure());
      if (response.session == null) {
        await _pending.save(
          PendingSignup(
            email: email,
            name: name,
            username: username,
            referralPartnerId: referralPartnerId,
            legalAccept: legalAccept,
          ),
        );
        return Error(
          AuthFailure(
            _pendingConfirmationMessage(),
            false,
            false,
            false,
            true,
          ),
        );
      }
      return Success(_toAppUser(user));
    } on AuthException catch (e) {
      // The trigger refusing the username aborts the sign-up, and Supabase
      // Auth reports any such database error with one generic message. Ask
      // the database again: if the name is taken now, that was the reason.
      if (classifyAuthError(e) == AuthErrorKind.unknown &&
          await _isUsernameTakenNow(username)) {
        return Error(
          AuthFailure(UsernameTakenFailure().message, false, false, true),
        );
      }
      return Error(_failureFrom(e));
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> verifySignupCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: code,
      );
      if (response.session == null) return Error(AuthFailure());
      await _pending.clear();
      return const Success(null);
    } on AuthException catch (e) {
      final kind = classifyAuthError(e);
      return Error(
        AuthFailure(
          authErrorMessage(
            kind == AuthErrorKind.network || kind == AuthErrorKind.rateLimited
                ? kind
                : AuthErrorKind.invalidCode,
          ),
        ),
      );
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> resendSignupCode({required String email}) async {
    try {
      await _client.auth.resend(type: OtpType.signup, email: email);
      return const Success(null);
    } on AuthException catch (e) {
      return Error(_failureFrom(e));
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> discardUnconfirmedSignup({
    required String email,
    required String password,
  }) async {
    try {
      final done = await _client.rpc<bool>(
        'discard_unconfirmed_signup',
        params: {'p_email': email, 'p_password': password},
      );
      if (!done) return Error(AuthFailure());
      return const Success(null);
    } on AuthException catch (e) {
      return Error(_failureFrom(e));
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<PublicAppConfig?> publicConfig() async {
    try {
      final raw = await _client
          .rpc<dynamic>('get_public_app_config')
          .timeout(const Duration(seconds: 8));
      final json = raw as Map;
      final legal = json['legal'];
      return PublicAppConfig(
        enforced: json['enforced'] == true,
        trialHours: (json['trial_hours'] as num?)?.toInt() ?? 72,
        legal: [
          if (legal is List)
            for (final d in legal)
              LegalDocument(
                kind: (d as Map)['kind'] as String,
                version: d['version'] as String,
                url: d['url'] as String,
              ),
        ],
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PendingSignup?> pendingSignup() => _pending.read();

  @override
  Future<void> clearPendingSignup() => _pending.clear();

  Future<bool> _isUsernameTakenNow(String username) async {
    try {
      final available = await _client.rpc<bool>(
        'is_username_available',
        params: {'p_username': username},
      );
      return !available;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Result<void>> sendPasswordReset({required String email}) async {
    try {
      // The recovery email carries a 6-digit code ({{ .Token }}), not a
      // link: no redirectTo, no deep link, no PKCE round trip between
      // devices. The code is typed back into the app (verifyRecoveryCode).
      await _client.auth.resetPasswordForEmail(email);
      return const Success(null);
    } on AuthException catch (e) {
      return Error(_failureFrom(e));
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> verifyRecoveryCode({
    required String email,
    required String code,
  }) async {
    try {
      await _client.auth.verifyOTP(
        type: OtpType.recovery,
        email: email,
        token: code,
      );
      return const Success(null);
    } on AuthException catch (e) {
      final kind = classifyAuthError(e);
      // Anything the server refuses here that isn't connectivity or rate
      // limiting is the code itself being wrong or expired.
      return Error(
        AuthFailure(
          authErrorMessage(
            kind == AuthErrorKind.network || kind == AuthErrorKind.rateLimited
                ? kind
                : AuthErrorKind.invalidCode,
          ),
        ),
      );
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> updatePassword({required String newPassword}) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return const Success(null);
    } on AuthException catch (e) {
      return Error(_failureFrom(e));
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _queue?.flush().timeout(const Duration(seconds: 5));
    } catch (_) {}
    await _cache?.clearUserData();
    await _client.auth.signOut();
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      // Only throws on a non-2xx response (see FunctionException below) --
      // reaching the next line means the server already deleted the
      // account. No user_id is ever sent: the Edge Function resolves it
      // from this same call's JWT.
      await _client.functions.invoke('delete-account');
      await _queue?.clearForCurrentUser();
      await _cache?.clearUserData();
      await _client.auth.signOut();
      return const Success(null);
    } on FunctionException catch (e) {
      final details = e.details;
      final message = details is Map ? details['error'] as String? : null;
      return Error(ServerFailure(message));
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    return user == null ? null : _toAppUser(user);
  }

  AppUser _toAppUser(User user) =>
      AppUser(id: user.id, email: user.email ?? '');

  AuthFailure _failureFrom(AuthException e) {
    final kind = classifyAuthError(e);
    return AuthFailure(
      authErrorMessage(kind),
      kind == AuthErrorKind.invalidCredentials,
      kind == AuthErrorKind.emailTaken,
    );
  }

  String _pendingConfirmationMessage() {
    final language = GetIt.instance.isRegistered<LocaleCubit>()
        ? GetIt.instance<LocaleCubit>().state
        : AppLanguage.portuguese;
    return switch (language) {
      AppLanguage.portuguese =>
        'Conta criada. Confirme seu e-mail antes de entrar.',
      AppLanguage.english =>
        'Account created. Please confirm your email before signing in.',
      AppLanguage.spanish =>
        'Cuenta creada. Confirma tu correo electrónico antes de entrar.',
    };
  }
}
