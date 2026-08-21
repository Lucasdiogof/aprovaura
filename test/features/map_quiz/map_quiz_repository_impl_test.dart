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

    test('loads 45 European capitals with valid point geometry', () async {
      final regions = await loadOk('europe_capitals');
      expect(regions, hasLength(45));
      expectValidGeometry(regions, minPoints: 1);
      final france = regions.singleWhere((region) => region.id == 'FRA');
      expect(france.name, 'Paris');
    });

    test(
      'loads 12 South American capitals with valid point geometry',
      () async {
        final regions = await loadOk('south_america_capitals');
        expect(regions, hasLength(12));
        expectValidGeometry(regions, minPoints: 1);
        final brazil = regions.singleWhere((region) => region.id == 'BRA');
        expect(brazil.name, 'Brasília');
      },
    );

    test('loads 51 African capitals with valid point geometry', () async {
      final regions = await loadOk('africa_capitals');
      expect(regions, hasLength(51));
      expectValidGeometry(regions, minPoints: 1);
      final egypt = regions.singleWhere((region) => region.id == 'EGY');
      expect(egypt.name, 'Cairo');
    });

    test('loads 47 Asian capitals with valid point geometry', () async {
      final regions = await loadOk('asia_capitals');
      expect(regions, hasLength(47));
      expectValidGeometry(regions, minPoints: 1);
      final japan = regions.singleWhere((region) => region.id == 'JPN');
      expect(japan.name, 'Tóquio');
    });

    test('loads 15 major European cities with valid point geometry', () async {
      final regions = await loadOk('europe_cities');
      expect(regions, hasLength(15));
      expectValidGeometry(regions, minPoints: 1);
      expect(regions.map((r) => r.name), contains('Paris'));
    });

    test(
      'loads 12 major South American cities with valid point geometry',
      () async {
        final regions = await loadOk('south_america_cities');
        expect(regions, hasLength(12));
        expectValidGeometry(regions, minPoints: 1);
        expect(regions.map((r) => r.name), contains('São Paulo'));
      },
    );

    test('loads 15 major African cities with valid point geometry', () async {
      final regions = await loadOk('africa_cities');
      expect(regions, hasLength(15));
      expectValidGeometry(regions, minPoints: 1);
      expect(regions.map((r) => r.name), contains('Cairo'));
    });

    test('loads 15 major Asian cities with valid point geometry', () async {
      final regions = await loadOk('asia_cities');
      expect(regions, hasLength(15));
      expectValidGeometry(regions, minPoints: 1);
      expect(regions.map((r) => r.name), contains('Tóquio'));
    });

    test(
      'loads 23 North American countries with valid polygon geometry',
      () async {
        final regions = await loadOk('north_america_countries');
        expect(regions, hasLength(23));
        expectValidGeometry(regions, minPoints: 4);
        final mexico = regions.singleWhere((region) => region.id == 'MEX');
        expect(mexico.name, 'México');
      },
    );

    test('loads 6 North American rivers with valid line geometry', () async {
      final regions = await loadOk('north_america_rivers');
      expect(regions, hasLength(6));
      expectValidGeometry(regions, minPoints: 2);
      expect(regions.map((r) => r.name), contains('Mississippi'));
    });

    test(
      'loads 23 North American capitals with valid point geometry',
      () async {
        final regions = await loadOk('north_america_capitals');
        expect(regions, hasLength(23));
        expectValidGeometry(regions, minPoints: 1);
      },
    );

    test(
      'loads 15 major North American cities with valid point geometry',
      () async {
        final regions = await loadOk('north_america_cities');
        expect(regions, hasLength(15));
        expectValidGeometry(regions, minPoints: 1);
      },
    );

    test('loads 14 Oceania countries with valid polygon geometry', () async {
      final regions = await loadOk('oceania_countries');
      expect(regions, hasLength(14));
      expectValidGeometry(regions, minPoints: 4);
      final australia = regions.singleWhere((region) => region.id == 'AUS');
      expect(australia.name, 'Austrália');
    });

    test('loads 13 Oceania capitals with valid point geometry', () async {
      final regions = await loadOk('oceania_capitals');
      expect(regions, hasLength(13));
      expectValidGeometry(regions, minPoints: 1);
    });

    test('loads 10 major Oceania cities with valid point geometry', () async {
      final regions = await loadOk('oceania_cities');
      expect(regions, hasLength(10));
      expectValidGeometry(regions, minPoints: 1);
    });

    test('loads 194 world countries with valid polygon geometry', () async {
      final regions = await loadOk('world_countries');
      expect(regions, hasLength(194));
      expectValidGeometry(regions, minPoints: 4);
      final brazil = regions.singleWhere((region) => region.id == 'BRA');
      expect(brazil.name, 'Brasil');
    });

    test('loads 191 world capitals with valid point geometry', () async {
      final regions = await loadOk('world_capitals');
      expect(regions, hasLength(191));
      expectValidGeometry(regions, minPoints: 1);
    });

    test('loads 30 major world cities with valid point geometry', () async {
      final regions = await loadOk('world_cities');
      expect(regions, hasLength(30));
      expectValidGeometry(regions, minPoints: 1);
      expect(regions.map((r) => r.name), contains('Tóquio'));
    });

    test('loads 15 great world rivers with valid line geometry', () async {
      final regions = await loadOk('world_rivers');
      expect(regions, hasLength(15));
      expectValidGeometry(regions, minPoints: 2);
      expect(
        regions.map((r) => r.name),
        containsAll(['Nilo', 'Sena', 'Níger', 'Indo']),
      );
    });

    test('loads 15 world relief points with valid point geometry', () async {
      final regions = await loadOk('world_relief');
      expect(regions, hasLength(15));
      expectValidGeometry(regions, minPoints: 1);
      expect(regions.map((r) => r.name), contains('Himalaia'));
    });

    test('loads 12 world soil points with valid point geometry', () async {
      final regions = await loadOk('world_soils');
      expect(regions, hasLength(12));
      expectValidGeometry(regions, minPoints: 1);
    });

    test('loads 9 world ocean currents with valid line geometry', () async {
      final regions = await loadOk('world_currents');
      expect(regions, hasLength(9));
      expectValidGeometry(regions, minPoints: 2);
      expect(regions.map((r) => r.name), contains('Corrente do Brasil'));
    });

    test('loads 17 Brazil relief points with valid point geometry', () async {
      final regions = await loadOk('brazil_relief');
      expect(regions, hasLength(17));
      expectValidGeometry(regions, minPoints: 1);
      expect(regions.map((r) => r.name), contains('Serra do Mar'));
    });

    test('loads 12 Brazil industry points with valid point geometry', () async {
      final regions = await loadOk('brazil_industry');
      expect(regions, hasLength(12));
      expectValidGeometry(regions, minPoints: 1);
    });

    test('loads the lightweight world_countries_bg background with the same '
        'country count as the full-resolution file', () async {
      final full = await loadOk('world_countries');
      final bg = await loadOk('world_countries_bg');
      expect(bg, hasLength(full.length));
    });

    test('loads the lightweight brazil_states_bg background with the same '
        'state count as the full-resolution file', () async {
      final full = await loadOk('brazil_states');
      final bg = await loadOk('brazil_states_bg');
      expect(bg, hasLength(full.length));
    });

    test(
      'returns the exact same cached list on a second call for the same '
      'mapId, instead of re-parsing the asset',
      () async {
        final first = await loadOk('south_america_countries');
        final second = await loadOk('south_america_countries');
        expect(identical(first, second), isTrue);
      },
    );
  });
}
