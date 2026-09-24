import 'package:equatable/equatable.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';

/// What happened to the user's most recent attempt at a theme. Mirrors
/// essay_submissions.status.
enum EssaySubmissionStatus {
  submitted,
  evaluating,
  evaluated,
  failed;

  static EssaySubmissionStatus? fromDb(String? value) => switch (value) {
    'submitted' => EssaySubmissionStatus.submitted,
    'evaluating' => EssaySubmissionStatus.evaluating,
    'evaluated' => EssaySubmissionStatus.evaluated,
    'failed' => EssaySubmissionStatus.failed,
    _ => null,
  };

  /// True while the server still owes an answer -- the app polls instead of
  /// keeping any state of its own.
  bool get isInProgress =>
      this == EssaySubmissionStatus.submitted ||
      this == EssaySubmissionStatus.evaluating;
}

/// A theme as it appears in the list: the proposal's identity plus where
/// this particular user stands on it.
///
/// [lastScore] is null until an attempt has actually been graded. A theme
/// never tried shows nothing -- not a zero, not "no score", not a progress
/// bar. Redação has no percentage to show.
class EssayThemeSummary extends Equatable {
  const EssayThemeSummary({
    required this.id,
    required this.title,
    required this.origin,
    required this.hasDraft,
    required this.attemptCount,
    this.description,
    this.lastStatus,
    this.lastScore,
  });

  final String id;
  final String title;
  final EssayThemeOrigin origin;

  /// A saved draft with something actually written in it.
  final bool hasDraft;
  final int attemptCount;
  final String? description;
  final EssaySubmissionStatus? lastStatus;
  final int? lastScore;

  bool get hasBeenTried => attemptCount > 0;

  @override
  List<Object?> get props => [
    id,
    title,
    origin,
    hasDraft,
    attemptCount,
    description,
    lastStatus,
    lastScore,
  ];
}
