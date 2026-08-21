import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/auth/presentation/cubit/register_form_cubit.dart';
import 'package:aura/features/auth/presentation/cubit/register_form_state.dart';

void main() {
  group(RegisterFormCubit, () {
    test('starts with the default $RegisterFormState', () {
      expect(RegisterFormCubit().state, const RegisterFormState());
    });

    blocTest<RegisterFormCubit, RegisterFormState>(
      'toggleObscurePassword flips obscurePassword only',
      build: RegisterFormCubit.new,
      act: (cubit) => cubit.toggleObscurePassword(),
      expect: () => [const RegisterFormState(obscurePassword: false)],
    );

    blocTest<RegisterFormCubit, RegisterFormState>(
      'toggleObscureConfirmPassword flips obscureConfirmPassword only',
      build: RegisterFormCubit.new,
      act: (cubit) => cubit.toggleObscureConfirmPassword(),
      expect: () => [const RegisterFormState(obscureConfirmPassword: false)],
    );

    blocTest<RegisterFormCubit, RegisterFormState>(
      'markSubmitted sets submitted to true',
      build: RegisterFormCubit.new,
      act: (cubit) => cubit.markSubmitted(),
      expect: () => [const RegisterFormState(submitted: true)],
    );

    blocTest<RegisterFormCubit, RegisterFormState>(
      'notifyFieldChanged increments revision',
      build: RegisterFormCubit.new,
      act: (cubit) => cubit.notifyFieldChanged(),
      expect: () => [const RegisterFormState(revision: 1)],
    );
  });
}
