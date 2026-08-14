import 'package:equatable/equatable.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

class InterestedSubjectsFormState extends Equatable {
  const InterestedSubjectsFormState({
    this.selected = const {},
    this.saving = false,
  });

  final Set<Subject> selected;
  final bool saving;

  InterestedSubjectsFormState copyWith({Set<Subject>? selected, bool? saving}) {
    return InterestedSubjectsFormState(
      selected: selected ?? this.selected,
      saving: saving ?? this.saving,
    );
  }

  @override
  List<Object?> get props => [selected, saving];
}
