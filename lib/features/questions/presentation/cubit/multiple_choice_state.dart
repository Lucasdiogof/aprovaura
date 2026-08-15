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
    this.selectedIndex,
  });

  final List<Question> questions;
  final int currentIndex;
  final int correctCount;
  final int? selectedIndex;

  Question get currentQuestion => questions[currentIndex];
  bool get hasAnswered => selectedIndex != null;
  bool get isLastQuestion => currentIndex == questions.length - 1;

  MultipleChoicePlaying copyWith({
    int? currentIndex,
    int? correctCount,
    int? selectedIndex,
    bool clearSelection = false,
  }) => MultipleChoicePlaying(
    questions: questions,
    currentIndex: currentIndex ?? this.currentIndex,
    correctCount: correctCount ?? this.correctCount,
    selectedIndex: clearSelection
        ? null
        : (selectedIndex ?? this.selectedIndex),
  );

  @override
  List<Object?> get props => [
    questions,
    currentIndex,
    correctCount,
    selectedIndex,
  ];
}

class MultipleChoiceFinished extends MultipleChoiceState {
  const MultipleChoiceFinished({
    required this.correctCount,
    required this.totalCount,
  });

  final int correctCount;
  final int totalCount;

  @override
  List<Object?> get props => [correctCount, totalCount];
}
