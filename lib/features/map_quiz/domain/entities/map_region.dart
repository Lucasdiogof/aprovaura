import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class MapRegion extends Equatable {
  const MapRegion({required this.id, required this.name, required this.parts});

  final String id;
  final String name;
  final List<List<LatLng>> parts;

  @override
  List<Object?> get props => [id, name, parts];
}
