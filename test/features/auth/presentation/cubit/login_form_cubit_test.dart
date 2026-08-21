import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/auth/presentation/cubit/login_form_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/login_form_state.dart';

void main() {
  group(LoginFormCubit, () {
    test('starts with the default $LoginFormState', () {
      expect(LoginFormCubit().state, const LoginFormState());
    });

    blocTest<LoginFormCubit, LoginFormState>(
      'toggleObscurePassword flips obscurePassword from true to false',
      build: LoginFormCubit.new,
      act: (cubit) => cubit.toggleObscurePassword(),
      expect: () => [const LoginFormState(obscurePassword: false)],
    );

    blocTest<LoginFormCubit, LoginFormState>(
      'toggleObscurePassword twice returns obscurePassword to true',
      build: LoginFormCubit.new,
      act: (cubit) {
        cubit.toggleObscurePassword();
        cubit.toggleObscurePassword();
      },
      expect: () => [
        const LoginFormState(obscurePassword: false),
        const LoginFormState(),
      ],
    );

    blocTest<LoginFormCubit, LoginFormState>(
      'markSubmitted sets submitted to true',
      build: LoginFormCubit.new,
      act: (cubit) => cubit.markSubmitted(),
      expect: () => [const LoginFormState(submitted: true)],
    );

    blocTest<LoginFormCubit, LoginFormState>(
      'notifyFieldChanged increments revision',
      build: LoginFormCubit.new,
      act: (cubit) {
        cubit.notifyFieldChanged();
        cubit.notifyFieldChanged();
      },
      expect: () => [
        const LoginFormState(revision: 1),
        const LoginFormState(revision: 2),
      ],
    );
  });
}
