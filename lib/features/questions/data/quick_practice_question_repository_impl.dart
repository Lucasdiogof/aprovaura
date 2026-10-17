import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/cache/offline_cache.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/network/connection_monitor.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/core/sync/pending_sync_queue.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';

/// Questions the user has never answered, one per subject per round (see
/// `supabase/quick_practice.sql`).
///
/// Same rows and same shape as [QuestionRepositoryImpl], so the shared quiz
/// engine doesn't know the difference -- and because the deck is just
/// ordinary questions, answering them already counts toward their own
/// topic's progress and already feeds "revisar erros".
///
/// `catalogNodeId` and `difficulty` are ignored: a quick-practice deck
/// spans the whole catalog and every level. They stay in the signature to
/// satisfy [QuestionRepository], the same way review sessions ignore
/// difficulty.
class QuickPracticeQuestionRepositoryImpl implements QuestionRepository {
  QuickPracticeQuestionRepositoryImpl(
    this._client,
    this._localeCubit,
    this._cache,
    this._queue,
    this._monitor,
  );

  /// How many questions one round of quick practice serves.
  static const deckSize = 10;

  final SupabaseClient _client;
  final LocaleCubit _localeCubit;
  final OfflineCache _cache;
  final PendingSyncQueue _queue;
  final ConnectionMonitor _monitor;

  // Offline stand-in for "questions never answered": a shuffled deck from
  // topics already opened online, skipping what was answered while offline.
  // The server cannot be asked which ones the account answered before, so
  // some may repeat -- progress still counts once per question (upsert).
  List<Question>? _offlineDeck() {
    final prefix = _cache.publicKey(
      'questions.${_localeCubit.state.databaseLocale}.',
    );
    final skip = _queue.pendingAnswerIds();
    final byId = <String, Question>{};
    for (final key in _cache.keysWithPrefix(prefix)) {
      final raw = _cache.read(key);
      if (raw is! List) continue;
      for (final row in raw) {
        try {
          final question = _fromJson(Map<String, dynamic>.from(row as Map));
          if (!skip.contains(question.id)) byId[question.id] = question;
        } catch (_) {}
      }
    }
    if (byId.isEmpty) return null;
    final all = byId.values.toList()..shuffle();
    return all.take(deckSize).toList(growable: false);
  }

  @override
  Future<Result<List<Question>>> getQuestions(
    String catalogNodeId, {
    QuestionDifficulty? difficulty,
  }) async {
    if (!_monitor.isOnline) {
      final deck = _offlineDeck();
      if (deck != null) return Success(deck);
      return Error(NetworkFailure());
    }
    try {
      final rows = await _client
          .rpc<List<dynamic>>(
            'get_quick_practice_questions',
            params: {
              'p_limit': deckSize,
              'p_locale': _localeCubit.state.databaseLocale,
            },
          )
          .withRequestTimeout(const Duration(seconds: 8));
      final questions = rows
          .cast<Map<String, dynamic>>()
          .map(_fromJson)
          .toList(growable: false);
      return Success(questions);
    } catch (error) {
      final failure = failureFromError(error);
      if (isConnectionFailure(failure)) {
        final deck = _offlineDeck();
        if (deck != null) return Success(deck);
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
    subject: json['subject'] as String?,
  );
}
