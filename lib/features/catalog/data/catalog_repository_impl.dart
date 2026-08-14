import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';
import 'package:aura/features/catalog/domain/repositories/catalog_repository.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<CatalogNode>>> getChildren({
    required String subject,
    String? parentId,
  }) async {
    try {
      var query = _client.from('catalog_nodes').select().eq('subject', subject);
      query = parentId == null
          ? query.filter('parent_id', 'is', null)
          : query.eq('parent_id', parentId);
      final rows = await query.order('order_index', ascending: true);
      return Success(
        rows.map((row) => CatalogNode.fromJson(row)).toList(growable: false),
      );
    } on PostgrestException {
      return Error(ServerFailure());
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }
}
