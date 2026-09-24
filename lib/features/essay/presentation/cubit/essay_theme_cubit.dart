import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/cubit/essay_theme_state.dart';

class EssayThemeCubit extends Cubit<EssayThemeState> {
  EssayThemeCubit(this._repository, this.themeId)
    : super(const EssayThemeLoading()) {
    load();
  }

  final EssayRepository _repository;
  final String themeId;

  Future<void> load() async {
    emit(const EssayThemeLoading());
    final result = await _repository.getTheme(themeId);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(EssayThemeLoaded(data));
      case Error():
        emit(const EssayThemeError());
    }
  }
}
