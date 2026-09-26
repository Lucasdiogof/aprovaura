import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_review_state.dart';

/// Loads a finished exam's own items for a read-only review of what was
/// answered vs. what was correct. Same RPC the exam runner uses
/// (getItems) -- it already returns correct_index/is_correct/explanation
/// once the exam is finished, so no new endpoint was needed for this.
class MockExamReviewCubit extends Cubit<MockExamReviewState> {
  MockExamReviewCubit(this._repository, {required this.mockExamId})
    : super(const MockExamReviewLoading()) {
    load();
  }

  final MockExamRepository _repository;
  final String mockExamId;

  Future<void> load() async {
    emit(const MockExamReviewLoading());
    final result = await _repository.getItems(mockExamId);
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => MockExamReviewLoaded(data),
      Error() => const MockExamReviewError(),
    });
  }
}
