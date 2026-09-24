import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';
import 'package:aura/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._client, this._localeCubit);

  final SupabaseClient _client;
  final LocaleCubit _localeCubit;

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
      return Success(
        rows.map((row) => CatalogNode.fromJson(row)).toList(growable: false),
      );
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  Future<List<Map<String, dynamic>>> _plainChildren({
    required String subject,
    required String? parentId,
  }) async {
    final result = await _client.rpc<List<dynamic>>(
      'catalog_children',
      params: {
        'p_subject': subject,
        'p_parent': parentId,
        'p_locale': _localeCubit.state.databaseLocale,
      },
    );
    return result.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> _childrenWithDifficulty({
    required String subject,
    required String? parentId,
    required QuestionDifficulty difficulty,
  }) async {
    final result = await _client.rpc<List<dynamic>>(
      'catalog_children_with_difficulty',
      params: {
        'p_subject': subject,
        'p_parent': parentId,
        'p_difficulty': difficulty.dbValue,
        'p_locale': _localeCubit.state.databaseLocale,
      },
    );
    return result.cast<Map<String, dynamic>>();
  }
}
