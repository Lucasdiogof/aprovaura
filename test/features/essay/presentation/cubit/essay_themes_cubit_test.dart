import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/cubit/essay_themes_cubit.dart';
import 'package:aura/features/essay/presentation/cubit/essay_themes_state.dart';

class _MockEssayRepository extends Mock implements EssayRepository {}

const _theme = EssayThemeSummary(
  id: 't1',
  title: 'Desinformação e o direito de saber',
  origin: EssayThemeOrigin.practice(),
  hasDraft: false,
  attemptCount: 0,
);

void main() {
  group(EssayThemesCubit, () {
    late EssayRepository repository;

    setUp(() => repository = _MockEssayRepository());

    void stub(Result<List<EssayThemeSummary>> result) {
      when(() => repository.listThemes()).thenAnswer((_) async => result);
    }

    blocTest<EssayThemesCubit, EssayThemesState>(
      'emits the themes it loaded',
      build: () {
        stub(const Success([_theme]));
        return EssayThemesCubit(repository);
      },
      expect: () => [
        const EssayThemesLoaded([_theme]),
      ],
    );

    blocTest<EssayThemesCubit, EssayThemesState>(
      'an empty catalog is a loaded state, not an error',
      build: () {
        stub(const Success([]));
        return EssayThemesCubit(repository);
      },
      expect: () => [const EssayThemesLoaded([])],
      verify: (cubit) {
        expect((cubit.state as EssayThemesLoaded).isEmpty, isTrue);
      },
    );

    blocTest<EssayThemesCubit, EssayThemesState>(
      'emits an error state that carries no server message',
      build: () {
        stub(Error(ServerFailure('relation "essay_themes" does not exist')));
        return EssayThemesCubit(repository);
      },
      expect: () => [const EssayThemesError()],
    );

    blocTest<EssayThemesCubit, EssayThemesState>(
      'load() goes back through loading, so a retry shows progress',
      build: () {
        stub(const Success([_theme]));
        return EssayThemesCubit(repository);
      },
      // Waits for the constructor's own load to land first: emitting a
      // state equal to the current one is a no-op in Cubit, so without the
      // gap the second loading would be swallowed and prove nothing.
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 1));
        await cubit.load();
      },
      skip: 1,
      expect: () => [
        const EssayThemesLoading(),
        const EssayThemesLoaded([_theme]),
      ],
    );

    blocTest<EssayThemesCubit, EssayThemesState>(
      'refresh() reloads without flashing the loading state',
      build: () {
        stub(const Success([_theme]));
        return EssayThemesCubit(repository);
      },
      act: (cubit) async {
        await Future<void>.delayed(const Duration(milliseconds: 1));
        await cubit.refresh();
      },
      skip: 1,
      // Same list, no loading in between: nothing new to emit.
      expect: () => <EssayThemesState>[],
      verify: (_) => verify(() => repository.listThemes()).called(2),
    );
  });
}
