import 'package:flutter_test/flutter_test.dart';
import 'package:aura/shared/utils/validators.dart';

void main() {
  group(isValidEmail, () {
    test('returns true for a plain address', () {
      expect(isValidEmail('usuario@gmail.com'), isTrue);
    });

    test('returns true for an address with a dot in the local part', () {
      expect(isValidEmail('nome.sobrenome@gmail.com'), isTrue);
    });

    test('returns true for an address with a plus tag', () {
      expect(isValidEmail('usuario+teste@gmail.com'), isTrue);
    });

    test('returns true for an address with a subdomain', () {
      expect(isValidEmail('usuario@mail.exemplo.com.br'), isTrue);
    });

    test('returns true for an address with a numeric domain label', () {
      expect(isValidEmail('usuario@123.com'), isTrue);
    });

    test('returns true when surrounded by leading/trailing whitespace', () {
      expect(isValidEmail('  usuario@gmail.com  '), isTrue);
    });

    test('returns false for a bare username with no @', () {
      expect(isValidEmail('usuario'), isFalse);
    });

    test('returns false when the domain is missing after @', () {
      expect(isValidEmail('usuario@'), isFalse);
    });

    test('returns false when the local part is missing before @', () {
      expect(isValidEmail('@gmail.com'), isFalse);
    });

    test('returns false when the domain has no top-level part', () {
      expect(isValidEmail('usuario@gmail'), isFalse);
    });

    test('returns false for a doubled @ symbol', () {
      expect(isValidEmail('usuario@@gmail.com'), isFalse);
    });

    test('returns false for an address containing a space', () {
      expect(isValidEmail('usuario nome@gmail.com'), isFalse);
    });

    test('returns false for a domain starting with a hyphen', () {
      expect(isValidEmail('usuario@-gmail.com'), isFalse);
    });

    test('returns false for a domain label ending with a hyphen', () {
      expect(isValidEmail('usuario@gmail-.com'), isFalse);
    });

    test('returns false for an empty string', () {
      expect(isValidEmail(''), isFalse);
    });

    test('returns false for a string made only of spaces', () {
      expect(isValidEmail('   '), isFalse);
    });

    test('returns true for a very long but well-formed local part', () {
      final local = 'a' * 60;
      expect(isValidEmail('$local@gmail.com'), isTrue);
    });
  });

  group(isPasswordProvided, () {
    test('returns true for a non-empty password', () {
      expect(isPasswordProvided('senha123'), isTrue);
    });

    test('returns true for a single-character password', () {
      expect(isPasswordProvided('a'), isTrue);
    });

    test('returns false for an empty string', () {
      expect(isPasswordProvided(''), isFalse);
    });

    test('returns true for a whitespace-only value, matching current behavior '
        '(this validator only checks presence, not blankness)', () {
      expect(isPasswordProvided('   '), isTrue);
    });
  });

  group(isNameProvided, () {
    test('returns true for a full name', () {
      expect(isNameProvided('Lucas Diogo'), isTrue);
    });

    test('returns true for a name with "da"/"dos" particles', () {
      expect(isNameProvided('João da Silva dos Santos'), isTrue);
    });

    test('returns true for a name with an apostrophe', () {
      expect(isNameProvided("D'Angelo Souza"), isTrue);
    });

    test('returns true for a hyphenated name', () {
      expect(isNameProvided('Ana-Maria Costa-Lima'), isTrue);
    });

    test('returns true for a name with accented characters', () {
      expect(isNameProvided('José Ápio Cunhã'), isTrue);
    });

    test('returns true for a single-word name', () {
      expect(isNameProvided('Lucas'), isTrue);
    });

    test('returns true for a name that is only digits, since this '
        'validator only checks presence, not character composition', () {
      expect(isNameProvided('123456'), isTrue);
    });

    test('returns false for an empty string', () {
      expect(isNameProvided(''), isFalse);
    });

    test('returns false for a single space', () {
      expect(isNameProvided(' '), isFalse);
    });

    test('returns false for multiple spaces', () {
      expect(isNameProvided('     '), isFalse);
    });

    test('returns true when there is real content padded with spaces', () {
      expect(isNameProvided('  Lucas Diogo  '), isTrue);
    });
  });

  group(doPasswordsMatch, () {
    test('returns true for two identical passwords', () {
      expect(doPasswordsMatch('senha123', 'senha123'), isTrue);
    });

    test('returns false for two different passwords', () {
      expect(doPasswordsMatch('senha123', 'senha456'), isFalse);
    });

    test('is case-sensitive', () {
      expect(doPasswordsMatch('Senha123', 'senha123'), isFalse);
    });

    test('returns false when confirmation has trailing whitespace', () {
      expect(doPasswordsMatch('senha123', 'senha123 '), isFalse);
    });

    test('returns true when both are empty', () {
      expect(doPasswordsMatch('', ''), isTrue);
    });

    test('returns false when only one is empty', () {
      expect(doPasswordsMatch('senha123', ''), isFalse);
    });
  });
}
