import 'dart:math' as math;
import 'dart:ui';

import 'package:latlong2/latlong.dart';
import 'package:aura/features/map_quiz/domain/entities/map_board.dart';
import 'package:aura/features/map_quiz/domain/entities/map_interaction_type.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';
import 'package:aura/features/map_quiz/presentation/viewport/map_viewport_policy.dart';

/// Visual size versus touch size of the board's markers: the dot is drawn
/// small so a crowded world map stays readable, while the area that
/// accepts a tap is several times larger.
abstract final class MapMarkerSizes {
  static const pointVisualRadius = 5.5;
  static const pointHitRadius = 20.0;
  static const proxyVisualRadius = 4.0;
  static const proxyHitRadius = 16.0;

  /// Over another country, a stand-in only takes taps this close to it.
  static const proxyOverLandRadius = 9.0;
  static const lineHitDistance = 16.0;
}

/// Which answer a tap means. Pure: `toScreen` projects a board coordinate
/// to the screen, so tests don't need a live map.
///
/// Order matters:
/// 1. markers (points, or stand-ins for tiny polygons) -- the nearest one
///    within its hit radius wins, so a tap between two dots goes to the
///    closer one instead of whichever was drawn last (a stand-in yields to
///    the country under the tap unless the tap is right on its dot);
/// 2. polygons, smallest first (the reverse of the paint order), honoring
///    holes -- a tap on the Vatican is the Vatican, not Italy;
/// 3. lines, the nearest within [MapMarkerSizes.lineHitDistance].
String? hitTestBoard({
  required MapBoard board,
  required MapViewport viewport,
  required LatLng tap,
  required Offset tapOnScreen,
  required Offset Function(LatLng) toScreen,
}) {
  final type = board.interactionType;

  final byId = {for (final r in board.regions) r.id: r};

  // 1. Markers: the nearest within its hit radius.
  final isPoint = type == MapInteractionType.point;
  final markerIds = isPoint
      ? board.regions.map((r) => r.id)
      : viewport.proxyIds;
  final hitRadius = isPoint
      ? MapMarkerSizes.pointHitRadius
      : MapMarkerSizes.proxyHitRadius;
  String? nearest;
  var nearestDistance = double.infinity;
  for (final id in markerIds) {
    final anchor = board.metrics[id]!.anchor;
    final onScreen =
        toScreen(anchor) + (viewport.displacements[id] ?? Offset.zero);
    final d = (onScreen - tapOnScreen).distance;
    if (d <= hitRadius && d < nearestDistance) {
      nearest = id;
      nearestDistance = d;
    }
  }
  if (isPoint) return nearest;

  // 2. Polygons, top-most (smallest) first.
  if (type == MapInteractionType.polygon) {
    String? containing;
    for (final id in board.paintOrder.reversed) {
      if (_polygonContains(byId[id]!, tap)) {
        containing = id;
        break;
      }
    }
    // A stand-in marker must not swallow taps meant for the country it
    // sits in (San Marino's dot is a few px from Florence when Europe is
    // zoomed out): inside a real country, it only wins when the tap is on
    // the dot itself; over the sea it keeps its larger hit area.
    if (nearest != null &&
        (containing == null ||
            viewport.proxyIds.contains(containing) ||
            nearestDistance <= MapMarkerSizes.proxyOverLandRadius)) {
      return nearest;
    }
    return containing;
  }

  // 3. Lines.
  if (type == MapInteractionType.line) {
    String? best;
    var bestDistance = double.infinity;
    for (final region in board.regions) {
      for (final part in region.parts) {
        for (var i = 1; i < part.length; i++) {
          final d = _segmentDistance(
            tapOnScreen,
            toScreen(part[i - 1]),
            toScreen(part[i]),
          );
          if (d < bestDistance) {
            bestDistance = d;
            best = region.id;
          }
        }
      }
    }
    return bestDistance <= MapMarkerSizes.lineHitDistance ? best : null;
  }
  return null;
}

bool _polygonContains(MapRegion region, LatLng p) {
  for (var i = 0; i < region.parts.length; i++) {
    if (_ringContains(region.parts[i], p) &&
        !region.holesOf(i).any((hole) => _ringContains(hole, p))) {
      return true;
    }
  }
  return false;
}

bool _ringContains(List<LatLng> ring, LatLng p) {
  var inside = false;
  final x = p.longitude, y = p.latitude;
  for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    final xi = ring[i].longitude, yi = ring[i].latitude;
    final xj = ring[j].longitude, yj = ring[j].latitude;
    if ((yi > y) != (yj > y) && x < (xj - xi) * (y - yi) / (yj - yi) + xi) {
      inside = !inside;
    }
  }
  return inside;
}

double _segmentDistance(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 == 0) return (p - a).distance;
  final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(0.0, 1.0);
  return (p - (a + ab * t)).distance;
}

/// Pure projection matching flutter_map's Web Mercator camera, for tests
/// and for code that needs screen positions without a live MapCamera.
Offset Function(LatLng) boardProjection({
  required LatLng center,
  required double zoom,
  required Size size,
}) {
  final scale = math.pow(2, zoom).toDouble();
  final cx = WebMercator.x(center.longitude) * scale;
  final cy = WebMercator.y(center.latitude) * scale;
  return (p) => Offset(
    WebMercator.x(p.longitude) * scale - cx + size.width / 2,
    WebMercator.y(p.latitude) * scale - cy + size.height / 2,
  );
}
