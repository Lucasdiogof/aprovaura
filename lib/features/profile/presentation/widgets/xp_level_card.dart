import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';
import 'package:aura/shared/widgets/aura/aura_glyph.dart';

/// Level + Aura progress. Named after the backend's XP (user_xp) that
/// feeds it; everything on screen says Aura.
///
/// Two lines on purpose: "Nível 2" and "50 / 100 Aura para o nível 3" used
/// to share one row and overflowed on 360px phones.
class XpLevelCard extends StatelessWidget {
  const XpLevelCard({required this.strings, required this.xp, super.key});

  final ProfileStrings strings;
  final UserXp xp;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.auraViolet.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const AuraGlyph(size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.levelLabel(xp.level),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      strings.auraTotal(xp.totalXp),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _AuraProgressBar(value: xp.levelProgress),
          const SizedBox(height: AppSpacing.sm),
          Text(
            strings.auraToNextLevel(
              xp.xpIntoLevel,
              xp.xpForNextLevel,
              xp.level + 1,
            ),
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// The level bar is an Aura element, so it's the one place on this screen
/// that carries the brand gradient.
class _AuraProgressBar extends StatelessWidget {
  const _AuraProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        height: 8,
        color: colors.secondary,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0, 1),
          // Without this the fill gets a loose height and paints nothing.
          heightFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: colors.auraGradient),
          ),
        ),
      ),
    );
  }
}
