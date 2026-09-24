import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/essay_failure.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/cubit/essay_submission_state.dart';

/// Opens one attempt and, while the server still owes an answer, keeps
/// asking for it.
///
/// The server is the only place the marking lives: closing the app or
/// swapping devices loses nothing, because reopening this screen just
/// reads the status again. Nothing is kept locally.
///
/// Polling is bounded on purpose. It stops the moment the attempt reaches
/// a final state, when the screen closes, and after [maxPolls] tries --
/// a marking that slow is better checked later than watched forever.
class EssaySubmissionCubit extends Cubit<EssaySubmissionState> {
  EssaySubmissionCubit(
    this._repository,
    this.submissionId, {
    this.pollInterval = const Duration(seconds: 3),
    this.maxPolls = 40,
  }) : super(const EssaySubmissionLoading()) {
    load();
  }

  final EssayRepository _repository;
  final String submissionId;
  final Duration pollInterval;

  /// 40 × 3s ≈ two minutes of watching before it suggests coming back.
  final int maxPolls;

  Timer? _timer;
  int _polls = 0;

  /// Guards the request: a rebuild must never fire a second marking.
  bool _requesting = false;
  bool _requestedOnce = false;

  /// Survives the polls. Without it, the next read would emit a fresh
  /// state and quietly wipe the reason the marking did not happen.
  EssayEvaluationFailure? _failure;

  Future<void> load() async {
    emit(const EssaySubmissionLoading());
    await _fetch(startIfWaiting: true);
  }

  Future<void> _fetch({bool startIfWaiting = false}) async {
    final result = await _repository.getSubmission(submissionId);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(
          EssaySubmissionLoaded(
            data,
            isRequesting: _requesting,
            failure: _failure,
          ),
        );
        // Submitted and nobody started marking it: this is the resume
        // path after the app was closed mid-flow. Asking again costs no
        // extra quota -- the day's charge is per submission.
        if (startIfWaiting &&
            !_requestedOnce &&
            data.status == EssaySubmissionStatus.submitted) {
          await requestEvaluation();
          return;
        }
        // Only watch while something is actually running. A refused
        // request (daily limit, provider down) leaves the attempt sitting
        // at 'submitted' with nothing to wait for.
        if (data.status == EssaySubmissionStatus.evaluating ||
            (data.status.isInProgress && _failure == null)) {
          _schedulePoll();
        } else {
          _stopPolling();
        }
      case Error():
        emit(const EssaySubmissionError());
    }
  }

  /// Asks the server to mark this attempt. Used right after sending, on
  /// reopening an attempt nobody picked up, and by the retry button.
  Future<void> requestEvaluation() async {
    if (_requesting) return;
    _requesting = true;
    _requestedOnce = true;
    _failure = null;
    final current = state;
    if (current is EssaySubmissionLoaded) {
      emit(current.copyWith(isRequesting: true, clearFailure: true));
    }

    final result = await _repository.requestEvaluation(submissionId);
    _requesting = false;
    if (isClosed) return;

    switch (result) {
      case Success():
        await _fetch();
      case Error(:final failure):
        // The attempt itself is fine -- only the marking did not happen.
        // The reason is kept so the person knows whether to try again now
        // or tomorrow.
        _failure = failure is EssayEvaluationFailureWrapper
            ? failure.kind
            : EssayEvaluationFailure.unexpected;
        await _fetch();
    }
  }

  void _schedulePoll() {
    _timer?.cancel();
    if (_polls >= maxPolls) return;
    _timer = Timer(pollInterval, () {
      _polls++;
      unawaited(_fetch());
    });
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  /// True once the cubit gave up watching: the marking may still finish on
  /// the server, so the screen says to come back rather than that it broke.
  bool get gaveUpWaiting => _polls >= maxPolls;

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
