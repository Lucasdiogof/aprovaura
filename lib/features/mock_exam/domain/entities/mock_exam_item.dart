import 'package:equatable/equatable.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

/// One question of a mock exam as get_mock_exam_items() hands it over
/// while the exam is in progress: already in its frozen position, with its
/// options already in their frozen order. There is deliberately no correct
/// answer here -- the server doesn't send one until the exam is finished.
class MockExamItem extends Equatable {
  const MockExamItem({
    required this.position,
    required this.questionId,
    required this.subject,
    required this.difficulty,
    required this.prompt,
    required this.options,
    this.selectedIndex,
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

  @override
  List<Object?> get props => [
    position,
    questionId,
    subject,
    difficulty,
    prompt,
    options,
    selectedIndex,
  ];
}
