import 'package:equatable/equatable.dart';

/// The editable text of one theme. There is at most one per user per theme
/// (unique in `essay_drafts`), so writing for twenty minutes keeps updating
/// the same row instead of piling up versions.
class EssayDraft extends Equatable {
  const EssayDraft({required this.body, required this.updatedAt});

  final String body;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [body, updatedAt];
}
