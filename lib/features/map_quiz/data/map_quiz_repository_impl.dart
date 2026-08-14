import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';
import 'package:aura/features/map_quiz/domain/repositories/map_quiz_repository.dart';

class MapQuizRepositoryImpl implements MapQuizRepository {
  static const _assetPaths = {
    'brazil_states': 'lib/assets/maps/brazil_states.geojson',
  };

  @override
  Future<Result<List<MapRegion>>> loadRegions(String mapId) async {
    final path = _assetPaths[mapId];
    if (path == null) return Error(UnexpectedFailure());
    try {
      final raw = await rootBundle.loadString(path);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final features = json['features'] as List<dynamic>;
      final regions = features
          .map((feature) => _parseFeature(feature as Map<String, dynamic>))
          .toList(growable: false);
      return Success(regions);
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  MapRegion _parseFeature(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    final parts = switch (geometry['type']) {
      'MultiPolygon' =>
        coordinates
            .map(
              (polygon) => _ringToLatLngs(
                (polygon as List<dynamic>).first as List<dynamic>,
              ),
            )
            .toList(growable: false),
      _ => [_ringToLatLngs(coordinates.first as List<dynamic>)],
    };
    return MapRegion(
      id: properties['sigla'] as String,
      name: properties['nome'] as String,
      parts: parts,
    );
  }

  List<LatLng> _ringToLatLngs(List<dynamic> ring) => ring
      .map((point) {
        final coords = point as List<dynamic>;
        return LatLng(
          (coords[1] as num).toDouble(),
          (coords[0] as num).toDouble(),
        );
      })
      .toList(growable: false);
}
