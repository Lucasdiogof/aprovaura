import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

class InterestedSubjectsFormCubit extends Cubit<Set<Subject>> {
  InterestedSubjectsFormCubit(super.initial);

  void toggle(Subject subject) {
    final updated = Set<Subject>.from(state);
    if (!updated.remove(subject)) updated.add(subject);
    emit(updated);
  }
}
