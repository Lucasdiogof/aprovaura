import 'package:equatable/equatable.dart';

enum MockExamStatus {
  inProgress,
  finished,
  abandoned;

  static MockExamStatus? fromDb(String? value) => switch (value) {
    'in_progress' => MockExamStatus.inProgress,
    'finished' => MockExamStatus.finished,
    'abandoned' => MockExamStatus.abandoned,
    _ => null,
  };
}

/// A mock exam's current status and resume position, read straight from
/// the server every time the exam screen opens -- never from a previous
/// screen's memory.
class MockExamSessionInfo extends Equatable {
  const MockExamSessionInfo({required this.status, this.currentItemPosition});

  final MockExamStatus status;
  final int? currentItemPosition;

  @override
  List<Object?> get props => [status, currentItemPosition];
}
