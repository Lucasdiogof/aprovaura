import 'package:equatable/equatable.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_availability.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_difficulty.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_subject_config.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_quantity.dart';

enum MockExamSetupStatus { loading, loadError, ready }

class MockExamSetupState extends Equatable {
  const MockExamSetupState({
    this.status = MockExamSetupStatus.loading,
    this.availability = const MockExamAvailability.empty(),
    this.subjects = const [],
    this.selections = const {},
    this.isSubmitting = false,
  });

  final MockExamSetupStatus status;
  final MockExamAvailability availability;

  /// Subjects offered on screen, in the app's usual subject order.
  final List<String> subjects;

  /// Only the selected subjects. Deselecting removes the entry entirely, so
  /// a hidden count can never linger and inflate the total.
  final Map<String, MockExamSubjectConfig> selections;
  final bool isSubmitting;

  bool isSelected(String subject) => selections.containsKey(subject);

  int available(String subject, MockExamDifficulty difficulty) =>
      availability.countFor(subject, difficulty);

  int get totalQuestions =>
      selections.values.fold(0, (sum, entry) => sum + entry.questionCount);

  int get selectedSubjectCount => selections.length;

  bool get isAtGlobalLimit =>
      totalQuestions >= MockExamQuantity.maxTotalQuestions;

  /// Questions picked in every subject except [subject] -- what the
  /// 180 cap leaves room for in this one.
  int otherSubjectsTotal(String subject) =>
      totalQuestions - (selections[subject]?.questionCount ?? 0);

  /// First count a subject gets when selected with [difficulty], or 0 when
  /// nothing fits (no questions at that level, or the exam is already at
  /// 180 without it).
  int initialCount(String subject, MockExamDifficulty difficulty) =>
      MockExamQuantity.increase(
        current: 0,
        available: available(subject, difficulty),
        otherSubjectsTotal: otherSubjectsTotal(subject),
      );

  bool canSelect(String subject) =>
      isSelected(subject) ||
      initialCount(subject, MockExamDifficulty.misto) > 0;

  bool canIncrease(String subject) {
    final entry = selections[subject];
    if (entry == null) return false;
    return MockExamQuantity.increase(
          current: entry.questionCount,
          available: available(subject, entry.difficulty),
          otherSubjectsTotal: otherSubjectsTotal(subject),
        ) >
        entry.questionCount;
  }

  /// "-" stops at the smallest valid count; removing the subject is what
  /// the checkbox is for.
  bool canDecrease(String subject) {
    final entry = selections[subject];
    if (entry == null) return false;
    return MockExamQuantity.decrease(entry.questionCount) > 0;
  }

  bool get canStart =>
      status == MockExamSetupStatus.ready &&
      !isSubmitting &&
      selections.isNotEmpty &&
      totalQuestions > 0 &&
      totalQuestions <= MockExamQuantity.maxTotalQuestions &&
      selections.values.every(
        (entry) =>
            entry.questionCount > 0 &&
            entry.questionCount <= available(entry.subject, entry.difficulty),
      );

  /// Selected subjects in on-screen order -- what gets sent and summarized.
  List<MockExamSubjectConfig> get orderedSelections => [
    for (final subject in subjects) ?selections[subject],
  ];

  MockExamSetupState copyWith({
    MockExamSetupStatus? status,
    MockExamAvailability? availability,
    List<String>? subjects,
    Map<String, MockExamSubjectConfig>? selections,
    bool? isSubmitting,
  }) => MockExamSetupState(
    status: status ?? this.status,
    availability: availability ?? this.availability,
    subjects: subjects ?? this.subjects,
    selections: selections ?? this.selections,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );

  @override
  List<Object?> get props => [
    status,
    availability,
    subjects,
    selections,
    isSubmitting,
  ];
}
