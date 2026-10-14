import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/password_reset_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group(PasswordResetCubit, () {
    late AuthRepository repository;

    const email = 'dash@example.com';

    setUp(() {
      repository = _MockAuthRepository();
    });

    void stubSend(Result<void> result) {
      when(
        () => repository.sendPasswordReset(email: any(named: 'email')),
      ).thenAnswer((_) async => result);
    }

    test('starts in $PasswordResetIdle', () {
      expect(PasswordResetCubit(repository).state, const PasswordResetIdle());
    });

    group('send', () {
      blocTest<PasswordResetCubit, PasswordResetState>(
        'emits [$PasswordResetSending, $PasswordResetSent] when the email '
        'goes out',
        build: () {
          stubSend(const Success(null));
          return PasswordResetCubit(repository);
        },
        act: (cubit) => cubit.send(email),
        expect: () => [
          const PasswordResetSending(),
          const PasswordResetSent(email),
        ],
      );

      blocTest<PasswordResetCubit, PasswordResetState>(
        'goes back to $PasswordResetIdle carrying the failure message',
        build: () {
          stubSend(Error(AuthFailure('Rate limit reached')));
          return PasswordResetCubit(repository);
        },
        act: (cubit) => cubit.send(email),
        expect: () => [
          const PasswordResetSending(),
          const PasswordResetIdle(errorMessage: 'Rate limit reached'),
        ],
      );

      blocTest<PasswordResetCubit, PasswordResetState>(
        'ignores a second send while one is in flight',
        build: () {
          stubSend(const Success(null));
          return PasswordResetCubit(repository);
        },
        act: (cubit) {
          cubit.send(email);
          return cubit.send(email);
        },
        verify: (_) {
          verify(() => repository.sendPasswordReset(email: email)).called(1);
        },
      );
    });

    group('resend', () {
      blocTest<PasswordResetCubit, PasswordResetState>(
        'stays on the code step while resending',
        build: () {
          stubSend(const Success(null));
          return PasswordResetCubit(repository);
        },
        seed: () => const PasswordResetSent(email, cooldown: 0),
        act: (cubit) => cubit.resend(),
        expect: () => [
          const PasswordResetSent(
            email,
            resend: ResendStatus.sending,
            cooldown: 0,
          ),
          const PasswordResetSent(email, resend: ResendStatus.sent),
        ],
      );

      blocTest<PasswordResetCubit, PasswordResetState>(
        'reports a failed resend without losing the address',
        build: () {
          stubSend(Error(ServerFailure()));
          return PasswordResetCubit(repository);
        },
        seed: () => const PasswordResetSent(email, cooldown: 0),
        act: (cubit) => cubit.resend(),
        expect: () => [
          const PasswordResetSent(
            email,
            resend: ResendStatus.sending,
            cooldown: 0,
          ),
          const PasswordResetSent(
            email,
            resend: ResendStatus.failed,
            cooldown: 0,
          ),
        ],
      );

      blocTest<PasswordResetCubit, PasswordResetState>(
        'does nothing before an email has been sent',
        build: () {
          stubSend(const Success(null));
          return PasswordResetCubit(repository);
        },
        act: (cubit) => cubit.resend(),
        expect: () => <PasswordResetState>[],
        verify: (_) {
          verifyNever(
            () => repository.sendPasswordReset(email: any(named: 'email')),
          );
        },
      );
    });

    group('resend cooldown', () {
      blocTest<PasswordResetCubit, PasswordResetState>(
        'refuses to resend while the wait is running',
        build: () {
          stubSend(const Success(null));
          return PasswordResetCubit(repository);
        },
        seed: () => const PasswordResetSent(email),
        act: (cubit) => cubit.resend(),
        expect: () => <PasswordResetState>[],
      );

      test('counts down once a second after the code is sent', () async {
        stubSend(const Success(null));
        final cubit = PasswordResetCubit(repository);
        await cubit.send(email);
        await Future<void>.delayed(const Duration(milliseconds: 1100));
        expect((cubit.state as PasswordResetSent).cooldown, lessThan(60));
        await cubit.close();
      });
    });

    group('verifyCode', () {
      void stubVerify(Result<void> result) {
        when(
          () => repository.verifyRecoveryCode(
            email: any(named: 'email'),
            code: any(named: 'code'),
          ),
        ).thenAnswer((_) async => result);
      }

      blocTest<PasswordResetCubit, PasswordResetState>(
        'moves to the new-password step when the code is accepted',
        build: () {
          stubVerify(const Success(null));
          when(() => repository.signOut()).thenAnswer((_) async {});
          return PasswordResetCubit(repository);
        },
        seed: () => const PasswordResetSent(email),
        act: (cubit) => cubit.verifyCode('123456'),
        expect: () => [
          const PasswordResetSent(email, isVerifying: true),
          const PasswordResetVerified(),
        ],
        verify: (_) {
          verify(
            () => repository.verifyRecoveryCode(email: email, code: '123456'),
          ).called(1);
        },
      );

      blocTest<PasswordResetCubit, PasswordResetState>(
        'stays on the code step with the message when the code is wrong',
        build: () {
          stubVerify(Error(AuthFailure('Código incorreto')));
          return PasswordResetCubit(repository);
        },
        seed: () => const PasswordResetSent(email),
        act: (cubit) => cubit.verifyCode('000000'),
        expect: () => [
          const PasswordResetSent(email, isVerifying: true),
          const PasswordResetSent(email, errorMessage: 'Código incorreto'),
        ],
      );
    });

    group('savePassword', () {
      blocTest<PasswordResetCubit, PasswordResetState>(
        'changes the password, closes the temporary session and finishes',
        build: () {
          when(
            () => repository.updatePassword(
              newPassword: any(named: 'newPassword'),
            ),
          ).thenAnswer((_) async => const Success(null));
          when(() => repository.signOut()).thenAnswer((_) async {});
          return PasswordResetCubit(repository);
        },
        seed: () => const PasswordResetVerified(),
        act: (cubit) => cubit.savePassword('nova-senha'),
        expect: () => [
          const PasswordResetVerified(isSaving: true),
          const PasswordResetDone(),
        ],
        verify: (_) {
          verify(() => repository.signOut()).called(1);
        },
      );

      blocTest<PasswordResetCubit, PasswordResetState>(
        'keeps the step and shows the failure when the update is refused',
        build: () {
          when(
            () => repository.updatePassword(
              newPassword: any(named: 'newPassword'),
            ),
          ).thenAnswer((_) async => Error(AuthFailure('Igual à atual')));
          when(() => repository.signOut()).thenAnswer((_) async {});
          return PasswordResetCubit(repository);
        },
        seed: () => const PasswordResetVerified(),
        act: (cubit) => cubit.savePassword('x'),
        expect: () => [
          const PasswordResetVerified(isSaving: true),
          const PasswordResetVerified(errorMessage: 'Igual à atual'),
        ],
      );

      test('abandoning the step signs the temporary session out', () async {
        when(() => repository.signOut()).thenAnswer((_) async {});
        final cubit = PasswordResetCubit(repository)
          ..emit(const PasswordResetVerified());
        await cubit.close();
        verify(() => repository.signOut()).called(1);
      });
    });
  });
}
