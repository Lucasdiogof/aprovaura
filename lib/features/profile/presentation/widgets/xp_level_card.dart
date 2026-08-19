import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';

class XpLevelCard extends StatelessWidget {
  const XpLevelCard({required this.strings, required this.xp, super.key});

  final ProfileStrings strings;
  final UserXp xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
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
                  color: context.colors.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.military_tech_outlined,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                strings.levelLabel(xp.level),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: context.colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                strings.xpToNextLevel(xp.xpIntoLevel, xp.xpForNextLevel),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: xp.levelProgress,
              minHeight: 8,
              backgroundColor: context.colors.secondary,
              valueColor: AlwaysStoppedAnimation(context.colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
