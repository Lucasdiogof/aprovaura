import 'package:flutter_map/flutter_map.dart';

/// Web Mercator exactly as flutter_map's default, minus the endless
/// repetition of the planet past ±180°. A quiz board is one world: a
/// second copy of Fiji peeking in at the left edge of a world map is just
/// a confusing duplicate answer.
class BoardCrs extends Epsg3857 {
  const BoardCrs();

  @override
  bool get replicatesWorldLongitude => false;
}
