import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';

AppLanguage _currentLanguage() {
  if (!GetIt.instance.isRegistered<LocaleCubit>()) {
    return AppLanguage.portuguese;
  }
  return GetIt.instance<LocaleCubit>().state;
}

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthFailure extends Failure {
  AuthFailure([
    String? message,
    this.isInvalidCredentials = false,
    this.isEmailTaken = false,
    this.isUsernameTaken = false,
  ]) : super(message ?? _defaultMessage());

  final bool isInvalidCredentials;

  /// Sign-up hit an email that already has an account.
  final bool isEmailTaken;

  /// Sign-up was refused because someone took the username (after it was
  /// checked). Nothing was created: the person just picks another name.
  final bool isUsernameTaken;

  static String _defaultMessage() => switch (_currentLanguage()) {
    AppLanguage.portuguese => 'Falha de autenticação.',
    AppLanguage.english => 'Authentication failed.',
    AppLanguage.spanish => 'Fallo de autenticación.',
  };

  @override
  List<Object?> get props => [
    message,
    isInvalidCredentials,
    isEmailTaken,
    isUsernameTaken,
  ];
}

/// The database refused a username someone else already has (the unique
/// index on lower(username)). Screens turn it into the username field's own
/// "already taken" message instead of a generic error.
class UsernameTakenFailure extends Failure {
  UsernameTakenFailure() : super(_defaultMessage());

  static String _defaultMessage() => switch (_currentLanguage()) {
    AppLanguage.portuguese => 'Esse nome de usuário já está em uso.',
    AppLanguage.english => 'That username is already taken.',
    AppLanguage.spanish => 'Ese nombre de usuario ya está en uso.',
  };
}

class ServerFailure extends Failure {
  ServerFailure([String? message]) : super(message ?? _defaultMessage());

  static String _defaultMessage() => switch (_currentLanguage()) {
    AppLanguage.portuguese => 'Erro ao carregar os dados. Tente novamente.',
    AppLanguage.english => 'Error loading data. Please try again.',
    AppLanguage.spanish => 'Error al cargar los datos. Intenta de nuevo.',
  };
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure([String? message]) : super(message ?? _defaultMessage());

  static String _defaultMessage() => switch (_currentLanguage()) {
    AppLanguage.portuguese => 'Erro inesperado. Tente novamente.',
    AppLanguage.english => 'Unexpected error. Please try again.',
    AppLanguage.spanish => 'Error inesperado. Intenta de nuevo.',
  };
}
