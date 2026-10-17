import 'package:aura/core/error/result.dart';
import 'package:aura/features/catalog/domain/entities/catalog_node.dart';
import 'package:aura/features/questions/domain/entities/question_difficulty.dart';

abstract class CatalogRepository {
  Future<Result<List<CatalogNode>>> getChildren({
    required String subject,
    String? parentId,
    QuestionDifficulty? difficulty,
  });

  /// The last list fetched successfully for the same arguments, or null when
  /// nothing was saved. Lets screens show something while (or instead of)
  /// asking the server.
  Future<List<CatalogNode>?> cachedChildren({
    required String subject,
    String? parentId,
    QuestionDifficulty? difficulty,
  }) async => null;
}
