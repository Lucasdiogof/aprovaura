import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';
import 'package:aura/features/questions/presentation/cubit/multiple_choice_state.dart';

class MultipleChoiceCubit extends Cubit<MultipleChoiceState> {
  MultipleChoiceCubit(
    this._repository,
    this._progressRepository, {
    required this.catalogNodeId,
    this.difficulty,
    this.trackProgress = true,
  }) : super(const MultipleChoiceLoading()) {
    load();
  }

  final QuestionRepository _repository;
  final ProgressRepository _progressRepository;
  final String catalogNodeId;
  final QuestionDifficulty? difficulty;
  // False for content (like Atualidades dossiers) that isn't part of the
  // catalog_nodes/questions tree that progress is tracked against.
  final bool trackProgress;

  Future<void> load() async {
    emit(const MultipleChoiceLoading());
    final result = await _repository.getQuestions(
      catalogNodeId,
      difficulty: difficulty,
    );
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        if (data.isEmpty) {
          emit(const MultipleChoiceEmpty());
        } else {
          emit(
            MultipleChoicePlaying(
              questions: data.map(_withShuffledOptions).toList(),
              currentIndex: 0,
              correctCount: 0,
            ),
          );
        }
      case Error(:final failure):
        emit(MultipleChoiceError(failure.message));
    }
  }

  // Most of the question bank has correct_index hardcoded to the same
  // position in the database, so the on-screen order is re-randomized here
  // on every load instead of trusting the stored order.
  Question _withShuffledOptions(Question question) {
    final order = List<int>.generate(question.options.length, (i) => i)
      ..shuffle();
    return Question(
      id: question.id,
      prompt: question.prompt,
      options: [for (final i in order) question.options[i]],
      correctIndex: order.indexOf(question.correctIndex),
      explanation: question.explanation,
      difficulty: question.difficulty,
    );
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
    if (trackProgress) {
      _progressRepository.registerQuestionAnswered(
        questionId: current.currentQuestion.id,
        isCorrect: isCorrect,
      );
    }
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
