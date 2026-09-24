import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/favorites/presentation/cubit/favorite_questions_state.dart';

class FavoriteQuestionsCubit extends Cubit<FavoriteQuestionsState> {
  FavoriteQuestionsCubit(this._repository, {required this.catalogNodeId})
    : super(const FavoriteQuestionsLoading()) {
    load();
  }

  final FavoritesRepository _repository;
  final String catalogNodeId;

  Future<void> load() async {
    emit(const FavoriteQuestionsLoading());
    await _fetch();
  }

  // Reloads in place after returning from practice, so statuses (and any
  // question unfavorited mid-practice) update without a loading flash.
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    final result = await _repository.listFavoriteQuestions(catalogNodeId);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(FavoriteQuestionsLoaded(data));
      case Error(:final failure):
        emit(FavoriteQuestionsError(failure.message));
    }
  }
}
