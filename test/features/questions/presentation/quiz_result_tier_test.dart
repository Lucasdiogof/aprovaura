import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/questions/presentation/quiz_result_tier.dart';

void main() {
  group(QuizResultTier, () {
    test('0% is zero, not developing', () {
      expect(QuizResultTier.fromFraction(0), QuizResultTier.zero);
    });

    test('just under half is developing', () {
      expect(QuizResultTier.fromFraction(0.3), QuizResultTier.developing);
      expect(QuizResultTier.fromFraction(0.49), QuizResultTier.developing);
    });

    test('half and above (but under 100%) is good', () {
      expect(QuizResultTier.fromFraction(0.5), QuizResultTier.good);
      expect(QuizResultTier.fromFraction(0.99), QuizResultTier.good);
    });

    test('100% is excellent', () {
      expect(QuizResultTier.fromFraction(1), QuizResultTier.excellent);
    });

    test('only good and excellent are celebratory', () {
      expect(QuizResultTier.zero.isCelebratory, isFalse);
      expect(QuizResultTier.developing.isCelebratory, isFalse);
      expect(QuizResultTier.good.isCelebratory, isTrue);
      expect(QuizResultTier.excellent.isCelebratory, isTrue);
    });
  });
}
