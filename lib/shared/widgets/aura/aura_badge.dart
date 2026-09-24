import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/shared/l10n/aura_strings.dart';
import 'package:aura/shared/widgets/aura/aura_glyph.dart';

/// "+10 Aura" -- an Aura amount just earned, as a compact tonal pill with
/// the Aura glyph. Always reads as a reward (signed), never as a total.
class AuraBadge extends StatelessWidget {
  const AuraBadge({required this.amount, super.key});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return _AuraPill(label: AuraStrings.gained(amount), emphasized: true);
  }
}

/// "150 Aura" -- a running Aura total (e.g. Home's header).
class AuraCounter extends StatelessWidget {
  const AuraCounter({required this.total, super.key});

  final int total;

  @override
  Widget build(BuildContext context) {
    return _AuraPill(label: AuraStrings.amount(total), emphasized: false);
  }
}

class _AuraPill extends StatelessWidget {
  const _AuraPill({required this.label, required this.emphasized});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: colors.auraViolet.withValues(alpha: emphasized ? 0.16 : 0.10),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: colors.auraViolet.withValues(alpha: emphasized ? 0.35 : 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AuraGlyph(size: 14),
            const SizedBox(width: AppSpacing.xs + 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
