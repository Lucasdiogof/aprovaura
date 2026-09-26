import 'package:aura/core/error/result.dart';
import 'package:aura/features/error_review/domain/entities/error_topic.dart';

abstract class ErrorReviewRepository {
  /// [source] narrows to only errors from that kind of attempt --
  /// 'practice' or 'mock_exam' -- or every pending error when null.
  Future<Result<List<ErrorTopic>>> listPendingTopics({String? source});
}
