import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/core/theme/theme_cubit.dart';
import 'package:aura/core/theme/theme_mode_label.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/features/profile/presentation/pages/about_page.dart';
import 'package:aura/features/profile/presentation/pages/language_settings_page.dart';
import 'package:aura/features/profile/presentation/pages/theme_settings_page.dart';
import 'package:aura/features/profile/presentation/widgets/profile_row.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';
import 'package:aura/shared/widgets/section_label.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = ProfileStrings(context.watch<LocaleCubit>().state);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          ModernAppBar(
            title: t.settingsPageTitle,
            subtitle: t.settingsPageSubtitle,
            showBackButton: true,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              children: [
                SectionLabel(t.appearanceSectionLabel),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, mode) => ProfileRow(
                    icon: Icons.palette_outlined,
                    label: t.themeRowLabel,
                    value: themeModeLabel(mode, t.language),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: context.colors.textSecondary,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ThemeSettingsPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionLabel(t.languageSectionLabel),
                ProfileRow(
                  icon: Icons.translate,
                  label: t.languageRowLabel,
                  value: t.language.label,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: context.colors.textSecondary,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LanguageSettingsPage(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionLabel(t.aboutSectionLabel),
                ProfileRow(
                  icon: Icons.info_outline,
                  label: t.aboutRowLabel,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: context.colors.textSecondary,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AboutPage()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
