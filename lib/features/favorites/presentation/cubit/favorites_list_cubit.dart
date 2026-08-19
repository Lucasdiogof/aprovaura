import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/favorites/presentation/cubit/favorites_list_state.dart';

class FavoritesListCubit extends Cubit<FavoritesListState> {
  FavoritesListCubit(this._repository) : super(const FavoritesListLoading()) {
    load();
  }

  final FavoritesRepository _repository;

  Future<void> load() async {
    emit(const FavoritesListLoading());
    await _fetch();
  }

  // Reloads in place, without the loading flash -- used when returning to
  // this screen after unfavoriting questions during practice.
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    final result = await _repository.listFavoriteTopics();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(FavoritesListLoaded(data));
      case Error(:final failure):
        emit(FavoritesListError(failure.message));
    }
  }
}
