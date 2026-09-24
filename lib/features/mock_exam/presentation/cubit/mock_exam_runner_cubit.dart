import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_item.dart';
import 'package:aura/features/mock_exam/domain/entities/mock_exam_session_info.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_failure.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/mock_exam/presentation/cubit/mock_exam_runner_state.dart';

sealed class MockExamFinishResult {
  const MockExamFinishResult();
}

/// Graded (now, or already -- e.g. handed in on another device): go to the
/// result, which loads everything by id.
class MockExamFinished extends MockExamFinishResult {
  const MockExamFinished();
}

class MockExamFinishFailed extends MockExamFinishResult {
  const MockExamFinishFailed(this.failure);

  final MockExamFailure failure;
}

/// Nothing for the caller to do: a second tap while already finishing, or
/// the exam turned out to be closed and the screen already says so.
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
/// The server is the source of truth: every open reads status, position,
/// order and answers fresh; every write (answers and "which question am I
/// on") goes through one serial queue so they land in the order they
/// happened; and any write the server refuses because the exam was closed
/// elsewhere, or because a question was deleted, switches the screen to
/// what the server says instead of retrying blindly.
class MockExamRunnerCubit extends Cubit<MockExamRunnerState> {
  MockExamRunnerCubit(this._repository, {required this.mockExamId})
    : super(const MockExamRunnerState()) {
    load();
  }

  final MockExamRepository _repository;
  final String mockExamId;

  /// Last value the server acknowledged per position.
  final Map<int, int> _confirmed = {};

  /// Latest value chosen per position whose write hasn't been acknowledged
  /// yet. Survives a reload, so a tap still in the queue is never hidden
  /// behind older server data.
  final Map<int, int> _pending = {};

  /// Per-position counter of taps, so a write knows whether it is still
  /// the latest choice for its question (value equality isn't enough:
  /// B -> C -> B has two different "B" writes).
  final Map<int, int> _tapSeq = {};
  Future<void> _queue = Future.value();

  bool get _isClosedElsewhere =>
      state.status == MockExamRunnerStatus.finishedElsewhere ||
      state.status == MockExamRunnerStatus.abandonedElsewhere ||
      state.status == MockExamRunnerStatus.notFound;

  /// Where to resume: the saved position if that question still exists; if
  /// it was deleted, the nearest question after it; with no usable saved
  /// position (or nothing after it), the first blank question; with
  /// everything answered, the last one (ready to hand in). Never an index
  /// outside [items].
  static int resumeIndex(List<MockExamItem> items, int? savedPosition) {
    if (savedPosition != null && savedPosition >= 1) {
      final exact = items.indexWhere((i) => i.position == savedPosition);
      if (exact >= 0) return exact;
      final after = items.indexWhere((i) => i.position > savedPosition);
      if (after >= 0) return after;
    }
    final blank = items.indexWhere((i) => i.selectedIndex == null);
    if (blank >= 0) return blank;
    return items.isEmpty ? 0 : items.length - 1;
  }

