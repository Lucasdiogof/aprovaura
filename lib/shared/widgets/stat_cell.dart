import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';

/// An icon, a big value and a small label underneath -- the pattern used
/// for result/progress stats (quiz results today; Home's daily-goal panel
/// and Profile's progress summary reuse it too).
class StatCell extends StatelessWidget {
  const StatCell({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
        ),
      ],
    );
  }
}
