import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/l10n/app_language.dart';
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
                _PortalEntry(language: t.language),
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

/// Atalho para o portal (/partners) só para quem é professor parceiro ou administrador:
/// o papel vem do servidor (get_my_access); sem rede ou sem papel, nada aparece.
class _PortalEntry extends StatefulWidget {
  const _PortalEntry({required this.language});
  final AppLanguage language;

  @override
  State<_PortalEntry> createState() => _PortalEntryState();
}

class _PortalEntryState extends State<_PortalEntry> {
  bool? _admin; // null = sem acesso ao portal

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final me = await Supabase.instance.client.rpc<dynamic>('get_my_access');
      final roles = (me as Map)['roles'] as Map;
      if (!mounted) return;
      if (roles['admin'] == true) {
        setState(() => _admin = true);
      } else if (roles['partner'] == true) {
        setState(() => _admin = false);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final admin = _admin;
    if (admin == null) return const SizedBox.shrink();
    final (section, label) = switch (widget.language) {
      AppLanguage.portuguese => ('Portal', admin ? 'Portal administrativo' : 'Portal do professor'),
      AppLanguage.english => ('Portal', admin ? 'Admin portal' : 'Teacher portal'),
      AppLanguage.spanish => ('Portal', admin ? 'Portal administrativo' : 'Portal del profesor'),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(section),
        ProfileRow(
          icon: Icons.dashboard_outlined,
          label: label,
          trailing: Icon(Icons.chevron_right, color: context.colors.textSecondary),
          onTap: () => context.go('/partners'),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
