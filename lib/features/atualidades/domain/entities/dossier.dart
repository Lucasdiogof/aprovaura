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
  );

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
  ];
}
