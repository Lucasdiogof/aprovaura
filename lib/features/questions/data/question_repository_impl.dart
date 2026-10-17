import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/cache/offline_cache.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  QuestionRepositoryImpl(this._client, this._localeCubit, this._cache);

  final SupabaseClient _client;
  final LocaleCubit _localeCubit;
  final OfflineCache _cache;

  // Question text is public content (the same for every account), cached
  // per language, topic and difficulty. Answers/progress are never cached
  // here.
  String _cacheKey(String nodeId, QuestionDifficulty? difficulty) =>
      _cache.publicKey(
        'questions.${_localeCubit.state.databaseLocale}.$nodeId.'
        '${difficulty?.dbValue ?? 'all'}',
      );

  List<Question>? _readCached(String nodeId, QuestionDifficulty? difficulty) {
    final raw = _cache.read(_cacheKey(nodeId, difficulty));
    if (raw is! List || raw.isEmpty) return null;
    try {
      return raw
          .map((row) => _fromJson(Map<String, dynamic>.from(row as Map)))
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Result<List<Question>>> getQuestions(
    String catalogNodeId, {
    QuestionDifficulty? difficulty,
  }) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'get_catalog_questions',
        params: {
          'p_catalog_node_id': catalogNodeId,
          'p_difficulty': difficulty?.dbValue,
          'p_locale': _localeCubit.state.databaseLocale,
        },
      ).withRequestTimeout(const Duration(seconds: 8));
      final questions = rows
          .cast<Map<String, dynamic>>()
          .map(_fromJson)
          .toList(growable: false);
      if (rows.isNotEmpty) {
        await _cache.write(_cacheKey(catalogNodeId, difficulty), rows);
      }
      return Success(questions);
    } catch (error) {
      final failure = failureFromError(error);
      // Offline or too slow: the last questions fetched for this topic are
      // still valid content, so use them instead of an error.
      if (isConnectionFailure(failure)) {
        final cached = _readCached(catalogNodeId, difficulty);
        if (cached != null) return Success(cached);
      }
      return Error(failure);
    }
  }

  Question _fromJson(Map<String, dynamic> json) => Question(
    id: json['id'] as String,
    prompt: json['prompt'] as String,
    options: (json['options'] as List<dynamic>).cast<String>(),
    correctIndex: json['correct_index'] as int,
    explanation: json['explanation'] as String?,
    difficulty: QuestionDifficulty.fromDb(json['difficulty'] as String?),
  );
}
