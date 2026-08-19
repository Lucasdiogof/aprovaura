import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/xp/domain/repositories/xp_repository.dart';
import 'package:aura/features/xp/presentation/cubit/xp_state.dart';

class XpCubit extends Cubit<XpState> {
  // Lives above the auth boundary (provided once for the whole app), so
  // load() is triggered explicitly once a session exists (HomeShellPage)
  // instead of eagerly here, where there may be no signed-in user yet.
  XpCubit(this._repository) : super(const XpLoading());

  final XpRepository _repository;

  Future<void> load() async {
    final result = await _repository.getCurrent();
    switch (result) {
      case Success(:final data):
        emit(XpLoaded(data));
      case Error():
        emit(const XpError());
    }
  }

  Future<void> awardActivityCompletion() async {
    final result = await _repository.awardActivityXp();
    if (result case Success(:final data)) {
      emit(XpLoaded(data));
    }
  }
}
