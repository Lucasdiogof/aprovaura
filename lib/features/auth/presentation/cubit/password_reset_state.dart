import 'package:equatable/equatable.dart';

/// Status of a second send from the confirmation step. It lives inside
/// [PasswordResetSent] instead of being its own state so that asking for
/// another email never takes the sheet back to the form.
enum ResendStatus { idle, sending, sent, failed }

sealed class PasswordResetState extends Equatable {
  const PasswordResetState();

  @override
  List<Object?> get props => [];
}

class PasswordResetIdle extends PasswordResetState {
  const PasswordResetIdle({this.errorMessage});

  final String? errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

class PasswordResetSending extends PasswordResetState {
  const PasswordResetSending();
}

class PasswordResetSent extends PasswordResetState {
  const PasswordResetSent(this.email, {this.resend = ResendStatus.idle});

  final String email;
  final ResendStatus resend;

  PasswordResetSent copyWith({ResendStatus? resend}) =>
      PasswordResetSent(email, resend: resend ?? this.resend);

  @override
  List<Object?> get props => [email, resend];
}
