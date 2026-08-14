import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/home/l10n/home_strings.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({
    required this.strings,
    required this.streakDays,
    super.key,
  });

  final HomeStrings strings;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.secondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: context.colors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Color(0xFFE8763D),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.streakLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.colors.primary,
                  ),
                ),
                Text(
                  strings.streakDaysCount(streakDays),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.streakSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: context.colors.textSecondary),
        ],
      ),
    );
  }
}
