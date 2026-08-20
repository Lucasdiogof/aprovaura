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
  });

  final List<MapRegion> regions;
  final List<MapRegion> backgroundRegions;
  final List<String> remainingIds;
  final String currentTargetId;
  final int correctCount;
  final int totalCount;
  final TapFeedback? lastTap;

  MapQuizPlaying copyWith({
    List<String>? remainingIds,
    String? currentTargetId,
    int? correctCount,
    TapFeedback? lastTap,
    bool clearLastTap = false,
  }) => MapQuizPlaying(
    regions: regions,
    backgroundRegions: backgroundRegions,
    remainingIds: remainingIds ?? this.remainingIds,
    currentTargetId: currentTargetId ?? this.currentTargetId,
    correctCount: correctCount ?? this.correctCount,
    totalCount: totalCount,
    lastTap: clearLastTap ? null : (lastTap ?? this.lastTap),
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
  ];
}

class MapQuizFinished extends MapQuizState {
  const MapQuizFinished({required this.correctCount, required this.totalCount});

  final int correctCount;
  final int totalCount;

  @override
  List<Object?> get props => [correctCount, totalCount];
}
