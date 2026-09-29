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

  /// Past the target, not just on it: the card stops saying "20 / 10".
  bool get isExceeded => target > 0 && answered > target;

  /// Whole times the target was reached (20 of 10 -> 2, 29 of 10 -> 2).
  int get timesReached => target <= 0 ? 0 : answered ~/ target;

  /// The day [instant] counts toward, as the server counts it:
  /// get_daily_question_count() dates answers in America/Sao_Paulo (UTC-3,
  /// no daylight saving since 2019), not in the device's own zone. Anything
  /// keyed by "the goal of that day" uses this, so a phone set to another
  /// timezone never files today's goal under a different date.
  static DateTime dayOf(DateTime instant) {
    final saoPaulo = instant.toUtc().subtract(const Duration(hours: 3));
    return DateTime(saoPaulo.year, saoPaulo.month, saoPaulo.day);
  }

  @override
  List<Object?> get props => [answered, target];
}
