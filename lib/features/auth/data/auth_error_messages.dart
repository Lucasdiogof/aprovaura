import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';

/// What went wrong with a Supabase Auth call, in terms the screens act on.
enum AuthErrorKind {
  invalidCredentials,
  emailTaken,
  weakPassword,
  invalidEmail,
  emailNotConfirmed,
  rateLimited,
  network,
  unknown,
}

/// Classifies [e] by its error code, falling back to the message and status
/// for servers that don't send a code. Supabase's own text is English and
/// technical, so it is never shown to the person -- only [authErrorMessage].
AuthErrorKind classifyAuthError(AuthException e) {
  if (e is AuthRetryableFetchException) return AuthErrorKind.network;
  if (e is AuthWeakPasswordException) return AuthErrorKind.weakPassword;
  final code = e.code;
  final message = e.message.toLowerCase();
  if (code == 'invalid_credentials' ||
      message.contains('invalid login credentials')) {
    return AuthErrorKind.invalidCredentials;
  }
  if (code == 'user_already_exists' ||
      code == 'email_exists' ||
      message.contains('already registered')) {
    return AuthErrorKind.emailTaken;
  }
  if (code == 'weak_password') return AuthErrorKind.weakPassword;
  if (code == 'email_address_invalid' || code == 'validation_failed') {
    return AuthErrorKind.invalidEmail;
  }
  if (code == 'email_not_confirmed') return AuthErrorKind.emailNotConfirmed;
  if (e.statusCode == '429' ||
      (code != null && code.startsWith('over_') && code.endsWith('limit'))) {
    return AuthErrorKind.rateLimited;
  }
  return AuthErrorKind.unknown;
}

String authErrorMessage(AuthErrorKind kind) => switch ((
  kind,
  _currentLanguage(),
)) {
  (AuthErrorKind.invalidCredentials, AppLanguage.portuguese) =>
    'E-mail ou senha incorretos.',
  (AuthErrorKind.invalidCredentials, AppLanguage.english) =>
    'Incorrect email or password.',
  (AuthErrorKind.invalidCredentials, AppLanguage.spanish) =>
    'Correo o contraseña incorrectos.',
  (AuthErrorKind.emailTaken, AppLanguage.portuguese) =>
    'Já existe uma conta com este e-mail. Entre com ela ou use outro e-mail.',
  (AuthErrorKind.emailTaken, AppLanguage.english) =>
    'An account with this email already exists. Sign in or use another email.',
  (AuthErrorKind.emailTaken, AppLanguage.spanish) =>
    'Ya existe una cuenta con este correo. Inicia sesión o usa otro correo.',
  (AuthErrorKind.weakPassword, AppLanguage.portuguese) =>
    'Senha muito fraca. Use pelo menos 6 caracteres.',
  (AuthErrorKind.weakPassword, AppLanguage.english) =>
    'Password too weak. Use at least 6 characters.',
  (AuthErrorKind.weakPassword, AppLanguage.spanish) =>
    'Contraseña muy débil. Usa al menos 6 caracteres.',
  (AuthErrorKind.invalidEmail, AppLanguage.portuguese) =>
    'Esse e-mail não é válido. Confira e tente de novo.',
  (AuthErrorKind.invalidEmail, AppLanguage.english) =>
    "That email isn't valid. Check it and try again.",
  (AuthErrorKind.invalidEmail, AppLanguage.spanish) =>
    'Ese correo no es válido. Revísalo e intenta de nuevo.',
  (AuthErrorKind.emailNotConfirmed, AppLanguage.portuguese) =>
    'Confirme seu e-mail antes de entrar.',
  (AuthErrorKind.emailNotConfirmed, AppLanguage.english) =>
    'Please confirm your email before signing in.',
  (AuthErrorKind.emailNotConfirmed, AppLanguage.spanish) =>
    'Confirma tu correo antes de entrar.',
  (AuthErrorKind.rateLimited, AppLanguage.portuguese) =>
    'Muitas tentativas seguidas. Aguarde um pouco e tente de novo.',
  (AuthErrorKind.rateLimited, AppLanguage.english) =>
    'Too many attempts. Wait a moment and try again.',
  (AuthErrorKind.rateLimited, AppLanguage.spanish) =>
    'Demasiados intentos. Espera un momento e intenta de nuevo.',
  (AuthErrorKind.network, AppLanguage.portuguese) =>
    'Sem conexão com o servidor. Confira sua internet e tente de novo.',
  (AuthErrorKind.network, AppLanguage.english) =>
    "Can't reach the server. Check your connection and try again.",
  (AuthErrorKind.network, AppLanguage.spanish) =>
    'Sin conexión con el servidor. Revisa tu internet e intenta de nuevo.',
  (AuthErrorKind.unknown, AppLanguage.portuguese) =>
    'Não foi possível concluir agora. Tente novamente em instantes.',
  (AuthErrorKind.unknown, AppLanguage.english) =>
    "Couldn't finish that right now. Please try again shortly.",
  (AuthErrorKind.unknown, AppLanguage.spanish) =>
    'No se pudo completar ahora. Intenta de nuevo en unos instantes.',
};

AppLanguage _currentLanguage() => GetIt.instance.isRegistered<LocaleCubit>()
    ? GetIt.instance<LocaleCubit>().state
    : AppLanguage.portuguese;
