import 'package:equatable/equatable.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';

/// One attempt in a theme's history: what was sent, when, and where its
/// marking stands.
///
/// [totalScore] exists only once an evaluation was really stored. An
/// attempt still waiting shows its status, never a zero.
class EssayAttempt extends Equatable {
  const EssayAttempt({
    required this.id,
    required this.status,
    required this.wordCount,
    required this.submittedAt,
    this.totalScore,
    this.evaluatedAt,
  });

  final String id;
  final EssaySubmissionStatus status;
  final int wordCount;
  final DateTime submittedAt;
  final int? totalScore;
  final DateTime? evaluatedAt;

  @override
  List<Object?> get props => [
    id,
    status,
    wordCount,
    submittedAt,
    totalScore,
    evaluatedAt,
  ];
}

/// A submitted attempt, read-only by construction: the server has no update
/// or delete policy for essay_submissions, so nothing in the app can change
/// what was sent.
class EssaySubmission extends Equatable {
  const EssaySubmission({
    required this.id,
    required this.themeTitle,
    required this.body,
    required this.wordCount,
    required this.status,
    required this.submittedAt,
    this.totalScore,
    this.evaluatedAt,
  });

  final String id;
  final String themeTitle;
  final String body;
  final int wordCount;
  final EssaySubmissionStatus status;
  final DateTime submittedAt;
  final int? totalScore;
  final DateTime? evaluatedAt;

  @override
  List<Object?> get props => [
    id,
    themeTitle,
    body,
    wordCount,
    status,
    submittedAt,
    totalScore,
    evaluatedAt,
  ];
}
