import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:aura/features/map_quiz/domain/entities/map_interaction_type.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';
import 'package:aura/features/map_quiz/domain/entities/map_viewport_spec.dart';

/// Web Mercator at zoom 0 (a 256 px world), the same projection flutter_map
/// draws with. Everything size-related on the board is measured here once;
/// at zoom z a length is simply multiplied by 2^z.
abstract final class WebMercator {
  static const maxLatitude = 85.0511287798;
  static const worldSize = 256.0;

  static double x(double lng) => (lng + 180) / 360 * worldSize;

  static double y(double lat) {
    final s = math.sin(lat.clamp(-maxLatitude, maxLatitude) * math.pi / 180);
    return (0.5 - math.log((1 + s) / (1 - s)) / (4 * math.pi)) * worldSize;
  }

  static double lng(double x) => x / worldSize * 360 - 180;

  static double lat(double y) {
    final n = math.pi - 2 * math.pi * y / worldSize;
    return 180 / math.pi * math.atan(0.5 * (math.exp(n) - math.exp(-n)));
  }
}

/// What the viewport policy needs to know about one answer, measured once
/// at zoom 0.
class RegionMetrics extends Equatable {
  const RegionMetrics({
    required this.anchor,
    required this.size,
    required this.area,
  });

  /// Where a point marker (or a stand-in marker for a region too small to
  /// tap) goes: the point itself, or the centroid of the region's main part.
  final LatLng anchor;

  /// Typical on-screen size at zoom 0, in px: the geometric mean of the
  /// main part's bounding box for polygons (so a long thin Chile isn't
  /// judged by its length alone), the longer side for lines, 0 for points.
  final double size;

  /// Total projected area at zoom 0, used only to paint big regions first
  /// and small ones on top.
  final double area;

  @override
  List<Object?> get props => [anchor, size, area];
}

/// The quiz's geometry, prepared once per activity: everything the policy,
/// the painter and the hit tester need, independent of screen size.
class MapBoard extends Equatable {
  const MapBoard({
    required this.regions,
    required this.background,
    required this.interactionType,
    required this.spec,
    required this.lngOffset,
    required this.bounds,
    required this.metrics,
    required this.paintOrder,
  });

  /// The answers, in the board's longitude frame (see [lngOffset]).
  final List<MapRegion> regions;
  final List<MapRegion> background;
  final MapInteractionType interactionType;
  final MapViewportSpec spec;

  /// Degrees added to every longitude. Non-zero only when the answers wrap
  /// around the antimeridian (Oceania, the Aleutians): the whole board is
  /// turned so it's contiguous around 0°. In Mercator that is a pure
  /// horizontal shift -- no distortion -- and with no tiles or labels on
  /// the map it isn't visible, while it lets bounds and camera limits work
  /// with plain west < east boxes.
  final double lngOffset;

  /// Box around every answer (restricted to the spec's focus), in the
  /// board's frame. Framing always starts from this -- never from the
  /// current target, which would give the answer away.
  final GeoBox bounds;

  final Map<String, RegionMetrics> metrics;

  /// Region ids from largest to smallest area: painted in this order (and
  /// hit-tested in reverse) so an enclave sits on top of its surroundings.
  final List<String> paintOrder;

  @override
  List<Object?> get props => [
    regions,
    background,
    interactionType,
    spec,
    lngOffset,
    bounds,
    metrics,
    paintOrder,
  ];
}

class MapBoardInput {
  const MapBoardInput({
    required this.regions,
    required this.background,
    required this.interactionType,
    required this.spec,
  });

  final List<MapRegion> regions;
  final List<MapRegion> background;
  final MapInteractionType interactionType;
  final MapViewportSpec spec;
}

