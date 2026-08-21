import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/profile/presentation/cubit/account_form_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/account_form_state.dart';

void main() {
  group(AccountFormCubit, () {
    test('starts with the default $AccountFormState', () {
      expect(AccountFormCubit().state, const AccountFormState());
    });

    blocTest<AccountFormCubit, AccountFormState>(
      'notifyFieldChanged increments revision',
      build: AccountFormCubit.new,
      act: (cubit) => cubit.notifyFieldChanged(),
      expect: () => [const AccountFormState(revision: 1)],
    );

    blocTest<AccountFormCubit, AccountFormState>(
      'setSaving updates saving without touching revision',
      build: AccountFormCubit.new,
      act: (cubit) {
        cubit.notifyFieldChanged();
        cubit.setSaving(true);
      },
      expect: () => [
        const AccountFormState(revision: 1),
        const AccountFormState(revision: 1, saving: true),
      ],
    );
  });
}
