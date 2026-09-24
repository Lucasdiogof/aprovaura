import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());
    final result = await _repository.signIn(email: email, password: password);
    switch (result) {
      case Success(:final data):
        emit(AuthSuccess(data));
      case Error(:final failure):
        emit(
          AuthError(
            failure.message,
            isInvalidCredentials:
                failure is AuthFailure && failure.isInvalidCredentials,
          ),
        );
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(const AuthLoading());
    final result = await _repository.signUp(email: email, password: password);
    switch (result) {
      case Success(:final data):
        emit(AuthSuccess(data));
      case Error(:final failure):
        emit(AuthError(failure.message));
    }
  }

  Future<void> signOut() => _repository.signOut();

  // Deliberately doesn't touch AuthState (like signOut): this cubit is
  // shared app-wide, and nothing outside the delete-account flow itself
  // should react to a submitting/error state here. The caller reads the
  // Result directly, the same way ProfileCubit.updateProfile() is used
  // from MyAccountPage.
  Future<Result<void>> deleteAccount() => _repository.deleteAccount();
}
