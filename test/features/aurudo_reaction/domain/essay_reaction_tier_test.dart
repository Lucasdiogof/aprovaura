import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/essay_reaction_tier.dart';

void main() {
  group(EssayReactionTier, () {
    test('900-1000 is excellent', () {
      expect(EssayReactionTier.fromScore(900), EssayReactionTier.excellent);
      expect(EssayReactionTier.fromScore(920), EssayReactionTier.excellent);
      expect(EssayReactionTier.fromScore(1000), EssayReactionTier.excellent);
    });

    test('700-899 is great', () {
      expect(EssayReactionTier.fromScore(700), EssayReactionTier.great);
      expect(EssayReactionTier.fromScore(800), EssayReactionTier.great);
      expect(EssayReactionTier.fromScore(899), EssayReactionTier.great);
    });

    test('500-699 is developing', () {
      expect(EssayReactionTier.fromScore(500), EssayReactionTier.developing);
      expect(EssayReactionTier.fromScore(600), EssayReactionTier.developing);
      expect(EssayReactionTier.fromScore(699), EssayReactionTier.developing);
    });

    test('0-499 is encourage', () {
      expect(EssayReactionTier.fromScore(0), EssayReactionTier.encourage);
      expect(EssayReactionTier.fromScore(400), EssayReactionTier.encourage);
      expect(EssayReactionTier.fromScore(499), EssayReactionTier.encourage);
    });
  });
}
