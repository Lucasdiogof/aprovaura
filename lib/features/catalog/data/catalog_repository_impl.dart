import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/cache/offline_cache.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';
import 'package:aura/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._client, this._localeCubit, this._cache);

  final SupabaseClient _client;
  final LocaleCubit _localeCubit;
  final OfflineCache _cache;

  // Catalog structure is public content, so it is cached per language but
  // not per account.
  String _cacheKey(
    String subject,
    String? parentId,
    QuestionDifficulty? difficulty,
  ) => _cache.publicKey(
    'catalog.${_localeCubit.state.databaseLocale}.$subject.'
    '${parentId ?? 'root'}.${difficulty?.dbValue ?? 'all'}',
  );

  @override
  Future<List<CatalogNode>?> cachedChildren({
    required String subject,
    String? parentId,
    QuestionDifficulty? difficulty,
  }) async {
    final raw = _cache.read(_cacheKey(subject, parentId, difficulty));
    if (raw is! List || raw.isEmpty) return null;
    try {
      return raw
          .map(
            (row) =>
                CatalogNode.fromJson(Map<String, dynamic>.from(row as Map)),
          )
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Result<List<CatalogNode>>> getChildren({
    required String subject,
    String? parentId,
    QuestionDifficulty? difficulty,
  }) async {
    try {
      final rows = difficulty == null
          ? await _plainChildren(subject: subject, parentId: parentId)
          : await _childrenWithDifficulty(
              subject: subject,
              parentId: parentId,
              difficulty: difficulty,
            );
      final nodes = rows
          .map((row) => CatalogNode.fromJson(row))
          .toList(growable: false);
      // An empty answer is not saved: it would later hide real content
      // behind a "coming soon" the server no longer shows.
      if (rows.isNotEmpty) {
        await _cache.write(_cacheKey(subject, parentId, difficulty), rows);
      }
      return Success(nodes);
    } catch (error) {
      return Error(failureFromError(error));
    }
  }

  Future<List<Map<String, dynamic>>> _plainChildren({
    required String subject,
    required String? parentId,
  }) async {
    final result = await _client
        .rpc<List<dynamic>>(
          'catalog_children',
          params: {
            'p_subject': subject,
            'p_parent': parentId,
            'p_locale': _localeCubit.state.databaseLocale,
          },
        )
        .withRequestTimeout();
    return result.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> _childrenWithDifficulty({
    required String subject,
    required String? parentId,
    required QuestionDifficulty difficulty,
  }) async {
    final result = await _client
        .rpc<List<dynamic>>(
          'catalog_children_with_difficulty',
          params: {
            'p_subject': subject,
            'p_parent': parentId,
            'p_difficulty': difficulty.dbValue,
            'p_locale': _localeCubit.state.databaseLocale,
          },
        )
        .withRequestTimeout();
    return result.cast<Map<String, dynamic>>();
  }
}
