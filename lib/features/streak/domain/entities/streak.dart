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
