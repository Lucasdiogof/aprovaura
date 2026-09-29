import 'package:flutter/animation.dart';

/// The one clock behind an [AurudoReactionStage]'s reveal order --
/// mascot, then headline, then result, then stats, then CTA -- so nothing
/// is timed with a scattered `Future.delayed` per element. Every reveal
/// point is a fraction of [totalDuration] read off the same
/// [AnimationController], which makes the whole scene both deterministic
/// and directly testable with `tester.pump(Duration)`.
///
/// Reduced motion collapses this to an instantly-completed controller:
/// every reveal point is already past, so everything using it appears at
/// once (each still gets its own short local fade -- see
/// `AurudoReactionStage`'s `_Reveal` -- never a hard cut).
class AurudoReactionSequence {
  AurudoReactionSequence({
    required TickerProvider vsync,
    this.reducedMotion = false,
  }) : controller = AnimationController(vsync: vsync, duration: totalDuration);

  /// Roughly the spec's timing table: mascot at ~150ms, headline at
  /// ~900ms, result at ~1300ms, stats at ~1560ms, CTA at ~1800ms, done by
  /// ~2000ms.
  static const totalDuration = Duration(milliseconds: 2000);

  static const mascotAt = 0.075;
  static const headlineAt = 0.45;
  static const resultAt = 0.65;
  static const statsAt = 0.78;
  static const ctaAt = 0.90;

  final AnimationController controller;
  final bool reducedMotion;

  void start() {
    if (reducedMotion) {
      controller.value = 1;
    } else {
      controller.forward();
    }
  }

  /// The tap-to-skip affordance: jumps straight to the fully-revealed end
  /// state. Never invokes the CTA itself -- it only makes it visible.
  void skipToEnd() => controller.value = 1;

  void dispose() => controller.dispose();
}
