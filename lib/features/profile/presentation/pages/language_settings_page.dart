import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';
import 'package:aura/shared/widgets/selectable_option_tile.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = ProfileStrings(context.watch<LocaleCubit>().state);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          ModernAppBar(
            title: t.languagePageTitle,
            subtitle: t.languagePageSubtitle,
            showBackButton: true,
          ),
          Expanded(
            child: BlocBuilder<LocaleCubit, AppLanguage>(
              builder: (context, language) => ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  for (final option in AppLanguage.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SelectableOptionTile(
                        title: option.label,
                        description: t.languageOptionDescription(option),
                        icon: Icons.translate,
                        selected: language == option,
                        onTap: () =>
                            context.read<LocaleCubit>().setLanguage(option),
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
