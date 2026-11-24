import 'package:aura/core/l10n/app_language.dart';

/// Texts of the "my teacher" section of the profile.
class PartnerStrings {
  const PartnerStrings(this.language);

  final AppLanguage language;

  String _t(String pt, String en, String es) => switch (language) {
    AppLanguage.portuguese => pt,
    AppLanguage.english => en,
    AppLanguage.spanish => es,
  };

  String get tileTitle => _t('Professor indicador', 'Referring teacher', 'Profesor que te recomendó');

  String get notLinked => _t('Nenhum professor vinculado', 'No teacher linked', 'Ningún profesor vinculado');

  String get pendingChange => _t('Troca em análise', 'Change under review', 'Cambio en revisión');

  String get title => _t('Professor indicador', 'Referring teacher', 'Profesor que te recomendó');

  String get chooseDescription => _t(
    'Foi um professor que indicou o AprovaAura para você? Escolha-o abaixo. Você pode fazer isso uma vez; trocas depois passam por análise.',
    'Did a teacher recommend AprovaAura to you? Pick them below. You can do this once; later changes are reviewed.',
    '¿Un profesor te recomendó AprovaAura? Elígelo abajo. Puedes hacerlo una vez; los cambios posteriores se revisan.',
  );

  String linkedDescription(String name) => _t(
    'Seu professor indicador é $name.',
    'Your referring teacher is $name.',
    'Tu profesor que te recomendó es $name.',
  );

  String get pendingDescription => _t(
    'Você já pediu uma troca. Ela será analisada; não é possível enviar outra enquanto isso.',
    'You already asked for a change. It will be reviewed; you cannot send another meanwhile.',
    'Ya pediste un cambio. Será revisado; no puedes enviar otro mientras tanto.',
  );

  String get changeAction => _t('Solicitar troca', 'Request change', 'Solicitar cambio');

  String get chooseAction => _t('Escolher professor', 'Choose teacher', 'Elegir profesor');

  String get reasonLabel => _t('Motivo (opcional)', 'Reason (optional)', 'Motivo (opcional)');

  String get changeNote => _t(
    'A troca depende de aprovação e não altera pagamentos já feitos.',
    'The change needs approval and does not alter past payments.',
    'El cambio requiere aprobación y no altera pagos ya hechos.',
  );

  String get confirmLink => _t('Vincular', 'Link', 'Vincular');

  String get sendRequest => _t('Enviar solicitação', 'Send request', 'Enviar solicitud');

  String get linkedOk => _t('Professor vinculado.', 'Teacher linked.', 'Profesor vinculado.');

  String get requestedOk => _t('Solicitação enviada.', 'Request sent.', 'Solicitud enviada.');

  String get failed => _t('Não foi possível concluir. Tente de novo.', 'Could not complete. Try again.', 'No se pudo completar. Intenta de nuevo.');

  String get noPartners => _t('Ainda não há professores parceiros disponíveis.', 'There are no partner teachers available yet.', 'Aún no hay profesores asociados disponibles.');
}
