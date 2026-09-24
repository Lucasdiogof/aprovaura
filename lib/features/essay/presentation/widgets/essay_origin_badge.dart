import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/essay/domain/entities/essay_theme.dart';
import 'package:aura/features/essay/l10n/essay_strings.dart';

/// "Aura · Tema de treino" or "Oficial · ENEM 2025".
///
/// The exam line only exists when the theme really carries exam and year
/// (the database refuses to store one without the other), so this can never
/// render a half-invented provenance.
class EssayOriginBadge extends StatelessWidget {
  const EssayOriginBadge({
    required this.origin,
    required this.strings,
    super.key,
  });

  final EssayThemeOrigin origin;
  final EssayStrings strings;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isOfficial = origin.isOfficial;
    final label = isOfficial
        ? '${strings.officialBadge} · ${origin.examName} ${origin.examYear}'
        : strings.practiceBadge;
    // Official gets the brand colour; ours stays quiet, so a practice theme
    // never looks like it is claiming authority it does not have.
    final foreground = isOfficial ? colors.primary : colors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: foreground,
        ),
      ),
    );
  }
}
