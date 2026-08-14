import 'package:equatable/equatable.dart';
import 'package:aura/features/profile/domain/entities/goal.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

class OnboardingState extends Equatable {
  const OnboardingState({
    this.step = 0,
    this.goal,
    this.examYear,
    this.selectedSubjects = const {},
    this.saving = false,
  });

  final int step;
  final Goal? goal;
  final String? examYear;
  final Set<Subject> selectedSubjects;
  final bool saving;

  OnboardingState copyWith({
    int? step,
    Goal? goal,
    String? examYear,
    Set<Subject>? selectedSubjects,
    bool? saving,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      goal: goal ?? this.goal,
      examYear: examYear ?? this.examYear,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
      saving: saving ?? this.saving,
    );
  }

  @override
  List<Object?> get props => [step, goal, examYear, selectedSubjects, saving];
}
