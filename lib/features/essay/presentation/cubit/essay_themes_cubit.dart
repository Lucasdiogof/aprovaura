import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/cubit/essay_themes_state.dart';

class EssayThemesCubit extends Cubit<EssayThemesState> {
  EssayThemesCubit(this._repository) : super(const EssayThemesLoading()) {
    load();
  }

  final EssayRepository _repository;

  Future<void> load() async {
    emit(const EssayThemesLoading());
    await _fetch();
  }

  /// Reloads without the loading flash -- for coming back to the list after
  /// writing, when the draft badge or the last score may have changed.
  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    final result = await _repository.listThemes();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(EssayThemesLoaded(data));
      // The failure's own message never reaches the screen: the UI says
      // one human sentence and offers to try again.
      case Error():
        emit(const EssayThemesError());
    }
  }
}
