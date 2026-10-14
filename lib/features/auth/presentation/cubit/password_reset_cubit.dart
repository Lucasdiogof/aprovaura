import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/cubit/password_reset_state.dart';

/// Drives the "forgot my password" sheet: email -> 6-digit code -> new
/// password. It is deliberately separate from [AuthCubit]: the code opens a
/// session only to authorise the password change, and routing that through
/// the auth state machine would make the login page react to it.
class PasswordResetCubit extends Cubit<PasswordResetState> {
  PasswordResetCubit(this._repository) : super(const PasswordResetIdle());

  final AuthRepository _repository;
  Timer? _timer;

  Future<void> send(String email) async {
    if (state is PasswordResetSending) return;
    emit(const PasswordResetSending());
    final result = await _repository.sendPasswordReset(email: email);
    if (isClosed) return;
    switch (result) {
      case Success():
        emit(PasswordResetSent(email));
        _startCooldown();
      case Error(:final failure):
        emit(PasswordResetIdle(errorMessage: failure.message));
    }
  }

  Future<void> resend() async {
    final current = state;
    if (current is! PasswordResetSent ||
        current.resend == ResendStatus.sending ||
        current.cooldown > 0) {
      return;
    }
    emit(current.copyWith(resend: ResendStatus.sending, clearError: true));
    final result = await _repository.sendPasswordReset(email: current.email);
    if (isClosed) return;
    final ok = result is Success;
    emit(
      PasswordResetSent(
        current.email,
        resend: ok ? ResendStatus.sent : ResendStatus.failed,
        cooldown: ok ? resendCooldownSeconds : 0,
      ),
    );
    if (ok) _startCooldown();
  }

  Future<void> verifyCode(String code) async {
    final current = state;
    if (current is! PasswordResetSent || current.isVerifying) return;
    emit(current.copyWith(isVerifying: true, clearError: true));
    final result = await _repository.verifyRecoveryCode(
      email: current.email,
      code: code,
    );
    if (isClosed) return;
    switch (result) {
      case Success():
        _timer?.cancel();
        emit(const PasswordResetVerified());
      case Error(:final failure):
        emit(
          current.copyWith(isVerifying: false, errorMessage: failure.message),
        );
    }
  }

  Future<void> savePassword(String newPassword) async {
    final current = state;
    if (current is! PasswordResetVerified || current.isSaving) return;
    emit(const PasswordResetVerified(isSaving: true));
    final result = await _repository.updatePassword(newPassword: newPassword);
    if (isClosed) return;
    switch (result) {
      case Success():
        // The code's session only existed to allow this change: close it so
        // the person signs in with the new password like anyone else.
        await _repository.signOut();
        if (isClosed) return;
        emit(const PasswordResetDone());
      case Error(:final failure):
        emit(PasswordResetVerified(errorMessage: failure.message));
    }
  }

  void _startCooldown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state;
      if (current is! PasswordResetSent || current.cooldown <= 0) {
        timer.cancel();
        return;
      }
      emit(current.copyWith(cooldown: current.cooldown - 1));
      if (current.cooldown - 1 <= 0) timer.cancel();
    });
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    // Leaving the sheet after the code was accepted but before choosing a
    // password must not leave that temporary session signed in.
    if (state is PasswordResetVerified) {
      await _repository.signOut();
    }
    return super.close();
  }
}
