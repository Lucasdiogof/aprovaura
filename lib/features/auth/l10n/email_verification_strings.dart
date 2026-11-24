import 'package:aura/core/l10n/app_language.dart';

/// Texts of the e-mail confirmation page and the sign-up legal line.
class EmailVerificationStrings {
  const EmailVerificationStrings(this.language);

  final AppLanguage language;

  String _t(String pt, String en, String es) => switch (language) {
    AppLanguage.portuguese => pt,
    AppLanguage.english => en,
    AppLanguage.spanish => es,
  };

  String get subtitle => _t(
    'Falta só confirmar seu e-mail.',
    'Just one step left: confirm your email.',
    'Solo falta confirmar tu correo.',
  );

  String get title => _t(
    'Confirme seu e-mail',
    'Confirm your email',
    'Confirma tu correo',
  );

  String get description => _t(
    'Enviamos um código de 6 dígitos para:',
    'We sent a 6-digit code to:',
    'Enviamos un código de 6 dígitos a:',
  );

  String get spamHint => _t(
    'Não chegou? Veja também a caixa de spam.',
    "Didn't arrive? Check your spam folder too.",
    '¿No llegó? Revisa también la carpeta de spam.',
  );

  String get submit =>
      _t('Confirmar e-mail', 'Confirm email', 'Confirmar correo');

  String get locked => _t(
    'Muitas tentativas. Aguarde um pouco para tentar de novo.',
    'Too many attempts. Wait a moment and try again.',
    'Demasiados intentos. Espera un momento e intenta de nuevo.',
  );

  String lockedIn(int s) => _t(
    'Tente de novo em ${s}s',
    'Try again in ${s}s',
    'Intenta de nuevo en ${s}s',
  );

  String get fixEmail => _t(
    'Digitei o e-mail errado',
    'I typed the wrong email',
    'Escribí mal el correo',
  );

  String get fixEmailTitle =>
      _t('Corrigir e-mail', 'Correct your email', 'Corregir correo');

  String get fixEmailDescription => _t(
    'Informe o e-mail certo e a senha que você criou. Enviaremos um novo código.',
    'Enter the right email and the password you created. We will send a new code.',
    'Ingresa el correo correcto y la contraseña que creaste. Enviaremos un nuevo código.',
  );

  String get fixEmailNewLabel =>
      _t('E-mail correto', 'Correct email', 'Correo correcto');

  String get fixEmailSubmit => _t(
    'Corrigir e enviar código',
    'Correct and send code',
    'Corregir y enviar código',
  );

  String get fixEmailFailed => _t(
    'Não foi possível corrigir. Confira a senha ou volte e entre na conta.',
    'Could not correct it. Check the password or go back and sign in.',
    'No se pudo corregir. Revisa la contraseña o vuelve e inicia sesión.',
  );

  String get fixEmailUnavailable => _t(
    'Para corrigir o e-mail, refaça o cadastro.',
    'To correct the email, sign up again.',
    'Para corregir el correo, vuelve a registrarte.',
  );

  String get backToSignIn =>
      _t('Voltar para o login', 'Back to sign in', 'Volver al inicio de sesión');

  String get verified => _t(
    'E-mail confirmado!',
    'Email confirmed!',
    '¡Correo confirmado!',
  );

  // --- legal line on sign-up ---
  String get legalPrefix => _t('Li e concordo com a ', 'I have read and agree to the ', 'Leí y acepto la ');
  String get legalPrefixPlural => _t('Li e concordo com os ', 'I have read and agree to the ', 'Leí y acepto los ');

  String legalName(String kind) => switch (kind) {
    'terms' => _t('Termos de Uso', 'Terms of Use', 'Términos de Uso'),
    _ => _t('Política de Privacidade', 'Privacy Policy', 'Política de Privacidad'),
  };

  String get legalRequired => _t(
    'Aceite para criar a conta.',
    'Accept to create your account.',
    'Acepta para crear la cuenta.',
  );

  String get legalLoadFailed => _t(
    'Não foi possível carregar os termos. Conecte-se e tente de novo para criar a conta.',
    'Could not load the terms. Connect and try again to create your account.',
    'No se pudieron cargar los términos. Conéctate e intenta de nuevo para crear la cuenta.',
  );

  String get legalAnd => _t(' e a ', ' and the ', ' y la ');

  // --- referral picker on sign-up ---
  String get referralLabel => _t(
    'Qual professor indicou o AprovaAura para você?',
    'Which teacher recommended AprovaAura to you?',
    '¿Qué profesor te recomendó AprovaAura?',
  );

  String get referralNone => _t(
    'Não fui indicado por um professor.',
    'I was not referred by a teacher.',
    'Ningún profesor me lo recomendó.',
  );

  String get referralSearchHint =>
      _t('Buscar professor', 'Search teacher', 'Buscar profesor');

  String get referralEmpty => _t(
    'Nenhum professor encontrado.',
    'No teacher found.',
    'Ningún profesor encontrado.',
  );

  String get referralLoadMore => _t('Ver mais', 'Show more', 'Ver más');

  String get referralError => _t(
    'Não foi possível carregar a lista.',
    'Could not load the list.',
    'No se pudo cargar la lista.',
  );

  String get retry => _t('Tentar de novo', 'Try again', 'Intentar de nuevo');
}
