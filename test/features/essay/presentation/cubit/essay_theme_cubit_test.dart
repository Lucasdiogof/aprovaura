import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/cubit/essay_theme_cubit.dart';
import 'package:aura/features/essay/presentation/cubit/essay_theme_state.dart';

class _MockEssayRepository extends Mock implements EssayRepository {}

const _theme = EssayTheme(
  id: 't1',
  title: 'Desinformação e o direito de saber',
  prompt: 'Redija um texto dissertativo-argumentativo...',
  origin: EssayThemeOrigin.practice(),
);

void main() {
  group(EssayThemeCubit, () {
    late EssayRepository repository;

    setUp(() => repository = _MockEssayRepository());

    blocTest<EssayThemeCubit, EssayThemeState>(
      'loads the proposal',
      build: () {
        when(
          () => repository.getTheme('t1'),
        ).thenAnswer((_) async => const Success(_theme));
        return EssayThemeCubit(repository, 't1');
      },
      expect: () => [const EssayThemeLoaded(_theme)],
    );

    blocTest<EssayThemeCubit, EssayThemeState>(
      'a failure becomes a plain error state',
      build: () {
        when(
          () => repository.getTheme('t1'),
        ).thenAnswer((_) async => Error(ServerFailure()));
        return EssayThemeCubit(repository, 't1');
      },
      expect: () => [const EssayThemeError()],
    );
  });
}
