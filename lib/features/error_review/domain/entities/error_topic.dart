import 'package:equatable/equatable.dart';

class ErrorTopic extends Equatable {
  const ErrorTopic({
    required this.catalogNodeId,
    required this.subject,
    required this.title,
    required this.wrongCount,
    this.parentTitle,
  });

  final String catalogNodeId;
  final String subject;
  final String title;
  final String? parentTitle;
  final int wrongCount;

  @override
  List<Object?> get props => [
    catalogNodeId,
    subject,
    title,
    parentTitle,
    wrongCount,
  ];
}
