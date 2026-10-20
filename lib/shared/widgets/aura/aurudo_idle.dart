import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// One instant of the idle motion, before it is placed on screen.
@immutable
class IdlePose {
  const IdlePose({
    required this.bob,
    required this.breath,
    required this.sway,
    required this.angle,
    required this.lift,
    required this.inhale,
  });

  /// The slow vertical float, -1..1 (times a fraction of his size).
  final double bob;

  /// The breath, -1..1.
  final double breath;

  /// The tiny continuous roll, -1..1 (times a fraction of a degree).
  final double sway;

  /// The lean of a glance, in radians; positive is clockwise on screen.
  final double angle;

  /// How far a glance raises him, as a fraction of his size.
  final double lift;

  /// An extra, deeper breath riding on a glance, 0..1.
  final double inhale;
}

enum _GestureKind {
  /// A lean toward something, a hair of lift, and back.
  glance,

  /// No lean: he only takes a deeper breath and rises a little, as if he
  /// had thought of something.
  perk,
}

class _Gesture {
  const _Gesture({
    required this.kind,
    required this.startMs,
    required this.durationMs,
    required this.angle,
  });

  final _GestureKind kind;
  final double startMs;
  final double durationMs;
  final double angle;

  double get endMs => startMs + durationMs;
}

/// The score the idle follows: an endless, unrepeating sequence of small
/// gestures separated by pauses of uneven length.
///
/// The continuous drift (breath, float, roll) never stops, but its three
/// rhythms are unrelated to each other and each is slowly bent by a much
/// slower one, so the pose never lands twice in the same place. Over it,
/// every few seconds, one gesture: mostly a glance to one side or the
/// other, sometimes just a deeper breath. Gap, length, size and side are all
/// drawn from a seeded generator, so a given seed always tells the same
/// story (what the tests rely on) while the app does not feel like a loop.
///
/// It is a function of time alone, and one [shared] score serves every
/// mascot on screen. That is what lets him change pose -- thinking to
/// studying, say -- without the drift jumping: both poses read the very
/// same instant of the very same motion.
class IdleChoreography {
  IdleChoreography({int seed = 11}) : _rng = math.Random(seed);

  /// What the app uses.
  static final shared = IdleChoreography();

  final math.Random _rng;
  final List<_Gesture> _gestures = [];
  double _cursorMs = 0;
  bool _lastWasClockwise = false;
  Duration? _origin;
  int _generated = 0;

  /// Frame timestamps count from boot (or from the test binding's epoch), so
  /// they are huge and say nothing about this score. The first frame that
  /// reaches a score is its zero: everything after is measured from there.
  /// Every mascot on a score shares that one origin, which is what keeps two
  /// of them -- or one handing over to the next -- on the same instant of the
  /// motion, however late each appeared.
  Duration localTime(Duration frame) {
    final origin = _origin ??= frame;
    final local = frame - origin;
    return local.isNegative ? Duration.zero : local;
  }

  /// [localTime] without starting the clock: null until a frame has set the
  /// origin. For a mascot that appears before its first frame.
  Duration? peekLocalTime(Duration frame) {
    final origin = _origin;
    if (origin == null) return null;
    final local = frame - origin;
    return local.isNegative ? Duration.zero : local;
  }

  /// How many gestures were ever drawn / are held now. Tests use them to
  /// prove the cost of a sample does not grow with the time asked for.
  @visibleForTesting
  int get debugGenerated => _generated;

  @visibleForTesting
  int get debugStored => _gestures.length;

  /// A sample this far past what the score has drawn jumps ahead instead of
  /// drawing every gesture on the way: nobody saw them (the app was in the
  /// background, or the clock is far from zero), and drawing them would make
  /// the cost grow with the gap. Anything shorter -- every frame of a running
  /// app -- is drawn in full, exactly as before.
  static const maxCatchUpMs = 5 * 60 * 1000.0;

  /// No gesture before this: he settles in first.
  static const firstGestureMs = 3500.0;

  /// Longest lean, in radians (about 1.7 degrees): attentive, never a turn.
  static const maxLean = 0.03;

  void _fillTo(double ms) {
    if (ms - _cursorMs > maxCatchUpMs) {
      // Resume a calm minute before the instant asked for, from the same
      // generator, so the story stays deterministic for a given seed.
      _gestures.clear();
      _cursorMs = ms - 60000;
      _lastWasClockwise = false;
    }
    while (_cursorMs < ms + 20000) {
      // Mostly 3-8s of quiet; now and then a long one.
      var gap = 3000 + _rng.nextDouble() * 5000;
      if (_rng.nextDouble() < 0.22) gap += 4000 + _rng.nextDouble() * 4000;
      if (_gestures.isEmpty) gap = firstGestureMs + _rng.nextDouble() * 2500;
      final start = _cursorMs + gap;
      final duration = 1500 + _rng.nextDouble() * 1100;
      if (_rng.nextDouble() < 0.28) {
        _gestures.add(
          _Gesture(
            kind: _GestureKind.perk,
            startMs: start,
            durationMs: duration + 300,
            angle: 0,
          ),
        );
      } else {
        // Usually the other way from last time, not always.
        final clockwise = _rng.nextDouble() < 0.75
            ? !_lastWasClockwise
            : _lastWasClockwise;
        _lastWasClockwise = clockwise;
        final size = 0.011 + _rng.nextDouble() * (maxLean - 0.011);
        _gestures.add(
          _Gesture(
            kind: _GestureKind.glance,
            startMs: start,
            durationMs: duration,
            angle: clockwise ? size : -size,
          ),
        );
      }
      _generated++;
      _cursorMs = _gestures.last.endMs;
    }
    if (_gestures.length > 400) _gestures.removeRange(0, 200);
  }

