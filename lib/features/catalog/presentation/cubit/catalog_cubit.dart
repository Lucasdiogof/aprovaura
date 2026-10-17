import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';
import 'package:aura/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:aura/features/catalog/presentation/cubit/catalog_state.dart';
import 'package:aura/features/progress/domain/entities/topic_progress.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(
    this._repository,
    this._progressRepository, {
    required this.subject,
    this.parentId,
    this.difficulty,
  }) : super(const CatalogLoading()) {
    load();
  }

  final CatalogRepository _repository;
  final ProgressRepository _progressRepository;
  final String subject;
  final String? parentId;
  QuestionDifficulty? difficulty;

  // Bumped on every load/refresh/filter change. A response that comes back
  // after a newer request started (slow network, quick filter taps) is
  // dropped, so it can never overwrite the list of the filter now selected.
  int _requestId = 0;

  Future<void> setDifficulty(QuestionDifficulty? value) async {
    if (difficulty == value) return;
    difficulty = value;
    await load();
  }

  // Shows the last saved copy right away (if any) and asks the server in the
  // background; with nothing saved, shows the loading state instead.
  Future<void> load() => _fetch(showLoading: true);

  // Reloads in place, without the CatalogLoading flash — used when returning
  // to this screen from a finished activity, so the progress bars update
  // without the list disappearing for a moment.
  Future<void> refresh() => _fetch(showLoading: false);

  Future<void> _fetch({required bool showLoading}) async {
    final requestId = ++_requestId;
    final requested = difficulty;
    bool stale() => isClosed || requestId != _requestId;

    List<CatalogNode>? shown;
    Map<String, TopicProgress> shownProgress = const {};
    if (showLoading) {
      shown = await _repository.cachedChildren(
        subject: subject,
        parentId: parentId,
        difficulty: requested,
      );
      if (stale()) return;
      if (shown != null) {
        shownProgress =
            await _progressRepository.cachedBatchProgress(
              shown.map((node) => node.id).toList(growable: false),
              difficulty: requested,
            ) ??
            const {};
        if (stale()) return;
        emit(CatalogLoaded(shown, shownProgress));
      } else {
        emit(const CatalogLoading());
      }
    } else if (state case CatalogLoaded(:final nodes, :final progressByNodeId)) {
      shown = nodes;
      shownProgress = progressByNodeId;
    }

    final result = await _repository.getChildren(
      subject: subject,
      parentId: parentId,
      difficulty: requested,
    );
    if (stale()) return;
    switch (result) {
      case Success(:final data):
        final progressResult = await _progressRepository.getBatchProgress(
          data.map((node) => node.id).toList(growable: false),
          difficulty: requested,
        );
        if (stale()) return;
        final progress = switch (progressResult) {
          Success(data: final progressMap) => progressMap,
          Error() => data.any((node) => shownProgress.containsKey(node.id))
              ? shownProgress
              : const <String, TopicProgress>{},
        };
        emit(CatalogLoaded(data, progress));
      case Error(:final failure):
        if (shown != null) {
          // Keep the last good data instead of wiping it; just say why it
          // may be out of date.
          emit(
            CatalogLoaded(
              shown,
              shownProgress,
              offlineMessage: failure.message,
            ),
          );
        } else {
          emit(
            CatalogError(
              failure.message,
              isConnection: isConnectionFailure(failure),
            ),
          );
        }
    }
  }
}
