import 'package:equatable/equatable.dart';
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
  const EssayThemeLoaded(this.theme);

  final EssayTheme theme;

  @override
  List<Object?> get props => [theme];
}
