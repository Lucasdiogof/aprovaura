import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';

class SelectableOptionTile extends StatelessWidget {
  const SelectableOptionTile({
    required this.title,
    required this.selected,
    required this.onTap,
    super.key,
    this.description,
    this.icon,
    this.multiSelect = false,
  });

  final String title;
  final String? description;
  final IconData? icon;
  final bool selected;
  final bool multiSelect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? context.colors.primary : context.colors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: context.colors.primary, size: 18),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                selected
                    ? (multiSelect ? Icons.check_box : Icons.check_circle)
                    : (multiSelect
                          ? Icons.check_box_outline_blank
                          : Icons.circle_outlined),
                color: selected
                    ? context.colors.primary
                    : context.colors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
