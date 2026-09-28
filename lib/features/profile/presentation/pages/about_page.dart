import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/config/app_info.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/features/profile/presentation/widgets/profile_row.dart';
import 'package:aura/shared/widgets/app_logo.dart';
import 'package:aura/shared/utils/external_link.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

/// What the app is, its privacy policy (public, on lucksrei.com -- the
/// stores require it to be reachable from inside the app) and its version.
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
                  icon: Icons.privacy_tip_outlined,
                  label: t.privacyPolicyRowLabel,
                  trailing: Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: context.colors.textSecondary,
                  ),
                  onTap: () =>
                      openExternalLink(context, AppInfo.privacyPolicyUrl),
                ),
                const SizedBox(height: AppSpacing.sm),
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
