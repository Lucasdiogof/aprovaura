import 'package:equatable/equatable.dart';
import 'package:aura/features/questions/domain/entities/question.dart';

/// Derived from the caller's user_question_progress row for the question,
/// the same row error review reads -- never stored separately, so it can't
/// drift from what the rest of the app considers answered/wrong.
enum FavoriteQuestionStatus {
  /// No progress row: never answered anywhere in the app.
  unanswered,

  /// Latest answer was correct.
  correct,

  /// Latest answer was wrong -- the same condition that puts it in Revisar
  /// erros, and answering it correctly (here or there) clears both.
  needsReview;

  static FavoriteQuestionStatus fromProgress(bool? isCorrect) =>
      switch (isCorrect) {
        null => FavoriteQuestionStatus.unanswered,
        true => FavoriteQuestionStatus.correct,
        false => FavoriteQuestionStatus.needsReview,
      };
}

class FavoriteQuestion extends Equatable {
  const FavoriteQuestion({required this.question, required this.status});

  final Question question;
  final FavoriteQuestionStatus status;

  @override
  List<Object?> get props => [question, status];
}
