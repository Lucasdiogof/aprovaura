import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/utils/id_generator.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/essay_failure.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/essay/presentation/cubit/essay_editor_state.dart';

/// Persistence for the editor: loads the draft, autosaves it, saves on
/// demand, and deletes it.
///
/// The text itself is NOT held here -- it lives in the page's
/// TextEditingController, and reaches this cubit through [textChanged].
/// Keeping it out of the state is what stops every keystroke from
/// rebuilding the field (and stealing the cursor).
///
/// ORDERING GUARANTEE. Saves are serial and always carry the newest text:
/// [_inFlight] means "a request is running", so a change arriving mid-flight
/// only updates [_pendingBody] and the save is re-fired when the current one
/// returns. Two saves can never overlap, so an older body can never land
/// after a newer one -- the A → AB → ABC case ends with ABC on the server
/// whatever order the network would have delivered.
///
/// Across DEVICES the rule is last-write-wins, by design: two phones
/// editing the same draft overwrite each other and nothing is merged.
/// Merging prose automatically would invent text the person never wrote.
class EssayEditorCubit extends Cubit<EssayEditorState> {
  EssayEditorCubit(
    this._repository,
    this.themeId, {
    this.requestIdGenerator = generateAttemptId,
  }) : super(const EssayEditorLoading()) {
    load();
  }

  final EssayRepository _repository;
  final String themeId;

  /// Injectable so a test can pin the id this screen will send.
  final String Function() requestIdGenerator;

  /// Long enough that a normal typing rhythm produces one save per pause,
  /// short enough that stopping to think already persists.
  static const debounce = Duration(milliseconds: 900);

  Timer? _debounceTimer;

  /// The newest text the user has typed, saved or not.
  String _pendingBody = '';

  /// The text the server last confirmed.
  String _persistedBody = '';

  bool _inFlight = false;

  /// Completes when the save that is running right now returns. [saveNow]
  /// waits on it instead of walking away: a flush that reports "not saved"
  /// only because another save was mid-flight would send the person a
  /// warning about text that was about to land.
  Future<void>? _inFlightSave;

  /// Identifies this attempt to submit. Generated once and kept: a retry
  /// after a timeout carries the same id, so the server recognises it as
  /// the same attempt instead of creating a second one.
  String? _requestId;

  /// Guards [submit] synchronously. The flag in the state is for the UI and
  /// is only set after the flush awaits -- two taps in the same frame would
  /// both get past a check that depended on it.
  bool _submitting = false;

  /// The attempt this editor produced, once it has been sent.
  EssayAttempt? submittedAttempt;

  /// True while a change is typed but not yet confirmed by the server.
  bool get hasUnsavedChanges => _pendingBody != _persistedBody;

