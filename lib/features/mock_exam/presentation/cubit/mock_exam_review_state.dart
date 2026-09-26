import 'package:equatable/equatable.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_item.dart';

sealed class MockExamReviewState extends Equatable {
  const MockExamReviewState();

  @override
  List<Object?> get props => [];
}

class MockExamReviewLoading extends MockExamReviewState {
  const MockExamReviewLoading();
}

class MockExamReviewError extends MockExamReviewState {
  const MockExamReviewError();
}

class MockExamReviewLoaded extends MockExamReviewState {
  const MockExamReviewLoaded(this.items);

  /// Every item, in position order -- filtering to only wrong/blank ones
  /// is the page's job, not the cubit's (it's a display choice, not data).
  final List<MockExamItem> items;

  @override
  List<Object?> get props => [items];
}
