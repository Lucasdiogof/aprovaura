import 'package:equatable/equatable.dart';

/// Where a theme comes from. A practice theme is ours and says so; an
/// official one carries the exam that actually used it.
///
/// The database enforces this split (`essay_themes_official_needs_source`):
/// an official theme without exam, year and source cannot be stored, and a
/// practice theme is forbidden from carrying them. So [examName] and
/// [examYear] are non-null exactly when [isOfficial] -- the UI never has to
/// invent a label for a half-filled theme.
class EssayThemeOrigin extends Equatable {
  const EssayThemeOrigin.practice()
    : examName = null,
      examYear = null,
      sourceUrl = null;

  const EssayThemeOrigin.official({
    required String this.examName,
    required int this.examYear,
    this.sourceUrl,
  });

  final String? examName;
  final int? examYear;
  final String? sourceUrl;

  bool get isOfficial => examName != null;

  @override
  List<Object?> get props => [examName, examYear, sourceUrl];
}

/// One motivating text of a proposal: the collection of texts a candidate
/// reads before writing. [title] and [source] are optional because real
/// proposals mix titled excerpts with bare quotes.
class EssaySupportingText extends Equatable {
  const EssaySupportingText({required this.body, this.title, this.source});

  final String body;
  final String? title;
  final String? source;

  @override
  List<Object?> get props => [title, body, source];
}

/// A full proposal, as shown on the theme screen.
class EssayTheme extends Equatable {
  const EssayTheme({
    required this.id,
    required this.title,
    required this.prompt,
    required this.origin,
    this.description,
    this.supportingTexts = const [],
  });

  final String id;
  final String title;

  /// The instruction the candidate writes against ("A partir da leitura
  /// dos textos motivadores...").
  final String prompt;
  final EssayThemeOrigin origin;
  final String? description;
  final List<EssaySupportingText> supportingTexts;

  @override
  List<Object?> get props => [
    id,
    title,
    prompt,
    origin,
    description,
    supportingTexts,
  ];
}
