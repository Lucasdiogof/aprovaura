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
    final result = await _repository.updateProfile(
      name: name,
      username: username,
      goal: goal,
      examYear: examYear,
      interestedSubjects: interestedSubjects,
    );
    if (result is Success<void>) {
      final profile = state.profile;
      if (profile != null) {
        emit(
          state.copyWith(
            profile: profile.copyWith(
              name: name,
              username: username,
              goal: goal,
              examYear: examYear,
              interestedSubjects: interestedSubjects,
            ),
          ),
        );
      }
    }
    return result;
  }
}
