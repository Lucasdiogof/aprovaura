import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/auth_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group(AuthCubit, () {
    late AuthRepository repository;

    const user = AppUser(id: 'u1', email: 'dash@example.com');

    setUp(() {
      repository = _MockAuthRepository();
    });

    test('starts in $AuthInitial', () {
      expect(AuthCubit(repository).state, const AuthInitial());
    });

    group('signIn', () {
      blocTest<AuthCubit, AuthState>(
        'emits [$AuthLoading, $AuthSuccess] when sign in succeeds',
        build: () {
          when(
            () => repository.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => const Success(user));
          return AuthCubit(repository);
        },
        act: (cubit) =>
            cubit.signIn(email: 'dash@example.com', password: '123456'),
        expect: () => [const AuthLoading(), const AuthSuccess(user)],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [$AuthLoading, $AuthError] with isInvalidCredentials true '
        'when the repository reports invalid credentials',
        build: () {
          when(
            () => repository.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer(
            (_) async => Error(AuthFailure('Invalid credentials', true)),
          );
          return AuthCubit(repository);
        },
        act: (cubit) =>
            cubit.signIn(email: 'dash@example.com', password: 'wrong'),
        expect: () => [
          const AuthLoading(),
          const AuthError('Invalid credentials', isInvalidCredentials: true),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [$AuthLoading, $AuthError] with isInvalidCredentials false '
        'for a non-auth failure',
        build: () {
          when(
            () => repository.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => Error(ServerFailure('Network down')));
          return AuthCubit(repository);
        },
        act: (cubit) =>
            cubit.signIn(email: 'dash@example.com', password: '123456'),
        expect: () => [const AuthLoading(), const AuthError('Network down')],
      );

      blocTest<AuthCubit, AuthState>(
        'calls repository.signIn with the given email and password',
        build: () {
          when(
            () => repository.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => const Success(user));
          return AuthCubit(repository);
        },
        act: (cubit) =>
            cubit.signIn(email: 'dash@example.com', password: '123456'),
        verify: (_) {
          verify(
            () => repository.signIn(
              email: 'dash@example.com',
              password: '123456',
            ),
          ).called(1);
        },
      );
    });

    group('signUp', () {
      blocTest<AuthCubit, AuthState>(
        'emits [$AuthLoading, $AuthSuccess] when sign up succeeds',
        build: () {
          when(
            () => repository.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => const Success(user));
          return AuthCubit(repository);
        },
        act: (cubit) =>
            cubit.signUp(email: 'dash@example.com', password: '123456'),
        expect: () => [const AuthLoading(), const AuthSuccess(user)],
      );

      blocTest<AuthCubit, AuthState>(
        'emits [$AuthLoading, $AuthError] without invalid-credentials '
        'flagging when sign up fails',
        build: () {
          when(
            () => repository.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenAnswer((_) async => Error(ServerFailure('Email taken')));
          return AuthCubit(repository);
        },
        act: (cubit) =>
            cubit.signUp(email: 'dash@example.com', password: '123456'),
        expect: () => [const AuthLoading(), const AuthError('Email taken')],
      );
    });

    group('signOut', () {
      test('calls repository.signOut', () async {
        when(() => repository.signOut()).thenAnswer((_) async {});
        final cubit = AuthCubit(repository);

        await cubit.signOut();

        verify(() => repository.signOut()).called(1);
      });
    });

    group('deleteAccount', () {
      test('delegates to repository.deleteAccount without touching '
          'AuthState', () async {
        when(
          () => repository.deleteAccount(),
        ).thenAnswer((_) async => const Success(null));
        final cubit = AuthCubit(repository);

        final result = await cubit.deleteAccount();

        expect(result, isA<Success<void>>());
        verify(() => repository.deleteAccount()).called(1);
        expect(cubit.state, const AuthInitial());
      });

      test('returns the repository failure as-is on error', () async {
        when(
          () => repository.deleteAccount(),
        ).thenAnswer((_) async => Error(ServerFailure('boom')));
        final cubit = AuthCubit(repository);

        final result = await cubit.deleteAccount();

        expect(result, isA<Error<void>>());
        expect((result as Error<void>).failure.message, 'boom');
        expect(cubit.state, const AuthInitial());
      });
    });
  });
}
