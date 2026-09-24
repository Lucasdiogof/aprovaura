import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/shared/widgets/aura_sparkle_burst.dart';

/// One tab in [AuraBottomNavBar].
class AuraNavDestination {
  const AuraNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;

  /// Filled version of the same icon. The change of weight is half of what
  /// makes the active tab obvious; the pill behind it is the other half.
  final IconData selectedIcon;

  final String label;
}

/// The app's bottom navigation.
///
/// Built by hand rather than from Material's `NavigationBar` because the
/// active tab needed far more presence than the default indicator gives,
/// and because the pill has to slide between tabs instead of blinking out
/// in one place and in again in another.
///
/// Labels stay under every tab, selected or not: an icon alone asks people
/// to remember what a lightning bolt means.
class AuraBottomNavBar extends StatefulWidget {
  const AuraBottomNavBar({
    required this.currentIndex,
    required this.destinations,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final List<AuraNavDestination> destinations;

  /// Called only for a tab that is not already selected.
  final ValueChanged<int> onTap;

  @override
  State<AuraBottomNavBar> createState() => _AuraBottomNavBarState();
}

class _AuraBottomNavBarState extends State<AuraBottomNavBar>
    with SingleTickerProviderStateMixin {
  static const _slide = Duration(milliseconds: 280);
  static const _burst = Duration(milliseconds: 450);

  /// Height of the lane the pill lives in, above the labels.
  static const _pillHeight = 34.0;
  static const _pillWidth = 62.0;
  static const _pillTop = 6.0;
  static const _labelSize = 11.5;
  static const _labelGap = AppSpacing.xs;

  late final _burstController = AnimationController(
    vsync: this,
    duration: _burst,
  );

  @override
  void didUpdateWidget(AuraBottomNavBar old) {
    super.didUpdateWidget(old);
    // Only a real change of tab is worth celebrating.
    if (old.currentIndex != widget.currentIndex && !_animationsOff) {
      _burstController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  bool get _animationsOff => MediaQuery.disableAnimationsOf(context);

  void _handleTap(int index) {
    // Tapping the tab you are already on does nothing at all: no sparkles,
    // no haptic, no navigation event.
    if (index == widget.currentIndex) return;
    if (!_animationsOff) HapticFeedback.selectionClick();
    widget.onTap(index);
  }

  /// The pill lane, the gap, and however tall one line of label is at the
  /// reader's font size.
  static double _barHeight(BuildContext context) {
    final labelHeight = MediaQuery.textScalerOf(
      context,
    ).scale(_labelSize * 1.3);
    return _pillTop + _pillHeight + _labelGap + labelHeight + _pillTop;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduced = _animationsOff;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        // Just enough of a curve to lift the bar off the content; a heavy
        // shadow would make it float over a page it belongs to.
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          // Grows with the label instead of clipping it: at a large system
          // font size a fixed 64 cut the text off by a few pixels.
          height: _barHeight(context),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final slotWidth =
                  constraints.maxWidth / widget.destinations.length;
              final pillLeft =
                  slotWidth * widget.currentIndex +
                  (slotWidth - _pillWidth) / 2;

              return Stack(
                children: [
                  // The pill travels between tabs on its own layer, so it
                  // slides instead of appearing somewhere else.
                  AnimatedPositioned(
                    duration: reduced ? Duration.zero : _slide,
                    curve: Curves.easeOutCubic,
                    left: pillLeft,
                    top: _pillTop,
                    width: _pillWidth,
                    height: _pillHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  // The burst lands on the destination immediately -- it is
                  // an arrival, not something dragged across the bar.
                  if (!reduced)
                    Positioned(
                      left: pillLeft,
                      top: _pillTop,
                      width: _pillWidth,
                      height: _pillHeight,
                      child: AuraSparkleBurst(
                        controller: _burstController,
                        colors: [
                          colors.primary,
                          colors.auraCyan,
                          colors.auraViolet,
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      for (final (index, destination)
                          in widget.destinations.indexed)
                        Expanded(
                          child: _NavItem(
                            destination: destination,
                            selected: index == widget.currentIndex,
                            reduced: reduced,
                            onTap: () => _handleTap(index),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.reduced,
    required this.onTap,
  });

  final AuraNavDestination destination;
  final bool selected;
  final bool reduced;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tone = selected ? colors.primary : colors.textSecondary;

    return Semantics(
      selected: selected,
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: 40,
        child: Padding(
          // Same top inset as the pill lane, so the pill sits exactly
          // behind the icon rather than half a pixel off it.
          padding: const EdgeInsets.only(top: _AuraBottomNavBarState._pillTop),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: _AuraBottomNavBarState._pillHeight,
                child: Center(
                  child: AnimatedScale(
                    // A touch bigger, not a pop: the pill already says
                    // which one is active.
                    scale: selected ? 1.08 : 1,
                    duration: reduced
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      selected ? destination.selectedIcon : destination.icon,
                      size: 24,
                      color: tone,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: _AuraBottomNavBarState._labelGap),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _AuraBottomNavBarState._labelSize,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: tone,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
