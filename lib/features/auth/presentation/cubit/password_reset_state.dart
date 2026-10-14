import 'package:equatable/equatable.dart';

/// Status of a second send from the code step. It lives inside
/// [PasswordResetSent] instead of being its own state so that asking for
/// another code never takes the sheet back to the form.
enum ResendStatus { idle, sending, sent, failed }

/// Seconds the person waits before asking for another code; Supabase itself
/// refuses a second recovery email for the same address within a minute.
const resendCooldownSeconds = 60;

sealed class PasswordResetState extends Equatable {
  const PasswordResetState();

  @override
  List<Object?> get props => [];
}

/// Step 1: asking for the email.
class PasswordResetIdle extends PasswordResetState {
  const PasswordResetIdle({this.errorMessage});

  final String? errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

class PasswordResetSending extends PasswordResetState {
  const PasswordResetSending();
}

/// Step 2: the code was emailed and is being typed back.
class PasswordResetSent extends PasswordResetState {
  const PasswordResetSent(
    this.email, {
    this.resend = ResendStatus.idle,
    this.cooldown = resendCooldownSeconds,
    this.isVerifying = false,
    this.errorMessage,
  });

  final String email;
  final ResendStatus resend;

  /// Seconds left before "send again" is available again.
  final int cooldown;
  final bool isVerifying;
  final String? errorMessage;

  PasswordResetSent copyWith({
    ResendStatus? resend,
    int? cooldown,
    bool? isVerifying,
    String? errorMessage,
    bool clearError = false,
  }) => PasswordResetSent(
    email,
    resend: resend ?? this.resend,
    cooldown: cooldown ?? this.cooldown,
    isVerifying: isVerifying ?? this.isVerifying,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    email,
    resend,
    cooldown,
    isVerifying,
    errorMessage,
  ];
}

/// Step 3: the code opened a session; a new password is being chosen.
class PasswordResetVerified extends PasswordResetState {
  const PasswordResetVerified({this.isSaving = false, this.errorMessage});

  final bool isSaving;
  final String? errorMessage;

  @override
  List<Object?> get props => [isSaving, errorMessage];
}

/// The password is changed (and the temporary session closed).
class PasswordResetDone extends PasswordResetState {
  const PasswordResetDone();
}
