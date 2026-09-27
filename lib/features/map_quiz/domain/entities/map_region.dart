import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class MapRegion extends Equatable {
  const MapRegion({
    required this.id,
    required this.name,
    required this.parts,
    this.holes = const [],
  });

  final String id;
  final String name;

  /// Outer rings (polygons), lines, or a single point per part.
  final List<List<LatLng>> parts;

  /// Interior rings of each polygon part, index-aligned with [parts]:
  /// `holes[i]` are the holes of `parts[i]`. Empty for lines and points,
  /// and may be shorter than [parts] when trailing parts have none.
  ///
  /// They matter for enclaves: Italy's polygon has holes where the Vatican
  /// and San Marino are, and dropping them painted Italy over both and
  /// sent every tap on them to Italy.
  final List<List<List<LatLng>>> holes;

  List<List<LatLng>> holesOf(int partIndex) =>
      partIndex < holes.length ? holes[partIndex] : const [];

  @override
  List<Object?> get props => [id, name, parts, holes];
}
