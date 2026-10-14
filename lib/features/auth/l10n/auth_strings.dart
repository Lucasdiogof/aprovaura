import 'package:aura/core/l10n/app_language.dart';

class AuthStrings {
  const AuthStrings(this.language);

  final AppLanguage language;

  String get nameHint => switch (language) {
    AppLanguage.portuguese => 'Seu nome',
    AppLanguage.english => 'Your name',
    AppLanguage.spanish => 'Tu nombre',
  };

  /// Real, static label above the name field -- "Nome completo", distinct
  /// from [nameHint], which stays inside the field as a discreet example.
  String get nameLabel => switch (language) {
    AppLanguage.portuguese => 'Nome completo',
    AppLanguage.english => 'Full name',
    AppLanguage.spanish => 'Nombre completo',
  };

  String get nameRequired => switch (language) {
    AppLanguage.portuguese => 'Informe seu nome.',
    AppLanguage.english => 'Enter your name.',
    AppLanguage.spanish => 'Ingresa tu nombre.',
  };

  String get usernameHint => switch (language) {
    AppLanguage.portuguese => 'Nome de usuário',
    AppLanguage.english => 'Username',
    AppLanguage.spanish => 'Nombre de usuario',
  };

  String get usernameLabel => switch (language) {
    AppLanguage.portuguese => 'Nome de usuário',
    AppLanguage.english => 'Username',
    AppLanguage.spanish => 'Nombre de usuario',
  };

  String get passwordTooShort => switch (language) {
    AppLanguage.portuguese => 'Use pelo menos 6 caracteres.',
    AppLanguage.english => 'Use at least 6 characters.',
    AppLanguage.spanish => 'Usa al menos 6 caracteres.',
  };

  String get emailHint => switch (language) {
    AppLanguage.portuguese => 'seuemail@exemplo.com',
    AppLanguage.english => 'youremail@example.com',
    AppLanguage.spanish => 'tucorreo@ejemplo.com',
  };

  String get emailLabel => switch (language) {
    AppLanguage.portuguese => 'E-mail',
    AppLanguage.english => 'Email',
    AppLanguage.spanish => 'Correo electrónico',
  };

  String get passwordHint => switch (language) {
    AppLanguage.portuguese => 'Digite sua senha',
    AppLanguage.english => 'Enter your password',
    AppLanguage.spanish => 'Ingresa tu contraseña',
  };

  String get passwordLabel => switch (language) {
    AppLanguage.portuguese => 'Senha',
    AppLanguage.english => 'Password',
    AppLanguage.spanish => 'Contraseña',
  };

  String get emailRequired => switch (language) {
    AppLanguage.portuguese => 'Informe seu e-mail.',
    AppLanguage.english => 'Enter your email.',
    AppLanguage.spanish => 'Ingresa tu correo electrónico.',
  };

  String get emailInvalid => switch (language) {
    AppLanguage.portuguese => 'Informe um e-mail válido.',
    AppLanguage.english => 'Enter a valid email.',
    AppLanguage.spanish => 'Ingresa un correo electrónico válido.',
  };

  String get passwordRequired => switch (language) {
    AppLanguage.portuguese => 'Informe sua senha.',
    AppLanguage.english => 'Enter your password.',
    AppLanguage.spanish => 'Ingresa tu contraseña.',
  };

  String get signInButton => switch (language) {
    AppLanguage.portuguese => 'Entrar',
    AppLanguage.english => 'Sign in',
    AppLanguage.spanish => 'Entrar',
  };

  String get forgotPasswordLabel => switch (language) {
    AppLanguage.portuguese => 'Esqueci minha senha',
    AppLanguage.english => 'Forgot my password',
    AppLanguage.spanish => 'Olvidé mi contraseña',
  };

  String get createAccountQuestion => switch (language) {
    AppLanguage.portuguese => 'Ainda não tem uma conta?',
    AppLanguage.english => "Don't have an account yet?",
    AppLanguage.spanish => '¿Todavía no tienes una cuenta?',
  };

