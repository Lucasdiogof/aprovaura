import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/profile/domain/entities/goal.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/profile/presentation/cubit/profile_state.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository, AppUser authUser)
    : super(ProfileState(authUser: authUser)) {
    load();
  }

  final ProfileRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    final result = await _repository.getCurrent();
    switch (result) {
      case Success(:final data):
        emit(state.copyWith(profile: data, loading: false));
      case Error():
        emit(state.copyWith(loading: false));
    }
  }

  void applyName(String name) {
    final profile = state.profile;
    if (profile == null) return;
    emit(state.copyWith(profile: profile.copyWith(name: name)));
  }

  void applyUsername(String username) {
    final profile = state.profile;
    if (profile == null) return;
    emit(state.copyWith(profile: profile.copyWith(username: username)));
  }

  void applyGoal(Goal goal) {
    final profile = state.profile;
    if (profile == null) return;
    emit(state.copyWith(profile: profile.copyWith(goal: goal)));
  }

  void applyInterestedSubjects(List<Subject> subjects) {
    final profile = state.profile;
    if (profile == null) return;
    emit(
      state.copyWith(profile: profile.copyWith(interestedSubjects: subjects)),
    );
  }

  Future<Result<void>> updateProfile({
    String? name,
    String? username,
    Goal? goal,
    String? examYear,
    List<Subject>? interestedSubjects,
  }) async {
    // Optimistic: the choice shows up the instant it's tapped instead of
    // after the round trip, which on a slow connection read as "the screen
    // ignores my taps". Rolled back if the save fails.
    final previous = state.profile;
    if (previous != null) {
      emit(
        state.copyWith(
          profile: previous.copyWith(
            name: name,
            username: username,
            goal: goal,
            examYear: examYear,
            interestedSubjects: interestedSubjects,
          ),
        ),
      );
    }
    final result = await _repository.updateProfile(
      name: name,
      username: username,
      goal: goal,
      examYear: examYear,
      interestedSubjects: interestedSubjects,
    );
    switch (result) {
      case Success():
        // Nothing local to patch if the profile never loaded: fetch the
        // saved row, or the screen would keep showing no selection at all.
        if (previous == null) await load();
      case Error():
        if (previous != null) emit(state.copyWith(profile: previous));
    }
    return result;
  }
}
