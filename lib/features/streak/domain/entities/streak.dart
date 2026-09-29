import 'package:equatable/equatable.dart';

class Streak extends Equatable {
  const Streak({
    required this.currentStreak,
    required this.longestStreak,
    required this.streakBreakVersion,
    required this.seenStreakBreakVersion,
    this.lastActivityDate,
    this.lastBrokenStreak,
  });

  static const initial = Streak(
    currentStreak: 0,
    longestStreak: 0,
    streakBreakVersion: 0,
    seenStreakBreakVersion: 0,
  );

  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final int? lastBrokenStreak;
  final int streakBreakVersion;
  final int seenStreakBreakVersion;

  bool get hasUnseenBreak => streakBreakVersion > seenStreakBreakVersion;

  /// Whether today's activity is already counted. The server dates the
  /// streak in America/Sao_Paulo (UTC-3, no daylight saving since 2019),
  /// so "today" is taken in that same zone, not the device's.
  bool isActiveToday({DateTime? now}) {
    final last = lastActivityDate;
    if (last == null) return false;
    final today = (now ?? DateTime.now()).toUtc().subtract(
      const Duration(hours: 3),
    );
    return last.year == today.year &&
        last.month == today.month &&
        last.day == today.day;
  }

  Streak copyWith({int? seenStreakBreakVersion}) => Streak(
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    lastActivityDate: lastActivityDate,
    lastBrokenStreak: lastBrokenStreak,
    streakBreakVersion: streakBreakVersion,
    seenStreakBreakVersion:
        seenStreakBreakVersion ?? this.seenStreakBreakVersion,
  );

  @override
  List<Object?> get props => [
    currentStreak,
    longestStreak,
    lastActivityDate,
    lastBrokenStreak,
    streakBreakVersion,
    seenStreakBreakVersion,
  ];
}
