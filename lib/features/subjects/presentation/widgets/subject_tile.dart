import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/shared/widgets/aura_sparkle_burst.dart';

/// The visual of a card in the Practice grid, with no idea what it stands
/// for. Extracted so Redação -- which is a feature of its own, not a
/// catalog subject -- can sit in the grid looking exactly like the others
/// without being forced into the Subject enum (and from there into the mock
/// exam config, the interested-subjects screen, and every other place that
/// walks Subject.values).
class SubjectTile extends StatefulWidget {
  const SubjectTile({
    required this.icon,
    required this.accentColor,
    required this.label,
    required this.description,
    required this.onTap,
    super.key,
    this.inFocus = false,
    this.justEnteredFocus = false,
  });

  final IconData icon;
  final Color accentColor;
  final String label;
  final String description;
  final VoidCallback onTap;

  /// The person picked this subject as one of their "matérias em foco".
  /// The subject's own accent still says what the content is; this is a
  /// second, personal layer on top of it (border + a small mark), never a
  /// full repaint of the card.
  final bool inFocus;

  /// True only on the one build where [inFocus] just became true during
  /// this session (the person just added it) -- the one moment the sparkle
  /// is allowed to play. A card that has always been in focus, or that
  /// becomes visible again on a later visit, never animates.
  final bool justEnteredFocus;

  @override
  State<SubjectTile> createState() => _SubjectTileState();
}

class _SubjectTileState extends State<SubjectTile>
    with SingleTickerProviderStateMixin {
  static const _burst = Duration(milliseconds: 450);

  late final _burstController = AnimationController(
    vsync: this,
    duration: _burst,
  );

  @override
  void initState() {
    super.initState();
    // Reading MediaQuery isn't safe yet in initState -- deferred to the
    // post-frame callback, by which point the element can depend on it.
    if (widget.justEnteredFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_reducedMotion) _burstController.forward(from: 0);
      });
    }
  }

  @override
  void didUpdateWidget(SubjectTile old) {
    super.didUpdateWidget(old);
    if (widget.justEnteredFocus && !old.justEnteredFocus && !_reducedMotion) {
      _burstController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  bool get _reducedMotion => MediaQuery.disableAnimationsOf(context);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inFocus = widget.inFocus;
    return Material(
      color: inFocus
          ? colors.auraViolet.withValues(alpha: 0.06)
          : colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: inFocus
                  ? colors.auraViolet.withValues(alpha: 0.55)
                  : colors.border,
              width: inFocus ? 1.4 : 1,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.accentColor,
                          size: 19,
                        ),
                      ),
                      if (inFocus) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 13,
                          color: colors.auraViolet,
                        ),
                      ],
                      const Spacer(),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colors.textSecondary.withValues(alpha: 0.7),
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs + 2),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
              if (widget.justEnteredFocus && !_reducedMotion)
                Positioned(
                  left: 10,
                  top: 10,
                  child: AuraSparkleBurst(
                    controller: _burstController,
                    colors: [
                      colors.auraViolet,
                      colors.auraCyan,
                      colors.primary,
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
