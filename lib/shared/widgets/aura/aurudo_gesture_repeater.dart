import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'package:aura/shared/widgets/aura/aurudo_idle.dart';

/// What one repeat of a gesture looks like. Each replay draws a new one, so
/// the hand never taps the same pattern twice in a row.
@immutable
class GestureBurst {
  const GestureBurst({
    required this.taps,
    required this.amplitude,
    required this.duration,
  });

  /// How many dips (or swings) the gesture makes.
  final int taps;

  /// 0..1 of the gesture's maximum turn. Never above 1: the cut-outs hold
  /// up to that much and no more.
  final double amplitude;

  /// How long the gesture takes, start to settled.
  final Duration duration;
}

/// Brings a one-shot gesture back after a pause, for as long as it is on
/// screen: study taps, a chin tap, a hello.
///
/// It owns one [Timer], always cancelled by [dispose] and by [cancel], and
/// it never arms in the widget-test suite ([AurudoIdle.debugEnabled] off),
/// where a pending timer would fail every test that does not tear it down.
/// The owner decides, when the time comes, whether to actually play (it
/// still has to be on screen, in motion, mounted) and calls [arm] again
/// either way.
class AurudoGestureRepeater {
  AurudoGestureRepeater({
    required this.minPause,
    required this.maxPause,
    required this.onFire,
    int? seed,
  }) : _rng = math.Random(seed);

  final Duration minPause;
  final Duration maxPause;
  final void Function() onFire;
  final math.Random _rng;
  Timer? _timer;

  /// A fair random number in [min, max).
  double between(double min, double max) =>
      min + _rng.nextDouble() * (max - min);

  int betweenInt(int min, int max) => min + _rng.nextInt(max - min + 1);

  /// Waits a pause of uneven length, then fires once.
  void arm() {
    _timer?.cancel();
    if (!AurudoIdle.debugEnabled) return;
    final span = maxPause.inMilliseconds - minPause.inMilliseconds;
    final wait = minPause.inMilliseconds + (_rng.nextDouble() * span).round();
    _timer = Timer(Duration(milliseconds: wait), onFire);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => cancel();
}
