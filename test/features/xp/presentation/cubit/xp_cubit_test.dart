import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';
import 'package:aura/features/xp/domain/repositories/xp_repository.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/features/xp/presentation/cubit/xp_state.dart';

class _MockXpRepository extends Mock implements XpRepository {}

void main() {
  group(XpCubit, () {
    late XpRepository repository;

    const xp = UserXp(totalXp: 250);

    setUp(() {
      repository = _MockXpRepository();
    });

    test('starts in $XpLoading', () {
      expect(XpCubit(repository).state, const XpLoading());
    });

    group('load', () {
      blocTest<XpCubit, XpState>(
        'emits $XpLoaded when the repository call succeeds',
        build: () {
          when(
            () => repository.getCurrent(),
          ).thenAnswer((_) async => const Success(xp));
          return XpCubit(repository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [const XpLoaded(xp)],
      );

      blocTest<XpCubit, XpState>(
        'emits $XpError when the repository call fails',
        build: () {
          when(
            () => repository.getCurrent(),
          ).thenAnswer((_) async => Error(ServerFailure('boom')));
          return XpCubit(repository);
        },
        act: (cubit) => cubit.load(),
        expect: () => [const XpError()],
      );
    });

    group('awardQuizXp', () {
      blocTest<XpCubit, XpState>(
        'emits $XpLoaded with the updated total on success',
        build: () {
          when(
            () => repository.awardQuizXp(
              attemptId: any(named: 'attemptId'),
              correctCount: any(named: 'correctCount'),
            ),
          ).thenAnswer((_) async => const Success(UserXp(totalXp: 300)));
          return XpCubit(repository);
        },
        act: (cubit) =>
            cubit.awardQuizXp(attemptId: 'attempt-1', correctCount: 5),
        expect: () => [const XpLoaded(UserXp(totalXp: 300))],
        verify: (_) {
          verify(
            () =>
                repository.awardQuizXp(attemptId: 'attempt-1', correctCount: 5),
          ).called(1);
        },
      );

      blocTest<XpCubit, XpState>(
        'emits nothing when the repository call fails',
        build: () {
          when(
            () => repository.awardQuizXp(
              attemptId: any(named: 'attemptId'),
              correctCount: any(named: 'correctCount'),
            ),
          ).thenAnswer((_) async => Error<UserXp>(ServerFailure('boom')));
          return XpCubit(repository);
        },
        act: (cubit) =>
            cubit.awardQuizXp(attemptId: 'attempt-1', correctCount: 0),
        expect: () => <XpState>[],
      );
    });
  });
}
