import 'package:equatable/equatable.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';

class TapFeedback extends Equatable {
  const TapFeedback({required this.regionId, required this.wasCorrect});

  final String regionId;
  final bool wasCorrect;

  @override
  List<Object?> get props => [regionId, wasCorrect];
}

sealed class MapQuizState extends Equatable {
  const MapQuizState();

  @override
  List<Object?> get props => [];
}

class MapQuizLoading extends MapQuizState {
  const MapQuizLoading();
}

class MapQuizError extends MapQuizState {
  const MapQuizError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class MapQuizPlaying extends MapQuizState {
  const MapQuizPlaying({
    required this.regions,
    required this.remainingIds,
    required this.currentTargetId,
    required this.correctCount,
    required this.totalCount,
    this.backgroundRegions = const [],
    this.lastTap,
    this.wrongAttempts = 0,
    this.revealed = false,
  });

  final List<MapRegion> regions;
  final List<MapRegion> backgroundRegions;
  final List<String> remainingIds;
  final String currentTargetId;
  final int correctCount;
  final int totalCount;
  final TapFeedback? lastTap;
  // How many wrong taps the user has made on the current target. Resets to
  // 0 whenever the target changes (correct answer or reveal-and-skip).
  final int wrongAttempts;
  // True once wrongAttempts hits the miss limit: the current target's
  // region is shown highlighted as the answer instead of accepting more
  // taps, until the page advances past it.
  final bool revealed;

  MapQuizPlaying copyWith({
    List<String>? remainingIds,
    String? currentTargetId,
    int? correctCount,
    TapFeedback? lastTap,
    bool clearLastTap = false,
    int? wrongAttempts,
    bool? revealed,
  }) => MapQuizPlaying(
    regions: regions,
    backgroundRegions: backgroundRegions,
    remainingIds: remainingIds ?? this.remainingIds,
    currentTargetId: currentTargetId ?? this.currentTargetId,
    correctCount: correctCount ?? this.correctCount,
    totalCount: totalCount,
    lastTap: clearLastTap ? null : (lastTap ?? this.lastTap),
    wrongAttempts: wrongAttempts ?? this.wrongAttempts,
    revealed: revealed ?? this.revealed,
  );

  @override
  List<Object?> get props => [
    regions,
    backgroundRegions,
    remainingIds,
    currentTargetId,
    correctCount,
    totalCount,
    lastTap,
    wrongAttempts,
    revealed,
  ];
}

class MapQuizFinished extends MapQuizState {
  const MapQuizFinished({
    required this.correctCount,
    required this.totalCount,
    required this.attemptId,
  });

  final int correctCount;
  final int totalCount;
  // Identifies this attempt for award_quiz_xp()'s idempotency check --
  // see MultipleChoiceFinished.attemptId for the full rationale.
  final String attemptId;

  @override
  List<Object?> get props => [correctCount, totalCount, attemptId];
}
