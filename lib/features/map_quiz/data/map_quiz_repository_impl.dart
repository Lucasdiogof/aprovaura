import 'dart:convert';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';
import 'package:aura/core/error/failures.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';
import 'package:aura/features/map_quiz/domain/entities/map_viewport_spec.dart';
import 'package:aura/features/map_quiz/domain/repositories/map_quiz_repository.dart';

class MapQuizRepositoryImpl implements MapQuizRepository {
  // Map assets are static and bundled at build time, so parsing them once
  // per mapId and reusing the result is always safe. Without this, every
  // "Tentar novamente" tap, and every quiz sharing a background map (e.g.
  // world_countries_bg across 7 different quizzes), re-read and
  // re-JSON-decoded the same file from scratch.
  final Map<String, List<MapRegion>> _cache = {};
  Map<String, MapViewportSpec>? _specs;

  @override
  Future<Result<List<MapRegion>>> loadRegions(String mapId) async {
    final cached = _cache[mapId];
    if (cached != null) return Success(cached);
    try {
      final raw = await rootBundle.loadString('lib/assets/maps/$mapId.geojson');
      // world_countries is ~850 KB / 37k vertices: decoding it on the UI
      // thread visibly froze the screen on mid-range phones.
      final regions = await compute(parseMapRegions, raw);
      _cache[mapId] = regions;
      return Success(regions);
    } catch (_) {
      return Error(UnexpectedFailure());
    }
  }

  /// Framing metadata is optional: a missing or unreadable entry falls back
  /// to [MapViewportSpec.fallback] (auto mode, framed on every answer), so a
  /// new dataset works before anyone writes its entry.
  @override
  Future<MapViewportSpec> loadViewportSpec(String mapId) async {
    if (_specs == null) {
      try {
        final raw = await rootBundle.loadString(
          'lib/assets/maps/viewports.json',
        );
        _specs = {
          for (final MapEntry(:key, :value)
              in (jsonDecode(raw) as Map<String, dynamic>).entries)
            if (value is Map<String, dynamic>)
              key: MapViewportSpec.fromJson(value),
        };
      } catch (_) {
        return MapViewportSpec.fallback;
      }
    }
    return _specs![mapId] ?? MapViewportSpec.fallback;
  }
}

/// Top-level so it can run in `compute()`.
List<MapRegion> parseMapRegions(String raw) {
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final features = json['features'] as List<dynamic>;
  return features
      .map((feature) => _parseFeature(feature as Map<String, dynamic>))
      .toList(growable: false);
}

MapRegion _parseFeature(Map<String, dynamic> feature) {
  final properties = feature['properties'] as Map<String, dynamic>;
  final geometry = feature['geometry'] as Map<String, dynamic>;
  final coordinates = geometry['coordinates'] as List<dynamic>;
  final parts = <List<LatLng>>[];
  final holes = <List<List<LatLng>>>[];
  void addPolygon(List<dynamic> rings) {
    parts.add(_ringToLatLngs(rings.first as List<dynamic>));
    holes.add([
      for (final ring in rings.skip(1)) _ringToLatLngs(ring as List<dynamic>),
    ]);
  }

  switch (geometry['type']) {
    case 'MultiPolygon':
      for (final polygon in coordinates) {
        addPolygon(polygon as List<dynamic>);
      }
    case 'Polygon':
      addPolygon(coordinates);
    case 'MultiLineString':
      parts.addAll(coordinates.map((l) => _ringToLatLngs(l as List<dynamic>)));
    case 'LineString':
      parts.add(_ringToLatLngs(coordinates));
    case 'Point':
      parts.add([
        LatLng(
          (coordinates[1] as num).toDouble(),
          (coordinates[0] as num).toDouble(),
        ),
      ]);
    case final type:
      throw UnsupportedError('Unsupported geometry type: $type');
  }
  return MapRegion(
    id: properties['sigla'] as String,
    name: properties['nome'] as String,
    parts: parts,
    holes: holes.any((h) => h.isNotEmpty) ? holes : const [],
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
