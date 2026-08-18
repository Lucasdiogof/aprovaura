import 'package:equatable/equatable.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

class Question extends Equatable {
  const Question({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.difficulty = QuestionDifficulty.medio,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final QuestionDifficulty difficulty;

  @override
  List<Object?> get props => [
    id,
    prompt,
    options,
    correctIndex,
    explanation,
    difficulty,
  ];
}
