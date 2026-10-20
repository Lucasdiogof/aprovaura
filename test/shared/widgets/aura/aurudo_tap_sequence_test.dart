import 'package:flutter_test/flutter_test.dart';
import 'package:aura/shared/widgets/aura/aurudo_tap_sequence.dart';

void main() {
  group('TapSpec', () {
    const tap = TapSpec(startMs: 100, downMs: 100, upMs: 200, amplitude: 0.8);

    test('rests before, after, and lands exactly on zero', () {
      expect(tap.at(0), 0);
      expect(tap.at(100), 0);
      expect(tap.at(399.999), closeTo(0, 1e-9));
      expect(tap.at(400), 0);
      expect(tap.at(5000), 0);
    });

    test('goes down to its amplitude and no deeper', () {
      expect(tap.at(200), closeTo(0.8, 1e-12));
      for (var ms = 0; ms <= 400; ms++) {
        expect(tap.at(ms.toDouble()), inInclusiveRange(0, 0.8 + 1e-9));
      }
    });

    test('has no corner: no jump between two nearby instants', () {
      var prev = tap.at(0);
      for (var ms = 1; ms <= 400; ms++) {
        final v = tap.at(ms.toDouble());
        expect((v - prev).abs(), lessThan(0.03));
        prev = v;
      }
    });

    test('goes down faster than it comes back', () {
      expect(tap.downMs, lessThan(tap.upMs));
    });
  });

  group('TapSequence', () {
    const seq = TapSequence(
      leadMs: 50,
      tailMs: 80,
      taps: [
        TapSpec(startMs: 50, downMs: 80, upMs: 120, amplitude: 1),
        TapSpec(startMs: 300, downMs: 80, upMs: 120, amplitude: 0.7),
      ],
    );

    test('lasts until the last tap is done, plus the tail', () {
      expect(seq.durationMs, 300 + 200 + 80);
      expect(seq.count, 2);
      expect(seq.beats, [0, 250]);
    });

    test('reads the deepest tap where two overlap, never their sum', () {
      const overlap = TapSequence(
        leadMs: 0,
        tailMs: 0,
        taps: [
          TapSpec(startMs: 0, downMs: 100, upMs: 200, amplitude: 1),
          TapSpec(startMs: 100, downMs: 100, upMs: 200, amplitude: 1),
        ],
      );
      for (var ms = 0; ms <= 400; ms += 5) {
        expect(overlap.k(ms.toDouble()), lessThanOrEqualTo(1.0 + 1e-9));
      }
    });

    test('rests at the very start and the very end', () {
      expect(seq.k(0), 0);
      expect(seq.k(seq.durationMs), 0);
    });
  });

  group('pickWeighted', () {
    const choices = [
      Weighted(0.3, 'a'),
      Weighted(0.5, 'b'),
      Weighted(0.2, 'c'),
    ];

    test('lands on each choice exactly at its edges', () {
      expect(pickWeighted(choices, 0.0), 'a');
      expect(pickWeighted(choices, 0.299), 'a');
      expect(pickWeighted(choices, 0.3), 'b');
      expect(pickWeighted(choices, 0.799), 'b');
      expect(pickWeighted(choices, 0.8), 'c');
      expect(pickWeighted(choices, 0.999999), 'c');
    });

    test('weights need not add up to one', () {
      const odd = [Weighted(2, 'x'), Weighted(6, 'y')];
      expect(pickWeighted(odd, 0.24), 'x');
      expect(pickWeighted(odd, 0.26), 'y');
    });
  });
}
