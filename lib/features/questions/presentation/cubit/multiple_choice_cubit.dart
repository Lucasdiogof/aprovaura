import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/utils/id_generator.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';
import 'package:aura/features/questions/presentation/cubit/multiple_choice_state.dart';

class MultipleChoiceCubit extends Cubit<MultipleChoiceState> {
  MultipleChoiceCubit(
    this._repository,
    this._progressRepository,
    this._favoritesRepository, {
    required this.catalogNodeId,
    this.difficulty,
    this.trackProgress = true,
    this.attemptIdGenerator = generateAttemptId,
  }) : super(const MultipleChoiceLoading()) {
    load();
  }

  final QuestionRepository _repository;
  final ProgressRepository _progressRepository;
  final FavoritesRepository _favoritesRepository;
  final String catalogNodeId;
  final QuestionDifficulty? difficulty;
  // False for content (like Atualidades dossiers) that isn't part of the
  // catalog_nodes/questions tree that progress/favorites are tracked
  // against.
  final bool trackProgress;
  // Overridable only so tests can assert on a deterministic
  // MultipleChoiceFinished.attemptId instead of a random UUID. Not
  // private: a named initializing formal for a private field can't be
  // passed by name from another library, which is exactly what tests
  // need to do.
  final String Function() attemptIdGenerator;
  // Set fresh on every load() (including a retry), so award_quiz_xp()
  // treats each attempt as its own idempotency key.
  String _attemptId = '';

  Future<void> load() async {
    _attemptId = attemptIdGenerator();
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
          return;
        }
        final questions = data.map(_withShuffledOptions).toList();
        final favoriteIds = trackProgress
            ? await _loadFavoriteIds(questions)
            : const <String>{};
        if (isClosed) return;
        emit(
          MultipleChoicePlaying(
            questions: questions,
            currentIndex: 0,
            correctCount: 0,
            favoriteQuestionIds: favoriteIds,
          ),
        );
      case Error(:final failure):
        emit(MultipleChoiceError(failure.message));
    }
  }

  Future<Set<String>> _loadFavoriteIds(List<Question> questions) async {
    final result = await _favoritesRepository.getFavoriteQuestionIds(
      questions.map((q) => q.id).toList(growable: false),
    );
    return switch (result) {
      Success(:final data) => data,
      Error() => const {},
    };
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
        answers: {...current.answers, current.currentIndex: index},
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
          attemptId: _attemptId,
        ),
      );
      return;
    }
    emit(current.copyWith(currentIndex: current.currentIndex + 1));
  }

  void previous() {
    final current = state;
    if (current is! MultipleChoicePlaying || current.isFirstQuestion) return;
    emit(current.copyWith(currentIndex: current.currentIndex - 1));
  }

  void toggleFavorite() {
    if (!trackProgress) return;
    final current = state;
    if (current is! MultipleChoicePlaying) return;

    final questionId = current.currentQuestion.id;
    final isFavorited = current.favoriteQuestionIds.contains(questionId);
    final updatedIds = {...current.favoriteQuestionIds};
    if (isFavorited) {
      updatedIds.remove(questionId);
    } else {
      updatedIds.add(questionId);
    }
    emit(current.copyWith(favoriteQuestionIds: updatedIds));

    if (isFavorited) {
      _favoritesRepository.removeFavorite(questionId);
    } else {
      _favoritesRepository.addFavorite(questionId);
    }
  }
}
