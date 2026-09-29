import 'dart:async';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/utils/id_generator.dart';
import 'package:aura/features/map_quiz/domain/entities/map_board.dart';
import 'package:aura/features/map_quiz/domain/entities/map_interaction_type.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';
import 'package:aura/features/map_quiz/domain/repositories/map_quiz_repository.dart';
import 'package:aura/features/map_quiz/presentation/cubit/map_quiz_state.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';

// After this many wrong taps on the same target, the correct region is
// revealed instead of accepting more attempts.
const _maxWrongAttempts = 3;

class MapQuizCubit extends Cubit<MapQuizState> {
  /// How long a tap's own feedback stays on the board. One definition:
  /// the page waits this long before clearing the green/red, and the last
  /// answer of the map waits exactly the same before the result appears.
  static const feedbackDuration = Duration(milliseconds: 700);

  /// How long a revealed answer stays up after the miss limit. Longer on
  /// purpose -- it is the one moment the map teaches instead of testing.
  static const revealDuration = Duration(milliseconds: 1800);

  MapQuizCubit(
    this._repository,
    this._progressRepository, {
    required this.mapId,
    required this.catalogNodeId,
    this.interactionType = MapInteractionType.polygon,
    this.backgroundMapId,
    this.attemptIdGenerator = generateAttemptId,
    this.boardBuilder = buildMapBoardInBackground,
  }) : super(const MapQuizLoading()) {
    load();
  }

  final MapQuizRepository _repository;
  final ProgressRepository _progressRepository;
  final String mapId;
  final String catalogNodeId;
  // A non-interactive reference layer (e.g. world countries) rendered
  // behind quizzes whose own shapes (short strait lines, points) don't
  // convey a recognizable map on their own the way filled country
  // polygons do.
  final String? backgroundMapId;
  final MapInteractionType interactionType;
  // Walks every vertex once (37k on the world map), so by default it runs
  // off the UI thread. Tests pass [buildMapBoard] directly.
  final Future<MapBoard> Function(MapBoardInput) boardBuilder;
  // Overridable only so tests can assert on a deterministic
  // MapQuizFinished.attemptId instead of a random UUID. Not private: a
  // named initializing formal for a private field can't be passed by
  // name from another library, which is exactly what tests need to do.
  final String Function() attemptIdGenerator;
  // Set fresh on every load() (including a retry), so award_quiz_xp()
  // treats each attempt as its own idempotency key.
  String _attemptId = '';

  /// Holds the map on its last answer's feedback before finishing.
  /// Cancelled on close, so leaving the page mid-feedback never emits
  /// into a closed cubit.
  Timer? _finishTimer;

  Future<void> load() async {
    _finishTimer?.cancel();
    _attemptId = attemptIdGenerator();
    emit(const MapQuizLoading());
    final result = await _repository.loadRegions(mapId);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        final background = await _loadBackground();
        final spec = await _repository.loadViewportSpec(mapId);
        final board = await boardBuilder(
          MapBoardInput(
            regions: data,
            background: background,
            interactionType: interactionType,
            spec: spec,
          ),
        );
        if (isClosed) return;
        final ids = data.map((region) => region.id).toList()..shuffle();
        emit(
          MapQuizPlaying(
            board: board,
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
    if (current is! MapQuizPlaying || current.revealed || current.finishing) {
      return;
    }

    final wasCorrect = tappedId == current.currentTargetId;
    if (!wasCorrect) {
      final wrongAttempts = current.wrongAttempts + 1;
      emit(
        current.copyWith(
          lastTap: TapFeedback(regionId: tappedId, wasCorrect: false),
          wrongAttempts: wrongAttempts,
          revealed: wrongAttempts >= _maxWrongAttempts,
        ),
      );
      return;
    }

    _progressRepository.registerRegionFound(
      catalogNodeId: catalogNodeId,
      regionId: tappedId,
    );

    _advance(current, wasCorrect: true);
  }

  void clearFeedback() {
    final current = state;
    // Not while finishing: that feedback is the last thing on screen
    // before the result, and clearing it early is the very flash this
    // exists to avoid.
    if (current is MapQuizPlaying &&
        current.lastTap != null &&
        !current.finishing) {
      emit(current.copyWith(clearLastTap: true));
    }
  }

  // Called by the page once it's shown the revealed answer long enough --
  // moves on to the next target without counting the miss as correct.
  void advancePastReveal() {
    final current = state;
    if (current is! MapQuizPlaying || !current.revealed) return;
    _advance(current, wasCorrect: false);
  }

  @override
  Future<void> close() {
    _finishTimer?.cancel();
    return super.close();
  }

  void _advance(MapQuizPlaying current, {required bool wasCorrect}) {
    final targetId = current.currentTargetId;
    final remaining = List<String>.from(current.remainingIds)..remove(targetId);
    final correctCount = current.correctCount + (wasCorrect ? 1 : 0);
    if (remaining.isEmpty) {
      // A revealed answer has already had its own (longer) moment on
      // screen, so it finishes straight away -- the two waits must never
      // stack.
      if (!wasCorrect) {
        emit(
          MapQuizFinished(
            correctCount: correctCount,
            totalCount: current.totalCount,
            attemptId: _attemptId,
          ),
        );
        return;
      }
      // The last correct tap used to jump straight to the result, so the
      // region it found never turned green. It now gets the same moment
      // every other answer gets, and only then does the map finish.
      emit(
        current.copyWith(
          remainingIds: const [],
          correctCount: correctCount,
          lastTap: TapFeedback(regionId: targetId, wasCorrect: true),
          wrongAttempts: 0,
          revealed: false,
          finishing: true,
        ),
      );
      _finishTimer?.cancel();
      _finishTimer = Timer(feedbackDuration, () {
        if (isClosed) return;
        emit(
          MapQuizFinished(
            correctCount: correctCount,
            totalCount: current.totalCount,
            attemptId: _attemptId,
          ),
        );
      });
      return;
    }
    emit(
      current.copyWith(
        remainingIds: remaining,
        currentTargetId: remaining.first,
        correctCount: correctCount,
        lastTap: wasCorrect
            ? TapFeedback(regionId: targetId, wasCorrect: true)
            : null,
        clearLastTap: !wasCorrect,
        wrongAttempts: 0,
        revealed: false,
      ),
    );
  }
}

/// Walks every vertex once (37k on the world map), so it runs off the UI
/// thread. Public because MapQuizPage forwards it as the default for its
/// own test seam.
Future<MapBoard> buildMapBoardInBackground(MapBoardInput input) =>
    compute(buildMapBoard, input);
