import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:aura/features/map_quiz/domain/entities/map_viewport_spec.dart';

/// Keeps the board on screen.
///
/// Per axis: when the board (plus [padding]) is narrower than the screen,
/// it's centered on that axis; when it's wider (zoomed in), the camera can
/// pan only until the board's edge reaches the screen's edge. So the user
/// can never drag Europe away and stare at empty ocean, and a world board
/// -- bounded at ±180° -- never shows the repeated copies of the planet
/// flutter_map would draw past the antimeridian.
///
/// flutter_map's own `CameraConstraint.contain` gives up (returns null) when
/// the bounds are smaller than the screen on either axis, which is exactly
/// the fitted state of every board.
class BoardCameraConstraint extends CameraConstraint {
  const BoardCameraConstraint({
    required this.bounds,
    this.padding = 0,
    this.reservedRight = 0,
  });

  final GeoBox bounds;
  final double padding;

  /// Room kept for the map's buttons on the right (see
  /// `MapViewport.reservedRight`), counted as extra board width: a centered
  /// board settles left of the buttons, not under them.
  final double reservedRight;

  @override
  MapCamera constrain(MapCamera camera) {
    final nw = camera.projectAtZoom(LatLng(bounds.north, bounds.west));
    final se = camera.projectAtZoom(LatLng(bounds.south, bounds.east));
    final left = nw.dx - padding;
    final right = se.dx + padding + reservedRight;
    final top = nw.dy - padding, bottom = se.dy + padding;
    final half = camera.size / 2;
    final c = camera.projectAtZoom(camera.center);

    double axis(double v, double lo, double hi, double halfSpan) =>
        hi - lo <= halfSpan * 2
        ? (lo + hi) / 2
        : v.clamp(lo + halfSpan, hi - halfSpan);

    final constrained = Offset(
      axis(c.dx, left, right, half.width),
      axis(c.dy, top, bottom, half.height),
    );
    if ((constrained - c).distance < 0.01) return camera;
    return camera.withPosition(center: camera.unprojectAtZoom(constrained));
  }

  @override
  bool operator ==(Object other) =>
      other is BoardCameraConstraint &&
      other.bounds == bounds &&
      other.padding == padding &&
      other.reservedRight == reservedRight;

  @override
  int get hashCode => Object.hash(bounds, padding, reservedRight);
}