  Future<void> load() async {
    emit(const EssayEditorLoading());
    final result = await _repository.getDraft(themeId);
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        _pendingBody = data?.body ?? '';
        _persistedBody = _pendingBody;
        emit(
          EssayEditorReady(
            initialBody: _pendingBody,
            hasSavedDraft: (data?.body ?? '').trim().isNotEmpty,
          ),
        );
      case Error():
        emit(const EssayEditorLoadFailed());
    }
  }

  /// Called on every keystroke. Cheap on purpose: it records the text and
  /// (re)arms the debounce, emitting at most one state change.
  void textChanged(String body) {
    _pendingBody = body;
    _debounceTimer?.cancel();
    if (!hasUnsavedChanges) return;
    _setStatus(EssaySaveStatus.saving);
    _debounceTimer = Timer(debounce, _save);
  }

  /// "Salvar rascunho" and the exit path: saves right now instead of
  /// waiting out the debounce. Returns true when the server holds the
  /// current text -- including the case where there was nothing to save.
  Future<bool> saveNow() async {
    _debounceTimer?.cancel();
    // Wait out whatever is already running -- including the follow-up save
    // that fires when text changed mid-request -- before judging whether
    // the server has the current text.
    while (_inFlightSave != null) {
      await _inFlightSave;
      if (isClosed) return false;
    }
    if (!hasUnsavedChanges) return true;
    await _save();
    return !hasUnsavedChanges;
  }

  Future<void> _save() async {
    if (_inFlight) return;
    final body = _pendingBody;
    _inFlight = true;
    final done = Completer<void>();
    _inFlightSave = done.future;
    _setStatus(EssaySaveStatus.saving);

    final result = await _repository.saveDraft(themeId, body);
    _inFlight = false;
    _inFlightSave = null;
    done.complete();
    if (isClosed) return;

    switch (result) {
      case Success():
        _persistedBody = body;
        // Typed again while that request was in flight: the newer text is
        // still unsaved, so go straight back in instead of reporting
        // "Salvo" for something already stale.
        if (hasUnsavedChanges) {
          unawaited(_save());
          return;
        }
        _setStatus(
          EssaySaveStatus.saved,
          hasSavedDraft: body.trim().isNotEmpty,
        );
      case Error():
        // The text stays in the editor. Only the status changes.
        _setStatus(EssaySaveStatus.failed);
    }
  }

  /// Sends the essay for marking.
  ///
  /// Order matters: whatever is on screen is flushed FIRST, and a failed
  /// flush aborts the whole thing -- freezing an older version than the one
  /// the person is looking at would be the worst possible outcome here.
  ///
  /// Creating the submission consumes no evaluation quota and starts no
  /// marking: it only freezes the text.
  Future<EssaySubmitOutcome> submit() async {
    if (state is! EssayEditorReady || _submitting) {
      return EssaySubmitOutcome.submitFailed;
    }
    _submitting = true;
    try {
      if (!await saveNow()) return EssaySubmitOutcome.saveFailed;
      if (isClosed) return EssaySubmitOutcome.submitFailed;

      emit((state as EssayEditorReady).copyWith(isSubmitting: true));
      // Generated once and kept: a retry after a timeout carries the same
      // id, so the server recognises the attempt instead of creating two.
      final requestId = _requestId ??= requestIdGenerator();
      final result = await _repository.submitDraft(
        themeId: themeId,
        clientRequestId: requestId,
      );
      if (isClosed) return EssaySubmitOutcome.submitFailed;

      switch (result) {
        case Success(:final data):
          submittedAttempt = data;
          _pendingBody = '';
          _persistedBody = '';
          emit(
            (state as EssayEditorReady).copyWith(
              isSubmitting: false,
              hasSavedDraft: false,
            ),
          );
          return EssaySubmitOutcome.submitted;
        case Error(:final failure):
          // The draft is still there: the server only deletes it inside
          // the same transaction that creates the submission.
          emit((state as EssayEditorReady).copyWith(isSubmitting: false));
          if (failure is EssaySubmitFailure &&
              failure.kind == EssaySubmitFailureKind.textTooShort) {
            return EssaySubmitOutcome.textTooShort;
          }
          return EssaySubmitOutcome.submitFailed;
      }
    } finally {
      _submitting = false;
    }
  }

  /// Retry after a failed save, from the status line.
  Future<void> retrySave() => _save();

  /// Throws away the draft on the server. The editor is only cleared once
  /// the server confirms -- a failed delete leaves both text and draft
  /// exactly where they were.
  ///
  /// Submissions are untouched: a previously graded attempt survives this.
  Future<bool> deleteDraft() async {
    final current = state;
    if (current is! EssayEditorReady || current.isDeleting) return false;
    _debounceTimer?.cancel();
    emit(current.copyWith(isDeleting: true));

    final result = await _repository.deleteDraft(themeId);
    if (isClosed) return false;
    switch (result) {
      case Success():
        _pendingBody = '';
        _persistedBody = '';
        emit(
          (state as EssayEditorReady).copyWith(
            isDeleting: false,
            hasSavedDraft: false,
            status: EssaySaveStatus.idle,
          ),
        );
        return true;
      case Error():
        emit((state as EssayEditorReady).copyWith(isDeleting: false));
        return false;
    }
  }

  void _setStatus(EssaySaveStatus status, {bool? hasSavedDraft}) {
    final current = state;
    if (current is! EssayEditorReady) return;
    emit(current.copyWith(status: status, hasSavedDraft: hasSavedDraft));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