  String get createAccountAction => switch (language) {
    AppLanguage.portuguese => 'Criar conta',
    AppLanguage.english => 'Create account',
    AppLanguage.spanish => 'Crear cuenta',
  };

  String get accountNotFoundTitle => switch (language) {
    AppLanguage.portuguese => 'Não encontramos essa conta',
    AppLanguage.english => "We couldn't find that account",
    AppLanguage.spanish => 'No encontramos esa cuenta',
  };

  String get accountNotFoundDescription => switch (language) {
    AppLanguage.portuguese =>
      'Confira o e-mail e a senha, ou crie uma conta caso ainda não tenha uma.',
    AppLanguage.english =>
      "Check your email and password, or create an account if you don't have one yet.",
    AppLanguage.spanish =>
      'Revisa el correo y la contraseña, o crea una cuenta si todavía no '
          'tienes una.',
  };

  String get emailTakenTitle => switch (language) {
    AppLanguage.portuguese => 'Esse e-mail já tem conta',
    AppLanguage.english => 'This email already has an account',
    AppLanguage.spanish => 'Este correo ya tiene una cuenta',
  };

  String get confirmPasswordHint => switch (language) {
    AppLanguage.portuguese => 'Confirmar senha',
    AppLanguage.english => 'Confirm password',
    AppLanguage.spanish => 'Confirmar contraseña',
  };

  String get confirmPasswordLabel => switch (language) {
    AppLanguage.portuguese => 'Confirmar senha',
    AppLanguage.english => 'Confirm password',
    AppLanguage.spanish => 'Confirmar contraseña',
  };

  String get confirmPasswordRequired => switch (language) {
    AppLanguage.portuguese => 'Confirme sua senha.',
    AppLanguage.english => 'Confirm your password.',
    AppLanguage.spanish => 'Confirma tu contraseña.',
  };

  String get passwordsDoNotMatch => switch (language) {
    AppLanguage.portuguese => 'As senhas não coincidem.',
    AppLanguage.english => 'Passwords do not match.',
    AppLanguage.spanish => 'Las contraseñas no coinciden.',
  };

  String get registerSubmitButton => switch (language) {
    AppLanguage.portuguese => 'Criar conta',
    AppLanguage.english => 'Create account',
    AppLanguage.spanish => 'Crear cuenta',
  };

  String get signInSubtitle => switch (language) {
    AppLanguage.portuguese => 'Entre para continuar seus estudos.',
    AppLanguage.english => 'Sign in to continue your studies.',
    AppLanguage.spanish => 'Entra para continuar tus estudios.',
  };

  String get registerSubtitle => switch (language) {
    AppLanguage.portuguese => 'Leva menos de um minuto para começar a estudar.',
    AppLanguage.english => 'It takes less than a minute to start studying.',
    AppLanguage.spanish => 'Toma menos de un minuto para empezar a estudiar.',
  };

  String get forgotPasswordTitle => switch (language) {
    AppLanguage.portuguese => 'Recuperar senha',
    AppLanguage.english => 'Reset your password',
    AppLanguage.spanish => 'Recuperar contraseña',
  };

  String get forgotPasswordDescription => switch (language) {
    AppLanguage.portuguese =>
      'Informe o e-mail da sua conta e enviaremos um código de 6 dígitos '
          'para você criar uma nova senha.',
    AppLanguage.english =>
      "Enter your account's email and we'll send you a 6-digit code to "
          'create a new password.',
    AppLanguage.spanish =>
      'Ingresa el correo de tu cuenta y te enviaremos un código de 6 '
          'dígitos para crear una nueva contraseña.',
  };

  String get forgotPasswordSubmit => switch (language) {
    AppLanguage.portuguese => 'Enviar código',
    AppLanguage.english => 'Send code',
    AppLanguage.spanish => 'Enviar código',
  };

  String get forgotPasswordSentTitle => switch (language) {
    AppLanguage.portuguese => 'Verifique seu e-mail',
    AppLanguage.english => 'Check your email',
    AppLanguage.spanish => 'Revisa tu correo electrónico',
  };

