import 'package:equatable/equatable.dart';
import 'package:aura/features/favorites/domain/entities/favorite_topic.dart';

/// One subject on the Favorites landing screen. Built client-side from
/// list_favorite_topics() -- that RPC already returns subject and a
/// per-topic question count, so grouping here needs no extra SQL.
class FavoriteSubject extends Equatable {
  const FavoriteSubject({required this.subject, required this.topics});

  final String subject;
  final List<FavoriteTopic> topics;

  /// Favorited questions, not topics -- what the user actually saved.
  int get questionCount =>
      topics.fold(0, (sum, topic) => sum + topic.favoriteCount);

  /// Keeps the incoming order (the RPC sorts topics by most recently
  /// favorited), so the subject favorited most recently comes first and
  /// topics inside each subject keep the same recency order. Topics with
  /// no favorites left are dropped, and so is any subject left empty.
  static List<FavoriteSubject> group(List<FavoriteTopic> topics) {
    final bySubject = <String, List<FavoriteTopic>>{};
    for (final topic in topics) {
      if (topic.favoriteCount <= 0) continue;
      bySubject.putIfAbsent(topic.subject, () => []).add(topic);
    }
    return [
      for (final entry in bySubject.entries)
        FavoriteSubject(subject: entry.key, topics: entry.value),
    ];
  }

  @override
  List<Object?> get props => [subject, topics];
}
