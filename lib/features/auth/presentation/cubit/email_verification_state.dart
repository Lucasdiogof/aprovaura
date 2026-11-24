import 'package:equatable/equatable.dart';

const emailCodeResendCooldownSeconds = 60;

/// After this many wrong codes in a row the field locks for a while (the
/// server also rate-limits; this keeps the app from hammering it).
const emailCodeMaxAttempts = 5;
const emailCodeLockSeconds = 60;

enum EmailResendStatus { idle, sending, sent, failed }

class EmailVerificationState extends Equatable {
  const EmailVerificationState({
    required this.email,
    this.isVerifying = false,
    this.verified = false,
    this.errorMessage,
    this.resend = EmailResendStatus.idle,
    this.cooldown = 0,
    this.attempts = 0,
    this.lockedFor = 0,
  });

  final String email;
  final bool isVerifying;
  final bool verified;
  final String? errorMessage;
  final EmailResendStatus resend;
  final int cooldown;
  final int attempts;
  final int lockedFor;

  bool get isLocked => lockedFor > 0;

  EmailVerificationState copyWith({
    String? email,
    bool? isVerifying,
    bool? verified,
    String? errorMessage,
    bool clearError = false,
    EmailResendStatus? resend,
    int? cooldown,
    int? attempts,
    int? lockedFor,
  }) => EmailVerificationState(
    email: email ?? this.email,
    isVerifying: isVerifying ?? this.isVerifying,
    verified: verified ?? this.verified,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    resend: resend ?? this.resend,
    cooldown: cooldown ?? this.cooldown,
    attempts: attempts ?? this.attempts,
    lockedFor: lockedFor ?? this.lockedFor,
  );

  @override
  List<Object?> get props => [
    email,
    isVerifying,
    verified,
    errorMessage,
    resend,
    cooldown,
    attempts,
    lockedFor,
  ];
}
