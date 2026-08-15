import 'package:aura/features/map_quiz/domain/entities/country_iso_codes.dart';

String? flagEmojiForCountryId(String adm0A3) {
  final isoA2 = countryIsoA3ToA2[adm0A3];
  if (isoA2 == null || isoA2.length != 2) return null;
  final codeUnits = isoA2
      .toUpperCase()
      .codeUnits
      .map((unit) => 0x1F1E6 + (unit - 0x41))
      .toList(growable: false);
  return String.fromCharCodes(codeUnits);
}
