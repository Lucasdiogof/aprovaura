import 'package:equatable/equatable.dart';

class TopicProgress extends Equatable {
  const TopicProgress({required this.completed, required this.total});

  static const empty = TopicProgress(completed: 0, total: 0);

  final int completed;
  final int total;

  double get fraction => total == 0 ? 0 : completed / total;
  bool get isCompleted => total > 0 && completed == total;

  @override
  List<Object?> get props => [completed, total];
}
