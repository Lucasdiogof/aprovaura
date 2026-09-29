import 'dart:async';

import 'package:flutter/material.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/presentation/aura_particles.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_mascot_view.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_reaction_sequence.dart';

/// Which [AuraParticles] play behind the mascot for a resolved reaction,
/// and how many. `null` means no particles at all -- `normal`,
/// `encourage` and `correctionReady` are not celebrations, so nothing
/// scatters around Aurudo for them.
///
/// `dailyGoalComplete` deliberately uses fewer particles than
/// `perfectFarmAura`: perfect has to stay the visually strongest reaction
/// in the app, never tied by a smaller achievement landing in the same
/// activity.
AuraParticlesStyle? _particlesStyleFor(AurudoReactionType type) =>
    switch (type) {
      AurudoReactionType.perfectFarmAura => AuraParticlesStyle.converge,
      AurudoReactionType.dailyGoalComplete => AuraParticlesStyle.converge,
      AurudoReactionType.great => AuraParticlesStyle.burst,
      AurudoReactionType.levelUp => AuraParticlesStyle.burst,
      AurudoReactionType.streakMilestone => AuraParticlesStyle.burst,
      AurudoReactionType.writing => AuraParticlesStyle.ambient,
      AurudoReactionType.normal => null,
      AurudoReactionType.encourage => null,
      AurudoReactionType.correctionReady => null,
    };

int _particlesCountFor(AurudoReactionType type) => switch (type) {
  AurudoReactionType.perfectFarmAura => 10,
  AurudoReactionType.levelUp => 8,
  AurudoReactionType.dailyGoalComplete => 5,
  AurudoReactionType.writing => 4,
  _ => 6,
};

/// Presents an already-resolved [AurudoReaction]: mascot first, then
/// [headline], [content], [stats] and [cta] revealed in that order on one
/// shared timeline (see [AurudoReactionSequence]).
///
/// Purely a view. It never computes a score, reads XP/streak/goal, calls
/// [AurudoReactionResolver], touches the reaction ledger, or talks to
/// Supabase -- all of that happens before this widget is even built,
/// and marking the reaction as "seen" is the caller's job, done outside
/// this widget's lifecycle (so a stage that never finishes mounting, or
/// gets torn down early, never marks anything as celebrated by accident).
class AurudoReactionStage extends StatefulWidget {
  const AurudoReactionStage({
    required this.reaction,
    this.headline,
    this.content,
    this.stats,
    this.cta,
    this.mascotSize = 160,
    this.onSequenceCompleted,
    super.key,
  });

  final AurudoReaction reaction;
  final Widget? headline;
  final Widget? content;
  final Widget? stats;
  final Widget? cta;
  final double mascotSize;
  final VoidCallback? onSequenceCompleted;

  /// How long after the scene starts a tap is allowed to skip to the end.
  /// Short enough not to feel unresponsive, long enough that an
  /// accidental early tap doesn't just skip past the reaction entirely.
  static const skipUnlockDelay = Duration(milliseconds: 600);

  @override
  State<AurudoReactionStage> createState() => _AurudoReactionStageState();
}

class _AurudoReactionStageState extends State<AurudoReactionStage>
    with SingleTickerProviderStateMixin {
  AurudoReactionSequence? _sequence;
  bool _canSkip = false;
  Timer? _skipTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sequence != null) return;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final sequence = AurudoReactionSequence(vsync: this, reducedMotion: reduced)
      ..controller.addStatusListener(_onStatus);
    _sequence = sequence;
    sequence.start();
    if (reduced) {
      _canSkip = true;
    } else {
      _skipTimer = Timer(AurudoReactionStage.skipUnlockDelay, () {
        if (mounted) setState(() => _canSkip = true);
      });
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onSequenceCompleted?.call();
    }
  }

  void _handleTap() {
    if (!_canSkip) return;
    _skipTimer?.cancel();
    _sequence?.skipToEnd();
  }

  @override
  void dispose() {
    _skipTimer?.cancel();
    _sequence?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sequence = _sequence!;
    final particlesStyle = _particlesStyleFor(widget.reaction.type);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: sequence.controller,
        builder: (context, child) {
          final t = sequence.controller.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: widget.mascotSize * 1.6,
                height: widget.mascotSize * 1.6,
                child: t < AurudoReactionSequence.mascotAt
                    ? null
                    : _MascotEntrance(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (particlesStyle != null &&
                                !sequence.reducedMotion)
                              AuraParticles(
                                style: particlesStyle,
                                count: _particlesCountFor(widget.reaction.type),
                              ),
                            AurudoMascotView(
                              type: widget.reaction.type,
                              essayTier: widget.reaction.essayTier,
                              size: widget.mascotSize,
                            ),
                          ],
                        ),
                      ),
              ),
              _Reveal(
                visible: t >= AurudoReactionSequence.headlineAt,
                child: widget.headline,
              ),
              _Reveal(
                visible: t >= AurudoReactionSequence.resultAt,
                child: widget.content,
              ),
              _Reveal(
                visible: t >= AurudoReactionSequence.statsAt,
                child: widget.stats,
              ),
              _Reveal(
                visible: t >= AurudoReactionSequence.ctaAt,
                child: widget.cta,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The mascot's own arrival: a few pixels of upward travel, on top of
/// whichever fade [AurudoMascotView]/[AuraParticles] already do on their
/// own. Only ever plays once, the moment this subtree is first built (the
/// sequence flips it in from nothing at `mascotAt`) -- never a repeating
/// or continuous motion.
class _MascotEntrance extends StatelessWidget {
  const _MascotEntrance({required this.child});

  final Widget child;

  static const _distance = 8.0;
  static const _duration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduced ? Duration.zero : _duration,
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, t, child) => Transform.translate(
        offset: Offset(0, _distance * (1 - t)),
        child: child,
      ),
    );
  }
}

/// One reveal step: a short fade + a small upward slide, no bounce. Under
/// reduced motion the sequence's controller is already at its end value
/// from the first frame, so every step's [visible] is already true and
/// this still plays its (short) fade rather than a hard cut -- exactly
/// the "no more than a short fade" reduced-motion allowance.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.visible, required this.child});

  final bool visible;
  final Widget? child;

  static const _duration = Duration(milliseconds: 260);

  @override
  Widget build(BuildContext context) {
    final child = this.child;
    if (child == null) return const SizedBox.shrink();
    return AnimatedSlide(
      duration: _duration,
      curve: Curves.easeOutCubic,
      offset: visible ? Offset.zero : const Offset(0, 0.12),
      child: AnimatedOpacity(
        duration: _duration,
        curve: Curves.easeOutCubic,
        opacity: visible ? 1 : 0,
        child: child,
      ),
    );
  }
}
