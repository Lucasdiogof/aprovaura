import 'package:equatable/equatable.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInProgress extends SplashState {
  const SplashInProgress();
}

class SplashCompleted extends SplashState {
  const SplashCompleted();
}
