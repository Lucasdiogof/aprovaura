import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_score.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_runner_state.dart';

sealed class MockExamFinishResult {
  const MockExamFinishResult();
}

class MockExamFinished extends MockExamFinishResult {
  const MockExamFinished(this.score);

  final MockExamScore score;
}

class MockExamFinishFailed extends MockExamFinishResult {
  const MockExamFinishFailed(this.failure);

  final MockExamFailure failure;
}

/// Already finishing (a second tap) -- the first call's result is what
/// counts, so the caller should do nothing.
class MockExamFinishIgnored extends MockExamFinishResult {
  const MockExamFinishIgnored();
}

/// Runs an exam-mode session. Deliberately NOT MultipleChoiceCubit: that
/// engine grades on tap (correctIndex, explanation, green/red, XP per
/// deck), and bolting an exam mode onto it would leave all of that one
/// flag away from leaking. Here nothing is graded -- there is no correct
/// answer on the client at all -- and the visual pieces (QuizAnswerOption,
/// QuizProgress) are shared instead.
///
/// Every server write (answers and "which question am I on") goes through
/// one serial queue, so they reach the server in the order they happened:
/// tapping B then C on the same question can never end with B saved.
class MockExamRunnerCubit extends Cubit<MockExamRunnerState> {
  MockExamRunnerCubit(this._repository, {required this.mockExamId})
    : super(const MockExamRunnerState()) {
    load();
  }

  final MockExamRepository _repository;
  final String mockExamId;

  /// Last value the server acknowledged per position -- what the screen
  /// falls back to if a newer tap fails to save.
  final Map<int, int> _confirmed = {};
  Future<void> _queue = Future.value();

  Future<void> load() async {
    emit(state.copyWith(status: MockExamRunnerStatus.loading));
    final (activeResult, itemsResult) = await (
      _repository.getActiveMockExam(),
      _repository.getItems(mockExamId),
    ).wait;
    if (isClosed) return;

    final active = switch (activeResult) {
      Success(:final data) => data,
      Error() => null,
    };
    if (activeResult is Success && active?.id != mockExamId) {
      emit(state.copyWith(status: MockExamRunnerStatus.notInProgress));
      return;
    }
    switch (itemsResult) {
      case Error():
        emit(state.copyWith(status: MockExamRunnerStatus.loadError));
        return;
      case Success(:final data) when data.isEmpty:
        emit(state.copyWith(status: MockExamRunnerStatus.notInProgress));
        return;
      case Success(:final data):
        _confirmed
          ..clear()
          ..addAll({
            for (final item in data)
              if (item.selectedIndex != null)
                item.position: item.selectedIndex!,
          });
        // Resume exactly where the user was looking; if that's unknown (or
        // that question no longer exists), the first blank one; else the
        // first question.
        var index = data.indexWhere(
          (item) => item.position == active?.currentItemPosition,
        );
        if (index < 0) {
          index = data.indexWhere((item) => item.selectedIndex == null);
        }
        emit(
          state.copyWith(
            status: MockExamRunnerStatus.ready,
            items: data,
            currentIndex: index < 0 ? 0 : index,
            answers: Map.of(_confirmed),
            hasSaveError: false,
          ),
        );
    }
  }

  /// Picks (or changes) the answer to the current question. Shown at once,
  /// saved in order; tapping the option already chosen does nothing.
  void select(int optionIndex) {
    if (state.status != MockExamRunnerStatus.ready || state.isBusy) return;
    final position = state.currentItem.position;
    if (state.answers[position] == optionIndex) return;
    emit(
      state.copyWith(
        answers: {...state.answers, position: optionIndex},
        hasSaveError: false,
      ),
    );
    _enqueue(() => _saveAnswer(position, optionIndex));
  }

