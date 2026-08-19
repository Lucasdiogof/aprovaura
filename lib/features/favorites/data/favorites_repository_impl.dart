import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/favorites/domain/entities/favorite_topic.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._client);

  final SupabaseClient _client;

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
      final rows = await _client.rpc<List<dynamic>>('list_favorite_topics');
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

  FavoriteTopic _fromJson(Map<String, dynamic> json) => FavoriteTopic(
    catalogNodeId: json['catalog_node_id'] as String,
    subject: json['subject'] as String,
    title: json['title'] as String,
    parentTitle: json['parent_title'] as String?,
    favoriteCount: json['favorite_count'] as int,
  );
}
