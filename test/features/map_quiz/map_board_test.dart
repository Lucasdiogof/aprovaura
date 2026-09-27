import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:aura/features/map_quiz/data/map_quiz_repository_impl.dart';
import 'package:aura/features/map_quiz/domain/entities/map_board.dart';
import 'package:aura/features/map_quiz/domain/entities/map_interaction_type.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';
import 'package:aura/features/map_quiz/domain/entities/map_viewport_spec.dart';

/// Real datasets straight from the assets: the point of these tests is the
/// geometry that actually ships, not a hand-made mock.
List<MapRegion> _load(String mapId) =>
    parseMapRegions(File('lib/assets/maps/$mapId.geojson').readAsStringSync());

final Map<String, MapViewportSpec> _specs = {
  for (final MapEntry(:key, :value)
      in (jsonDecode(File('lib/assets/maps/viewports.json').readAsStringSync())
              as Map<String, dynamic>)
          .entries)
    if (value is Map<String, dynamic>) key: MapViewportSpec.fromJson(value),
};

MapBoard _board(String mapId, MapInteractionType type) => buildMapBoard(
  MapBoardInput(
    regions: _load(mapId),
    background: const [],
    interactionType: type,
    spec: _specs[mapId] ?? MapViewportSpec.fallback,
  ),
);

double _span(GeoBox b) => b.east - b.west;

void main() {
  group('parseMapRegions', () {
    test('keeps interior rings: Italy has holes for the Vatican and '
        'San Marino', () {
      final italy = _load(
        'europe_countries',
      ).firstWhere((r) => r.name == 'Itália');
      final holes = italy.holes.expand((h) => h).toList();
      expect(holes, hasLength(2));
    });

    test('regions without holes carry none', () {
      final brasilia = _load(
        'brazil_states',
      ).firstWhere((r) => r.name == 'Distrito Federal');
      expect(brasilia.holes, isEmpty);
    });
  });

  group('viewports.json', () {
    test('has an entry for every dataset an activity uses', () {
      final activities = File(
        'lib/features/catalog/presentation/mapped_activities.dart',
      ).readAsStringSync();
      final mapIds = RegExp(
        r"mapId: '([a-z_]+)'",
      ).allMatches(activities).map((m) => m.group(1)!).toSet();
      expect(mapIds.difference(_specs.keys.toSet()), isEmpty);
    });

    test('world datasets are scoped to the world', () {
      for (final MapEntry(:key, :value) in _specs.entries) {
        expect(
          value.scope == MapScope.world,
          key.startsWith('world_'),
          reason: key,
        );
      }
    });
  });

  group(buildMapBoard, () {
    test('Europe is framed on Europe, not on French Guiana or Kamchatka', () {
      final board = _board('europe_countries', MapInteractionType.polygon);
      expect(board.lngOffset, 0);
      expect(board.bounds.west, greaterThanOrEqualTo(-25));
      expect(board.bounds.east, lessThanOrEqualTo(50));
      expect(board.bounds.south, greaterThanOrEqualTo(34));
      expect(board.bounds.north, lessThanOrEqualTo(72));
    });

    test('South America leaves out the Galápagos and Easter Island', () {
      final board = _board(
        'south_america_countries',
        MapInteractionType.polygon,
      );
      expect(board.bounds.west, greaterThanOrEqualTo(-82));
    });

    test('Oceania wraps the antimeridian: the board is turned so it is one '
        'contiguous box instead of the whole world', () {
      final board = _board('oceania_countries', MapInteractionType.polygon);
      expect(board.lngOffset, isNot(0));
      expect(_span(board.bounds), lessThan(130));
      expect(board.bounds.west, lessThan(board.bounds.east));
    });

    test('the Aleutians no longer stretch North America around the globe', () {
      final board = _board(
        'north_america_countries',
        MapInteractionType.polygon,
      );
      expect(board.lngOffset, isNot(0));
      expect(_span(board.bounds), lessThan(160));
    });

    test('rings stay continuous after turning (no band across the map)', () {
      final board = _board('oceania_countries', MapInteractionType.polygon);
      for (final region in board.regions) {
        for (final part in region.parts) {
          for (var i = 1; i < part.length; i++) {
            expect(
              (part[i].longitude - part[i - 1].longitude).abs(),
              lessThan(180),
              reason: region.name,
            );
          }
        }
      }
    });

    test('world maps are never turned', () {
      for (final id in ['world_countries', 'world_straits']) {
        final type = id == 'world_straits'
            ? MapInteractionType.point
            : MapInteractionType.polygon;
        expect(_board(id, type).lngOffset, 0, reason: id);
      }
    });

    test('an enclave is painted after (on top of) the country around it', () {
      final board = _board('europe_countries', MapInteractionType.polygon);
      final order = board.paintOrder;
      final byName = {for (final r in board.regions) r.name: r.id};
      expect(
        order.indexOf(byName['Vaticano']!),
        greaterThan(order.indexOf(byName['Itália']!)),
      );
      expect(
        order.indexOf(byName['San Marino']!),
        greaterThan(order.indexOf(byName['Itália']!)),
      );
    });

    test('a microstate measures a fraction of a pixel at zoom 0', () {
      final board = _board('europe_countries', MapInteractionType.polygon);
      final vatican = board.regions.firstWhere((r) => r.name == 'Vaticano');
      expect(board.metrics[vatican.id]!.size, lessThan(0.01));
      final france = board.regions.firstWhere((r) => r.name == 'França');
      // Judged by mainland France, not by the bbox including Réunion.
      expect(
        board.metrics[france.id]!.anchor.longitude,
        inInclusiveRange(-5, 8),
      );
    });

    test('every answer of every dataset starts inside the initial frame', () {
      final activities = File(
        'lib/features/catalog/presentation/mapped_activities.dart',
      ).readAsStringSync();
      final pairs = RegExp(
        r"mapId: '([a-z_]+)',\s*interactionType: MapInteractionType\.(\w+)",
      ).allMatches(activities).map((m) => (m.group(1)!, m.group(2)!)).toSet();
      for (final (mapId, typeName) in pairs) {
        final type = MapInteractionType.values.byName(typeName);
        final board = _board(mapId, type);
        final b = board.bounds;
        bool inside(LatLng p) =>
            p.longitude >= b.west - 1e-9 &&
            p.longitude <= b.east + 1e-9 &&
            p.latitude >= b.south - 1e-9 &&
            p.latitude <= b.north + 1e-9;
        for (final region in board.regions) {
          expect(
            region.parts.expand((p) => p).any(inside),
            isTrue,
            reason: '$mapId: ${region.name} outside the initial frame',
          );
        }
      }
    });
  });
}
