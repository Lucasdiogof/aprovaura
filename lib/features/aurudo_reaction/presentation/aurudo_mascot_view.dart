import 'dart:async';

import 'package:flutter/material.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/essay_reaction_tier.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

/// Which [AurudoPose] (or short pose-to-pose story) plays for a resolved
/// [AurudoReactionType], today's honest placeholder until a rigged
/// Rive/Lottie asset exists: the character itself never fakes an
/// articulated gesture, only the surrounding scene (particles, halo) does
/// that work -- see [AurudoReactionStage].
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
    final pose = _poses[_index];
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
