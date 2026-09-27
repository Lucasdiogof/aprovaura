import 'dart:math' as math;
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:aura/features/map_quiz/domain/entities/map_board.dart';
import 'package:aura/features/map_quiz/domain/entities/map_interaction_type.dart';
import 'package:aura/features/map_quiz/domain/entities/map_viewport_spec.dart';

/// Everything about how the board is shown on one screen size. Resolved
/// from the board (all answers) and the map's real size -- never from the
/// current target, so the frame can't hint at the answer, and it doesn't
/// change between questions.
class MapViewport extends Equatable {
  const MapViewport({
    required this.mode,
    required this.center,
    required this.fitZoom,
    required this.minZoom,
    required this.maxZoom,
    required this.padding,
    required this.proxyIds,
    required this.displacements,
    this.reservedRight = 0,
    this.markerRadius = MapViewportPolicy.pointRadius,
  });

  /// [MapViewportMode.locked], [MapViewportMode.constrained] or
  /// [MapViewportMode.world] -- never auto once resolved.
  final MapViewportMode mode;

  /// The initial frame; "Ver tudo" returns exactly here.
  final LatLng center;
  final double fitZoom;
  final double minZoom;
  final double maxZoom;

  /// Space kept between the answers and the map's edge, in px.
  final double padding;

  /// Extra room kept free on the right for the map's own buttons, when the
  /// board would otherwise sit under them (an answer hidden under the zoom
  /// buttons can't be tapped). The board is shifted left by half of it.
  final double reservedRight;

  /// Drawn radius of point markers: smaller on crowded boards (world
  /// capitals) so dots don't merge into blobs. The hit radius stays large.
  final double markerRadius;

  /// Polygons too small to tap even at [maxZoom] (Vatican, Nauru): each gets
  /// a small stand-in marker on its real location, with a hit area larger
  /// than the drawn dot. They still stand for the real country.
  final Set<String> proxyIds;

  /// Markers (points or stand-ins) nudged away from a neighbour they'd
  /// otherwise sit on even at [maxZoom] (Rome/Vatican, Kinshasa/
  /// Brazzaville). Screen-pixel offsets; a leader line keeps showing where
  /// the real place is.
  final Map<String, Offset> displacements;

  bool get isInteractive => mode != MapViewportMode.locked;

  @override
  List<Object?> get props => [
    mode,
    center,
    fitZoom,
    minZoom,
    maxZoom,
    padding,
    proxyIds,
    displacements,
    reservedRight,
    markerRadius,
  ];
}

abstract final class MapViewportPolicy {
  /// A polygon is comfortably tappable from this size (geometric mean of
  /// its bounding box), a line from this length.
  static const minPolygonPx = 22.0;
  static const minLinePx = 24.0;

  /// Two markers closer than this are hard to tell apart with a finger.
  static const minMarkerGapPx = 14.0;

  /// A polygon smaller than this even at max zoom gets a stand-in marker.
  static const proxyBelowPx = 16.0;

  /// Markers still closer than this at max zoom are nudged apart by
  /// [displacementPx].
  static const displaceBelowPx = 10.0;
  static const displacementPx = 18.0;

  /// How many zoom levels past the fit a constrained board can go.
  static const maxConstrainedAllowance = 3.0;
  static const minConstrainedAllowance = 1.0;

  /// World boards: at least this much zoom, at most this much.
  static const minWorldAllowance = 2.0;
  static const maxWorldAllowance = 5.0;

  /// Margin around the answers. Kept small on phones -- every pixel of a
  /// portrait world map matters -- and roomier on bigger screens.
  static double paddingFor(Size size) =>
      size.shortestSide < 600 ? 10 : (size.shortestSide < 900 ? 20 : 28);

  /// Drawn radius of point markers on normal and on crowded boards.
  static const pointRadius = 5.5;
  static const crowdedPointRadius = 4.0;

