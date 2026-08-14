import 'package:equatable/equatable.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/profile/domain/entities/user_profile.dart';

class ProfileState extends Equatable {
  const ProfileState({
    required this.authUser,
    this.profile,
    this.loading = true,
  });

  final AppUser authUser;
  final UserProfile? profile;
  final bool loading;

  ProfileState copyWith({UserProfile? profile, bool? loading}) {
    return ProfileState(
      authUser: authUser,
      profile: profile ?? this.profile,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [authUser, profile, loading];
}
