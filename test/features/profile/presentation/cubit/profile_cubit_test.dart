import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/profile/domain/entities/goal.dart';
import 'package:aura/features/profile/domain/entities/user_profile.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/profile_state.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  group(ProfileCubit, () {
    late ProfileRepository repository;

    const authUser = AppUser(id: 'u1', email: 'dash@example.com');
    const profile = UserProfile(id: 'u1', name: 'Dash');

    setUp(() {
      repository = _MockProfileRepository();
      registerFallbackValue(Goal.enem);
      registerFallbackValue(<Subject>[]);
    });

    Future<ProfileCubit> buildLoadedCubit() async {
      when(
        () => repository.getCurrent(),
      ).thenAnswer((_) async => const Success(profile));
      final cubit = ProfileCubit(repository, authUser);
      await pumpEventQueue();
      return cubit;
    }

    test('settles with the fetched profile and loading false', () async {
      final cubit = await buildLoadedCubit();

      expect(
        cubit.state,
        const ProfileState(
          authUser: authUser,
          profile: profile,
          loading: false,
        ),
      );
    });

    test('keeps profile null and stops loading when the fetch fails', () async {
      when(
        () => repository.getCurrent(),
      ).thenAnswer((_) async => Error(ServerFailure('boom')));
      final cubit = ProfileCubit(repository, authUser);

      await pumpEventQueue();

      expect(
        cubit.state,
        const ProfileState(authUser: authUser, loading: false),
      );
    });

    group(
      'applyName / applyUsername / applyGoal / applyInterestedSubjects',
      () {
        test('applyName updates the loaded profile in place', () async {
          final cubit = await buildLoadedCubit();

          cubit.applyName('Dash Renamed');

          expect(
            cubit.state,
            ProfileState(
              authUser: authUser,
              profile: profile.copyWith(name: 'Dash Renamed'),
              loading: false,
            ),
          );
        });

        test('applyName does nothing when no profile has loaded yet', () async {
          when(
            () => repository.getCurrent(),
          ).thenAnswer((_) async => Error(ServerFailure('boom')));
          final cubit = ProfileCubit(repository, authUser);
          await pumpEventQueue();
          final before = cubit.state;

          cubit.applyName('Dash Renamed');

          expect(cubit.state, before);
        });

        test('applyGoal updates the loaded profile in place', () async {
          final cubit = await buildLoadedCubit();

          cubit.applyGoal(Goal.vestibular);

          expect(
            cubit.state,
            ProfileState(
              authUser: authUser,
              profile: profile.copyWith(goal: Goal.vestibular),
              loading: false,
            ),
          );
        });

        test(
          'applyInterestedSubjects updates the loaded profile in place',
          () async {
            final cubit = await buildLoadedCubit();

            cubit.applyInterestedSubjects([Subject.geografia]);

            expect(
              cubit.state,
              ProfileState(
                authUser: authUser,
                profile: profile.copyWith(
                  interestedSubjects: [Subject.geografia],
                ),
                loading: false,
              ),
            );
          },
        );
      },
    );

    group('updateProfile', () {
      test(
        'applies the change locally when the repository call succeeds',
        () async {
          final cubit = await buildLoadedCubit();
          when(
            () => repository.updateProfile(
              name: any(named: 'name'),
              username: any(named: 'username'),
              goal: any(named: 'goal'),
              examYear: any(named: 'examYear'),
              interestedSubjects: any(named: 'interestedSubjects'),
            ),
          ).thenAnswer((_) async => const Success(null));

          await cubit.updateProfile(name: 'Novo Nome');

          expect(
            cubit.state,
            ProfileState(
              authUser: authUser,
              profile: profile.copyWith(name: 'Novo Nome'),
              loading: false,
            ),
          );
        },
      );

      test('leaves state unchanged when the repository call fails', () async {
        final cubit = await buildLoadedCubit();
        when(
          () => repository.updateProfile(
            name: any(named: 'name'),
            username: any(named: 'username'),
            goal: any(named: 'goal'),
            examYear: any(named: 'examYear'),
            interestedSubjects: any(named: 'interestedSubjects'),
          ),
        ).thenAnswer((_) async => Error(ServerFailure('boom')));
        final before = cubit.state;

        await cubit.updateProfile(name: 'Novo Nome');

        expect(cubit.state, before);
      });

      test('returns the $Result from the repository call', () async {
        final cubit = await buildLoadedCubit();
        when(
          () => repository.updateProfile(
            name: any(named: 'name'),
            username: any(named: 'username'),
            goal: any(named: 'goal'),
            examYear: any(named: 'examYear'),
            interestedSubjects: any(named: 'interestedSubjects'),
          ),
        ).thenAnswer((_) async => const Success(null));

        final result = await cubit.updateProfile(name: 'Novo Nome');

        expect(result, isA<Success<void>>());
      });
    });
  });
}
