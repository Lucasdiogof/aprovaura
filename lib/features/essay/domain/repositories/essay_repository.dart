import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';

abstract class EssayRepository {
  /// Active themes plus this user's standing on each, in one round trip
  /// (`list_essay_themes_for_user`). Ordered by the server and stable --
  /// the list never reshuffles between openings.
  Future<Result<List<EssayThemeSummary>>> listThemes();

  /// The full proposal: instruction and motivating texts.
  Future<Result<EssayTheme>> getTheme(String themeId);
}