  /// [controls] is the bottom-right corner the map's buttons take, if any.
  static MapViewport resolve(
    MapBoard board,
    Size size, {
    Size controls = Size.zero,
  }) {
    final padding = paddingFor(size);
    final b = board.bounds;
    final x0 = WebMercator.x(b.west), x1 = WebMercator.x(b.east);
    final y0 = WebMercator.y(b.north), y1 = WebMercator.y(b.south);

    double fit(double reserved) {
      final usableW = math.max(size.width - 2 * padding - reserved, 1.0);
      final usableH = math.max(size.height - 2 * padding, 1.0);
      // A single point has no extent: frame it at a sensible regional zoom.
      return math.min(
        math.min(
          x1 - x0 > 1e-9 ? _log2(usableW / (x1 - x0)) : 6.0,
          y1 - y0 > 1e-9 ? _log2(usableH / (y1 - y0)) : 6.0,
        ),
        8.0,
      );
    }

    var reservedRight = 0.0;
    var fitZoom = fit(0);
    if (controls != Size.zero) {
      // Would the centered board reach under the buttons' corner?
      final scale = math.pow(2, fitZoom).toDouble();
      final boardRight = (size.width + (x1 - x0) * scale) / 2;
      final boardBottom = (size.height + (y1 - y0) * scale) / 2;
      if (boardRight > size.width - controls.width &&
          boardBottom > size.height - controls.height) {
        reservedRight = controls.width;
        fitZoom = fit(reservedRight);
      }
    }
    // The camera looks a little right of the board's center, so the board
    // itself sits centered in the room left of the buttons.
    final shift = reservedRight / 2 / math.pow(2, fitZoom);
    final center = LatLng(
      WebMercator.lat((y0 + y1) / 2),
      WebMercator.lng((x0 + x1) / 2 + shift),
    );

    final type = board.interactionType;
    final capZoom = fitZoom + maxConstrainedAllowance;
    double scaleAt(double zoom) => math.pow(2, zoom).toDouble();

    // Stand-ins for polygons too small to tap even fully zoomed in.
    final proxyIds = <String>{
      if (type == MapInteractionType.polygon)
        for (final r in board.regions)
          if (board.metrics[r.id]!.size * scaleAt(capZoom) < proxyBelowPx) r.id,
    };

    // Markers on the board: every point, plus the stand-ins.
    final markerIds = type == MapInteractionType.point
        ? [for (final r in board.regions) r.id]
        : [
            for (final r in board.regions)
              if (proxyIds.contains(r.id)) r.id,
          ];
    Offset z0(String id) {
      final a = board.metrics[id]!.anchor;
      return Offset(WebMercator.x(a.longitude), WebMercator.y(a.latitude));
    }

    final displacements = <String, Offset>{};
    var closestKept = double.infinity;
    for (var i = 0; i < markerIds.length; i++) {
      for (var j = i + 1; j < markerIds.length; j++) {
        final a = z0(markerIds[i]), bb = z0(markerIds[j]);
        final d = (a - bb).distance;
        if (d * scaleAt(capZoom) < displaceBelowPx) {
          // Nudge the later one (stable across runs) away from the other.
          final id = markerIds[j];
          if (!displacements.containsKey(id) &&
              !displacements.containsKey(markerIds[i])) {
            final dir = d > 1e-12
                ? (bb - a) / d
                : const Offset(math.sqrt1_2, -math.sqrt1_2);
            displacements[id] = dir * displacementPx;
          }
        } else {
          closestKept = math.min(closestKept, d);
        }
      }
    }

    // How much zoom the smallest remaining target needs to be tappable.
    var need = 0.0;
    for (final r in board.regions) {
      if (proxyIds.contains(r.id)) continue;
      final m = board.metrics[r.id]!;
      final minPx = switch (type) {
        MapInteractionType.polygon => minPolygonPx,
        MapInteractionType.line => minLinePx,
        MapInteractionType.point => 0.0,
      };
      if (minPx == 0) continue;
      final atFit = m.size * scaleAt(fitZoom);
      if (atFit > 0) need = math.max(need, _log2(minPx / atFit));
    }
    if (closestKept.isFinite && closestKept > 0) {
      need = math.max(
        need,
        _log2(minMarkerGapPx / (closestKept * scaleAt(fitZoom))),
      );
    }

    final forced = board.spec.mode;
    final mode = forced != MapViewportMode.auto
        ? forced
        : board.spec.scope == MapScope.world
        ? MapViewportMode.world
        : need <= 0
        ? MapViewportMode.locked
        : MapViewportMode.constrained;

    final maxZoom = switch (mode) {
      MapViewportMode.locked => fitZoom,
      MapViewportMode.constrained =>
        fitZoom +
            (need + 0.25).clamp(
              minConstrainedAllowance,
              maxConstrainedAllowance,
            ),
      MapViewportMode.world || MapViewportMode.auto =>
        fitZoom + (need + 0.25).clamp(minWorldAllowance, maxWorldAllowance),
    };

    return MapViewport(
      mode: mode,
      center: center,
      fitZoom: fitZoom,
      minZoom: fitZoom,
      maxZoom: maxZoom,
      padding: padding,
      proxyIds: proxyIds,
      displacements: displacements,
      reservedRight: reservedRight,
      markerRadius: _markerRadius(board, markerIds, fitZoom, z0),
    );
  }

  /// Smaller dots when more than a third of the points would touch a
  /// neighbour at the initial frame.
  static double _markerRadius(
    MapBoard board,
    List<String> markerIds,
    double fitZoom,
    Offset Function(String) z0,
  ) {
    if (board.interactionType != MapInteractionType.point ||
        markerIds.isEmpty) {
      return pointRadius;
    }
    final scale = math.pow(2, fitZoom).toDouble();
    const touching = pointRadius * 2 + 2;
    var crowded = 0;
    for (final a in markerIds) {
      final pa = z0(a);
      if (markerIds.any(
        (b) => b != a && (z0(b) - pa).distance * scale < touching,
      )) {
        crowded++;
      }
    }
    return crowded > markerIds.length / 3 ? crowdedPointRadius : pointRadius;
  }

  static double _log2(double v) => math.log(v) / math.ln2;
}