  Future<void> _saveAnswer(int position, int optionIndex) async {
    final result = await _repository.answerItem(
      mockExamId,
      position: position,
      selectedIndex: optionIndex,
    );
    switch (result) {
      case Success():
        _confirmed[position] = optionIndex;
      case Error():
        if (isClosed) return;
        // Only roll back if nothing newer was chosen meanwhile -- a later
        // tap is already queued behind this one and will be saved on its
        // own.
        if (state.answers[position] != optionIndex) return;
        final answers = {...state.answers};
        final confirmed = _confirmed[position];
        if (confirmed == null) {
          answers.remove(position);
        } else {
          answers[position] = confirmed;
        }
        emit(state.copyWith(answers: answers, hasSaveError: true));
    }
  }

  void next() => goTo(state.currentIndex + 1);

  void previous() => goTo(state.currentIndex - 1);

  /// Moves to [index] and remembers it on the server (best effort: a failed
  /// position write only means resuming lands on the first blank question
  /// instead). Blank questions can be skipped freely.
  void goTo(int index) {
    if (state.status != MockExamRunnerStatus.ready || state.isBusy) return;
    if (index < 0 || index >= state.totalCount) return;
    if (index == state.currentIndex) return;
    emit(state.copyWith(currentIndex: index));
    final position = state.items[index].position;
    _enqueue(() => _repository.setCurrentPosition(mockExamId, position));
  }

  void dismissSaveError() {
    if (state.hasSaveError) emit(state.copyWith(hasSaveError: false));
  }

  void _enqueue(Future<Object?> Function() write) {
    emit(state.copyWith(pendingSaves: state.pendingSaves + 1));
    _queue = _queue.then((_) async {
      try {
        await write();
      } catch (_) {
        // Repositories return Result instead of throwing; this only keeps
        // one unexpected throw from breaking every write queued after it.
      } finally {
        if (!isClosed) {
          emit(state.copyWith(pendingSaves: state.pendingSaves - 1));
        }
      }
    });
  }

  /// Waits for every queued write to reach the server.
  Future<void> flush() => _queue;

  /// Hands the exam in. Waits for every pending answer first (so the
  /// server grades what is on screen), refuses a second concurrent call,
  /// and leaves the retry safe: finish_mock_exam() on an already-finished
  /// exam just returns the same grade, with no second XP/progress.
  Future<MockExamFinishResult> finish() async {
    if (state.status != MockExamRunnerStatus.ready || state.isBusy) {
      return const MockExamFinishIgnored();
    }
    emit(state.copyWith(isFinishing: true));
    await flush();
    if (isClosed) return const MockExamFinishIgnored();

    final result = await _repository.finishMockExam(mockExamId);
    if (isClosed) return const MockExamFinishIgnored();
    switch (result) {
      case Success(:final data):
        // Stays "finishing" on purpose: the page navigates away now, and no
        // tap in between may reach an exam that is already graded.
        return MockExamFinished(data);
      case Error(:final failure):
        final mockFailure = failure is MockExamFailure
            ? failure
            : MockExamFailure(MockExamFailureKind.unexpected);
        emit(
          state.copyWith(
            isFinishing: false,
            status: mockFailure.kind == MockExamFailureKind.notInProgress
                ? MockExamRunnerStatus.notInProgress
                : null,
          ),
        );
        return MockExamFinishFailed(mockFailure);
    }
  }

  /// Discards the exam (explicit, confirmed action only). Returns null on
  /// success. Nothing is graded, no progress, no errors, no XP.
  Future<MockExamFailure?> abandon() async {
    if (state.isBusy) return null;
    emit(state.copyWith(isAbandoning: true));
    final result = await _repository.abandonMockExam(mockExamId);
    if (isClosed) return null;
    switch (result) {
      case Success():
        return null;
      case Error(:final failure):
        final mockFailure = failure is MockExamFailure
            ? failure
            : MockExamFailure(MockExamFailureKind.unexpected);
        emit(state.copyWith(isAbandoning: false));
        return mockFailure;
    }
  }
}
