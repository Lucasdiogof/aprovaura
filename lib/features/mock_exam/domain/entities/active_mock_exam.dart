import 'package:equatable/equatable.dart';

/// The user's single in-progress mock exam, as get_active_mock_exam()
/// reports it -- enough for "37 de 90 questões respondidas".
class ActiveMockExam extends Equatable {
  const ActiveMockExam({
    required this.id,
    required this.questionCount,
    required this.answeredCount,
  });

  final String id;
  final int questionCount;
  final int answeredCount;

  @override
  List<Object?> get props => [id, questionCount, answeredCount];
}
