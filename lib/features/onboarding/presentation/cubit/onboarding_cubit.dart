import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/onboarding/presentation/cubit/onboarding_state.dart';
import 'package:aura/features/profile/domain/entities/goal.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._repository) : super(const OnboardingState());

  final ProfileRepository _repository;

  static const _examYearStep = 1;

  bool get _skipsExamYear => state.goal == Goal.contaPropria;

  void selectGoal(Goal goal) => emit(state.copyWith(goal: goal));

  void selectExamYear(String year) => emit(state.copyWith(examYear: year));

  void toggleSubject(Subject subject) {
    final updated = Set<Subject>.from(state.selectedSubjects);
    if (!updated.remove(subject)) updated.add(subject);
    emit(state.copyWith(selectedSubjects: updated));
  }

  void next() {
    var nextStep = state.step + 1;
    if (nextStep == _examYearStep && _skipsExamYear) nextStep++;
    emit(state.copyWith(step: nextStep));
  }

  void back() {
    var previousStep = state.step - 1;
    if (previousStep == _examYearStep && _skipsExamYear) previousStep--;
    emit(state.copyWith(step: previousStep));
  }

  Future<Result<void>> submit() async {
    emit(state.copyWith(saving: true));
    final result = await _repository.updateProfile(
      goal: state.goal,
      examYear: state.examYear,
      interestedSubjects: state.selectedSubjects.toList(),
    );
    emit(state.copyWith(saving: false));
    return result;
  }
}
