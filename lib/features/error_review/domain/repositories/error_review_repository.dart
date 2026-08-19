import 'package:aura/core/error/result.dart';
import 'package:aura/features/error_review/domain/entities/error_topic.dart';

abstract class ErrorReviewRepository {
  Future<Result<List<ErrorTopic>>> listPendingTopics();
}
