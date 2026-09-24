import 'package:equatable/equatable.dart';

/// One line of the breakdown (a subject, or a real difficulty), exactly as
/// get_mock_exam_result() computes it -- nothing is derived on the client.
class MockExamResultLine extends Equatable {
  const MockExamResultLine({
    required this.key,
    required this.questionCount,
    required this.correctCount,
    required this.wrongCount,
    required this.blankCount,
    required this.accuracyPercent,
  });

  /// The subject key, or 'facil' / 'medio' / 'dificil'.
  final String key;
  final int questionCount;
  final int correctCount;
  final int wrongCount;
  final int blankCount;
  final double accuracyPercent;

  @override
  List<Object?> get props => [
    key,
    questionCount,
    correctCount,
    wrongCount,
    blankCount,
    accuracyPercent,
  ];
}

/// A finished mock exam's result, always loaded from the server by id
/// (get_mock_exam_summary + get_mock_exam_result). Opening it again, or
/// from a future history screen, reads the same rows -- and reading never
/// awards anything.
class MockExamResult extends Equatable {
  const MockExamResult({
    required this.mockExamId,
    required this.questionCount,
    required this.correctCount,
    required this.wrongCount,
    required this.blankCount,
    required this.accuracyPercent,
    required this.xpAwarded,
    required this.subjectCount,
    required this.bySubject,
    required this.byDifficulty,
  });

  final String mockExamId;

  /// Questions still in the exam (a question deleted afterwards is gone
  /// from every number at once, so these always add up).
  final int questionCount;
  final int correctCount;

  /// Answered and wrong -- blanks are counted separately, never here.
  final int wrongCount;
  final int blankCount;
  final double accuracyPercent;

  /// Exactly what finish_mock_exam() credited (xp_awards), not recomputed.
  final int xpAwarded;
  final int subjectCount;
  final List<MockExamResultLine> bySubject;

  /// Real difficulty of each question -- never 'misto'.
  final List<MockExamResultLine> byDifficulty;

  @override
  List<Object?> get props => [
    mockExamId,
    questionCount,
    correctCount,
    wrongCount,
    blankCount,
    accuracyPercent,
    xpAwarded,
    subjectCount,
    bySubject,
    byDifficulty,
  ];
}
