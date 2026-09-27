import 'package:aura/core/error/result.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';
import 'package:aura/features/map_quiz/domain/entities/map_viewport_spec.dart';

abstract class MapQuizRepository {
  Future<Result<List<MapRegion>>> loadRegions(String mapId);

  /// How the dataset should be framed (scope, focus, forced mode). Never
  /// fails: a dataset without an entry gets the default spec.
  Future<MapViewportSpec> loadViewportSpec(String mapId);
}
