import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:aura/features/map_quiz/data/map_quiz_repository_impl.dart';
import 'package:aura/features/map_quiz/domain/entities/map_board.dart';
import 'package:aura/features/map_quiz/domain/entities/map_interaction_type.dart';
import 'package:aura/features/map_quiz/domain/entities/map_viewport_spec.dart';
import 'package:aura/features/map_quiz/presentation/viewport/board_camera_constraint.dart';
import 'package:aura/features/map_quiz/presentation/viewport/map_hit_tester.dart';
import 'package:aura/features/map_quiz/presentation/viewport/map_viewport_policy.dart';

final _specs = {
  for (final MapEntry(:key, :value)
      in (jsonDecode(File('lib/assets/maps/viewports.json').readAsStringSync())
              as Map<String, dynamic>)
          .entries)
    if (value is Map<String, dynamic>) key: MapViewportSpec.fromJson(value),
};

final _boards = <String, MapBoard>{};
MapBoard _board(String mapId, MapInteractionType type) => _boards.putIfAbsent(
  mapId,
  () => buildMapBoard(
    MapBoardInput(
      regions: parseMapRegions(
        File('lib/assets/maps/$mapId.geojson').readAsStringSync(),
      ),
      background: const [],
      interactionType: type,
      spec: _specs[mapId]!,
    ),
  ),
);

// The map area under the compact header on a 360x800 phone, a portrait
// tablet and a desktop browser window.
const _phone = Size(360, 640);
const _tablet = Size(768, 900);
const _web = Size(1280, 640);

String _id(MapBoard b, String name) =>
    b.regions.firstWhere((r) => r.name == name).id;

