import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/cubit/essay_submission_state.dart';

class EssaySubmissionCubit extends Cubit<EssaySubmissionState> {
  EssaySubmissionCubit(this._repository, this.submissionId)
    : super(const EssaySubmissionLoading()) {
    load();
  }

  final EssayRepository _repository;
  final String submissionId;

  Future<void> load() async {
    emit(const EssaySubmissionLoading());
    final result = await _repository.getSubmission(submissionId);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(EssaySubmissionLoaded(data));
      case Error():
        emit(const EssaySubmissionError());
    }
  }
}
