import 'package:aura/core/l10n/app_language.dart';

class AuthStrings {
  const AuthStrings(this.language);

  final AppLanguage language;

  String get nameHint => switch (language) {
    AppLanguage.portuguese => 'Seu nome',
    AppLanguage.english => 'Your name',
  };

  String get nameRequired => switch (language) {
    AppLanguage.portuguese => 'Informe seu nome.',
    AppLanguage.english => 'Enter your name.',
  };

  String get usernameHint => switch (language) {
    AppLanguage.portuguese => 'Nome de usuário (opcional)',
    AppLanguage.english => 'Username (optional)',
  };

  String get emailHint => switch (language) {
    AppLanguage.portuguese => 'seuemail@exemplo.com',
    AppLanguage.english => 'youremail@example.com',
  };

  String get passwordHint => switch (language) {
    AppLanguage.portuguese => 'Digite sua senha',
    AppLanguage.english => 'Enter your password',
  };

  String get emailRequired => switch (language) {
    AppLanguage.portuguese => 'Informe seu e-mail.',
    AppLanguage.english => 'Enter your email.',
  };

  String get emailInvalid => switch (language) {
    AppLanguage.portuguese => 'Informe um e-mail válido.',
    AppLanguage.english => 'Enter a valid email.',
  };

  String get passwordRequired => switch (language) {
    AppLanguage.portuguese => 'Informe sua senha.',
    AppLanguage.english => 'Enter your password.',
  };

  String get signInButton => switch (language) {
    AppLanguage.portuguese => 'Entrar',
    AppLanguage.english => 'Sign in',
  };

  String get forgotPasswordLabel => switch (language) {
    AppLanguage.portuguese => 'Esqueci minha senha',
    AppLanguage.english => 'Forgot my password',
  };

  String get createAccountQuestion => switch (language) {
    AppLanguage.portuguese => 'Ainda não tem uma conta?',
    AppLanguage.english => "Don't have an account yet?",
  };

  String get createAccountAction => switch (language) {
    AppLanguage.portuguese => 'Criar conta',
    AppLanguage.english => 'Create account',
  };

  String get accountNotFoundTitle => switch (language) {
    AppLanguage.portuguese => 'Não encontramos essa conta',
    AppLanguage.english => "We couldn't find that account",
  };

  String get accountNotFoundDescription => switch (language) {
    AppLanguage.portuguese =>
      'Confira o e-mail e a senha, ou crie uma conta caso ainda não tenha uma.',
    AppLanguage.english =>
      "Check your email and password, or create an account if you don't have one yet.",
  };

  String get registerHeading => switch (language) {
    AppLanguage.portuguese => 'Criar sua conta',
    AppLanguage.english => 'Create your account',
  };

  String get confirmPasswordHint => switch (language) {
    AppLanguage.portuguese => 'Confirmar senha',
    AppLanguage.english => 'Confirm password',
  };

  String get confirmPasswordRequired => switch (language) {
    AppLanguage.portuguese => 'Confirme sua senha.',
    AppLanguage.english => 'Confirm your password.',
  };

  String get passwordsDoNotMatch => switch (language) {
    AppLanguage.portuguese => 'As senhas não coincidem.',
    AppLanguage.english => 'Passwords do not match.',
  };

  String get registerSubmitButton => switch (language) {
    AppLanguage.portuguese => 'Criar conta',
    AppLanguage.english => 'Create account',
  };

  String get alreadyHaveAccountQuestion => switch (language) {
    AppLanguage.portuguese => 'Já tem uma conta?',
    AppLanguage.english => 'Already have an account?',
  };

  String get signInAction => switch (language) {
    AppLanguage.portuguese => 'Entrar',
    AppLanguage.english => 'Sign in',
  };

  String get signInSubtitle => switch (language) {
    AppLanguage.portuguese => 'Entre para continuar de onde você parou.',
    AppLanguage.english => 'Sign in to pick up where you left off.',
  };

  String get registerSubtitle => switch (language) {
    AppLanguage.portuguese => 'Leva menos de um minuto para começar a estudar.',
    AppLanguage.english => 'It takes less than a minute to start studying.',
  };

  String get forgotPasswordTitle => switch (language) {
    AppLanguage.portuguese => 'Recuperar senha',
    AppLanguage.english => 'Reset your password',
  };

  String get forgotPasswordDescription => switch (language) {
    AppLanguage.portuguese =>
      'Informe o e-mail da sua conta e enviaremos um link para você criar '
          'uma nova senha.',
    AppLanguage.english =>
      "Enter your account's email and we'll send you a link to create a new "
          'password.',
  };

  String get forgotPasswordSubmit => switch (language) {
    AppLanguage.portuguese => 'Enviar link',
    AppLanguage.english => 'Send link',
  };

  String get forgotPasswordSentTitle => switch (language) {
    AppLanguage.portuguese => 'Verifique seu e-mail',
    AppLanguage.english => 'Check your email',
  };

  String get forgotPasswordSentDescription => switch (language) {
    AppLanguage.portuguese =>
      'Se essa conta existir, o link de recuperação chegou em:',
    AppLanguage.english =>
      'If that account exists, the recovery link is on its way to:',
  };

  String get forgotPasswordNotReceived => switch (language) {
    AppLanguage.portuguese => 'Não recebeu?',
    AppLanguage.english => "Didn't get it?",
  };

  String get forgotPasswordResend => switch (language) {
    AppLanguage.portuguese => 'Enviar de novo',
    AppLanguage.english => 'Send again',
  };

  String get forgotPasswordResending => switch (language) {
    AppLanguage.portuguese => 'Enviando...',
    AppLanguage.english => 'Sending...',
  };

  String get forgotPasswordResent => switch (language) {
    AppLanguage.portuguese => 'Link enviado de novo.',
    AppLanguage.english => 'Link sent again.',
  };

  String get forgotPasswordResendFailed => switch (language) {
    AppLanguage.portuguese => 'Não conseguimos reenviar. Tente mais tarde.',
    AppLanguage.english => "We couldn't resend it. Try again later.",
  };

  String get closeAction => switch (language) {
    AppLanguage.portuguese => 'Fechar',
    AppLanguage.english => 'Close',
  };
}
