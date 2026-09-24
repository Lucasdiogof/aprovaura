import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_result.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';

sealed class MockExamResultState extends Equatable {
  const MockExamResultState();

  @override
  List<Object?> get props => [];
}

class MockExamResultLoading extends MockExamResultState {
  const MockExamResultLoading();
}

class MockExamResultError extends MockExamResultState {
  const MockExamResultError();
}

/// No finished exam with that id for this user.
class MockExamResultNotFound extends MockExamResultState {
  const MockExamResultNotFound();
}

class MockExamResultLoaded extends MockExamResultState {
  const MockExamResultLoaded(this.result);

  final MockExamResult result;

  @override
  List<Object?> get props => [result];
}

/// Loads a finished exam's result by id. Read-only: retrying after an
/// error just reads again -- it never calls finish or awards anything.
class MockExamResultCubit extends Cubit<MockExamResultState> {
  MockExamResultCubit(this._repository, {required this.mockExamId})
    : super(const MockExamResultLoading()) {
    load();
  }

  final MockExamRepository _repository;
  final String mockExamId;

  Future<void> load() async {
    emit(const MockExamResultLoading());
    final result = await _repository.getResult(mockExamId);
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data?) => MockExamResultLoaded(data),
      Success() => const MockExamResultNotFound(),
      Error() => const MockExamResultError(),
    });
  }
}
