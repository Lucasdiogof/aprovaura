import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The streak flame, breathing instead of sitting still.
///
/// Two sine waves of unrelated periods drive it -- one slow for the
/// breath, one quicker and much smaller for the flicker -- so the loop
/// never lands on an obvious beat the way a single wave does. The flame
/// scales from its base, not its centre, because fire grows upwards, and
/// the glow behind it swells with the same breath.
///
/// The controller only exists while there is a streak to celebrate: with
/// [alive] off the flame is drawn once, still. It also stops when this
/// can't be seen (another tab in front, a route pushed on top) and under
/// reduced motion, and only the flame repaints -- the card around it
/// never rebuilds.
class StreakFlame extends StatefulWidget {
  const StreakFlame({
    required this.alive,
    super.key,
    this.color = const Color(0xFFE8763D),
    this.size = 22,
  });

  final bool alive;
  final Color color;
  final double size;

  static const period = Duration(milliseconds: 2600);

  @override
  State<StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<StreakFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: StreakFlame.period,
  );

  bool _canRun = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _canRun =
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    _sync();
  }

  @override
  void didUpdateWidget(StreakFlame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alive != oldWidget.alive) _sync();
  }

  void _sync() {
    if (widget.alive && _canRun) {
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
    final icon = Icon(
      Icons.local_fire_department,
      color: widget.color,
      size: widget.size,
    );
    if (!widget.alive || !_canRun) return icon;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _loop,
        child: icon,
        builder: (context, child) {
          final t = _loop.value * 2 * math.pi;
          // 0..1, and the flicker rides on top at a seventh of the weight.
          final breath =
              (math.sin(t) * 0.86 + math.sin(t * 3.7) * 0.14 + 1) / 2;
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.10 + breath * 0.22),
                  blurRadius: 8 + breath * 10,
                  spreadRadius: breath * 2,
                ),
              ],
            ),
            child: Transform.scale(
              scale: 1 + breath * 0.12,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
