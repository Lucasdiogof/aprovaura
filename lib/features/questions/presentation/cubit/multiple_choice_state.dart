import 'package:equatable/equatable.dart';
import 'package:aura/features/questions/domain/entities/question.dart';

sealed class MultipleChoiceState extends Equatable {
  const MultipleChoiceState();

  @override
  List<Object?> get props => [];
}

class MultipleChoiceLoading extends MultipleChoiceState {
  const MultipleChoiceLoading();
}

class MultipleChoiceError extends MultipleChoiceState {
  const MultipleChoiceError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class MultipleChoiceEmpty extends MultipleChoiceState {
  const MultipleChoiceEmpty();
}

class MultipleChoicePlaying extends MultipleChoiceState {
  const MultipleChoicePlaying({
    required this.questions,
    required this.currentIndex,
    required this.correctCount,
    this.answers = const {},
    this.favoriteQuestionIds = const {},
    this.isPersisting = false,
  });

  final List<Question> questions;
  final int currentIndex;
  final int correctCount;
  // Question index -> selected option index, so navigating back to an
  // earlier question still shows what was picked there.
  final Map<int, int> answers;
  final Set<String> favoriteQuestionIds;
  // True while the current answer's registerQuestionAnswered() call is in
  // flight. next() refuses to advance (and the UI disables its button)
  // until this clears, so the answer is guaranteed persisted before the
  // question changes or the deck finishes -- see selectOption()'s comment
  // for why that matters for quick practice's "Mais questões".
  final bool isPersisting;

  Question get currentQuestion => questions[currentIndex];
  int? get selectedIndex => answers[currentIndex];
  bool get hasAnswered => selectedIndex != null;
  bool get isFirstQuestion => currentIndex == 0;
  bool get isLastQuestion => currentIndex == questions.length - 1;
  bool get isCurrentFavorited =>
      favoriteQuestionIds.contains(currentQuestion.id);

  MultipleChoicePlaying copyWith({
    int? currentIndex,
    int? correctCount,
    Map<int, int>? answers,
    Set<String>? favoriteQuestionIds,
    bool? isPersisting,
  }) => MultipleChoicePlaying(
    questions: questions,
    currentIndex: currentIndex ?? this.currentIndex,
    correctCount: correctCount ?? this.correctCount,
    answers: answers ?? this.answers,
    favoriteQuestionIds: favoriteQuestionIds ?? this.favoriteQuestionIds,
    isPersisting: isPersisting ?? this.isPersisting,
  );

  @override
  List<Object?> get props => [
    questions,
    currentIndex,
    correctCount,
    answers,
    favoriteQuestionIds,
    isPersisting,
  ];
}

class MultipleChoiceFinished extends MultipleChoiceState {
  const MultipleChoiceFinished({
    required this.correctCount,
    required this.totalCount,
    required this.attemptId,
  });

  final int correctCount;
  final int totalCount;
  // Identifies this attempt for award_quiz_xp()'s idempotency check: the
  // same id for two calls (a rebuild, a retried request) is a no-op on
  // the server, so XP is never double-awarded for one attempt.
  final String attemptId;

  @override
  List<Object?> get props => [correctCount, totalCount, attemptId];
}
