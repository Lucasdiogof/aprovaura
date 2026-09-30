import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/subjects/domain/entities/subject.dart';

/// [Subject.key] is how a subject is written outside Dart: the
/// `catalog_nodes.subject` column, the RPCs and `interested_subjects`.
///
/// It used to be the enum's own `name`, which worked only while every
/// subject was a single word. Educação Física is not, so these tests pin
/// the spelling the database actually uses.
void main() {
  group('Subject.key', () {
    test('is the enum name for every single-word subject', () {
      for (final subject in Subject.values) {
        if (subject == Subject.educacaoFisica) continue;
        expect(subject.key, subject.name);
      }
    });

    test('is snake_case for the compound one', () {
      // What is stored in the database; `name` would be educacaoFisica.
      expect(Subject.educacaoFisica.key, 'educacao_fisica');
    });

    test('never repeats, so a key always points at one subject', () {
      final keys = Subject.values.map((s) => s.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('round-trips through fromKey', () {
      for (final subject in Subject.values) {
        expect(Subject.fromKey(subject.key), subject);
      }
    });

    test('an unknown key is null, not a wrong subject', () {
      // A row written by a newer build must not silently become the
      // first subject in the list.
      expect(Subject.fromKey('educacaoFisica'), isNull);
      expect(Subject.fromKey('astrologia'), isNull);
      expect(Subject.fromKey(''), isNull);
    });
  });
}
