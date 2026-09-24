import 'package:equatable/equatable.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';

sealed class EssayThemeState extends Equatable {
  const EssayThemeState();

  @override
  List<Object?> get props => [];
}

class EssayThemeLoading extends EssayThemeState {
  const EssayThemeLoading();
}

class EssayThemeError extends EssayThemeState {
  const EssayThemeError();
}

class EssayThemeLoaded extends EssayThemeState {
  const EssayThemeLoaded(this.theme, {this.attempts = const []});

  final EssayTheme theme;

  /// Newest first, straight from the server -- the history is never kept
  /// only in the app, so closing it or changing device loses nothing.
  final List<EssayAttempt> attempts;

  @override
  List<Object?> get props => [theme, attempts];
}
