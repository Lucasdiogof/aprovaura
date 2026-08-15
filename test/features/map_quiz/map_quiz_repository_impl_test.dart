import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/features/map_quiz/data/map_quiz_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapQuizRepositoryImpl', () {
    final repository = MapQuizRepositoryImpl();

    test('loads all 27 Brazilian states with valid geometry', () async {
      final result = await repository.loadRegions('brazil_states');
      final regions = switch (result) {
        Success(:final data) => data,
        Error(:final failure) => fail('expected Success, got $failure'),
      };

      expect(regions, hasLength(27));
      for (final region in regions) {
        expect(region.id, isNotEmpty);
        expect(region.name, isNotEmpty);
        expect(region.parts, isNotEmpty);
        for (final part in region.parts) {
          expect(part.length, greaterThanOrEqualTo(3));
        }
      }
    });

    test('parses known state correctly', () async {
      final result = await repository.loadRegions('brazil_states');
      final regions = switch (result) {
        Success(:final data) => data,
        Error(:final failure) => fail('expected Success, got $failure'),
      };

      final sp = regions.singleWhere((region) => region.id == 'SP');
      expect(sp.name, 'São Paulo');
    });

    test('returns Error for an unknown map id', () async {
      final result = await repository.loadRegions('does_not_exist');
      expect(result, isA<Error<Object>>());
    });

    test('loads 45 European countries with valid polygon geometry', () async {
      final result = await repository.loadRegions('europe_countries');
      final regions = switch (result) {
        Success(:final data) => data,
        Error(:final failure) => fail('expected Success, got $failure'),
      };

      expect(regions, hasLength(45));
      final france = regions.singleWhere((region) => region.id == 'FRA');
      expect(france.name, 'França');
      for (final region in regions) {
        for (final part in region.parts) {
          expect(part.length, greaterThanOrEqualTo(4));
        }
      }
    });

    test('loads 15 European rivers with valid line geometry', () async {
      final result = await repository.loadRegions('europe_rivers');
      final regions = switch (result) {
        Success(:final data) => data,
        Error(:final failure) => fail('expected Success, got $failure'),
      };

      expect(regions, hasLength(15));
      final danube = regions.singleWhere((region) => region.id == 'danubio');
      expect(danube.name, 'Danúbio');
      for (final region in regions) {
        for (final part in region.parts) {
          expect(part.length, greaterThanOrEqualTo(2));
        }
      }
    });
  });
}
