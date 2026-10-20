import 'dart:async';
import 'dart:math' as math;

import 'package:aura/shared/widgets/aura/aurudo_idle.dart';

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

  /// True with probability [p].
  bool chance(double p) => _rng.nextDouble() < p;

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