/// Top-level so it can run in `compute()`: on the world map this walks
/// ~37k vertices, which shouldn't happen on the UI thread.
MapBoard buildMapBoard(MapBoardInput input) {
  final spec = input.spec;
  final focus = spec.focus;

  // 1. Which vertices define the frame: every answer's vertices inside the
  //    focus, or all of them for an answer with nothing inside it.
  final framing = <LatLng>[];
  for (final region in input.regions) {
    final all = [for (final part in region.parts) ...part];
    final inside = focus == null
        ? all
        : all.where((p) => focus.contains(p.longitude, p.latitude)).toList();
    framing.addAll(inside.isEmpty ? all : inside);
  }

  // 2. Antimeridian: turn the board if those vertices wrap around ±180°.
  final offset = spec.scope == MapScope.world
      ? 0.0
      : _antimeridianOffset(framing.map((p) => p.longitude));

  List<MapRegion> rotate(List<MapRegion> regions) => offset == 0
      ? regions
      : [
          for (final r in regions)
            MapRegion(
              id: r.id,
              name: r.name,
              parts: [for (final part in r.parts) _rotateRing(part, offset)],
              holes: [
                for (final hs in r.holes)
                  [for (final h in hs) _rotateRing(h, offset)],
              ],
            ),
        ];

  final regions = rotate(input.regions);
  final background = rotate(input.background);

  var west = double.infinity, east = -double.infinity;
  var south = double.infinity, north = -double.infinity;
  for (final p in framing) {
    final lng = _wrap(p.longitude + offset);
    west = math.min(west, lng);
    east = math.max(east, lng);
    south = math.min(south, p.latitude);
    north = math.max(north, p.latitude);
  }
  if (framing.isEmpty) {
    west = -180;
    east = 180;
    south = -60;
    north = 80;
  }

  // 3. Per-answer measurements at zoom 0, taken in the original frame
  //    (where the focus box is defined); only the anchor is turned.
  final metrics = <String, RegionMetrics>{
    for (final region in input.regions)
      region.id: () {
        final m = _measure(region, input.interactionType, focus);
        return RegionMetrics(
          anchor: LatLng(m.anchor.latitude, _wrap(m.anchor.longitude + offset)),
          size: m.size,
          area: m.area,
        );
      }(),
  };
  final paintOrder = [for (final r in regions) r.id]
    ..sort((a, b) => metrics[b]!.area.compareTo(metrics[a]!.area));

  return MapBoard(
    regions: regions,
    background: background,
    interactionType: input.interactionType,
    spec: spec,
    lngOffset: offset,
    bounds: GeoBox(west: west, south: south, east: east, north: north),
    metrics: metrics,
    paintOrder: paintOrder,
  );
}

double _wrap(double lng) {
  var l = (lng + 180) % 360;
  if (l < 0) l += 360;
  return l - 180;
}

/// 0 when the longitudes fit in one arc that doesn't cross ±180°; otherwise
/// the shift that centers that arc on 0°. The arc is the complement of the
/// largest empty gap between the sorted longitudes.
double _antimeridianOffset(Iterable<double> lngs) {
  final sorted = lngs.map(_wrap).toSet().toList()..sort();
  if (sorted.length < 2) return 0;
  // The gap that wraps around ±180° (from the last longitude to the first).
  var bestGap = sorted.first + 360 - sorted.last;
  var arcStart = sorted.first;
  var wraps = false;
  for (var i = 1; i < sorted.length; i++) {
    final gap = sorted[i] - sorted[i - 1];
    if (gap > bestGap) {
      bestGap = gap;
      arcStart = sorted[i];
      wraps = true;
    }
  }
  final span = 360 - bestGap;
  // Nothing to fix, or the answers circle nearly the whole globe anyway.
  if (!wraps || span > 300) return 0;
  final center = arcStart + span / 2;
  return -_wrap(center);
}

