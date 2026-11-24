import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';

/// Textos e formatos do portal nos três idiomas. Uso: `t('pt', 'en', 'es')`.
/// O texto fica junto da tela que o usa; datas, moedas e números seguem o idioma.
class PortalStrings {
  const PortalStrings(this.language);

  /// Reconstrói a tela quando o idioma muda.
  factory PortalStrings.watch(BuildContext context) =>
      PortalStrings(context.watch<LocaleCubit>().state);

  /// Para handlers de evento (fora do build).
  factory PortalStrings.read(BuildContext context) =>
      PortalStrings(context.read<LocaleCubit>().state);

  final AppLanguage language;

  String call(String pt, String en, String es) => switch (language) {
        AppLanguage.portuguese => pt,
        AppLanguage.english => en,
        AppLanguage.spanish => es,
      };

  bool get _en => language == AppLanguage.english;

  String date(DateTime? d) {
    if (d == null) return '—';
    final l = d.toLocal();
    final dd = l.day.toString().padLeft(2, '0');
    final mm = l.month.toString().padLeft(2, '0');
    return _en ? '$mm/$dd/${l.year}' : '$dd/$mm/${l.year}';
  }

  String dateTime(DateTime? d) {
    if (d == null) return '—';
    final l = d.toLocal();
    final h = l.hour.toString().padLeft(2, '0');
    final m = l.minute.toString().padLeft(2, '0');
    return '${date(l)} $h:$m';
  }

  DateTime? parse(dynamic v) => v == null ? null : DateTime.tryParse('$v');

  String dateOf(dynamic v) => date(parse(v));
  String dateTimeOf(dynamic v) => dateTime(parse(v));

  String number(num n) {
    final neg = n < 0;
    final s = n.abs().round().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(_en ? ',' : '.');
      b.write(s[i]);
    }
    return '${neg ? '-' : ''}$b';
  }

  /// Centavos (inteiro) em reais.
  String money(num cents) {
    final neg = cents < 0;
    final v = cents.abs().round();
    final r = number(v ~/ 100);
    final c = (v % 100).toString().padLeft(2, '0');
    return '${neg ? '-' : ''}R\$ $r${_en ? '.' : ','}$c';
  }

  String percent(num? ratio, {int digits = 1}) {
    if (ratio == null) return '—';
    final s = (ratio * 100).toStringAsFixed(digits);
    return '${_en ? s : s.replaceAll('.', ',')}%';
  }

  String bps(num? v) => v == null ? '—' : percent(v / 10000, digits: 2);
}
