import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/error/result.dart';
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
  EssayEditorCubit(this._repository, this.themeId)
    : super(const EssayEditorLoading()) {
    load();
  }

  final EssayRepository _repository;
  final String themeId;

  /// Long enough that a normal typing rhythm produces one save per pause,
  /// short enough that stopping to think already persists.
  static const debounce = Duration(milliseconds: 900);

  Timer? _debounceTimer;

  /// The newest text the user has typed, saved or not.
  String _pendingBody = '';

  /// The text the server last confirmed.
  String _persistedBody = '';

  bool _inFlight = false;

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
    if (!hasUnsavedChanges && !_inFlight) return true;
    await _save();
    return !hasUnsavedChanges;
  }

  Future<void> _save() async {
    if (_inFlight) return;
    final body = _pendingBody;
    _inFlight = true;
    _setStatus(EssaySaveStatus.saving);

    final result = await _repository.saveDraft(themeId, body);
    _inFlight = false;
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
