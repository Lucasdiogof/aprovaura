import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

class ModernAppBar extends StatelessWidget {
  const ModernAppBar({
    required this.title,
    super.key,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  // Optional action at the far right (e.g. an overflow menu).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 20, 14),
        decoration: BoxDecoration(
          color: context.colors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          // Top, not centre: a two-line title (long title, or one with a
          // subtitle) used to pull the back button down into the middle of
          // that taller block, so it read as off-centre and small next to
          // it. Anchoring both to the top keeps the button the same
          // standard size and position regardless of how tall the text
          // block ends up.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBackButton) ...[
              // A proper round IconButton, standard Material style -- not
              // the old bare Icon wrapped in an InkWell, which had a
              // smaller, one-off tap area. Compact density keeps its
              // footprint close to a single line of title text, so it
              // doesn't grow the header even when there's no subtitle.
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
