import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:aura/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:aura/features/profile/domain/entities/goal.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  group(OnboardingCubit, () {
    late ProfileRepository repository;

    setUp(() {
      repository = _MockProfileRepository();
      registerFallbackValue(Goal.enem);
      registerFallbackValue(<Subject>[]);
    });

    test('starts with the default $OnboardingState', () {
      expect(OnboardingCubit(repository).state, const OnboardingState());
    });

    blocTest<OnboardingCubit, OnboardingState>(
      'selectGoal sets the chosen $Goal',
      build: () => OnboardingCubit(repository),
      act: (cubit) => cubit.selectGoal(Goal.vestibular),
      expect: () => [const OnboardingState(goal: Goal.vestibular)],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'selectExamYear sets the exam year',
      build: () => OnboardingCubit(repository),
      act: (cubit) => cubit.selectExamYear('2026'),
      expect: () => [const OnboardingState(examYear: '2026')],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'toggleSubject adds a subject that is not yet selected',
      build: () => OnboardingCubit(repository),
      act: (cubit) => cubit.toggleSubject(Subject.geografia),
      expect: () => [
        const OnboardingState(selectedSubjects: {Subject.geografia}),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'toggleSubject removes a subject that is already selected',
      build: () => OnboardingCubit(repository),
      act: (cubit) {
        cubit.toggleSubject(Subject.geografia);
        cubit.toggleSubject(Subject.geografia);
      },
      expect: () => [
        const OnboardingState(selectedSubjects: {Subject.geografia}),
        const OnboardingState(),
      ],
    );

    group('next', () {
      blocTest<OnboardingCubit, OnboardingState>(
        'advances one step at a time by default',
        build: () => OnboardingCubit(repository),
        act: (cubit) => cubit.next(),
        expect: () => [const OnboardingState(step: 1)],
      );

      blocTest<OnboardingCubit, OnboardingState>(
        'skips the exam-year step (1) when the goal is contaPropria',
        build: () => OnboardingCubit(repository),
        act: (cubit) {
          cubit.selectGoal(Goal.contaPropria);
          cubit.next();
        },
        skip: 1,
        expect: () => [const OnboardingState(goal: Goal.contaPropria, step: 2)],
      );

      blocTest<OnboardingCubit, OnboardingState>(
        'does not skip the exam-year step for a goal that needs it',
        build: () => OnboardingCubit(repository),
        act: (cubit) {
          cubit.selectGoal(Goal.enem);
          cubit.next();
        },
        skip: 1,
        expect: () => [const OnboardingState(goal: Goal.enem, step: 1)],
      );
    });

    group('back', () {
      blocTest<OnboardingCubit, OnboardingState>(
        'goes back one step at a time by default',
        build: () => OnboardingCubit(repository),
        act: (cubit) {
          cubit.next();
          cubit.next();
          cubit.back();
        },
        skip: 2,
        expect: () => [const OnboardingState(step: 1)],
      );

      blocTest<OnboardingCubit, OnboardingState>(
        'skips the exam-year step (1) when going back with contaPropria',
        build: () => OnboardingCubit(repository),
        act: (cubit) {
          cubit.selectGoal(Goal.contaPropria);
          cubit.next();
          cubit.back();
        },
        skip: 2,
        expect: () => [const OnboardingState(goal: Goal.contaPropria)],
      );
    });

    group('submit', () {
      blocTest<OnboardingCubit, OnboardingState>(
        'sets saving true then false, and returns $Success on success',
        build: () {
          when(
            () => repository.updateProfile(
              goal: any(named: 'goal'),
              examYear: any(named: 'examYear'),
              interestedSubjects: any(named: 'interestedSubjects'),
            ),
          ).thenAnswer((_) async => const Success(null));
          return OnboardingCubit(repository);
        },
        act: (cubit) => cubit.submit(),
        expect: () => [
          const OnboardingState(saving: true),
          const OnboardingState(),
        ],
      );

      blocTest<OnboardingCubit, OnboardingState>(
        'sets saving true then false, and returns $Error on failure',
        build: () {
          when(
            () => repository.updateProfile(
              goal: any(named: 'goal'),
              examYear: any(named: 'examYear'),
              interestedSubjects: any(named: 'interestedSubjects'),
            ),
          ).thenAnswer((_) async => Error(ServerFailure('boom')));
          return OnboardingCubit(repository);
        },
        act: (cubit) => cubit.submit(),
        expect: () => [
          const OnboardingState(saving: true),
          const OnboardingState(),
        ],
      );

      test('returns the $Result from the repository call', () async {
        when(
          () => repository.updateProfile(
            goal: any(named: 'goal'),
            examYear: any(named: 'examYear'),
            interestedSubjects: any(named: 'interestedSubjects'),
          ),
        ).thenAnswer((_) async => Error(ServerFailure('boom')));
        final cubit = OnboardingCubit(repository);

        final result = await cubit.submit();

        expect(result, isA<Error<void>>());
      });
    });
  });
}
