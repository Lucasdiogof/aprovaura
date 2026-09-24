import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/features/mock_exam/l10n/mock_exam_strings.dart';
import 'package:aura/features/mock_exam/presentation/mock_exam_result_tier.dart';

void main() {
  group('MockExamResultTier.fromAccuracy', () {
    test('never gives 20% and 95% the same message', () {
      expect(
        MockExamResultTier.fromAccuracy(20),
        isNot(MockExamResultTier.fromAccuracy(95)),
      );
    });

    test('boundaries', () {
      expect(MockExamResultTier.fromAccuracy(0), MockExamResultTier.review);
      expect(MockExamResultTier.fromAccuracy(39.9), MockExamResultTier.review);
      expect(MockExamResultTier.fromAccuracy(40), MockExamResultTier.advancing);
      expect(
        MockExamResultTier.fromAccuracy(69.9),
        MockExamResultTier.advancing,
      );
      expect(MockExamResultTier.fromAccuracy(70), MockExamResultTier.good);
      expect(MockExamResultTier.fromAccuracy(89.9), MockExamResultTier.good);
      expect(MockExamResultTier.fromAccuracy(90), MockExamResultTier.excellent);
      expect(
        MockExamResultTier.fromAccuracy(100),
        MockExamResultTier.excellent,
      );
    });
  });

  group('MockExamStrings.percent', () {
    const pt = MockExamStrings(AppLanguage.portuguese);
    const en = MockExamStrings(AppLanguage.english);

    test('uses the locale decimal separator', () {
      expect(pt.percent(75.6), '75,6%');
      expect(en.percent(75.6), '75.6%');
    });

    test('drops a zero decimal', () {
      expect(pt.percent(75), '75%');
      expect(pt.percent(100), '100%');
      expect(pt.percent(0), '0%');
    });
  });
}
