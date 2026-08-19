import 'package:equatable/equatable.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';

sealed class StreakState extends Equatable {
  const StreakState();

  @override
  List<Object?> get props => [];
}

class StreakLoading extends StreakState {
  const StreakLoading();
}

class StreakError extends StreakState {
  const StreakError();
}

class StreakLoaded extends StreakState {
  const StreakLoaded(this.streak);

  final Streak streak;

  @override
  List<Object?> get props => [streak];
}
