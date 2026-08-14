import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/features/profile/presentation/cubit/interested_subjects_form_state.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

class InterestedSubjectsFormCubit extends Cubit<InterestedSubjectsFormState> {
  InterestedSubjectsFormCubit(Set<Subject> initial)
    : super(InterestedSubjectsFormState(selected: initial));

  void toggle(Subject subject) {
    final updated = Set<Subject>.from(state.selected);
    if (!updated.remove(subject)) updated.add(subject);
    emit(state.copyWith(selected: updated));
  }

  void setSaving(bool saving) => emit(state.copyWith(saving: saving));
}
