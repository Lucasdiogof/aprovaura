import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/profile/presentation/cubit/interested_subjects_form_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/interested_subjects_form_state.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

void main() {
  group(InterestedSubjectsFormCubit, () {
    test('starts with the given initial selection', () {
      final cubit = InterestedSubjectsFormCubit({Subject.matematica});
      expect(
        cubit.state,
        const InterestedSubjectsFormState(selected: {Subject.matematica}),
      );
    });

    blocTest<InterestedSubjectsFormCubit, InterestedSubjectsFormState>(
      'toggle adds a subject that is not yet selected',
      build: () => InterestedSubjectsFormCubit(const {}),
      act: (cubit) => cubit.toggle(Subject.historia),
      expect: () => [
        const InterestedSubjectsFormState(selected: {Subject.historia}),
      ],
    );

    blocTest<InterestedSubjectsFormCubit, InterestedSubjectsFormState>(
      'toggle removes a subject that is already selected',
      build: () => InterestedSubjectsFormCubit({Subject.historia}),
      act: (cubit) => cubit.toggle(Subject.historia),
      expect: () => [const InterestedSubjectsFormState()],
    );

    blocTest<InterestedSubjectsFormCubit, InterestedSubjectsFormState>(
      'setSaving updates saving without touching the selection',
      build: () => InterestedSubjectsFormCubit({Subject.biologia}),
      act: (cubit) => cubit.setSaving(true),
      expect: () => [
        const InterestedSubjectsFormState(
          selected: {Subject.biologia},
          saving: true,
        ),
      ],
    );
  });
}
