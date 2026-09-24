import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/favorites/domain/entities/favorite_question.dart';
import 'package:aura/features/favorites/domain/entities/favorite_topic.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/questions/domain/entities/question.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._client, this._localeCubit);

  final SupabaseClient _client;
  final LocaleCubit _localeCubit;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<Result<Set<String>>> getFavoriteQuestionIds(
    List<String> questionIds,
  ) async {
    if (questionIds.isEmpty) return const Success({});
    try {
      final rows = await _client
          .from('user_question_favorites')
          .select('question_id')
          .eq('user_id', _userId)
          .inFilter('question_id', questionIds);
      return Success(rows.map((row) => row['question_id'] as String).toSet());
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> addFavorite(String questionId) async {
    try {
      await _client.from('user_question_favorites').insert({
        'user_id': _userId,
        'question_id': questionId,
      });
      return const Success(null);
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<void>> removeFavorite(String questionId) async {
    try {
      await _client
          .from('user_question_favorites')
          .delete()
          .eq('user_id', _userId)
          .eq('question_id', questionId);
      return const Success(null);
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  @override
  Future<Result<List<FavoriteTopic>>> listFavoriteTopics() async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'list_favorite_topics',
        params: {'p_locale': _localeCubit.state.databaseLocale},
      );
      final topics = rows
          .cast<Map<String, dynamic>>()
          .map(_fromJson)
          .toList(growable: false);
      return Success(topics);
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
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
      final rows = await _client.rpc<List<dynamic>>(
        'get_favorite_questions_for_node',
        params: {
          'p_catalog_node_id': catalogNodeId,
          'p_locale': _localeCubit.state.databaseLocale,
        },
      );
      final questions = rows
          .cast<Map<String, dynamic>>()
          .map(_questionFromJson)
          .toList(growable: false);
      if (questions.isEmpty) return const Success([]);

      final progressRows = await _client
          .from('user_question_progress')
          .select('question_id, is_correct')
          .eq('user_id', _userId)
          .inFilter('question_id', [for (final q in questions) q.id]);
      final isCorrectById = {
        for (final row in progressRows)
          row['question_id'] as String: row['is_correct'] as bool,
      };

      return Success([
        for (final question in questions)
          FavoriteQuestion(
            question: question,
            status: FavoriteQuestionStatus.fromProgress(
              isCorrectById[question.id],
            ),
          ),
      ]);
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
