import 'package:equatable/equatable.dart';

class Dossier extends Equatable {
  const Dossier({
    required this.id,
    required this.title,
    this.summary,
    this.context,
    this.whatHappened,
    this.whyItHappened,
    this.whoIsInvolved,
    this.consequences,
    this.keyTakeaways,
    this.sources = const [],
    this.readMinutes,
    this.status = 'current',
    this.publishedAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String? summary;
  final String? context;
  final String? whatHappened;
  final String? whyItHappened;
  final String? whoIsInvolved;
  final String? consequences;
  final String? keyTakeaways;
  final List<String> sources;
  final int? readMinutes;
  final String status;
  // Both columns are `not null default now()` in the database (see
  // dossiers_schema.sql), so real rows always have them -- nullable here
  // only so tests can build a Dossier without caring about dates, and so
  // a freshness badge simply doesn't show rather than guessing if one is
  // ever somehow missing.
  final DateTime? publishedAt;
  final DateTime? updatedAt;

  factory Dossier.fromJson(Map<String, dynamic> json) => Dossier(
    id: json['id'] as String,
    title: json['title'] as String,
    summary: json['summary'] as String?,
    context: json['context'] as String?,
    whatHappened: json['what_happened'] as String?,
    whyItHappened: json['why_it_happened'] as String?,
    whoIsInvolved: json['who_is_involved'] as String?,
    consequences: json['consequences'] as String?,
    keyTakeaways: json['key_takeaways'] as String?,
    sources: (json['sources'] as List<dynamic>? ?? []).cast<String>(),
    readMinutes: json['read_minutes'] as int?,
    status: json['status'] as String? ?? 'current',
    publishedAt: _parseDate(json['published_at']),
    updatedAt: _parseDate(json['updated_at']),
  );

  static DateTime? _parseDate(Object? value) =>
      value == null ? null : DateTime.parse(value as String);

  @override
  List<Object?> get props => [
    id,
    title,
    summary,
    context,
    whatHappened,
    whyItHappened,
    whoIsInvolved,
    consequences,
    keyTakeaways,
    sources,
    readMinutes,
    status,
    publishedAt,
    updatedAt,
  ];
}
