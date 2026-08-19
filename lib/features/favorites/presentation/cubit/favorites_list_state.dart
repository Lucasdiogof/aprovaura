import 'package:equatable/equatable.dart';
import 'package:aura/features/favorites/domain/entities/favorite_topic.dart';

sealed class FavoritesListState extends Equatable {
  const FavoritesListState();

  @override
  List<Object?> get props => [];
}

class FavoritesListLoading extends FavoritesListState {
  const FavoritesListLoading();
}

class FavoritesListError extends FavoritesListState {
  const FavoritesListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class FavoritesListLoaded extends FavoritesListState {
  const FavoritesListLoaded(this.topics);

  final List<FavoriteTopic> topics;

  @override
  List<Object?> get props => [topics];
}
