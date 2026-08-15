import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/map_quiz/data/map_quiz_repository_impl.dart';
import 'package:aura/features/map_quiz/domain/entities/map_region.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repository = MapQuizRepositoryImpl();

  Future<List<MapRegion>> loadOk(String mapId) async {
    final result = await repository.loadRegions(mapId);
    return switch (result) {
      Success(:final data) => data,
      Error(:final failure) => fail(
        'expected Success for $mapId, got $failure',
      ),
    };
  }

  void expectValidGeometry(List<MapRegion> regions, {required int minPoints}) {
    for (final region in regions) {
      expect(region.id, isNotEmpty);
      expect(region.name, isNotEmpty);
      expect(region.parts, isNotEmpty);
      for (final part in region.parts) {
        expect(part.length, greaterThanOrEqualTo(minPoints));
      }
    }
  }

  group('MapQuizRepositoryImpl', () {
    test('returns Error for an unknown map id', () async {
      final result = await repository.loadRegions('does_not_exist');
      expect(result, isA<Error<Object>>());
    });

    test('loads all 27 Brazilian states with valid geometry', () async {
      final regions = await loadOk('brazil_states');
      expect(regions, hasLength(27));
      expectValidGeometry(regions, minPoints: 3);
      final sp = regions.singleWhere((region) => region.id == 'SP');
      expect(sp.name, 'São Paulo');
    });

    test('loads 45 European countries with valid polygon geometry', () async {
      final regions = await loadOk('europe_countries');
      expect(regions, hasLength(45));
      expectValidGeometry(regions, minPoints: 4);
      final france = regions.singleWhere((region) => region.id == 'FRA');
      expect(france.name, 'França');
    });

    test('loads 15 European rivers with valid line geometry', () async {
      final regions = await loadOk('europe_rivers');
      expect(regions, hasLength(15));
      expectValidGeometry(regions, minPoints: 2);
      final danube = regions.singleWhere((region) => region.id == 'danubio');
      expect(danube.name, 'Danúbio');
    });

    test(
      'loads 12 South American countries with valid polygon geometry',
      () async {
        final regions = await loadOk('south_america_countries');
        expect(regions, hasLength(12));
        expectValidGeometry(regions, minPoints: 4);
        final brazil = regions.singleWhere((region) => region.id == 'BRA');
        expect(brazil.name, 'Brasil');
      },
    );

    test('loads 7 South American rivers with valid line geometry', () async {
      final regions = await loadOk('south_america_rivers');
      expect(regions, hasLength(7));
      expectValidGeometry(regions, minPoints: 2);
      final amazonas = regions.singleWhere((region) => region.id == 'amazonas');
      expect(amazonas.name, 'Amazonas');
    });

    test('loads 52 African countries with valid polygon geometry', () async {
      final regions = await loadOk('africa_countries');
      expect(regions, hasLength(52));
      expectValidGeometry(regions, minPoints: 4);
      final egypt = regions.singleWhere((region) => region.id == 'EGY');
      expect(egypt.name, 'Egito');
    });

    test('loads 7 African rivers with valid line geometry', () async {
      final regions = await loadOk('africa_rivers');
      expect(regions, hasLength(7));
      expectValidGeometry(regions, minPoints: 2);
      final nile = regions.singleWhere((region) => region.id == 'nilo');
      expect(nile.name, 'Nilo');
    });

    test('loads 48 Asian countries with valid polygon geometry', () async {
      final regions = await loadOk('asia_countries');
      expect(regions, hasLength(48));
      expectValidGeometry(regions, minPoints: 4);
      final japan = regions.singleWhere((region) => region.id == 'JPN');
      expect(japan.name, 'Japão');
    });

    test('loads 12 Asian rivers with valid line geometry', () async {
      final regions = await loadOk('asia_rivers');
      expect(regions, hasLength(12));
      expectValidGeometry(regions, minPoints: 2);
      final ganges = regions.singleWhere((region) => region.id == 'ganges');
      expect(ganges.name, 'Ganges');
    });
  });
}
