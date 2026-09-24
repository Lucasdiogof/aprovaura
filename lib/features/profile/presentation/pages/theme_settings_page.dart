import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/theme_cubit.dart';
import 'package:aura/core/theme/theme_mode_label.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';
import 'package:aura/shared/widgets/selectable_option_tile.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  static IconData _iconFor(ThemeMode mode) => switch (mode) {
    ThemeMode.system => Icons.brightness_auto_outlined,
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final t = ProfileStrings(context.watch<LocaleCubit>().state);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          ModernAppBar(
            title: t.themePageTitle,
            subtitle: t.themePageSubtitle,
            showBackButton: true,
          ),
          Expanded(
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) => ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  for (final option in ThemeMode.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SelectableOptionTile(
                        title: themeModeLabel(option, t.language),
                        description: t.themeOptionDescription(option),
                        icon: _iconFor(option),
                        selected: mode == option,
                        onTap: () => context.read<ThemeCubit>().setMode(option),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
