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
        'stays on the confirmation step while resending',
        build: () {
          stubSend(const Success(null));
          return PasswordResetCubit(repository);
        },
        seed: () => const PasswordResetSent(email),
        act: (cubit) => cubit.resend(),
        expect: () => [
          const PasswordResetSent(email, resend: ResendStatus.sending),
          const PasswordResetSent(email, resend: ResendStatus.sent),
        ],
      );

      blocTest<PasswordResetCubit, PasswordResetState>(
        'reports a failed resend without losing the address',
        build: () {
          stubSend(Error(ServerFailure()));
          return PasswordResetCubit(repository);
        },
        seed: () => const PasswordResetSent(email),
        act: (cubit) => cubit.resend(),
        expect: () => [
          const PasswordResetSent(email, resend: ResendStatus.sending),
          const PasswordResetSent(email, resend: ResendStatus.failed),
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
  });
}
