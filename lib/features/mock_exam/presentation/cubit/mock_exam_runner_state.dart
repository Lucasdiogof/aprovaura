import 'package:equatable/equatable.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_item.dart';

enum MockExamRunnerStatus {
  loading,
  loadError,
  ready,

  /// Handed in somewhere else (another device, an old screen): nothing left
  /// to answer, the result is what's next.
  finishedElsewhere,

  /// Discarded somewhere else: nothing left to answer or grade.
  abandonedElsewhere,

  /// No such exam for this user (or it has no questions left at all).
  notFound,
}

class MockExamRunnerState extends Equatable {
  const MockExamRunnerState({
    this.status = MockExamRunnerStatus.loading,
    this.items = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.pendingSaves = 0,
    this.hasSaveError = false,
    this.hasRemovedQuestionNotice = false,
    this.isFinishing = false,
    this.isAbandoning = false,
  });

  final MockExamRunnerStatus status;

  /// In item_position order, exactly as the server froze them.
  final List<MockExamItem> items;
  final int currentIndex;

  /// item_position -> option index as shown. What the screen displays: it
  /// flips the moment an option is tapped, and is pulled back to the last
  /// server-confirmed value if saving that tap fails.
  final Map<int, int> answers;

  /// Writes still in flight (answers and position). Finishing waits for 0.
  final int pendingSaves;

  /// The last answer couldn't be saved and was rolled back on screen.
  final bool hasSaveError;

  /// A question was deleted from the bank mid-session and the exam was
  /// reloaded without it.
  final bool hasRemovedQuestionNotice;
  final bool isFinishing;
  final bool isAbandoning;

  bool get isBusy => isFinishing || isAbandoning;

  MockExamItem get currentItem => items[currentIndex];
  int? get currentAnswer => answers[currentItem.position];
  bool get isFirst => currentIndex == 0;
  bool get isLast => currentIndex == items.length - 1;
  int get totalCount => items.length;
  int get answeredCount =>
      items.where((item) => answers.containsKey(item.position)).length;
  int get unansweredCount => totalCount - answeredCount;
  bool get isSaving => pendingSaves > 0;

  /// Where "Voltar e revisar" jumps: the first blank question, if any.
  int? get firstUnansweredIndex {
    final index = items.indexWhere(
      (item) => !answers.containsKey(item.position),
    );
    return index < 0 ? null : index;
  }

  MockExamRunnerState copyWith({
    MockExamRunnerStatus? status,
    List<MockExamItem>? items,
    int? currentIndex,
    Map<int, int>? answers,
    int? pendingSaves,
    bool? hasSaveError,
    bool? hasRemovedQuestionNotice,
    bool? isFinishing,
    bool? isAbandoning,
  }) => MockExamRunnerState(
    status: status ?? this.status,
    items: items ?? this.items,
    currentIndex: currentIndex ?? this.currentIndex,
    answers: answers ?? this.answers,
    pendingSaves: pendingSaves ?? this.pendingSaves,
    hasSaveError: hasSaveError ?? this.hasSaveError,
    hasRemovedQuestionNotice:
        hasRemovedQuestionNotice ?? this.hasRemovedQuestionNotice,
    isFinishing: isFinishing ?? this.isFinishing,
    isAbandoning: isAbandoning ?? this.isAbandoning,
  );

  @override
  List<Object?> get props => [
    status,
    items,
    currentIndex,
    answers,
    pendingSaves,
    hasSaveError,
    hasRemovedQuestionNotice,
    isFinishing,
    isAbandoning,
  ];
}
