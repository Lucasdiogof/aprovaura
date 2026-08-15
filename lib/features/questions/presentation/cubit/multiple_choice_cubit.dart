import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';
import 'package:aura/features/questions/presentation/cubit/multiple_choice_state.dart';

class MultipleChoiceCubit extends Cubit<MultipleChoiceState> {
  MultipleChoiceCubit(this._repository, {required this.catalogNodeId})
    : super(const MultipleChoiceLoading()) {
    load();
  }

  final QuestionRepository _repository;
  final String catalogNodeId;

  Future<void> load() async {
    emit(const MultipleChoiceLoading());
    final result = await _repository.getQuestions(catalogNodeId);
    switch (result) {
      case Success(:final data):
        if (data.isEmpty) {
          emit(const MultipleChoiceEmpty());
        } else {
          emit(
            MultipleChoicePlaying(
              questions: data,
              currentIndex: 0,
              correctCount: 0,
            ),
          );
        }
      case Error(:final failure):
        emit(MultipleChoiceError(failure.message));
    }
  }

  void selectOption(int index) {
    final current = state;
    if (current is! MultipleChoicePlaying || current.hasAnswered) return;

    final isCorrect = index == current.currentQuestion.correctIndex;
    emit(
      current.copyWith(
        selectedIndex: index,
        correctCount: isCorrect ? current.correctCount + 1 : null,
      ),
    );
  }

  void next() {
    final current = state;
    if (current is! MultipleChoicePlaying || !current.hasAnswered) return;

    if (current.isLastQuestion) {
      emit(
        MultipleChoiceFinished(
          correctCount: current.correctCount,
          totalCount: current.questions.length,
        ),
      );
      return;
    }
    emit(
      current.copyWith(
        currentIndex: current.currentIndex + 1,
        clearSelection: true,
      ),
    );
  }
}
