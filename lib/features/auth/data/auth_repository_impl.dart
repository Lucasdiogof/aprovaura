import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
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
      return Error(AuthFailure(e.message, e.code == 'invalid_credentials'));
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) return Error(AuthFailure());
      if (response.session == null) {
        return Error(AuthFailure(_pendingConfirmationMessage()));
      }
      return Success(_toAppUser(user));
    } on AuthException catch (e) {
      return Error(AuthFailure(e.message));
    } catch (_) {
      return Error(UnexpectedFailure());
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
      return Error(AuthFailure(e.message));
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  AppUser? get currentUser {
    final user = _client.auth.currentUser;
    return user == null ? null : _toAppUser(user);
  }

  AppUser _toAppUser(User user) =>
      AppUser(id: user.id, email: user.email ?? '');

  String _pendingConfirmationMessage() {
    final language = GetIt.instance.isRegistered<LocaleCubit>()
        ? GetIt.instance<LocaleCubit>().state
        : AppLanguage.portuguese;
    return switch (language) {
      AppLanguage.portuguese =>
        'Conta criada. Confirme seu e-mail antes de entrar.',
      AppLanguage.english =>
        'Account created. Please confirm your email before signing in.',
    };
  }
}
