import 'package:equatable/equatable.dart';

class Question extends Equatable {
  const Question({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  @override
  List<Object?> get props => [id, prompt, options, correctIndex, explanation];
}
