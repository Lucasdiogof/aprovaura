import 'package:equatable/equatable.dart';

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

  EssayEditorReady copyWith({
    EssaySaveStatus? status,
    bool? hasSavedDraft,
    bool? isDeleting,
  }) => EssayEditorReady(
    initialBody: initialBody,
    status: status ?? this.status,
    hasSavedDraft: hasSavedDraft ?? this.hasSavedDraft,
    isDeleting: isDeleting ?? this.isDeleting,
  );

  @override
  List<Object?> get props => [initialBody, status, hasSavedDraft, isDeleting];
}
