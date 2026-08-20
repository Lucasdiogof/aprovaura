import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';
import 'package:aura/features/map_quiz/domain/repositories/map_quiz_repository.dart';
import 'package:aura/features/map_quiz/presentation/cubit/map_quiz_state.dart';

class MapQuizCubit extends Cubit<MapQuizState> {
  MapQuizCubit(this._repository, {required this.mapId, this.backgroundMapId})
    : super(const MapQuizLoading()) {
    load();
  }

  final MapQuizRepository _repository;
  final String mapId;
  // A non-interactive reference layer (e.g. world countries) rendered
  // behind quizzes whose own shapes (short strait lines, points) don't
  // convey a recognizable map on their own the way filled country
  // polygons do.
  final String? backgroundMapId;

  Future<void> load() async {
    emit(const MapQuizLoading());
    final result = await _repository.loadRegions(mapId);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        final background = await _loadBackground();
        if (isClosed) return;
        final ids = data.map((region) => region.id).toList()..shuffle();
        emit(
          MapQuizPlaying(
            regions: data,
            backgroundRegions: background,
            remainingIds: ids,
            currentTargetId: ids.first,
            correctCount: 0,
            totalCount: data.length,
          ),
        );
      case Error(:final failure):
        emit(MapQuizError(failure.message));
    }
  }

  Future<List<MapRegion>> _loadBackground() async {
    final bgId = backgroundMapId;
    if (bgId == null) return const [];
    final result = await _repository.loadRegions(bgId);
    return switch (result) {
      Success(:final data) => data,
      Error() => const [],
    };
  }

  void onRegionTapped(String tappedId) {
    final current = state;
    if (current is! MapQuizPlaying) return;

    final wasCorrect = tappedId == current.currentTargetId;
    if (!wasCorrect) {
      emit(
        current.copyWith(
          lastTap: TapFeedback(regionId: tappedId, wasCorrect: false),
        ),
      );
      return;
    }

    final remaining = List<String>.from(current.remainingIds)..remove(tappedId);
    if (remaining.isEmpty) {
      emit(
        MapQuizFinished(
          correctCount: current.correctCount + 1,
          totalCount: current.totalCount,
        ),
      );
      return;
    }
    emit(
      current.copyWith(
        remainingIds: remaining,
        currentTargetId: remaining.first,
        correctCount: current.correctCount + 1,
        lastTap: TapFeedback(regionId: tappedId, wasCorrect: true),
      ),
    );
  }

  void clearFeedback() {
    final current = state;
    if (current is MapQuizPlaying && current.lastTap != null) {
      emit(current.copyWith(clearLastTap: true));
    }
  }
}
