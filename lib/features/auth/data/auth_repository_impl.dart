import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/auth/data/auth_error_messages.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final SupabaseClient _client;

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
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        // Read by the on_auth_user_created_claim_username trigger, which
        // writes the profile in the same transaction as the account.
        data: {'name': name, 'username': username},
      );
      final user = response.user;
      if (user == null) return Error(AuthFailure());
      if (response.session == null) {
        return Error(AuthFailure(_pendingConfirmationMessage()));
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
      // No redirectTo: the link points at the Site URL configured in the
      // Supabase dashboard, so the recovery flow can be re-targeted there
      // without shipping a new build.
      await _client.auth.resetPasswordForEmail(email);
      return const Success(null);
    } on AuthException catch (e) {
      return Error(_failureFrom(e));
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      // Only throws on a non-2xx response (see FunctionException below) --
      // reaching the next line means the server already deleted the
      // account. No user_id is ever sent: the Edge Function resolves it
      // from this same call's JWT.
      await _client.functions.invoke('delete-account');
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