  String get forgotPasswordSentDescription => switch (language) {
    AppLanguage.portuguese =>
      'Se essa conta existir, enviamos um código de 6 dígitos para:',
    AppLanguage.english => 'If that account exists, we sent a 6-digit code to:',
    AppLanguage.spanish =>
      'Si esa cuenta existe, enviamos un código de 6 dígitos a:',
  };

  String get forgotPasswordNotReceived => switch (language) {
    AppLanguage.portuguese => 'Não recebeu?',
    AppLanguage.english => "Didn't get it?",
    AppLanguage.spanish => '¿No lo recibiste?',
  };

  String get forgotPasswordResend => switch (language) {
    AppLanguage.portuguese => 'Enviar de novo',
    AppLanguage.english => 'Send again',
    AppLanguage.spanish => 'Enviar de nuevo',
  };

  String get forgotPasswordResending => switch (language) {
    AppLanguage.portuguese => 'Enviando...',
    AppLanguage.english => 'Sending...',
    AppLanguage.spanish => 'Enviando...',
  };

  String get forgotPasswordResent => switch (language) {
    AppLanguage.portuguese => 'Código enviado de novo.',
    AppLanguage.english => 'Code sent again.',
    AppLanguage.spanish => 'Código enviado de nuevo.',
  };

  String get forgotPasswordResendFailed => switch (language) {
    AppLanguage.portuguese => 'Não conseguimos reenviar. Tente mais tarde.',
    AppLanguage.english => "We couldn't resend it. Try again later.",
    AppLanguage.spanish => 'No pudimos reenviarlo. Intenta más tarde.',
  };

  String get recoveryCodeLabel => switch (language) {
    AppLanguage.portuguese => 'Código de 6 dígitos',
    AppLanguage.english => '6-digit code',
    AppLanguage.spanish => 'Código de 6 dígitos',
  };

  String get recoveryCodeHint => '000000';

  String get recoveryCodeRequired => switch (language) {
    AppLanguage.portuguese => 'Digite os 6 dígitos do código.',
    AppLanguage.english => 'Enter the 6 digits of the code.',
    AppLanguage.spanish => 'Ingresa los 6 dígitos del código.',
  };

  String get recoveryCodeSubmit => switch (language) {
    AppLanguage.portuguese => 'Confirmar código',
    AppLanguage.english => 'Confirm code',
    AppLanguage.spanish => 'Confirmar código',
  };

  String resendInSeconds(int seconds) => switch (language) {
    AppLanguage.portuguese => 'Enviar de novo em ${seconds}s',
    AppLanguage.english => 'Send again in ${seconds}s',
    AppLanguage.spanish => 'Enviar de nuevo en ${seconds}s',
  };

  String get newPasswordTitle => switch (language) {
    AppLanguage.portuguese => 'Crie sua nova senha',
    AppLanguage.english => 'Create your new password',
    AppLanguage.spanish => 'Crea tu nueva contraseña',
  };

  String get newPasswordDescription => switch (language) {
    AppLanguage.portuguese => 'Código confirmado. Escolha uma senha nova.',
    AppLanguage.english => 'Code confirmed. Choose a new password.',
    AppLanguage.spanish => 'Código confirmado. Elige una contraseña nueva.',
  };

  String get newPasswordSubmit => switch (language) {
    AppLanguage.portuguese => 'Salvar nova senha',
    AppLanguage.english => 'Save new password',
    AppLanguage.spanish => 'Guardar nueva contraseña',
  };

  String get passwordChangedTitle => switch (language) {
    AppLanguage.portuguese => 'Senha alterada',
    AppLanguage.english => 'Password changed',
    AppLanguage.spanish => 'Contraseña cambiada',
  };

  String get passwordChangedDescription => switch (language) {
    AppLanguage.portuguese => 'Pronto! Entre com a sua nova senha.',
    AppLanguage.english => 'All set! Sign in with your new password.',
    AppLanguage.spanish => '¡Listo! Entra con tu nueva contraseña.',
  };

  String get closeAction => switch (language) {
    AppLanguage.portuguese => 'Fechar',
    AppLanguage.english => 'Close',
    AppLanguage.spanish => 'Cerrar',
  };
}
