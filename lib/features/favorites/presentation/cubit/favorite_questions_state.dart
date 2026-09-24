import 'package:equatable/equatable.dart';
import 'package:aura/features/favorites/domain/entities/favorite_question.dart';

sealed class FavoriteQuestionsState extends Equatable {
  const FavoriteQuestionsState();

  @override
  List<Object?> get props => [];
}

class FavoriteQuestionsLoading extends FavoriteQuestionsState {
  const FavoriteQuestionsLoading();
}

class FavoriteQuestionsError extends FavoriteQuestionsState {
  const FavoriteQuestionsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class FavoriteQuestionsLoaded extends FavoriteQuestionsState {
  const FavoriteQuestionsLoaded(this.questions);

  final List<FavoriteQuestion> questions;

  @override
  List<Object?> get props => [questions];
}
