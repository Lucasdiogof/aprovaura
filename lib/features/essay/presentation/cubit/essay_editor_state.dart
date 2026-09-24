import 'package:equatable/equatable.dart';

/// How a submit ended, for the page to react without reading failures.
enum EssaySubmitOutcome {
  /// The attempt exists on the server.
  submitted,

  /// The pending text could not be saved, so nothing was submitted -- an
  /// older version must never be frozen in place of what is on screen.
  saveFailed,

  /// The server refused or never answered. The draft is untouched.
  submitFailed,

  /// Under the minimum word count. The screen normally stops this before
  /// it gets here; this is the server disagreeing, which it is entitled
  /// to do -- the draft stays exactly where it was.
  textTooShort,
}

/// What the little line above the editor says.
enum EssaySaveStatus {
  /// Nothing written since the last confirmed save.
  idle,

  /// A save is in flight, or a change is waiting for the debounce.
  saving,

  /// The server confirmed the current text.
  saved,

  /// The last save failed. The text is still in the editor -- nothing is
  /// ever discarded because a request failed.
  failed,
}

sealed class EssayEditorState extends Equatable {
  const EssayEditorState();

  @override
  List<Object?> get props => [];
}

/// Fetching whatever was written before.
class EssayEditorLoading extends EssayEditorState {
  const EssayEditorLoading();
}

/// The draft could not be loaded. Writing on top of an unknown draft would
/// risk overwriting it, so the editor is not offered at all.
class EssayEditorLoadFailed extends EssayEditorState {
  const EssayEditorLoadFailed();
}

class EssayEditorReady extends EssayEditorState {
  const EssayEditorReady({
    required this.initialBody,
    this.status = EssaySaveStatus.idle,
    this.hasSavedDraft = false,
    this.isDeleting = false,
    this.isSubmitting = false,
  });

  /// Only what the editor starts with. The live text lives in the
  /// TextEditingController and deliberately never passes through state:
  /// emitting on every keystroke would rebuild the field and fight the
  /// cursor.
  final String initialBody;
  final EssaySaveStatus status;

  /// True when the server currently holds a draft -- which is what decides
  /// whether "apagar rascunho" is offered at all.
  final bool hasSavedDraft;
  final bool isDeleting;
  final bool isSubmitting;

  EssayEditorReady copyWith({
    EssaySaveStatus? status,
    bool? hasSavedDraft,
    bool? isDeleting,
    bool? isSubmitting,
  }) => EssayEditorReady(
    initialBody: initialBody,
    status: status ?? this.status,
    hasSavedDraft: hasSavedDraft ?? this.hasSavedDraft,
    isDeleting: isDeleting ?? this.isDeleting,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );

  @override
  List<Object?> get props => [
    initialBody,
    status,
    hasSavedDraft,
    isDeleting,
    isSubmitting,
  ];
}
