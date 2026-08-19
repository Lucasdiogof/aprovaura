import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/error_review/domain/entities/error_topic.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';

class ErrorReviewRepositoryImpl implements ErrorReviewRepository {
  ErrorReviewRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<ErrorTopic>>> listPendingTopics() async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'list_pending_error_topics',
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

  ErrorTopic _fromJson(Map<String, dynamic> json) => ErrorTopic(
    catalogNodeId: json['catalog_node_id'] as String,
    subject: json['subject'] as String,
    title: json['title'] as String,
    parentTitle: json['parent_title'] as String?,
    wrongCount: json['wrong_count'] as int,
  );
}
