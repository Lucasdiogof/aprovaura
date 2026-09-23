import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/cubit/password_reset_state.dart';

/// Drives the "forgot my password" sheet. It is deliberately separate from
/// [AuthCubit]: sending a recovery email doesn't sign anyone in, and routing
/// it through the auth state machine would make the login page react to it.
class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit(this._repository) : super(const PasswordResetIdle());

  final AuthRepository _repository;

  Future<void> send(String email) async {
    if (state is PasswordResetSending) return;
    emit(const PasswordResetSending());
    final result = await _repository.sendPasswordReset(email: email);
    switch (result) {
      case Success():
        emit(PasswordResetSent(email));
      case Error(:final failure):
        emit(PasswordResetIdle(errorMessage: failure.message));
    }
  }

  Future<void> resend() async {
    if (state case PasswordResetSent(:final email, :final resend)) {
      if (resend == ResendStatus.sending) return;
      emit((state as PasswordResetSent).copyWith(resend: ResendStatus.sending));
      final result = await _repository.sendPasswordReset(email: email);
      if (isClosed) return;
      emit(
        PasswordResetSent(
          email,
          resend: result is Success ? ResendStatus.sent : ResendStatus.failed,
        ),
      );
    }
  }
}
