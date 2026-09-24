import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/domain/entities/essay_theme_summary.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';

class EssayRepositoryImpl implements EssayRepository {
  EssayRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<EssayThemeSummary>>> listThemes() async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'list_essay_themes_for_user',
      );
      return Success(
        rows
            .cast<Map<String, dynamic>>()
            .map(_summaryFromJson)
            .toList(growable: false),
      );
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<EssayTheme>> getTheme(String themeId) async {
    try {
      // essay_themes is public reference data, like catalog_nodes and
      // questions -- a plain select under RLS, no RPC needed.
      final row = await _client
          .from('essay_themes')
          .select()
          .eq('id', themeId)
          .maybeSingle();
      if (row == null) return Error(ServerFailure());
      return Success(_themeFromJson(row));
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  EssayThemeOrigin _originFromJson(Map<String, dynamic> json) {
    final examName = json['exam_name'] as String?;
    final examYear = json['exam_year'] as int?;
    // Defensive on purpose: the database constraint already guarantees an
    // official theme has both, but a half-filled row must degrade to
    // "practice" rather than render "null · null" as if it were an exam.
    if (json['source_type'] != 'official' ||
        examName == null ||
        examYear == null) {
      return const EssayThemeOrigin.practice();
    }
    return EssayThemeOrigin.official(
      examName: examName,
      examYear: examYear,
      sourceUrl: json['source_url'] as String?,
    );
  }

  EssayThemeSummary _summaryFromJson(Map<String, dynamic> json) =>
      EssayThemeSummary(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        origin: _originFromJson(json),
        hasDraft: json['has_draft'] as bool? ?? false,
        attemptCount: json['attempt_count'] as int? ?? 0,
        lastStatus: EssaySubmissionStatus.fromDb(
          json['last_status'] as String?,
        ),
        lastScore: json['last_score'] as int?,
      );

  EssayTheme _themeFromJson(Map<String, dynamic> json) => EssayTheme(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    prompt: json['prompt'] as String,
    origin: _originFromJson(json),
    supportingTexts: _supportingTexts(json['supporting_texts']),
  );

  List<EssaySupportingText> _supportingTexts(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => EssaySupportingText(
            body: e['body'] as String? ?? '',
            title: e['title'] as String?,
            source: e['source'] as String?,
          ),
        )
        .where((e) => e.body.trim().isNotEmpty)
        .toList(growable: false);
  }
}
