import 'package:equatable/equatable.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  const AuthError(
    this.message, {
    this.isInvalidCredentials = false,
    this.isEmailTaken = false,
    this.isUsernameTaken = false,
  });

  final String message;
  final bool isInvalidCredentials;
  final bool isEmailTaken;

  /// Sign-up refused: the username was taken meanwhile. No account exists.
  final bool isUsernameTaken;

  @override
  List<Object?> get props => [
    message,
    isInvalidCredentials,
    isEmailTaken,
    isUsernameTaken,
  ];
}
