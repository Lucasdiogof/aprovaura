import 'package:equatable/equatable.dart';

/// How much of the planet an activity is about. It decides only framing,
/// never which regions are answers.
enum MapScope {
  world,
  continent,
  country,
  region,
  subnational,
  custom;

  static MapScope fromName(String? name) =>
      MapScope.values.where((s) => s.name == name).firstOrNull ??
      MapScope.region;
}

/// How the board behaves once it's framed.
///
/// [auto] lets the viewport policy decide from the real pixel size of the
/// smallest target on the device; the others force a mode.
enum MapViewportMode {
  auto,

  /// A fixed board: no pan, no zoom, no controls. The region already fills
  /// the screen and every target is tappable as it is.
  locked,

  /// Starts on the whole region; allows a few levels of zoom and panning
  /// that can't leave the region.
  constrained,

  /// Answers spread over the planet: the whole world is framed first, then
  /// limited zoom and pan, never wrapping around.
  world;

  static MapViewportMode fromName(String? name) =>
      MapViewportMode.values.where((m) => m.name == name).firstOrNull ??
      MapViewportMode.auto;
}

/// A longitude/latitude box, in degrees. Plain data so the domain doesn't
/// depend on flutter_map's LatLngBounds (which also can't express a box
/// crossing the antimeridian).
class GeoBox extends Equatable {
  const GeoBox({
    required this.west,
    required this.south,
    required this.east,
    required this.north,
  });

  final double west;
  final double south;
  final double east;
  final double north;

  bool contains(double lng, double lat) =>
      lng >= west && lng <= east && lat >= south && lat <= north;

  @override
  List<Object?> get props => [west, south, east, north];
}

/// Per-dataset framing metadata, read from `lib/assets/maps/viewports.json`.
/// Keyed by the dataset (mapId), not by activity title, so every activity
/// drawing the same map (e.g. "Países da Europa" and "Bandeiras da Europa")
/// frames it the same way.
class MapViewportSpec extends Equatable {
  const MapViewportSpec({
    this.scope = MapScope.region,
    this.mode = MapViewportMode.auto,
    this.focus,
  });

  final MapScope scope;
  final MapViewportMode mode;

  /// The part of the planet the board is about. Geometry outside it is
  /// still drawn and still tappable, but doesn't count toward the initial
  /// frame -- so Russia's Asian side, French Guiana or the Canaries don't
  /// turn "Countries of Europe" into a world map. A region with nothing
  /// inside the focus (a remote island country) counts whole: every answer
  /// always stays inside the initial frame.
  final GeoBox? focus;

  static const fallback = MapViewportSpec();

  factory MapViewportSpec.fromJson(Map<String, dynamic> json) {
    final focus = json['focus'] as List<dynamic>?;
    return MapViewportSpec(
      scope: MapScope.fromName(json['scope'] as String?),
      mode: MapViewportMode.fromName(json['mode'] as String?),
      focus: focus == null
          ? null
          : GeoBox(
              west: (focus[0] as num).toDouble(),
              south: (focus[1] as num).toDouble(),
              east: (focus[2] as num).toDouble(),
              north: (focus[3] as num).toDouble(),
            ),
    );
  }

  @override
  List<Object?> get props => [scope, mode, focus];
}
