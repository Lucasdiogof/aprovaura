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
    this.subject,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final QuestionDifficulty difficulty;
  // catalog_nodes.subject key ("geografia", ...). Only filled where the
  // deck mixes subjects (quick practice), so the question can say which
  // one it's from; a topic's own questions don't need it.
  final String? subject;

  @override
  List<Object?> get props => [
    id,
    prompt,
    options,
    correctIndex,
    explanation,
    difficulty,
    subject,
  ];
}
