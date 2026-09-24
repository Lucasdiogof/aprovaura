import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/catalog/presentation/catalog_node_icon.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

void main() {
  group(catalogNodeIcon, () {
    test('maps a known glyph to its Material icon', () {
      expect(
        catalogNodeIcon('💧', Subject.geografia),
        Icons.water_drop_outlined,
      );
    });

    test('maps a variation-selector-less glyph the same as its VS16 form', () {
      expect(catalogNodeIcon('⛰️', Subject.geografia), Icons.terrain_outlined);
      expect(catalogNodeIcon('⛰', Subject.geografia), Icons.terrain_outlined);
    });

    test('maps any flag emoji to the flag icon', () {
      expect(catalogNodeIcon('🇧🇷', Subject.geografia), Icons.flag_outlined);
      expect(catalogNodeIcon('🇺🇸', Subject.geografia), Icons.flag_outlined);
    });

    test('falls back to the subject icon for an unknown glyph', () {
      expect(
        catalogNodeIcon('🦄', Subject.matematica),
        Subject.matematica.icon,
      );
    });

    test('falls back to the subject icon when there is no icon at all', () {
      expect(catalogNodeIcon(null, Subject.biologia), Subject.biologia.icon);
    });
  });
}
