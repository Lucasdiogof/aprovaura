import 'package:equatable/equatable.dart';

/// One ENEM competency, as the marking reported it.
///
/// [evidence] holds short quotes from the essay itself: the correction
/// points at what the person actually wrote instead of asserting a grade
/// out of nowhere.
class EssayCompetency extends Equatable {
  const EssayCompetency({
    required this.key,
    required this.title,
    required this.score,
    this.summary = '',
    this.strengths = const [],
    this.improvements = const [],
    this.evidence = const [],
  });

  /// c1..c5.
  final String key;
  final String title;
  final int score;
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> evidence;

  /// The ENEM scale: 0-200 per competency.
  static const maxScore = 200;

  double get fraction => score / maxScore;

  @override
  List<Object?> get props => [
    key,
    title,
    score,
    summary,
    strengths,
    improvements,
    evidence,
  ];
}

/// A finished marking.
///
/// [totalScore] is always the sum of the five competencies -- the database
/// refuses to store anything else -- and is an estimate for practice, never
/// sold as an official ENEM score.
class EssayEvaluation extends Equatable {
  const EssayEvaluation({
    required this.totalScore,
    required this.competencies,
    this.generalFeedback = '',
    this.strengths = const [],
    this.priorityImprovements = const [],
    this.possibleThemeDeviation = false,
    this.insufficientText = false,
  });

  final int totalScore;
  final List<EssayCompetency> competencies;
  final String generalFeedback;
  final List<String> strengths;

  /// At most a handful of concrete actions, in the order that would move
  /// the score most.
  final List<String> priorityImprovements;

  /// The text may not be about the proposal. Flagged rather than punished
  /// silently, because it changes how the whole score should be read.
  final bool possibleThemeDeviation;

  /// Too short to judge properly.
  final bool insufficientText;

  static const maxTotalScore = 1000;

  @override
  List<Object?> get props => [
    totalScore,
    competencies,
    generalFeedback,
    strengths,
    priorityImprovements,
    possibleThemeDeviation,
    insufficientText,
  ];
}
