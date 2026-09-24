import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/favorites/domain/entities/favorite_question.dart';
import 'package:aura/features/favorites/domain/entities/favorite_subject.dart';
import 'package:aura/features/favorites/domain/entities/favorite_topic.dart';

FavoriteTopic _topic(String id, String subject, int count) => FavoriteTopic(
  catalogNodeId: id,
  subject: subject,
  title: id,
  favoriteCount: count,
);

void main() {
  group('FavoriteSubject.group', () {
    test('returns no subjects for no topics', () {
      expect(FavoriteSubject.group(const []), isEmpty);
    });

    test('sums favorited questions, not topics, per subject', () {
      final subjects = FavoriteSubject.group([
        _topic('lagos', 'geografia', 3),
        _topic('rios', 'geografia', 2),
        _topic('vargas', 'historia', 1),
      ]);

      expect(subjects.map((s) => s.subject), ['geografia', 'historia']);
      expect(subjects[0].questionCount, 5);
      expect(subjects[0].topics.length, 2);
      expect(subjects[1].questionCount, 1);
    });

    test('keeps the incoming recency order across and within subjects', () {
      final subjects = FavoriteSubject.group([
        _topic('vargas', 'historia', 1),
        _topic('lagos', 'geografia', 1),
        _topic('colonia', 'historia', 1),
      ]);

      expect(subjects.map((s) => s.subject), ['historia', 'geografia']);
      expect(subjects[0].topics.map((t) => t.catalogNodeId), [
        'vargas',
        'colonia',
      ]);
    });

    test('drops topics with no favorites and subjects left empty', () {
      final subjects = FavoriteSubject.group([
        _topic('lagos', 'geografia', 0),
        _topic('vargas', 'historia', 2),
      ]);

      expect(subjects.map((s) => s.subject), ['historia']);
    });
  });

  group('FavoriteQuestionStatus.fromProgress', () {
    test('no progress row means never answered', () {
      expect(
        FavoriteQuestionStatus.fromProgress(null),
        FavoriteQuestionStatus.unanswered,
      );
    });

    test('latest answer correct means correct', () {
      expect(
        FavoriteQuestionStatus.fromProgress(true),
        FavoriteQuestionStatus.correct,
      );
    });

    test('latest answer wrong means it still needs review', () {
      expect(
        FavoriteQuestionStatus.fromProgress(false),
        FavoriteQuestionStatus.needsReview,
      );
    });
  });
}
