import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/error_review/domain/entities/error_topic.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';

class ErrorReviewRepositoryImpl implements ErrorReviewRepository {
  ErrorReviewRepositoryImpl(this._client, this._localeCubit);

  final SupabaseClient _client;
  final LocaleCubit _localeCubit;

  @override
  Future<Result<List<ErrorTopic>>> listPendingTopics({String? source}) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'list_pending_error_topics',
        params: {
          'p_locale': _localeCubit.state.databaseLocale,
          'p_source': source,
        },
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
