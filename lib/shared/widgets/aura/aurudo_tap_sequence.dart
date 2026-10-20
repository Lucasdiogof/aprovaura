import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// One dip of a hand (a chin tap, a key press): down into the surface, then
/// back to rest. [startMs] is when the hand leaves rest.
@immutable
class TapSpec {
  const TapSpec({
    required this.startMs,
    required this.downMs,
    required this.upMs,
    required this.amplitude,
  });

  final double startMs;
  final double downMs;
  final double upMs;

  /// 0..1 of the gesture's maximum turn.
  final double amplitude;

  double get endMs => startMs + downMs + upMs;

  /// 0 at rest, [amplitude] at the bottom. Both halves ease like a cosine, so
  /// the hand arrives and leaves at zero speed: no corner at the bottom, no
  /// jump when it lands back on the art.
  double at(double ms) {
    final t = ms - startMs;
    if (t <= 0 || t >= downMs + upMs) return 0;
    if (t <= downMs) {
      return amplitude * (0.5 - 0.5 * math.cos(math.pi * t / downMs));
    }
    final u = (t - downMs) / upMs;
    return amplitude * (0.5 + 0.5 * math.cos(math.pi * u));
  }
}

/// A burst of taps with its own uneven timing, drawn once per replay from the
/// repeater's generator (so a seed always tells the same story) and then
/// played back by time.
@immutable
class TapSequence {
  const TapSequence({
    required this.taps,
    required this.leadMs,
    required this.tailMs,
    this.pauseAfterTap,
    this.pauseMs = 0,
  });

  final List<TapSpec> taps;

  /// Set when the burst stops for an instant in the middle: the pause comes
  /// after the tap with this index, and lasts [pauseMs] on top of the usual
  /// gap. Null: no pause.
  final int? pauseAfterTap;
  final double pauseMs;

  /// Quiet before the first tap and after the last, so the hand is seen to
  /// settle before the sequence ends.
  final double leadMs;
  final double tailMs;

  int get count => taps.length;

  double get durationMs => (taps.isEmpty ? 0 : taps.last.endMs) + tailMs;

  /// Starts of the taps, relative to the first one.
  List<double> get beats => [
    for (final t in taps) t.startMs - taps.first.startMs,
  ];

  /// 0 at rest .. 1 at the deepest point, at [ms] into the sequence. Where two
  /// taps overlap, the deeper one wins.
  double k(double ms) {
    var best = 0.0;
    for (final t in taps) {
      final v = t.at(ms);
      if (v > best) best = v;
    }
    return best;
  }
}

/// A choice and how likely it is.
@immutable
class Weighted<T> {
  const Weighted(this.weight, this.value);

  final double weight;
  final T value;
}

/// The choice [roll] (0 <= roll < 1) lands on, by weight. Pure: the caller
/// supplies the roll from the repeater's generator, so tests can walk the
/// whole range without any randomness.
T pickWeighted<T>(List<Weighted<T>> choices, double roll) {
  final total = choices.fold<double>(0, (a, c) => a + c.weight);
  var edge = 0.0;
  for (final c in choices) {
    edge += c.weight / total;
    if (roll < edge) return c.value;
  }
  return choices.last.value;
}
