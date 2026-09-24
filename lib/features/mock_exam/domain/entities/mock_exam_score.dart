import 'package:equatable/equatable.dart';

/// What finish_mock_exam() returns: the server-side grade. [scoredCount]
/// counts every question still in the exam, blanks included (a blank is
/// simply not correct).
class MockExamScore extends Equatable {
  const MockExamScore({
    required this.scoredCount,
    required this.answeredCount,
    required this.correctCount,
  });

  final int scoredCount;
  final int answeredCount;
  final int correctCount;

  int get blankCount => scoredCount - answeredCount;

  @override
  List<Object?> get props => [scoredCount, answeredCount, correctCount];
}
