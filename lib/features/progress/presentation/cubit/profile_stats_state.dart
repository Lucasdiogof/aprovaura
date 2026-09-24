import 'package:equatable/equatable.dart';
import 'package:aura/features/progress/domain/entities/profile_stats.dart';

sealed class ProfileStatsState extends Equatable {
  const ProfileStatsState();

  @override
  List<Object?> get props => [];
}

class ProfileStatsLoading extends ProfileStatsState {
  const ProfileStatsLoading();
}

class ProfileStatsLoaded extends ProfileStatsState {
  const ProfileStatsLoaded(this.stats);

  final ProfileStats stats;

  @override
  List<Object?> get props => [stats];
}

class ProfileStatsError extends ProfileStatsState {
  const ProfileStatsError();
}
