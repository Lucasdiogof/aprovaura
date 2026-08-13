import 'package:aura/core/l10n/app_language.dart';

class AuthStrings {
  const AuthStrings(this.language);

  final AppLanguage language;

  String get tagline => switch (language) {
    AppLanguage.portuguese => 'Aprenda. Pratique. Evolua.',
    AppLanguage.english => 'Learn. Practice. Evolve.',
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
}
