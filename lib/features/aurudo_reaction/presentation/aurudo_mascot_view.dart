import 'dart:async';

import 'package:flutter/material.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/shared/widgets/aura/aurudo_illustration.dart';

/// Which [AurudoPose] (or short pose-to-pose story) plays for a resolved
/// [AurudoReactionType], today's honest placeholder until a rigged
/// Rive/Lottie asset exists: the character itself never fakes an
/// articulated gesture, only the surrounding scene (particles, halo) does
/// that work -- see [AurudoReactionStage].
///
/// `correctionReady` has no grade information at this layer yet (the
/// resolver doesn't carry a score band in Phase 1/2) -- it falls back to
/// [AurudoPose.neutral] until that's wired up.
List<AurudoPose> aurudoPoseSequence(AurudoReactionType type) => switch (type) {
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
  AurudoReactionType.correctionReady => const [AurudoPose.neutral],
};

/// Aurudo reacting to a resolved [type]. For the two-pose stories
/// (`normal`, `encourage`) the first pose holds briefly, then crossfades
/// into the final one; every other reaction is a single pose with
/// [AurudoIllustration]'s own short entrance. Reduced motion always shows
/// the sequence's last pose immediately, with no crossfade.
class AurudoMascotView extends StatefulWidget {
  const AurudoMascotView({required this.type, this.size = 160, super.key});

  final AurudoReactionType type;
  final double size;

  /// How long the first pose of a two-pose story holds before crossfading.
  static const firstPoseDuration = Duration(milliseconds: 600);
  static const crossfadeDuration = Duration(milliseconds: 250);

  @override
  State<AurudoMascotView> createState() => _AurudoMascotViewState();
}

class _AurudoMascotViewState extends State<AurudoMascotView> {
  late List<AurudoPose> _poses = aurudoPoseSequence(widget.type);
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
    _reduced = MediaQuery.disableAnimationsOf(context);
    if (_reduced && _index != _poses.length - 1) {
      _timer?.cancel();
      _index = _poses.length - 1;
    }
  }

  @override
  void didUpdateWidget(covariant AurudoMascotView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type == widget.type) return;
    _timer?.cancel();
    _poses = aurudoPoseSequence(widget.type);
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
