import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/progress/presentation/cubit/profile_stats_state.dart';

/// Feeds the lifetime "N questões, X% de acerto" line on Profile. Scoped
/// to ProfilePage (created once since Profile is one of the always-alive
/// IndexedStack tabs in HomeShellPage), not an app-level singleton like
/// StreakCubit/XpCubit -- Profile only ever renders once there's a
/// session, so there's no auth-boundary reason to delay loading.
class ProfileStatsCubit extends Cubit<ProfileStatsState> {
  ProfileStatsCubit(this._repository) : super(const ProfileStatsLoading()) {
    load();
  }

  final ProgressRepository _repository;

  Future<void> load() async {
    emit(const ProfileStatsLoading());
    final result = await _repository.getProfileStats();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(ProfileStatsLoaded(data));
      case Error():
        emit(const ProfileStatsError());
    }
  }
}
