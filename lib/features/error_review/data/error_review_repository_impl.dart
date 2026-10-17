import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/cache/offline_cache.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/error_review/domain/entities/error_topic.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';

class ErrorReviewRepositoryImpl implements ErrorReviewRepository {
  ErrorReviewRepositoryImpl(this._client, this._localeCubit, this._cache);

  final SupabaseClient _client;
  final LocaleCubit _localeCubit;
  final OfflineCache _cache;

  @override
  Future<Result<List<ErrorTopic>>> listPendingTopics({String? source}) async {
    final locale = _localeCubit.state.databaseLocale;
    final result = await _cache.rowsWithFallback(
      _cache.userKey(
        _client.auth.currentUser?.id ?? 'anon',
        'errors.$locale.${source ?? 'all'}',
      ),
      () => _client.rpc<List<dynamic>>(
        'list_pending_error_topics',
        params: {'p_locale': locale, 'p_source': source},
      ),
    );
    return switch (result) {
      Success(:final data) => Success(
        data.map(_fromJson).toList(growable: false),
      ),
      Error(:final failure) => Error(failure),
    };
  }

  ErrorTopic _fromJson(Map<String, dynamic> json) => ErrorTopic(
    catalogNodeId: json['catalog_node_id'] as String,
    subject: json['subject'] as String,
    title: json['title'] as String,
    parentTitle: json['parent_title'] as String?,
    wrongCount: json['wrong_count'] as int,
  );
}
