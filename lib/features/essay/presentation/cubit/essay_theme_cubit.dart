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
    // Both at once: the proposal and the history are independent, and
    // asking in sequence would just double the wait.
    final (themeResult, attemptsResult) = await (
      _repository.getTheme(themeId),
      _repository.listAttempts(themeId),
    ).wait;
    if (isClosed) return;

    switch (themeResult) {
      case Success(:final data):
        emit(
          EssayThemeLoaded(
            data,
            // A history that fails to load is not worth blocking the
            // proposal for: the page still does its main job.
            attempts: switch (attemptsResult) {
              Success(data: final attempts) => attempts,
              Error() => const [],
            },
          ),
        );
      case Error():
        emit(const EssayThemeError());
    }
  }
}
