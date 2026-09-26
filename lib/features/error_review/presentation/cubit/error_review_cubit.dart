import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';
import 'package:aura/features/error_review/presentation/cubit/error_review_state.dart';

class ErrorReviewCubit extends Cubit<ErrorReviewState> {
  ErrorReviewCubit(this._repository) : super(const ErrorReviewLoading()) {
    load();
  }

  final ErrorReviewRepository _repository;

  // Bumped on every fetch, so a slow earlier fetch (e.g. the constructor's
  // own initial load, still in flight) can't land after a newer one (e.g.
  // a fast setSource tap) and overwrite it with stale data -- neither
  // fetch cancels the other, so only the most recent one is allowed to
  // actually emit.
  int _requestId = 0;

  Future<void> load() async {
    emit(ErrorReviewLoading(state.source));
    await _fetch(state.source);
  }

  // Reloads in place, without the loading flash -- used when returning to
  // this screen after resolving (or adding to) a topic's pending errors.
  Future<void> refresh() => _fetch(state.source);

  /// Switches which kind of attempt the list shows (null = everything,
  /// 'practice', or 'mock_exam') and reloads for it.
  Future<void> setSource(String? source) async {
    if (source == state.source) return;
    emit(ErrorReviewLoading(source));
    await _fetch(source);
  }

  Future<void> _fetch(String? source) async {
    final requestId = ++_requestId;
    final result = await _repository.listPendingTopics(source: source);
    if (isClosed || requestId != _requestId) return;
    switch (result) {
      case Success(:final data):
        emit(ErrorReviewLoaded(data, source));
      case Error(:final failure):
        emit(ErrorReviewError(failure.message, source));
    }
  }
}
