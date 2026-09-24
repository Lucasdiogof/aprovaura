import 'package:equatable/equatable.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';

sealed class EssayThemesState extends Equatable {
  const EssayThemesState();

  @override
  List<Object?> get props => [];
}

class EssayThemesLoading extends EssayThemesState {
  const EssayThemesLoading();
}

class EssayThemesError extends EssayThemesState {
  const EssayThemesError();
}

class EssayThemesLoaded extends EssayThemesState {
  const EssayThemesLoaded(this.themes);

  final List<EssayThemeSummary> themes;

  bool get isEmpty => themes.isEmpty;

  @override
  List<Object?> get props => [themes];
}