/// Shifts a ring and keeps it continuous: each vertex takes the copy
/// (±360°) nearest to the previous one, so a ring never jumps across the
/// map and smears a horizontal band over it.
List<LatLng> _rotateRing(List<LatLng> ring, double offset) {
  if (ring.isEmpty) return ring;
  final out = <LatLng>[];
  var prev = _wrap(ring.first.longitude + offset);
  out.add(LatLng(ring.first.latitude, prev));
  for (final p in ring.skip(1)) {
    var lng = p.longitude + offset;
    while (lng - prev > 180) {
      lng -= 360;
    }
    while (prev - lng > 180) {
      lng += 360;
    }
    out.add(LatLng(p.latitude, lng));
    prev = lng;
  }
  return out;
}

RegionMetrics _measure(
  MapRegion region,
  MapInteractionType type,
  GeoBox? focus,
) {
  if (type == MapInteractionType.point) {
    final p = region.parts.first.first;
    return RegionMetrics(anchor: p, size: 0, area: 0);
  }

  ({double w, double h, double area, List<LatLng> ring}) box(
    List<LatLng> ring,
  ) {
    var x0 = double.infinity, x1 = -double.infinity;
    var y0 = double.infinity, y1 = -double.infinity;
    var area = 0.0;
    for (var i = 0; i < ring.length; i++) {
      final x = WebMercator.x(ring[i].longitude);
      final y = WebMercator.y(ring[i].latitude);
      x0 = math.min(x0, x);
      x1 = math.max(x1, x);
      y0 = math.min(y0, y);
      y1 = math.max(y1, y);
      final n = ring[(i + 1) % ring.length];
      area += x * WebMercator.y(n.latitude) - WebMercator.x(n.longitude) * y;
    }
    return (w: x1 - x0, h: y1 - y0, area: area.abs() / 2, ring: ring);
  }

  final boxes = region.parts.map(box).toList();
  if (type == MapInteractionType.line) {
    var x0 = double.infinity, x1 = -double.infinity;
    var y0 = double.infinity, y1 = -double.infinity;
    for (final p in region.parts.expand((r) => r)) {
      x0 = math.min(x0, WebMercator.x(p.longitude));
      x1 = math.max(x1, WebMercator.x(p.longitude));
      y0 = math.min(y0, WebMercator.y(p.latitude));
      y1 = math.max(y1, WebMercator.y(p.latitude));
    }
    final longest = region.parts.reduce((a, b) => a.length >= b.length ? a : b);
    return RegionMetrics(
      anchor: longest[longest.length ~/ 2],
      size: math.max(x1 - x0, y1 - y0),
      area: 0,
    );
  }

  // Polygon: judged by its main part -- the largest one inside the focus
  // (mainland France, not Réunion), or the largest overall.
  bool inFocus(List<LatLng> ring) =>
      focus == null || ring.any((p) => focus.contains(p.longitude, p.latitude));
  final candidates = boxes.where((b) => inFocus(b.ring)).toList();
  final main = (candidates.isEmpty ? boxes : candidates).reduce(
    (a, b) => a.area >= b.area ? a : b,
  );
  final holesArea = region.holes
      .expand((hs) => hs)
      .fold<double>(0, (sum, h) => sum + box(h).area);
  return RegionMetrics(
    anchor: _centroid(main.ring),
    size: math.sqrt(main.w * main.h),
    area: boxes.fold<double>(0, (sum, b) => sum + b.area) - holesArea,
  );
}

LatLng _centroid(List<LatLng> ring) {
  var a = 0.0, cx = 0.0, cy = 0.0;
  for (var i = 0; i < ring.length; i++) {
    final p = ring[i], q = ring[(i + 1) % ring.length];
    final cross = p.longitude * q.latitude - q.longitude * p.latitude;
    a += cross;
    cx += (p.longitude + q.longitude) * cross;
    cy += (p.latitude + q.latitude) * cross;
  }
  if (a.abs() < 1e-12) {
    final lat = ring.map((p) => p.latitude).reduce((s, v) => s + v);
    final lng = ring.map((p) => p.longitude).reduce((s, v) => s + v);
    return LatLng(lat / ring.length, lng / ring.length);
  }
  return LatLng(cy / (3 * a), cx / (3 * a));
}
