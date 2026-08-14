import 'package:aura/core/l10n/app_language.dart';

const unsureExamYear = 'unsure';

List<String> examYearOptions({DateTime? now}) {
  final year = (now ?? DateTime.now()).year;
  return [
    year.toString(),
    (year + 1).toString(),
    (year + 2).toString(),
    unsureExamYear,
  ];
}

String examYearLabel(String value, AppLanguage language) {
  if (value != unsureExamYear) return value;
  return switch (language) {
    AppLanguage.portuguese => 'Ainda não sei',
    AppLanguage.english => "I'm not sure yet",
  };
}
