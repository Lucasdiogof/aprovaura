import 'package:equatable/equatable.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_difficulty.dart';

/// One subject's line of a mock exam: which level and how many questions.
/// Serialized as-is into create_mock_exam()'s p_config array.
class MockExamSubjectConfig extends Equatable {
  const MockExamSubjectConfig({
    required this.subject,
    required this.difficulty,
    required this.questionCount,
  });

  final String subject;
  final MockExamDifficulty difficulty;
  final int questionCount;

  MockExamSubjectConfig copyWith({
    MockExamDifficulty? difficulty,
    int? questionCount,
  }) => MockExamSubjectConfig(
    subject: subject,
    difficulty: difficulty ?? this.difficulty,
    questionCount: questionCount ?? this.questionCount,
  );

  Map<String, Object> toJson() => {
    'subject': subject,
    'difficulty': difficulty.dbValue,
    'question_count': questionCount,
  };

  @override
  List<Object?> get props => [subject, difficulty, questionCount];
}
