import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/essay/domain/entities/essay_attempt.dart';
import 'package:aura/features/essay/domain/entities/essay_draft.dart';
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

  @override
  Future<Result<EssayDraft?>> getDraft(String themeId) async {
    try {
      // No user id in the filter: the RLS policy on essay_drafts already
      // narrows this to the caller's own row.
      final row = await _client
          .from('essay_drafts')
          .select('body, updated_at')
          .eq('theme_id', themeId)
          .maybeSingle();
      if (row == null) return const Success(null);
      return Success(
        EssayDraft(
          body: row['body'] as String? ?? '',
          updatedAt: DateTime.parse(row['updated_at'] as String),
        ),
      );
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<DateTime?>> saveDraft(String themeId, String body) async {
    try {
      final updatedAt = await _client.rpc<String?>(
        'save_essay_draft',
        params: {'p_theme_id': themeId, 'p_body': body},
      );
      return Success(updatedAt == null ? null : DateTime.parse(updatedAt));
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> deleteDraft(String themeId) async {
    try {
      await _client.rpc<void>(
        'delete_essay_draft',
        params: {'p_theme_id': themeId},
      );
      return const Success(null);
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<EssayAttempt>> submitDraft({
    required String themeId,
    required String clientRequestId,
  }) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'submit_essay_draft',
        params: {'p_theme_id': themeId, 'p_client_request_id': clientRequestId},
      );
      final row = rows.cast<Map<String, dynamic>>().first;
      return Success(
        EssayAttempt(
          id: row['id'] as String,
          status:
              EssaySubmissionStatus.fromDb(row['status'] as String?) ??
              EssaySubmissionStatus.submitted,
          wordCount: 0,
          submittedAt: DateTime.parse(row['submitted_at'] as String),
        ),
      );
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<List<EssayAttempt>>> listAttempts(String themeId) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'list_essay_attempts',
        params: {'p_theme_id': themeId},
      );
      return Success(
        rows
            .cast<Map<String, dynamic>>()
            .map(_attemptFromJson)
            .toList(growable: false),
      );
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<EssaySubmission>> getSubmission(String submissionId) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'get_essay_submission',
        params: {'p_submission_id': submissionId},
      );
      final list = rows.cast<Map<String, dynamic>>();
      if (list.isEmpty) return Error(ServerFailure());
      final row = list.first;
      return Success(
        EssaySubmission(
          id: row['id'] as String,
          themeTitle: row['theme_title'] as String? ?? '',
          body: row['body'] as String? ?? '',
          wordCount: row['word_count'] as int? ?? 0,
          status:
              EssaySubmissionStatus.fromDb(row['status'] as String?) ??
              EssaySubmissionStatus.submitted,
          submittedAt: DateTime.parse(row['submitted_at'] as String),
          totalScore: row['total_score'] as int?,
          evaluatedAt: _dateOrNull(row['evaluated_at']),
        ),
      );
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  EssayAttempt _attemptFromJson(Map<String, dynamic> json) => EssayAttempt(
    id: json['id'] as String,
    status:
        EssaySubmissionStatus.fromDb(json['status'] as String?) ??
        EssaySubmissionStatus.submitted,
    wordCount: json['word_count'] as int? ?? 0,
    submittedAt: DateTime.parse(json['submitted_at'] as String),
    totalScore: json['total_score'] as int?,
    evaluatedAt: _dateOrNull(json['evaluated_at']),
  );

  DateTime? _dateOrNull(Object? value) =>
      value is String ? DateTime.parse(value) : null;

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
