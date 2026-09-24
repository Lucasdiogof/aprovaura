import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';

/// A small caption above a group of rows -- e.g. Settings' "Aparência" /
/// "Idioma" / "Sobre" groups. Kept to text only (no divider, no
/// background) so a short list of these doesn't itself start looking like
/// a wall of cards.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, AppSpacing.sm),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: context.colors.textSecondary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
