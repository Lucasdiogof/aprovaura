import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/cubit/email_verification_state.dart';

/// Drives the e-mail confirmation page: type the 6-digit code, resend it
/// (with a minimum interval), survive wrong codes and lost connections.
/// Only the server confirms the e-mail; this cubit just relays the code.
class EmailVerificationCubit extends Cubit<EmailVerificationState> {
  EmailVerificationCubit(this._repository, String email)
    : super(EmailVerificationState(email: email));

  final AuthRepository _repository;
  Timer? _timer;

  /// Arriving from login (the code may be gone or expired): sends a fresh one.
  Future<void> sendFresh() => resend(force: true);

  Future<void> verify(String code) async {
    if (state.isVerifying || state.isLocked || state.verified) return;
    emit(state.copyWith(isVerifying: true, clearError: true));
    final result = await _repository.verifySignupCode(
      email: state.email,
      code: code,
    );
    if (isClosed) return;
    switch (result) {
      case Success():
        _timer?.cancel();
        emit(state.copyWith(isVerifying: false, verified: true));
      case Error(:final failure):
        // Wrong codes count; a lost connection or rate limit does not.
        final countable = failure is! NetworkFailure;
        final attempts = countable ? state.attempts + 1 : state.attempts;
        final locked = attempts >= emailCodeMaxAttempts;
        emit(
          state.copyWith(
            isVerifying: false,
            errorMessage: failure.message,
            attempts: locked ? 0 : attempts,
            lockedFor: locked ? emailCodeLockSeconds : 0,
          ),
        );
        if (locked) _startTimer();
    }
  }

  Future<void> resend({bool force = false}) async {
    if (state.resend == EmailResendStatus.sending ||
        (!force && state.cooldown > 0)) {
      return;
    }
    emit(state.copyWith(resend: EmailResendStatus.sending, clearError: true));
    final result = await _repository.resendSignupCode(email: state.email);
    if (isClosed) return;
    final ok = result is Success;
    emit(
      state.copyWith(
        resend: ok ? EmailResendStatus.sent : EmailResendStatus.failed,
        errorMessage: ok || force ? null : (result as Error).failure.message,
        clearError: ok || force,
        cooldown: ok ? emailCodeResendCooldownSeconds : state.cooldown,
      ),
    );
    if (ok) _startTimer();
  }

  /// After "corrigir e-mail" the page restarts on the new address.
  void changeEmail(String email) {
    _timer?.cancel();
    emit(EmailVerificationState(email: email));
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final s = state;
      final cooldown = s.cooldown > 0 ? s.cooldown - 1 : 0;
      final lockedFor = s.lockedFor > 0 ? s.lockedFor - 1 : 0;
      emit(s.copyWith(cooldown: cooldown, lockedFor: lockedFor));
      if (cooldown == 0 && lockedFor == 0) timer.cancel();
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
