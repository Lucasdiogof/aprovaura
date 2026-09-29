import 'dart:async';

import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction.dart';
import 'package:aura/features/aurudo_reaction/domain/entities/aurudo_reaction_type.dart';
import 'package:aura/features/aurudo_reaction/presentation/aura_particles.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_mascot_view.dart';

/// A short congratulation that appears over a screen and leaves on its
/// own.
///
/// Not a result screen and not a dialog: Home stays visible and usable
/// behind it, there is no button to dismiss, and it never holds anyone
/// for longer than about a second. It exists for an achievement that
/// really happened but that no result screen was in a position to show --
/// today, the daily goal reached in the middle of a mock exam.
///
/// The numbers on the screen behind are already correct before this ever
/// appears. This only says out loud what the cards already show.
class AurudoAchievementOverlay extends StatefulWidget {
  const AurudoAchievementOverlay({
    required this.reaction,
    required this.message,
    required this.onDismissed,
    super.key,
  });

  final AurudoReaction reaction;

  /// One line, already translated: "Meta batida!", "Nível 8!".
  final String message;

  final VoidCallback onDismissed;

  /// Long enough to read one line, short enough that nobody waits it out.
  static const visibleDuration = Duration(milliseconds: 1100);

  /// A tap before this is ignored, so the tap that opened Home cannot
  /// skip the congratulation it just triggered.
  static const tapUnlockDelay = Duration(milliseconds: 450);

  static const fadeDuration = Duration(milliseconds: 200);

  @override
  State<AurudoAchievementOverlay> createState() =>
      _AurudoAchievementOverlayState();
}

class _AurudoAchievementOverlayState extends State<AurudoAchievementOverlay> {
  Timer? _autoDismiss;
  Timer? _unlockTap;
  bool _canTap = false;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _autoDismiss = Timer(AurudoAchievementOverlay.visibleDuration, _dismiss);
    _unlockTap = Timer(AurudoAchievementOverlay.tapUnlockDelay, () {
      if (mounted) setState(() => _canTap = true);
    });
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _unlockTap?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (_leaving) return;
    _leaving = true;
    if (mounted) setState(() {});
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !_canTap,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _dismiss,
          child: AnimatedOpacity(
            opacity: _leaving ? 0 : 1,
            duration: reduced
                ? Duration.zero
                : AurudoAchievementOverlay.fadeDuration,
            child: ColoredBox(
              // Light on purpose: this sits over Home and Home stays
              // readable behind it. Anything heavier starts to feel like
              // a screen of its own.
              color: colors.background.withValues(alpha: 0.4),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Fewer and quieter than a perfect result: this
                          // is a good moment, not the app's biggest one.
                          if (!reduced)
                            const AuraParticles(
                              style: AuraParticlesStyle.burst,
                              count: 4,
                            ),
                          AurudoMascotView(
                            type: widget.reaction.type,
                            size: 96,
                            instant: reduced,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                      ),
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The one line the overlay says, for each achievement it can carry.
String achievementOverlayMessage(
  AurudoReaction reaction, {
  required String levelUp,
  required String streakMilestone,
  required String dailyGoal,
}) => switch (reaction.type) {
  AurudoReactionType.levelUp => levelUp,
  AurudoReactionType.streakMilestone => streakMilestone,
  _ => dailyGoal,
};
