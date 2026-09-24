import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
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

    setUp(() {
      repository = _MockEssayRepository();
      when(
        () => repository.listAttempts('t1'),
      ).thenAnswer((_) async => const Success(<EssayAttempt>[]));
    });

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
      'loads the history alongside the proposal, in one go',
      build: () {
        when(
          () => repository.getTheme('t1'),
        ).thenAnswer((_) async => const Success(_theme));
        when(() => repository.listAttempts('t1')).thenAnswer(
          (_) async => Success([
            EssayAttempt(
              id: 's1',
              status: EssaySubmissionStatus.evaluated,
              wordCount: 280,
              submittedAt: DateTime(2026, 9, 18),
              totalScore: 880,
            ),
          ]),
        );
        return EssayThemeCubit(repository, 't1');
      },
      verify: (cubit) {
        final state = cubit.state as EssayThemeLoaded;
        expect(state.attempts, hasLength(1));
        expect(state.attempts.single.totalScore, 880);
      },
    );

    blocTest<EssayThemeCubit, EssayThemeState>(
      'a history that fails to load does not take the proposal down with it',
      build: () {
        when(
          () => repository.getTheme('t1'),
        ).thenAnswer((_) async => const Success(_theme));
        when(
          () => repository.listAttempts('t1'),
        ).thenAnswer((_) async => Error(ServerFailure()));
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
