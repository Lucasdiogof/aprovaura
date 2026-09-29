import 'package:flutter_test/flutter_test.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_sequence.dart';

void main() {
  group(AurudoReactionSequence, () {
    late TestVSync vsync;

    setUp(() {
      // AnimationController.forward() reaches into SemanticsBinding for
      // AnimationBehavior, which needs the test binding up first -- these
      // are plain `test()`s, not `testWidgets()`, so nothing else does it.
      TestWidgetsFlutterBinding.ensureInitialized();
      vsync = const TestVSync();
    });

    test('has not started until start() is called', () {
      final sequence = AurudoReactionSequence(vsync: vsync);
      expect(sequence.controller.value, 0);
      sequence.dispose();
    });

    test('reduced motion jumps straight to the end on start()', () {
      final sequence = AurudoReactionSequence(
        vsync: vsync,
        reducedMotion: true,
      );
      sequence.start();
      expect(sequence.controller.value, 1);
      sequence.dispose();
    });

    test('skipToEnd reveals everything regardless of where it was', () {
      final sequence = AurudoReactionSequence(vsync: vsync);
      sequence.start();
      sequence.skipToEnd();
      expect(sequence.controller.value, 1);
      sequence.dispose();
    });

    test('reveal points are in the documented order', () {
      expect(
        AurudoReactionSequence.mascotAt < AurudoReactionSequence.headlineAt,
        isTrue,
      );
      expect(
        AurudoReactionSequence.headlineAt < AurudoReactionSequence.resultAt,
        isTrue,
      );
      expect(
        AurudoReactionSequence.resultAt < AurudoReactionSequence.statsAt,
        isTrue,
      );
      expect(
        AurudoReactionSequence.statsAt < AurudoReactionSequence.ctaAt,
        isTrue,
      );
    });
  });
}
