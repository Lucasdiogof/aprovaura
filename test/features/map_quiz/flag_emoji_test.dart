import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/map_quiz/domain/entities/flag_emoji.dart';

void main() {
  group('flagEmojiForCountryId', () {
    test('generates correct flag emoji for known countries', () {
      expect(flagEmojiForCountryId('BRA'), '🇧🇷');
      expect(flagEmojiForCountryId('FRA'), '🇫🇷');
      expect(flagEmojiForCountryId('JPN'), '🇯🇵');
      expect(flagEmojiForCountryId('USA'), '🇺🇸');
    });

    test('returns null for an unknown country id', () {
      expect(flagEmojiForCountryId('XXX'), isNull);
    });
  });
}
