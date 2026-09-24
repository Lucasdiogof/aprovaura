import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/entities/essay_draft.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';

abstract class EssayRepository {
  /// Active themes plus this user's standing on each, in one round trip
  /// (`list_essay_themes_for_user`). Ordered by the server and stable --
  /// the list never reshuffles between openings.
  Future<Result<List<EssayThemeSummary>>> listThemes();

  /// The full proposal: instruction and motivating texts.
  Future<Result<EssayTheme>> getTheme(String themeId);

  /// The user's saved draft for a theme, or null when there is none. The
  /// server is the source of truth: reopening the app, or opening it on
  /// another device, restores from here.
  Future<Result<EssayDraft?>> getDraft(String themeId);

  /// Upserts the draft and returns when the server stored it. Blank text
  /// deletes the draft instead of storing an empty row, and returns null.
  ///
  /// The user id is never sent -- `save_essay_draft` takes it from
  /// auth.uid() on the server.
  Future<Result<DateTime?>> saveDraft(String themeId, String body);

  /// Deletes the draft. Never touches submissions: a previously graded
  /// attempt survives throwing away a new draft.
  Future<Result<void>> deleteDraft(String themeId);
}
