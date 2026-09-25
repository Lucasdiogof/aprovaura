import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/home/l10n/home_strings.dart';
import 'package:aura/shared/widgets/aura/aura_badge.dart';

/// Home's compact hero: a context line (time of day), the person's name,
/// their running Aura total, and a low-key subtitle. Its own widget so the
/// composition (context → name+pill → subtitle) reads as one deliberate
/// block instead of a bare greeting bolted onto the page.
class HomeHero extends StatelessWidget {
  const HomeHero({
    required this.strings,
    required this.displayName,
    super.key,
    this.auraTotal,
  });

  final HomeStrings strings;
  final String displayName;

  /// Null until the real total has loaded -- the pill simply doesn't show
  /// rather than flashing a misleading 0.
  final int? auraTotal;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.timeGreeting(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ),
            if (auraTotal != null) ...[
              const SizedBox(width: AppSpacing.sm),
              AuraCounter(total: auraTotal!),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          strings.homeSubtitle,
          style: TextStyle(color: colors.textSecondary),
        ),
      ],
    );
  }
}
