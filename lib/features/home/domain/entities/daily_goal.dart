import 'package:equatable/equatable.dart';

/// How many questions the user has answered today (right or wrong -- this
/// tracks activity, not mastery; see catalog_node_progress for that) versus
/// the daily target. Going over the target still shows the real count (e.g.
/// 14/10), but [progress] clamps at 1.0 so the bar doesn't overflow.
class DailyGoal extends Equatable {
  const DailyGoal({required this.answered, this.target = defaultTarget});

  static const defaultTarget = 10;

  final int answered;
  final int target;

  double get progress =>
      target <= 0 ? 0 : (answered / target).clamp(0, 1).toDouble();

  bool get isComplete => answered >= target;

  @override
  List<Object?> get props => [answered, target];
}
