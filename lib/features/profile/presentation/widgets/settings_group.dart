import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';

/// Rows that belong together, in one surface with hairlines between them.
///
/// The profile used to be five separate cards floating with gaps, which
/// gave "Sair" exactly as much weight as "Meu objetivo" and left nothing
/// saying which of them were related. Grouping is the whole point: the
/// card is the boundary, and what is inside it is one subject.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(AppRadius.lg);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius,
        border: Border.all(color: colors.border),
      ),
      // The rows paint their own ink, which would otherwise spill out of
      // the rounded corners at the top and bottom of the group.
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          children: [
            for (final (index, child) in children.indexed) ...[
              if (index > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  // Starts past the icon, so the dividers line up with the
                  // text and read as one list instead of full-width cuts.
                  indent: AppSpacing.md * 2 + 40,
                  color: colors.border,
                ),
              child,
            ],
          ],
        ),
      ),
    );
  }
}