  /// Reads everything from the server. [silent] keeps the current screen
  /// up while reloading (used after a question disappeared mid-session).
  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: MockExamRunnerStatus.loading));
    final (sessionResult, itemsResult) = await (
      _repository.getSession(mockExamId),
      _repository.getItems(mockExamId),
    ).wait;
    if (isClosed) return;

    // Never open an exam whose status couldn't be confirmed: a finished
    // one would otherwise look answerable.
    final MockExamSessionInfo? session;
    switch (sessionResult) {
      case Error():
        emit(state.copyWith(status: MockExamRunnerStatus.loadError));
        return;
      case Success(:final data):
        session = data;
    }
    switch (session?.status) {
      case null:
        emit(state.copyWith(status: MockExamRunnerStatus.notFound));
        return;
      case MockExamStatus.finished:
        emit(state.copyWith(status: MockExamRunnerStatus.finishedElsewhere));
        return;
      case MockExamStatus.abandoned:
        emit(state.copyWith(status: MockExamRunnerStatus.abandonedElsewhere));
        return;
      case MockExamStatus.inProgress:
        break;
    }

    switch (itemsResult) {
      case Error():
        emit(state.copyWith(status: MockExamRunnerStatus.loadError));
      case Success(:final data) when data.isEmpty:
        emit(state.copyWith(status: MockExamRunnerStatus.notFound));
      case Success(:final data):
        final positions = {for (final item in data) item.position};
        _confirmed
          ..clear()
          ..addAll({
            for (final item in data)
              if (item.selectedIndex != null)
                item.position: item.selectedIndex!,
          });
        _pending.removeWhere((position, _) => !positions.contains(position));
        // A silent reload keeps the user near where they were; a fresh
        // open resumes from the server's saved position.
        final previous = silent && state.items.isNotEmpty
            ? state.currentItem.position
            : session!.currentItemPosition;
        emit(
          state.copyWith(
            status: MockExamRunnerStatus.ready,
            items: data,
            currentIndex: resumeIndex(data, previous),
            answers: {..._confirmed, ..._pending},
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
    _pending[position] = optionIndex;
    final seq = (_tapSeq[position] ?? 0) + 1;
    _tapSeq[position] = seq;
    emit(
      state.copyWith(
        answers: {...state.answers, position: optionIndex},
        hasSaveError: false,
      ),
    );
    _enqueue(() => _saveAnswer(position, optionIndex, seq));
  }

  Future<void> _saveAnswer(int position, int optionIndex, int seq) async {
    final result = await _repository.answerItem(
      mockExamId,
      position: position,
      selectedIndex: optionIndex,
    );
    final isLatest = _tapSeq[position] == seq;
    switch (result) {
      case Success():
        _confirmed[position] = optionIndex;
        if (isLatest) _pending.remove(position);
      case Error(:final failure):
        if (isLatest) _pending.remove(position);
        if (await _handleClosedOrChanged(failure)) return;
        if (isClosed || !isLatest) return;
        // Only roll back if nothing newer was chosen meanwhile -- a later
        // tap is already queued behind this one and will be saved on its
        // own. The screen never shows an answer the server doesn't have.
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

  /// Reacts to the server saying the exam or the question is gone. Returns
  /// true when it did (so the caller shouldn't treat it as a network blip).
  Future<bool> _handleClosedOrChanged(Failure failure) async {
    if (failure is! MockExamFailure || isClosed) return false;
    switch (failure.kind) {
      case MockExamFailureKind.notInProgress:
        var status = MockExamStatus.fromDb(failure.serverStatus);
        if (status == null) {
          final session = await _repository.getSession(mockExamId);
          if (isClosed) return true;
          status = switch (session) {
            Success(:final data) => data?.status,
            Error() => null,
          };
        }
        emit(
          state.copyWith(
            isFinishing: false,
            isAbandoning: false,
            status: switch (status) {
              MockExamStatus.finished => MockExamRunnerStatus.finishedElsewhere,
              MockExamStatus.abandoned =>
                MockExamRunnerStatus.abandonedElsewhere,
              _ => MockExamRunnerStatus.notFound,
            },
          ),
        );
        return true;
      case MockExamFailureKind.itemRemoved:
        await load(silent: true);
        if (!isClosed && state.status == MockExamRunnerStatus.ready) {
          emit(state.copyWith(hasRemovedQuestionNotice: true));
        }
        return true;
      default:
        return false;
    }
  }

  void next() => goTo(state.currentIndex + 1);

  void previous() => goTo(state.currentIndex - 1);

  /// Moves to [index] and remembers it on the server. A position write that
  /// fails for network reasons is dropped on purpose (resuming then lands
  /// on the nearest/first-blank question instead); one refused because the
  /// exam or question is gone is acted on like any other write.
  void goTo(int index) {
    if (state.status != MockExamRunnerStatus.ready || state.isBusy) return;
    if (index < 0 || index >= state.totalCount) return;
    if (index == state.currentIndex) return;
    emit(state.copyWith(currentIndex: index));
    final position = state.items[index].position;
    _enqueue(() async {
      final result = await _repository.setCurrentPosition(mockExamId, position);
      if (result case Error(:final failure)) {
        await _handleClosedOrChanged(failure);
      }
    });
  }

  void dismissSaveError() {
    if (state.hasSaveError) emit(state.copyWith(hasSaveError: false));
  }

  void dismissRemovedQuestionNotice() {
    if (state.hasRemovedQuestionNotice) {
      emit(state.copyWith(hasRemovedQuestionNotice: false));
    }
  }

  void _enqueue(Future<void> Function() write) {
    emit(state.copyWith(pendingSaves: state.pendingSaves + 1));
    _queue = _queue.then((_) async {
      try {
        // Once the server said the exam is closed, the rest of the queue
        // has nowhere to go.
        if (!_isClosedElsewhere) await write();
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

  /// Completes when every write queued so far has been answered by the
  /// server (successfully or not) -- a real wait on the real calls, not a
  /// timer. After it, [MockExamRunnerState.hasSaveError] tells whether the
  /// last answer made it.
  Future<void> flush() => _queue;

  /// Hands the exam in. Waits for every pending answer first (so the
  /// server grades what is on screen), refuses a second concurrent call,
  /// and stays safe to retry: finish_mock_exam() on an already-finished
  /// exam just returns the same grade, with no second XP/progress.
  Future<MockExamFinishResult> finish() async {
    if (state.status != MockExamRunnerStatus.ready || state.isBusy) {
      return const MockExamFinishIgnored();
    }
    emit(state.copyWith(isFinishing: true));
    await flush();
    if (isClosed) return const MockExamFinishIgnored();
    // A queued write may have found the exam closed meanwhile.
    if (state.status == MockExamRunnerStatus.finishedElsewhere) {
      return const MockExamFinished();
    }
    if (_isClosedElsewhere) return const MockExamFinishIgnored();

    final result = await _repository.finishMockExam(mockExamId);
    if (isClosed) return const MockExamFinishIgnored();
    switch (result) {
      case Success():
        // Stays "finishing" on purpose: the page navigates away now, and no
        // tap in between may reach an exam that is already graded.
        return const MockExamFinished();
      case Error(:final failure):
        if (await _handleClosedOrChanged(failure)) {
          return state.status == MockExamRunnerStatus.finishedElsewhere
              ? const MockExamFinished()
              : const MockExamFinishIgnored();
        }
        emit(state.copyWith(isFinishing: false));
        return MockExamFinishFailed(
          failure is MockExamFailure
              ? failure
              : MockExamFailure(MockExamFailureKind.unexpected),
        );
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
        if (await _handleClosedOrChanged(failure)) return null;
        emit(state.copyWith(isAbandoning: false));
        return failure is MockExamFailure
            ? failure
            : MockExamFailure(MockExamFailureKind.unexpected);
    }
  }
}
