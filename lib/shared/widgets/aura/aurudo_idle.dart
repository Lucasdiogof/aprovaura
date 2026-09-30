import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The loop that keeps Aurudo alive on screen once his entrance is done.
///
/// He is an astronaut, so he drifts rather than stands: a slow bob up and
/// down, a breath scaling him a hair, and a sway tilting him a fraction of
/// a degree. The three run at different rates -- six, four and three
/// cycles per [period] -- so the pose only lands in the same place once
/// every [period], instead of every couple of seconds like a single wave
/// would.
///
/// It moves the whole character, never a limb. The mascot's poses are flat
/// images, and faking an articulated gesture out of one reads as broken;
/// drifting reads as floating, which is what he is doing anyway. Real
/// articulation needs cut-out layers -- see AurudoFarmAuraAnimation, which
/// has them -- or a rigged asset.
///
/// The controller only exists while this can be seen: it stops under
/// reduced motion, behind another tab and under a pushed route, and only
/// the illustration repaints.
class AurudoIdle extends StatefulWidget {
  const AurudoIdle({required this.child, this.size = 140, super.key});

  final Widget child;

  /// The drift scales with the character, so he moves the same amount
  /// relative to his own body at any size.
  final double size;

  static const period = Duration(milliseconds: 15600);

  /// Off for the whole widget-test suite (see test/flutter_test_config.dart).
  ///
  /// Aurudo stands in eight screens, and a drift that never ends is a
  /// `pumpAndSettle` timeout in every test that opens one of them --
  /// noise about motion, in tests that are about what is on screen.
  /// Turning it off there costs nothing: the drift carries no meaning,
  /// and the tests that exist to check it turn it back on.
  static bool debugEnabled = true;

  @override
  State<AurudoIdle> createState() => _AurudoIdleState();
}

class _AurudoIdleState extends State<AurudoIdle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: AurudoIdle.period,
  );

  bool _canRun = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _canRun =
        AurudoIdle.debugEnabled &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (_canRun) {
      if (!_loop.isAnimating) _loop.repeat();
    } else if (_loop.isAnimating) {
      _loop
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_canRun) return widget.child;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _loop,
        child: widget.child,
        builder: (context, child) {
          final t = _loop.value * 2 * math.pi;
          final breath = math.sin(t * 6);
          final bob = math.sin(t * 4);
          final sway = math.sin(t * 3);
          return Transform.translate(
            offset: Offset(0, bob * widget.size * 0.022),
            child: Transform.rotate(
              angle: sway * 0.009,
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
