import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/mock_exam/domain/mock_exam_quantity.dart';

List<int> _climb({required int available, int otherSubjectsTotal = 0}) {
  final values = <int>[];
  var current = 0;
  while (true) {
    final next = MockExamQuantity.increase(
      current: current,
      available: available,
      otherSubjectsTotal: otherSubjectsTotal,
    );
    if (next == current) return values;
    values.add(next);
    current = next;
  }
}

List<int> _descend(int from) {
  final values = <int>[];
  var current = from;
  while (current > 0) {
    current = MockExamQuantity.decrease(current);
    values.add(current);
  }
  return values;
}

void main() {
  group('MockExamQuantity.increase', () {
    test('steps by 5 and reaches a remainder exactly (Português difícil)', () {
      expect(_climb(available: 18), [5, 10, 15, 18]);
    });

    test('a combination with fewer than 5 goes straight to its maximum', () {
      expect(_climb(available: 3), [3]);
    });

    test('an exact multiple of 5 ends on it', () {
      expect(_climb(available: 20), [5, 10, 15, 20]);
    });

    test('nothing available means the counter never moves', () {
      expect(_climb(available: 0), isEmpty);
    });

    test('never lets the whole exam pass 180, but reaches 180 exactly', () {
      // 173 already picked elsewhere -> this subject can add at most 7.
      expect(_climb(available: 199, otherSubjectsTotal: 173), [5, 7]);
    });

    test('is a no-op when the rest of the exam already uses all 180', () {
      expect(
        MockExamQuantity.increase(
          current: 0,
          available: 50,
          otherSubjectsTotal: 180,
        ),
        0,
      );
    });

    test('snaps an off-step value up to the next multiple of 5', () {
      expect(
        MockExamQuantity.increase(
          current: 7,
          available: 50,
          otherSubjectsTotal: 0,
        ),
        10,
      );
    });
  });

  group('MockExamQuantity.decrease', () {
    test('from a remainder, drops back onto the 5-grid', () {
      expect(_descend(18), [15, 10, 5, 0]);
    });

    test('below 5 goes straight to 0 (subject removed)', () {
      expect(_descend(3), [0]);
    });

    test('never goes negative', () {
      expect(MockExamQuantity.decrease(0), 0);
    });
  });

  group('MockExamQuantity.ceiling', () {
    test('is the smaller of availability and what is left of 180', () {
      expect(
        MockExamQuantity.ceiling(available: 18, otherSubjectsTotal: 0),
        18,
      );
      expect(
        MockExamQuantity.ceiling(available: 199, otherSubjectsTotal: 150),
        30,
      );
      expect(
        MockExamQuantity.ceiling(available: 10, otherSubjectsTotal: 200),
        0,
      );
    });
  });
}
