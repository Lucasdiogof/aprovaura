import 'package:equatable/equatable.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

/// One question of a mock exam as get_mock_exam_items() hands it over.
/// While the exam is in progress, [correctIndex]/[isCorrect]/[explanation]
/// are deliberately null -- the server doesn't send a correct answer until
/// the exam is finished. Once finished, the same call returns them
/// populated, which is what the review screen reads.
class MockExamItem extends Equatable {
  const MockExamItem({
    required this.position,
    required this.questionId,
    required this.subject,
    required this.difficulty,
    required this.prompt,
    required this.options,
    this.selectedIndex,
    this.correctIndex,
    this.isCorrect,
    this.explanation,
  });

  /// item_position (1-based, may have gaps if a question was deleted).
  final int position;
  final String questionId;
  final String subject;
  final QuestionDifficulty difficulty;
  final String prompt;

  /// In the order to show them. Never reshuffled on the client.
  final List<String> options;

  /// Index into [options] as shown, or null if left blank so far.
  final int? selectedIndex;

  /// Index into [options], or null while the exam isn't finished yet.
  final int? correctIndex;

  /// Null while the exam isn't finished yet, or if it was left blank
  /// (a blank answer is never "correct", but it's also not what
  /// [wasBlank] means -- see there).
  final bool? isCorrect;

  /// Null while the exam isn't finished yet, and possibly still null once
  /// it is (not every question has one).
  final String? explanation;

  bool get wasBlank => selectedIndex == null;

  @override
  List<Object?> get props => [
    position,
    questionId,
    subject,
    difficulty,
    prompt,
    options,
    selectedIndex,
    correctIndex,
    isCorrect,
    explanation,
  ];
}
