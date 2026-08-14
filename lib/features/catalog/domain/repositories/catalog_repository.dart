import 'package:aura/core/error/result.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';

abstract class CatalogRepository {
  Future<Result<List<CatalogNode>>> getChildren({
    required String subject,
    String? parentId,
  });
}
