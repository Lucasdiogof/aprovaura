import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/config/app_info.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/features/profile/presentation/widgets/profile_row.dart';
import 'package:aura/shared/widgets/app_logo.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// Just what's real today: what the app is, and its version. No privacy
/// policy link -- there isn't one written yet, and a placeholder would be
/// worse than not having the row at all.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = ProfileStrings(context.watch<LocaleCubit>().state);
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          ModernAppBar(title: t.aboutPageTitle, showBackButton: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
              children: [
                const Center(child: AppLogo.mark(size: 64)),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  t.aboutAppDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ProfileRow(
                  icon: Icons.info_outline,
                  label: t.versionRowLabel,
                  value: AppInfo.version,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
