import 'package:equatable/equatable.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_difficulty.dart';

/// Real question counts per subject + difficulty, exactly as
/// get_mock_exam_availability() reports them (including the server-side
/// 'misto' total). Nothing here is computed or hardcoded on the client.
class MockExamAvailability extends Equatable {
  const MockExamAvailability(this._counts);

  const MockExamAvailability.empty() : _counts = const {};

  final Map<String, Map<MockExamDifficulty, int>> _counts;

  Iterable<String> get subjects => _counts.keys;

  int countFor(String subject, MockExamDifficulty difficulty) =>
      _counts[subject]?[difficulty] ?? 0;

  @override
  List<Object?> get props => [_counts];
}
