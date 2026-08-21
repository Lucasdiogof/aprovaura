import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/streak/domain/repositories/streak_repository.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/streak/presentation/cubit/streak_state.dart';

class _MockStreakRepository extends Mock implements StreakRepository {}

void main() {
  group(StreakCubit, () {
    late StreakRepository repository;

    const streak = Streak(
      currentStreak: 3,
      longestStreak: 5,
      streakBreakVersion: 1,
      seenStreakBreakVersion: 1,
    );

    setUp(() {
      repository = _MockStreakRepository();
    });

    test('starts in $StreakLoading', () {
      expect(StreakCubit(repository).state, const StreakLoading());
    });

    group('load', () {
      blocTest<StreakCubit, StreakState>(
        'emits $StreakLoaded when the repository call succeeds',
        build: () {
          when(
            () => repository.getOrRefresh(),
          ).thenAnswer((_) async => const Success(streak));
          return StreakCubit(repository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [const StreakLoaded(streak)],
      );

      blocTest<StreakCubit, StreakState>(
        'emits $StreakError when the repository call fails',
        build: () {
          when(
            () => repository.getOrRefresh(),
          ).thenAnswer((_) async => Error(ServerFailure('boom')));
          return StreakCubit(repository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [const StreakError()],
      );
    });

    group('registerActivityCompletion', () {
      blocTest<StreakCubit, StreakState>(
        'emits $StreakLoaded with the updated streak on success',
        build: () {
          when(
            () => repository.registerActivityCompletion(),
          ).thenAnswer((_) async => const Success(streak));
          return StreakCubit(repository);
        },
        act: (cubit) => cubit.registerActivityCompletion(),
        expect: () => [const StreakLoaded(streak)],
      );

      blocTest<StreakCubit, StreakState>(
        'emits nothing when the repository call fails',
        build: () {
          when(
            () => repository.registerActivityCompletion(),
          ).thenAnswer((_) async => Error(ServerFailure('boom')));
          return StreakCubit(repository);
        },
        act: (cubit) => cubit.registerActivityCompletion(),
        expect: () => <StreakState>[],
      );
    });

    group('dismissBreakNotice', () {
      blocTest<StreakCubit, StreakState>(
        'marks seenStreakBreakVersion as caught up and calls markBreakSeen',
        build: () {
          when(
            () => repository.markBreakSeen(),
          ).thenAnswer((_) async => const Success(null));
          return StreakCubit(repository);
        },
        seed: () => const StreakLoaded(
          Streak(
            currentStreak: 0,
            longestStreak: 5,
            streakBreakVersion: 2,
            seenStreakBreakVersion: 1,
          ),
        ),
        act: (cubit) => cubit.dismissBreakNotice(),
        expect: () => [
          const StreakLoaded(
            Streak(
              currentStreak: 0,
              longestStreak: 5,
              streakBreakVersion: 2,
              seenStreakBreakVersion: 2,
            ),
          ),
        ],
        verify: (_) {
          verify(() => repository.markBreakSeen()).called(1);
        },
      );

      blocTest<StreakCubit, StreakState>(
        'does nothing when there is no loaded streak yet',
        build: () => StreakCubit(repository),
        act: (cubit) => cubit.dismissBreakNotice(),
        expect: () => <StreakState>[],
        verify: (_) {
          verifyNever(() => repository.markBreakSeen());
        },
      );
    });
  });
}
