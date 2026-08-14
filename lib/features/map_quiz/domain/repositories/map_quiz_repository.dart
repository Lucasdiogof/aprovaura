import 'package:aura/core/error/result.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';

abstract class MapQuizRepository {
  Future<Result<List<MapRegion>>> loadRegions(String mapId);
}
