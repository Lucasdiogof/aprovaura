import 'package:equatable/equatable.dart';

/// The user's single in-progress mock exam, as get_active_mock_exam()
/// reports it -- enough for "37 de 90 questões respondidas".
class ActiveMockExam extends Equatable {
  const ActiveMockExam({
    required this.id,
    required this.questionCount,
    required this.answeredCount,
    this.currentItemPosition,
  });

  final String id;
  final int questionCount;
  final int answeredCount;

  /// The question the user was last looking at (item_position), where
  /// "Continuar simulado" resumes. Null until they first navigate.
  final int? currentItemPosition;

  @override
  List<Object?> get props => [
    id,
    questionCount,
    answeredCount,
    currentItemPosition,
  ];
}
