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

/// The device could not reach the server at all (airplane mode, no signal,
/// DNS failure). Distinct from [ServerFailure] so screens can say "you are
/// offline" and fall back to saved content.
class NetworkFailure extends Failure {
  NetworkFailure([String? message]) : super(message ?? _defaultMessage());

  static String _defaultMessage() => switch (_currentLanguage()) {
    AppLanguage.portuguese =>
      'Sem conexão com a internet. Conecte-se e tente novamente.',
    AppLanguage.english => 'No internet connection. Connect and try again.',
    AppLanguage.spanish =>
      'Sin conexión a internet. Conéctate e intenta de nuevo.',
  };
}

/// The request got no answer in time (a connection that hangs instead of
/// failing, common on a flaky network).
class RequestTimeoutFailure extends Failure {
  RequestTimeoutFailure([String? message])
    : super(message ?? _defaultMessage());

  static String _defaultMessage() => switch (_currentLanguage()) {
    AppLanguage.portuguese =>
      'A conexão demorou demais para responder. Tente novamente.',
    AppLanguage.english => 'The connection took too long. Please try again.',
    AppLanguage.spanish =>
      'La conexión tardó demasiado en responder. Intenta de nuevo.',
  };
}

/// True for failures caused by the connection rather than by the server or
/// the data — the cases where already-saved content is a valid substitute.
bool isConnectionFailure(Failure failure) =>
    failure is NetworkFailure || failure is RequestTimeoutFailure;

/// The action could not reach the server but was kept on the device and
/// will be sent once the connection is back. It is returned as an [Error]
/// so callers that only know "success/failure" never treat it as done on
/// the server; screens that care say "saved on this device".
class QueuedOfflineFailure extends Failure {
  QueuedOfflineFailure([String? message]) : super(message ?? _defaultMessage());

  static String _defaultMessage() => switch (_currentLanguage()) {
    AppLanguage.portuguese =>
      'Salvo no aparelho. Será enviado quando houver conexão.',
    AppLanguage.english => 'Saved on this device. It will sync when online.',
    AppLanguage.spanish =>
      'Guardado en el dispositivo. Se enviará cuando haya conexión.',
  };
}