  /// A swell that starts and ends at exactly 0, with a hint of anticipation
  /// (a small move the other way first) and a slightly slower way back.
  static double shape(double p) {
    final bump = math.sin(math.pi * p);
    return bump * bump - 0.3 * math.sin(2 * math.pi * p) * (1 - p) * 0.5;
  }

  IdlePose sample(Duration at) {
    final ms = at.inMicroseconds / 1000.0;
    _fillTo(ms);

    var angle = 0.0;
    var lift = 0.0;
    var inhale = 0.0;
    for (var i = _gestures.length - 1; i >= 0; i--) {
      final g = _gestures[i];
      if (g.endMs < ms - 4000) break;
      if (ms <= g.startMs || ms >= g.endMs) continue;
      final s = shape((ms - g.startMs) / g.durationMs);
      switch (g.kind) {
        case _GestureKind.glance:
          angle += g.angle * s;
          lift += s.abs() * 0.006;
          inhale += s.abs() * 0.4;
        case _GestureKind.perk:
          lift += s.abs() * 0.009;
          inhale += s.abs();
      }
    }

    final t = ms / 1000;
    // Each rhythm is bent by a far slower one, so it never settles into a
    // pattern.
    final breathPhase = 2 * math.pi * (t / 3.3) + 0.35 * math.sin(t * 0.30);
    final bobPhase = 2 * math.pi * (t / 4.3) + 0.5 * math.sin(t * 0.23);
    final swayPhase = 2 * math.pi * (t / 5.9) + 0.4 * math.sin(t * 0.17);
    return IdlePose(
      bob: math.sin(bobPhase),
      breath: math.sin(breathPhase),
      sway: math.sin(swayPhase),
      angle: angle,
      lift: lift,
      inhale: inhale,
    );
  }
}

/// The motion that keeps Aurudo alive on screen once his entrance is done.
///
/// He is an astronaut, so he drifts rather than stands: a slow float, a
/// breath scaling him a hair and a roll of a fraction of a degree -- plus,
/// every few seconds, a small gesture (a glance, a deeper breath); see
/// [IdleChoreography] for how the timing is kept from ever repeating.
///
/// It moves the whole character, never a limb. The mascot's poses are flat
/// images, and faking an articulated gesture out of one reads as broken;
/// drifting reads as floating, which is what he is doing anyway. Real
/// articulation needs cut-out layers -- see AurudoFarmAuraAnimation, which
/// has them -- or a rigged asset.
///
/// It reads the clock of the frame, not one of its own, so two of them on
/// screen -- or one handing over to the next when the pose changes -- are
/// always at the same point of the motion. The ticker only exists while
/// this can be seen: it stops under reduced motion, behind another tab and
/// under a pushed route, and only the illustration repaints.
class AurudoIdle extends StatefulWidget {
  const AurudoIdle({
    required this.child,
    this.size = 140,
    @visibleForTesting this.choreography,
    super.key,
  });

  final Widget child;

  /// The drift scales with the character, so he moves the same amount
  /// relative to his own body at any size.
  final double size;

  /// Defaults to [IdleChoreography.shared].
  final IdleChoreography? choreography;

  /// Off for the whole widget-test suite (see test/flutter_test_config.dart).
  ///
  /// Aurudo stands in eight screens, and a drift that never ends is a
  /// `pumpAndSettle` timeout in every test that opens one of them --
  /// noise about motion, in tests that are about what is on screen.
  /// Turning it off there costs nothing: the drift carries no meaning,
  /// and the tests that exist to check it turn it back on. The gesture
  /// timers of the other animations (studying, thinking, waving) follow
  /// the same switch.
  static bool debugEnabled = true;

  @override
  State<AurudoIdle> createState() => _AurudoIdleState();
}

class _AurudoIdleState extends State<AurudoIdle>
    with SingleTickerProviderStateMixin {
  IdleChoreography get _choreography =>
      widget.choreography ?? IdleChoreography.shared;

  late final Ticker _ticker = createTicker((_) {
    _now.value = _choreography.localTime(
      SchedulerBinding.instance.currentSystemFrameTimeStamp,
    );
  });

  /// Time on the choreography's own clock. Before the first frame has set its
  /// origin there is nothing to be late for: he stands at the start.
  late final ValueNotifier<Duration> _now = ValueNotifier(
    _choreography.peekLocalTime(
          SchedulerBinding.instance.currentSystemFrameTimeStamp,
        ) ??
        Duration.zero,
  );

  bool _canRun = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _canRun =
        AurudoIdle.debugEnabled && !MediaQuery.disableAnimationsOf(context);
    if (_canRun) {
      if (!_ticker.isActive) _ticker.start();
    } else if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _now.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_canRun) return widget.child;
    final choreography = _choreography;
    final size = widget.size;
    return RepaintBoundary(
      child: ValueListenableBuilder<Duration>(
        valueListenable: _now,
        child: widget.child,
        builder: (context, now, child) {
          final p = choreography.sample(now);
          final breath = p.breath + p.inhale * 1.2;
          return Transform.translate(
            offset: Offset(0, p.bob * size * 0.022 - p.lift * size),
            child: Transform.rotate(
              angle: p.sway * 0.009 + p.angle,
              child: Transform.scale(
                scaleY: 1 + breath * 0.012,
                scaleX: 1 - breath * 0.006,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
