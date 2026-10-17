import 'package:flutter_test/flutter_test.dart';
import 'package:aura/core/sync/pending_sync_queue.dart';

void main() {
  group(PendingAction, () {
    test('round-trips through json', () {
      const action = PendingAction(
        kind: PendingKind.answer,
        key: 'q1',
        payload: {'isCorrect': true},
        attempts: 2,
      );
      final back = PendingAction.fromJson(action.toJson())!;
      expect(back.kind, PendingKind.answer);
      expect(back.key, 'q1');
      expect(back.payload['isCorrect'], true);
      expect(back.attempts, 2);
    });

    test('same kind and key target the same entry', () {
      const a = PendingAction(
        kind: PendingKind.favorite,
        key: 'q',
        payload: {},
      );
      const b = PendingAction(
        kind: PendingKind.favorite,
        key: 'q',
        payload: {},
      );
      const c = PendingAction(kind: PendingKind.answer, key: 'q', payload: {});
      expect(a.sameTarget(b), isTrue);
      expect(a.sameTarget(c), isFalse);
    });

    test('unreadable json is dropped instead of throwing', () {
      expect(PendingAction.fromJson({'k': 'nope'}), isNull);
      expect(PendingAction.fromJson('x'), isNull);
    });
  });
}
