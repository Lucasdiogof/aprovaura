import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/streak/domain/repositories/streak_repository.dart';
import 'package:aura/features/streak/presentation/cubit/streak_state.dart';

class StreakCubit extends Cubit<StreakState> {
  // Lives above the auth boundary (provided once for the whole app), so
  // load() is triggered explicitly once a session exists (HomeShellPage)
  // instead of eagerly here, where there may be no signed-in user yet.
  StreakCubit(this._repository) : super(const StreakLoading());

  final StreakRepository _repository;

  Future<void> load() async {
    final result = await _repository.getOrRefresh();
    switch (result) {
      case Success(:final data):
        emit(StreakLoaded(data));
      case Error():
        emit(const StreakError());
    }
  }

  Future<void> registerActivityCompletion() async {
    final result = await _repository.registerActivityCompletion();
    if (result case Success(:final data)) {
      emit(StreakLoaded(data));
    }
  }

  Future<void> dismissBreakNotice() async {
    final current = state;
    if (current is! StreakLoaded) return;
    emit(
      StreakLoaded(
        current.streak.copyWith(
          seenStreakBreakVersion: current.streak.streakBreakVersion,
        ),
      ),
    );
    await _repository.markBreakSeen();
  }
}