void main() {
  group('modes from real pixel sizes', () {
    test('South America fits a phone with every country tappable: a locked '
        'board, no zoom at all', () {
      final v = MapViewportPolicy.resolve(
        _board('south_america_countries', MapInteractionType.polygon),
        _phone,
      );
      expect(v.mode, MapViewportMode.locked);
      expect(v.minZoom, v.maxZoom);
      expect(v.isInteractive, isFalse);
    });

    test('Europe on a phone is constrained: a few levels of zoom, no more', () {
      final v = MapViewportPolicy.resolve(
        _board('europe_countries', MapInteractionType.polygon),
        _phone,
      );
      expect(v.mode, MapViewportMode.constrained);
      expect(v.minZoom, v.fitZoom);
      expect(v.maxZoom - v.fitZoom, inInclusiveRange(1, 3));
    });

    test('Europe microstates get stand-in markers; real countries do not', () {
      final board = _board('europe_countries', MapInteractionType.polygon);
      final v = MapViewportPolicy.resolve(board, _phone);
      for (final name in ['Vaticano', 'Mônaco', 'San Marino']) {
        expect(v.proxyIds, contains(_id(board, name)), reason: name);
      }
      for (final name in ['França', 'Luxemburgo', 'Itália']) {
        expect(v.proxyIds, isNot(contains(_id(board, name))), reason: name);
      }
    });

    test('world boards are framed whole and allow limited zoom', () {
      final v = MapViewportPolicy.resolve(
        _board('world_straits', MapInteractionType.point),
        _phone,
      );
      expect(v.mode, MapViewportMode.world);
      expect(v.minZoom, v.fitZoom);
      expect(v.maxZoom - v.fitZoom, inInclusiveRange(2, 5));
    });

    test('a bigger screen frames closer and needs less zoom', () {
      final board = _board('europe_countries', MapInteractionType.polygon);
      final phone = MapViewportPolicy.resolve(board, _phone);
      final tablet = MapViewportPolicy.resolve(board, _tablet);
      expect(tablet.fitZoom, greaterThan(phone.fitZoom));
      expect(
        MapViewportPolicy.paddingFor(_phone),
        lessThan(MapViewportPolicy.paddingFor(_web)),
      );
    });

    test('a forced mode in the spec wins over the measurement', () {
      final board = _board(
        'south_america_countries',
        MapInteractionType.polygon,
      );
      final forced = MapBoard(
        regions: board.regions,
        background: board.background,
        interactionType: board.interactionType,
        spec: const MapViewportSpec(mode: MapViewportMode.constrained),
        lngOffset: board.lngOffset,
        bounds: board.bounds,
        metrics: board.metrics,
        paintOrder: board.paintOrder,
      );
      expect(
        MapViewportPolicy.resolve(forced, _phone).mode,
        MapViewportMode.constrained,
      );
    });
  });

  group('the initial frame', () {
    test('every answer of every activity is on screen at 360px, tablet and '
        'web', () {
      final activities = File(
        'lib/features/catalog/presentation/mapped_activities.dart',
      ).readAsStringSync();
      final pairs = RegExp(
        r"mapId: '([a-z_]+)',\s*interactionType: MapInteractionType\.(\w+)",
      ).allMatches(activities).map((m) => (m.group(1)!, m.group(2)!)).toSet();
      for (final (mapId, typeName) in pairs) {
        final board = _board(mapId, MapInteractionType.values.byName(typeName));
        for (final size in const [_phone, _tablet, _web]) {
          final v = MapViewportPolicy.resolve(board, size);
          final toScreen = boardProjection(
            center: v.center,
            zoom: v.fitZoom,
            size: size,
          );
          bool onScreen(LatLng p) {
            final o = toScreen(p);
            return o.dx >= -0.5 &&
                o.dx <= size.width + 0.5 &&
                o.dy >= -0.5 &&
                o.dy <= size.height + 0.5;
          }

          for (final region in board.regions) {
            expect(
              region.parts.expand((p) => p).any(onScreen),
              isTrue,
              reason: '$mapId @ $size: ${region.name} off screen',
            );
          }
        }
      }
    });

    test('depends only on the board and the screen -- there is no target '
        'to lean on, so it is identical for every question', () {
      final board = _board('europe_countries', MapInteractionType.polygon);
      expect(
        MapViewportPolicy.resolve(board, _phone),
        MapViewportPolicy.resolve(board, _phone),
      );
    });
  });

  group('the map buttons', () {
    test('when the board would sit under the zoom buttons, the frame keeps '
        'their corner free -- no answer hidden under a control', () {
      final board = _board('world_straits', MapInteractionType.point);
      const controls = Size(60, 108);
      final v = MapViewportPolicy.resolve(board, _web, controls: controls);
      expect(v.reservedRight, controls.width);
      final toScreen = boardProjection(
        center: v.center,
        zoom: v.fitZoom,
        size: _web,
      );
      for (final r in board.regions) {
        final o = toScreen(board.metrics[r.id]!.anchor);
        final underButtons =
            o.dx > _web.width - controls.width &&
            o.dy > _web.height - controls.height;
        expect(underButtons, isFalse, reason: r.name);
      }
    });

    test('when the board is nowhere near them, nothing is reserved', () {
      final board = _board('world_straits', MapInteractionType.point);
      final v = MapViewportPolicy.resolve(
        board,
        _phone,
        controls: const Size(60, 108),
      );
      expect(v.reservedRight, 0);
    });
  });

  group('marker size', () {
    test('crowded boards (world capitals) draw smaller dots', () {
      final crowded = MapViewportPolicy.resolve(
        _board('world_capitals', MapInteractionType.point),
        _phone,
      );
      final sparse = MapViewportPolicy.resolve(
        _board('south_america_capitals', MapInteractionType.point),
        _phone,
      );
      expect(crowded.markerRadius, MapViewportPolicy.crowdedPointRadius);
      expect(sparse.markerRadius, MapViewportPolicy.pointRadius);
      // The touch area never shrinks with the drawing.
      expect(
        MapMarkerSizes.pointHitRadius,
        greaterThan(MapViewportPolicy.pointRadius * 3),
      );
    });
  });

  group('markers too close together', () {
    test('Rome and the Vatican are nudged apart, not stacked', () {
      final board = _board('europe_capitals', MapInteractionType.point);
      final v = MapViewportPolicy.resolve(board, _phone);
      final rome = _id(board, 'Roma'), vatican = _id(board, 'Vaticano');
      final moved = v.displacements[rome] ?? v.displacements[vatican];
      expect(moved, isNotNull);
      expect(moved!.distance, closeTo(MapViewportPolicy.displacementPx, 0.01));
      // Only one of the pair moves; the other stays on its real spot.
      expect(
        v.displacements.containsKey(rome) &&
            v.displacements.containsKey(vatican),
        isFalse,
      );
    });
  });

  group(hitTestBoard, () {
    ({MapBoard board, MapViewport v, Offset Function(LatLng) toScreen}) setup(
      String mapId,
      MapInteractionType type, {
      double extraZoom = 0,
    }) {
      final board = _board(mapId, type);
      final v = MapViewportPolicy.resolve(board, _phone);
      return (
        board: board,
        v: v,
        toScreen: boardProjection(
          center: v.center,
          zoom: v.fitZoom + extraZoom,
          size: _phone,
        ),
      );
    }

    String? tapAt(
      ({MapBoard board, MapViewport v, Offset Function(LatLng) toScreen}) s,
      LatLng p, {
      Offset nudge = Offset.zero,
    }) => hitTestBoard(
      board: s.board,
      viewport: s.v,
      tap: p,
      tapOnScreen: s.toScreen(p) + nudge,
      toScreen: s.toScreen,
    );

    test('tapping the Vatican answers the Vatican, not Italy', () {
      final s = setup('europe_countries', MapInteractionType.polygon);
      final vatican = _id(s.board, 'Vaticano');
      expect(tapAt(s, s.board.metrics[vatican]!.anchor), vatican);
    });

    test('tapping inland Italy answers Italy once zoomed in a level, even '
        'with the San Marino dot nearby', () {
      // Florence is ~6 px from San Marino at the fit zoom (truly ambiguous
      // for a finger) and ~11 px one level in.
      final s = setup(
        'europe_countries',
        MapInteractionType.polygon,
        extraZoom: 1,
      );
      expect(tapAt(s, const LatLng(43.77, 11.25)), _id(s.board, 'Itália'));
    });

    test('Lesotho, surrounded by South Africa, is its own answer', () {
      final s = setup('africa_countries', MapInteractionType.polygon);
      expect(tapAt(s, const LatLng(-29.5, 28.2)), _id(s.board, 'Lesoto'));
    });

    test('the open sea is nobody', () {
      final s = setup('europe_countries', MapInteractionType.polygon);
      expect(tapAt(s, const LatLng(38.0, -15.0)), isNull);
    });

    test('a point is hit well outside its small drawn dot', () {
      final s = setup('world_straits', MapInteractionType.point);
      final gibraltar = _id(s.board, 'Estreito de Gibraltar');
      final anchor = s.board.metrics[gibraltar]!.anchor;
      // Westward, into the Atlantic: nothing else is nearer on that side.
      const nudge = Offset(-(MapMarkerSizes.pointVisualRadius + 6), 0);
      expect(nudge.distance, lessThan(MapMarkerSizes.pointHitRadius));
      expect(tapAt(s, anchor, nudge: nudge), gibraltar);
    });

    test('between two points the nearer one wins', () {
      final s = setup('world_straits', MapInteractionType.point, extraZoom: 3);
      final bosporus = _id(s.board, 'Bósforo');
      final dardanelles = _id(s.board, 'Dardanelos');
      final a = s.toScreen(s.board.metrics[bosporus]!.anchor);
      final b = s.toScreen(s.board.metrics[dardanelles]!.anchor);
      final nearA = a + (b - a) * 0.3;
      expect(
        hitTestBoard(
          board: s.board,
          viewport: s.v,
          tap: s.board.metrics[bosporus]!.anchor,
          tapOnScreen: nearA,
          toScreen: s.toScreen,
        ),
        bosporus,
      );
    });

    test('a line is hit near its stroke', () {
      final s = setup('europe_rivers', MapInteractionType.line);
      final danube = s.board.regions.firstWhere((r) => r.name == 'Danúbio');
      final mid = danube.parts.first[danube.parts.first.length ~/ 2];
      expect(tapAt(s, mid, nudge: const Offset(0, 6)), danube.id);
    });
  });

  group(BoardCameraConstraint, () {
    const bounds = GeoBox(west: -25, south: 34, east: 50, north: 72);
    MapCamera camera(LatLng center, double zoom) => MapCamera(
      crs: const Epsg3857(),
      center: center,
      zoom: zoom,
      rotation: 0,
      nonRotatedSize: _phone,
    );

    test('a board narrower than the screen stays centered', () {
      const constraint = BoardCameraConstraint(bounds: bounds);
      final c = constraint.constrain(camera(const LatLng(10, -60), 1));
      final expected = constraint.constrain(camera(const LatLng(55, 12), 1));
      expect(c.center.longitude, closeTo(expected.center.longitude, 1e-6));
    });

    test('zoomed in, the camera cannot be dragged past the board edge', () {
      const constraint = BoardCameraConstraint(bounds: bounds);
      final c = constraint.constrain(camera(const LatLng(0, -120), 5));
      final screenLeft = c.projectAtZoom(c.center).dx - _phone.width / 2;
      final boardLeft = c.projectAtZoom(const LatLng(72, -25)).dx;
      expect(screenLeft, greaterThanOrEqualTo(boardLeft - 0.5));
    });
  });
}
