import 'package:equatable/equatable.dart';

/// Lifetime totals for the Profile progress summary -- how many questions
/// answered across the whole app (any subject, any session type) and how
/// many of those were correct. Distinct from TopicProgress, which is
/// scoped to one catalog subtree.
class ProfileStats extends Equatable {
  const ProfileStats({
    required this.totalAnswered,
    required this.correctAnswered,
  });

  static const empty = ProfileStats(totalAnswered: 0, correctAnswered: 0);

  final int totalAnswered;
  final int correctAnswered;

  int get accuracyPercent => totalAnswered == 0
      ? 0
      : ((correctAnswered / totalAnswered) * 100).round();

  @override
  List<Object?> get props => [totalAnswered, correctAnswered];
}
