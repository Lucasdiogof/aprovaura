import 'package:aura/core/l10n/app_language.dart';

class AuthStrings {
  const AuthStrings(this.language);

  final AppLanguage language;

  String get nameHint => switch (language) {
    AppLanguage.portuguese => 'Seu nome',
    AppLanguage.english => 'Your name',
    AppLanguage.spanish => 'Tu nombre',
  };

  String get nameRequired => switch (language) {
    AppLanguage.portuguese => 'Informe seu nome.',
    AppLanguage.english => 'Enter your name.',
    AppLanguage.spanish => 'Ingresa tu nombre.',
  };

  String get usernameHint => switch (language) {
    AppLanguage.portuguese => 'Nome de usuário (opcional)',
    AppLanguage.english => 'Username (optional)',
    AppLanguage.spanish => 'Nombre de usuario (opcional)',
  };

  String get emailHint => switch (language) {
    AppLanguage.portuguese => 'seuemail@exemplo.com',
    AppLanguage.english => 'youremail@example.com',
    AppLanguage.spanish => 'tucorreo@ejemplo.com',
  };

  String get passwordHint => switch (language) {
    AppLanguage.portuguese => 'Digite sua senha',
    AppLanguage.english => 'Enter your password',
    AppLanguage.spanish => 'Ingresa tu contraseña',
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

  String get registerHeading => switch (language) {
    AppLanguage.portuguese => 'Criar sua conta',
    AppLanguage.english => 'Create your account',
    AppLanguage.spanish => 'Crea tu cuenta',
  };

  String get confirmPasswordHint => switch (language) {
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

  String get alreadyHaveAccountQuestion => switch (language) {
    AppLanguage.portuguese => 'Já tem uma conta?',
    AppLanguage.english => 'Already have an account?',
    AppLanguage.spanish => '¿Ya tienes una cuenta?',
  };

  String get signInAction => switch (language) {
    AppLanguage.portuguese => 'Entrar',
    AppLanguage.english => 'Sign in',
    AppLanguage.spanish => 'Entrar',
  };

  String get signInSubtitle => switch (language) {
    AppLanguage.portuguese => 'Entre para continuar de onde você parou.',
    AppLanguage.english => 'Sign in to pick up where you left off.',
    AppLanguage.spanish => 'Entra para continuar donde lo dejaste.',
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
      'Informe o e-mail da sua conta e enviaremos um link para você criar '
          'uma nova senha.',
    AppLanguage.english =>
      "Enter your account's email and we'll send you a link to create a new "
          'password.',
    AppLanguage.spanish =>
      'Ingresa el correo de tu cuenta y te enviaremos un enlace para '
          'crear una nueva contraseña.',
  };

  String get forgotPasswordSubmit => switch (language) {
    AppLanguage.portuguese => 'Enviar link',
    AppLanguage.english => 'Send link',
    AppLanguage.spanish => 'Enviar enlace',
  };

  String get forgotPasswordSentTitle => switch (language) {
    AppLanguage.portuguese => 'Verifique seu e-mail',
    AppLanguage.english => 'Check your email',
    AppLanguage.spanish => 'Revisa tu correo electrónico',
  };

  String get forgotPasswordSentDescription => switch (language) {
    AppLanguage.portuguese =>
      'Se essa conta existir, o link de recuperação chegou em:',
    AppLanguage.english =>
      'If that account exists, the recovery link is on its way to:',
    AppLanguage.spanish =>
      'Si esa cuenta existe, el enlace de recuperación llegó a:',
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
    AppLanguage.portuguese => 'Link enviado de novo.',
    AppLanguage.english => 'Link sent again.',
    AppLanguage.spanish => 'Enlace enviado de nuevo.',
  };

  String get forgotPasswordResendFailed => switch (language) {
    AppLanguage.portuguese => 'Não conseguimos reenviar. Tente mais tarde.',
    AppLanguage.english => "We couldn't resend it. Try again later.",
    AppLanguage.spanish => 'No pudimos reenviarlo. Intenta más tarde.',
  };

  String get closeAction => switch (language) {
    AppLanguage.portuguese => 'Fechar',
    AppLanguage.english => 'Close',
    AppLanguage.spanish => 'Cerrar',
  };
}
