import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';

/// How much weight a row carries.
enum SettingsTileTone {
  /// Goes somewhere. Brand colour on the icon.
  normal,

  /// Acts here and is not a destination -- "Sair". Quieter than the rows
  /// that navigate, so it reads as an action rather than one more place
  /// to visit, without pretending to be dangerous.
  muted,

  /// Ends the account. Error colour on the icon and the title, and
  /// deliberately not a red card: the row has to be findable and clearly
  /// final, not alarming every time the profile is opened.
  destructive,
}

/// One row inside a [SettingsGroup]: icon, title, optional subtitle, and a
/// chevron when tapping it goes somewhere.
///
/// The subtitle carries the current value ("Escola", "1 matéria
/// selecionada") or what lives behind the row ("Tema, idioma e
/// preferências"), so the list answers most questions without being
/// opened.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.showChevron = true,
    this.tone = SettingsTileTone.normal,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  /// Replaces the chevron -- a spinner, while the row is busy.
  final Widget? trailing;

  /// Off for rows that act in place instead of opening a screen: a chevron
  /// there would promise a page that does not exist.
  final bool showChevron;

  final SettingsTileTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = switch (tone) {
      SettingsTileTone.normal => colors.primary,
      SettingsTileTone.muted => colors.textSecondary,
      SettingsTileTone.destructive => colors.error,
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 20, color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: tone == SettingsTileTone.destructive
                            ? colors.error
                            : colors.textPrimary,
                      ),
                    ),
                    if (subtitle case final subtitle?) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.3,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing case final trailing?) ...[
                const SizedBox(width: AppSpacing.sm),
                trailing,
              ] else if (showChevron) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
