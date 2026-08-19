import 'package:aura/core/error/result.dart';
import 'package:aura/features/favorites/domain/entities/favorite_topic.dart';

abstract class FavoritesRepository {
  Future<Result<Set<String>>> getFavoriteQuestionIds(List<String> questionIds);
  Future<Result<void>> addFavorite(String questionId);
  Future<Result<void>> removeFavorite(String questionId);
  Future<Result<List<FavoriteTopic>>> listFavoriteTopics();
}
