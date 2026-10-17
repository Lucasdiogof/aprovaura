import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/cache/offline_cache.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/network/connection_monitor.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/core/sync/pending_sync_queue.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/favorites/domain/entities/favorite_question.dart';
import 'package:aura/features/favorites/domain/entities/favorite_topic.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(
    this._client,
    this._localeCubit,
    this._cache,
    this._queue,
    this._monitor,
  );

  final SupabaseClient _client;
  final LocaleCubit _localeCubit;
  final OfflineCache _cache;
  final PendingSyncQueue _queue;
  final ConnectionMonitor _monitor;

  String _userCacheKey(String key) =>
      _cache.userKey(_client.auth.currentUser?.id ?? 'anon', key);

  Future<Result<void>> _queueFavorite(String questionId, bool add) async {
    await _queue.enqueue(
      PendingAction(
        kind: PendingKind.favorite,
        key: questionId,
        payload: {'add': add},
      ),
    );
    return Error(QueuedOfflineFailure());
  }

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<Result<Set<String>>> getFavoriteQuestionIds(
    List<String> questionIds,
  ) async {
    if (questionIds.isEmpty) return const Success({});
    if (!_monitor.isOnline) return Error(NetworkFailure());
    try {
      final rows = await _client
          .from('user_question_favorites')
          .select('question_id')
          .eq('user_id', _userId)
          .inFilter('question_id', questionIds)
          .withRequestTimeout(const Duration(seconds: 6));
      return Success(rows.map((row) => row['question_id'] as String).toSet());
    } catch (error) {
      return Error(failureFromError(error));
    }
  }

  @override
  Future<Result<void>> addFavorite(String questionId) async {
    if (!_monitor.isOnline) return _queueFavorite(questionId, true);
    try {
      await _client.from('user_question_favorites').insert({
        'user_id': _userId,
        'question_id': questionId,
      }).withRequestTimeout();
      return const Success(null);
    } on PostgrestException catch (e) {
      // 23505: already a favorite, which is what was asked for.
      return e.code == '23505' ? const Success(null) : Error(ServerFailure());
    } catch (error) {
      final failure = failureFromError(error);
      return isConnectionFailure(failure)
          ? _queueFavorite(questionId, true)
          : Error(failure);
    }
  }

  @override
  Future<Result<void>> removeFavorite(String questionId) async {
    if (!_monitor.isOnline) return _queueFavorite(questionId, false);
    try {
      await _client
          .from('user_question_favorites')
          .delete()
          .eq('user_id', _userId)
          .eq('question_id', questionId)
          .withRequestTimeout();
      return const Success(null);
    } catch (error) {
      final failure = failureFromError(error);
      return isConnectionFailure(failure)
          ? _queueFavorite(questionId, false)
          : Error(failure);
    }
  }

  @override
  Future<Result<List<FavoriteTopic>>> listFavoriteTopics() async {
    final locale = _localeCubit.state.databaseLocale;
    final result = await _cache.rowsWithFallback(
      _userCacheKey('favorites.topics.$locale'),
      () => _client.rpc<List<dynamic>>(
        'list_favorite_topics',
        params: {'p_locale': locale},
      ),
    );
    return switch (result) {
      Success(:final data) => Success(
        data.map(_fromJson).toList(growable: false),
      ),
      Error(:final failure) => Error(failure),
    };
  }

  // Two round trips regardless of how many questions: the favorited
  // questions themselves (existing RPC, already ordered by order_index),
  // then the caller's progress rows for exactly those ids. A question with
  // no progress row simply isn't in the map -- that's "never answered".
  @override
  Future<Result<List<FavoriteQuestion>>> listFavoriteQuestions(
    String catalogNodeId,
  ) async {
    try {
      final locale = _localeCubit.state.databaseLocale;
      final rowsResult = await _cache.rowsWithFallback(
        _userCacheKey('favorites.questions.$locale.$catalogNodeId'),
        () => _client.rpc<List<dynamic>>(
          'get_favorite_questions_for_node',
          params: {'p_catalog_node_id': catalogNodeId, 'p_locale': locale},
        ),
      );
      final rows = switch (rowsResult) {
        Success(:final data) => data,
        Error(:final failure) => throw _Refused(failure),
      };
      final questions = rows.map(_questionFromJson).toList(growable: false);
      if (questions.isEmpty) return const Success([]);

      // Offline, the answered/wrong marks cannot be read; they show as
      // "never answered" rather than a guessed status.
      var isCorrectById = <String, bool>{};
      try {
        final progressRows = await _client
            .from('user_question_progress')
            .select('question_id, is_correct')
            .eq('user_id', _userId)
            .inFilter('question_id', [for (final q in questions) q.id])
            .withRequestTimeout();
        isCorrectById = {
          for (final row in progressRows)
            row['question_id'] as String: row['is_correct'] as bool,
        };
      } catch (error) {
        if (!isConnectionFailure(failureFromError(error))) rethrow;
      }

      return Success([
        for (final question in questions)
          FavoriteQuestion(
            question: question,
            status: FavoriteQuestionStatus.fromProgress(
              isCorrectById[question.id],
            ),
          ),
      ]);
    } on _Refused catch (refused) {
      return Error(refused.failure);
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  Question _questionFromJson(Map<String, dynamic> json) => Question(
    id: json['id'] as String,
    prompt: json['prompt'] as String,
    options: (json['options'] as List<dynamic>).cast<String>(),
    correctIndex: json['correct_index'] as int,
    explanation: json['explanation'] as String?,
    difficulty: QuestionDifficulty.fromDb(json['difficulty'] as String?),
  );

  FavoriteTopic _fromJson(Map<String, dynamic> json) => FavoriteTopic(
    catalogNodeId: json['catalog_node_id'] as String,
    subject: json['subject'] as String,
    title: json['title'] as String,
    parentTitle: json['parent_title'] as String?,
    favoriteCount: json['favorite_count'] as int,
  );
}

/// Carries a failure out of a block that would otherwise swallow it.
class _Refused implements Exception {
  _Refused(this.failure);
  final Failure failure;
}
