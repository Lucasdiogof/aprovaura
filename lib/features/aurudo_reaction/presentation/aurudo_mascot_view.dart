import 'dart:async';

import 'package:flutter/material.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/essay_reaction_tier.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_celebrating_animation.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_daily_goal_effect.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_farm_aura_animation.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_level_up_effect.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_streak_effect.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

/// Which [AurudoPose] (or short pose-to-pose story) plays for a resolved
/// [AurudoReactionType], today's honest placeholder until a rigged
/// Rive/Lottie asset exists: the character itself never fakes an
/// articulated gesture, only the surrounding scene (particles, halo) does
/// that work -- see [AurudoReactionStage]. Two exceptions: `perfectFarmAura`,
/// which [AurudoMascotView] hands to [AurudoFarmAuraAnimation], and any
/// single-pose sequence ending on [AurudoPose.celebrating], handed to
/// [AurudoCelebratingAnimation] -- both real cut-out layers; their pose here
/// is each animation's fallback. `dailyGoalComplete` shares the still pose,
/// never the animation.
///
/// [essayTier] only matters for [AurudoReactionType.correctionReady] --
/// every other reaction ignores it. A missing tier for `correctionReady`
/// (should not happen through the resolver, which always sets one) falls
/// back to [AurudoPose.neutral] rather than guessing.
List<AurudoPose> aurudoPoseSequence(
  AurudoReactionType type, {
  EssayReactionTier? essayTier,
}) => switch (type) {
  AurudoReactionType.perfectFarmAura => const [AurudoPose.farmingAura],
  AurudoReactionType.great => const [AurudoPose.celebrating],
  AurudoReactionType.normal => const [AurudoPose.thinking, AurudoPose.neutral],
  AurudoReactionType.encourage => const [
    AurudoPose.thinking,
    AurudoPose.studying,
  ],
  AurudoReactionType.dailyGoalComplete => const [AurudoPose.farmingAura],
  AurudoReactionType.levelUp => const [AurudoPose.celebrating],
  AurudoReactionType.streakMilestone => const [AurudoPose.celebrating],
  AurudoReactionType.writing => const [AurudoPose.studying],
  // Never `frustrated`, even for the lowest essay band -- the correction
  // encourages, it never shames a grade.
  AurudoReactionType.correctionReady => switch (essayTier) {
    // No tier at all shouldn't happen through the resolver, which always
    // sets one -- neutral, not an unearned celebration, is the safe
    // guess if it ever does.
    null => const [AurudoPose.neutral],
    EssayReactionTier.excellent ||
    EssayReactionTier.great => const [AurudoPose.celebrating],
    EssayReactionTier.developing => const [AurudoPose.neutral],
    EssayReactionTier.encourage => const [AurudoPose.studying],
  },
};

/// Whether [type]'s renderer draws its own particles -- the farm-Aura
/// animation and the level-up, streak and daily-goal scenes. A scene that
/// hosts the mascot (the result stage, Home's overlay) must not add its
/// generic particles on top of these.
bool aurudoReactionHasOwnParticles(AurudoReactionType type) => switch (type) {
  AurudoReactionType.perfectFarmAura ||
  AurudoReactionType.levelUp ||
  AurudoReactionType.streakMilestone ||
  AurudoReactionType.dailyGoalComplete => true,
  _ => false,
};

/// Aurudo reacting to a resolved [type]. For the two-pose stories
/// (`normal`, `encourage`) the first pose holds briefly, then crossfades
/// into the final one; every other reaction is a single pose with
/// [AurudoIllustration]'s own short entrance. Reduced motion always shows
/// the sequence's last pose immediately, with no crossfade.
class AurudoMascotView extends StatefulWidget {
  const AurudoMascotView({
    required this.type,
    this.essayTier,
    this.size = 160,
    this.instant = false,
    super.key,
  });

  final AurudoReactionType type;

  /// Only read when [type] is [AurudoReactionType.correctionReady] --
  /// ignored for every other reaction.
  final EssayReactionTier? essayTier;
  final double size;

  /// Forces the final pose immediately, regardless of the platform's
  /// reduced-motion setting -- see `AurudoReactionStage.instant`.
  final bool instant;

  /// How long the first pose of a two-pose story holds before crossfading.
  static const firstPoseDuration = Duration(milliseconds: 600);
  static const crossfadeDuration = Duration(milliseconds: 250);

  @override
  State<AurudoMascotView> createState() => _AurudoMascotViewState();
}

class _AurudoMascotViewState extends State<AurudoMascotView> {
  late List<AurudoPose> _poses = aurudoPoseSequence(
    widget.type,
    essayTier: widget.essayTier,
  );
  int _index = 0;
  Timer? _timer;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    _scheduleCrossfade();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = widget.instant || MediaQuery.disableAnimationsOf(context);
    if (_reduced && _index != _poses.length - 1) {
      _timer?.cancel();
      _index = _poses.length - 1;
    }
  }

  @override
  void didUpdateWidget(covariant AurudoMascotView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type == widget.type &&
        oldWidget.essayTier == widget.essayTier) {
      return;
    }
    _timer?.cancel();
    _poses = aurudoPoseSequence(widget.type, essayTier: widget.essayTier);
    _index = _reduced ? _poses.length - 1 : 0;
    if (!_reduced) _scheduleCrossfade();
  }

  void _scheduleCrossfade() {
    if (_poses.length <= 1) return;
    _timer = Timer(AurudoMascotView.firstPoseDuration, () {
      if (mounted) setState(() => _index = 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The signature reaction has its own renderer (all its motion lives
    // there); every other reaction keeps its still pose(s) below.
    if (widget.type == AurudoReactionType.perfectFarmAura) {
      return AurudoFarmAuraAnimation(size: widget.size, instant: _reduced);
    }
    // A level up keeps the celebrating mascot exactly as approved, with
    // its own ascension scene around him -- what tells it apart from
    // `great` is the scene, never a new pose.
    if (widget.type == AurudoReactionType.levelUp) {
      return AurudoLevelUpEffect(
        size: widget.size,
        instant: _reduced,
        child: AurudoCelebratingAnimation(size: widget.size, instant: _reduced),
      );
    }
    // A streak milestone: same untouched mascot, in front of its own
    // Aura flame.
    if (widget.type == AurudoReactionType.streakMilestone) {
      return AurudoStreakEffect(
        size: widget.size,
        instant: _reduced,
        child: AurudoCelebratingAnimation(size: widget.size, instant: _reduced),
      );
    }
    // Same deal for any reaction that lands on `celebrating` as its only
    // pose (great / levelUp / streakMilestone / the top essay tiers) --
    // never for the two-pose stories, which don't use it.
    if (_poses.length == 1 && _poses.single == AurudoPose.celebrating) {
      return AurudoCelebratingAnimation(size: widget.size, instant: _reduced);
    }
    final pose = _poses[_index];
    // The daily goal keeps the still farm-Aura pose (never the 100%
    // animation above) inside its own progress ring.
    if (widget.type == AurudoReactionType.dailyGoalComplete) {
      return AurudoDailyGoalEffect(
        size: widget.size,
        instant: _reduced,
        child: AurudoIllustration(
          pose: pose,
          size: widget.size,
          animate: !_reduced,
        ),
      );
    }
    return AnimatedSwitcher(
      duration: _reduced ? Duration.zero : AurudoMascotView.crossfadeDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      child: AurudoIllustration(
        key: ValueKey(pose),
        pose: pose,
        size: widget.size,
      ),
    );
  }
}
