import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/map_quiz/l10n/map_region_names.dart';

void main() {
  // Every `nome` of every bundled map, read straight from the assets so a new
  // or renamed region can't ship without its translation.
  final namesInAssets = <String>{
    for (final file in Directory('lib/assets/maps').listSync())
      if (file is File && file.path.endsWith('.geojson'))
        for (final feature
            in (jsonDecode(file.readAsStringSync())
                    as Map<String, dynamic>)['features']
                as List<dynamic>)
          ((feature as Map<String, dynamic>)['properties']
                  as Map<String, dynamic>)['nome']
              as String,
  };

  group('regionNameTranslations', () {
    test('covers every region name in lib/assets/maps', () {
      expect(namesInAssets, isNotEmpty);
      expect(
        namesInAssets.difference(regionNameTranslations.keys.toSet()),
        isEmpty,
      );
    });

    test('has no entry for a name no map uses anymore', () {
      expect(
        regionNameTranslations.keys.toSet().difference(namesInAssets),
        isEmpty,
      );
    });

    test('never maps to a blank name', () {
      for (final MapEntry(:key, :value) in regionNameTranslations.entries) {
        expect(value.$1.trim(), isNotEmpty, reason: '$key (en)');
        expect(value.$2.trim(), isNotEmpty, reason: '$key (es)');
      }
    });
  });

  group('localizedRegionName', () {
    test('returns the pt-BR name untouched in Portuguese', () {
      expect(
        localizedRegionName(
          'Estreito de Cook',
          AppLanguage.portuguese,
          mapId: 'world_straits',
        ),
        'Estreito de Cook',
      );
    });

    test('translates to English and Spanish', () {
      expect(
        localizedRegionName(
          'Estreito de Cook',
          AppLanguage.english,
          mapId: 'world_straits',
        ),
        'Cook Strait',
      );
      expect(
        localizedRegionName(
          'Estreito de Cook',
          AppLanguage.spanish,
          mapId: 'world_straits',
        ),
        'Estrecho de Cook',
      );
    });

    test('resolves a name shared across layers by the layer kind', () {
      expect(
        localizedRegionName(
          'Amazonas',
          AppLanguage.english,
          mapId: 'world_rivers',
        ),
        'Amazon',
      );
      expect(
        localizedRegionName(
          'Amazonas',
          AppLanguage.english,
          mapId: 'brazil_states',
        ),
        'Amazonas',
      );
      expect(
        localizedRegionName(
          'Kuwait',
          AppLanguage.english,
          mapId: 'asia_capitals',
        ),
        'Kuwait City',
      );
      expect(
        localizedRegionName(
          'Kuwait',
          AppLanguage.english,
          mapId: 'asia_countries',
        ),
        'Kuwait',
      );
    });

    test('falls back to the pt-BR name when there is no entry', () {
      expect(
        localizedRegionName(
          'Lugar Inexistente',
          AppLanguage.english,
          mapId: 'world_countries',
        ),
        'Lugar Inexistente',
      );
    });
  });
}
