import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';
import 'package:aura/features/map_quiz/domain/repositories/map_quiz_repository.dart';

class MapQuizRepositoryImpl implements MapQuizRepository {
  // Map assets are static and bundled at build time, so parsing them once
  // per mapId and reusing the result is always safe. Without this, every
  // "Tentar novamente" tap, and every quiz sharing a background map (e.g.
  // world_countries_bg across 7 different quizzes), re-read and
  // re-JSON-decoded the same file from scratch.
  final Map<String, List<MapRegion>> _cache = {};

  @override
  Future<Result<List<MapRegion>>> loadRegions(String mapId) async {
    final cached = _cache[mapId];
    if (cached != null) return Success(cached);
    try {
      final raw = await rootBundle.loadString('lib/assets/maps/$mapId.geojson');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final features = json['features'] as List<dynamic>;
      final regions = features
          .map((feature) => _parseFeature(feature as Map<String, dynamic>))
          .toList(growable: false);
      _cache[mapId] = regions;
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
      'Polygon' => [_ringToLatLngs(coordinates.first as List<dynamic>)],
      'MultiLineString' =>
        coordinates
            .map((line) => _ringToLatLngs(line as List<dynamic>))
            .toList(growable: false),
      'LineString' => [_ringToLatLngs(coordinates)],
      'Point' => [
        [
          LatLng(
            (coordinates[1] as num).toDouble(),
            (coordinates[0] as num).toDouble(),
          ),
        ],
      ],
      final type => throw UnsupportedError('Unsupported geometry type: $type'),
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
