import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';
import 'package:aura/features/error_review/presentation/cubit/error_review_state.dart';

class ErrorReviewCubit extends Cubit<ErrorReviewState> {
  ErrorReviewCubit(this._repository) : super(const ErrorReviewLoading()) {
    load();
  }

  final ErrorReviewRepository _repository;

  Future<void> load() async {
    emit(const ErrorReviewLoading());
    await _fetch();
  }

  // Reloads in place, without the loading flash -- used when returning to
  // this screen after resolving (or adding to) a topic's pending errors.
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    final result = await _repository.listPendingTopics();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(ErrorReviewLoaded(data));
      case Error(:final failure):
        emit(ErrorReviewError(failure.message));
    }
  }
}
