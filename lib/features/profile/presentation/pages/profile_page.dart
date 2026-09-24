import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/profile_state.dart';
import 'package:aura/features/profile/presentation/pages/goal_settings_page.dart';
import 'package:aura/features/profile/presentation/pages/interested_subjects_settings_page.dart';
import 'package:aura/features/profile/presentation/pages/my_account_page.dart';
import 'package:aura/features/profile/presentation/pages/settings_page.dart';
import 'package:aura/features/profile/presentation/widgets/delete_account_tile.dart';
import 'package:aura/features/profile/presentation/widgets/profile_stats_row.dart';
import 'package:aura/features/profile/presentation/widgets/settings_group.dart';
import 'package:aura/features/profile/presentation/widgets/settings_tile.dart';
import 'package:aura/features/profile/presentation/widgets/xp_level_card.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/progress/presentation/cubit/profile_stats_cubit.dart';
import 'package:aura/features/progress/presentation/cubit/profile_stats_state.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/streak/presentation/cubit/streak_state.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/features/xp/presentation/cubit/xp_state.dart';
import 'package:aura/shared/widgets/app_info_bottom_sheet.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';
import 'package:aura/shared/widgets/section_label.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileStatsCubit(sl<ProgressRepository>()),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  /// Asks first. Signing out is recoverable, so this is a short check
  /// rather than a warning -- but it sits one row above deleting the
  /// account, and a mis-tap there should not end the session either.
  Future<void> _confirmSignOut(BuildContext context, ProfileStrings t) async {
    await AppInfoBottomSheet.showInfo(
      context,
      title: t.signOutConfirmTitle,
      description: t.signOutConfirmDescription,
      primaryActionLabel: t.signOutConfirmButton,
      onPrimaryAction: () => _signOut(context),
      secondaryActionLabel: t.cancelButtonLabel,
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthCubit>().signOut();
    if (context.mounted) context.go('/login');
  }

  void _openMyAccount(BuildContext context, ProfileState state) {
    final profileCubit = context.read<ProfileCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // ProfileCubit lives above HomeShellPage, and a route pushed via
        // Navigator is not a descendant of that provider -- so it is
        // re-provided by .value here.
        builder: (_) => BlocProvider.value(
          value: profileCubit,
          child: MyAccountPage(
            initialName: state.profile?.name ?? '',
            initialUsername: state.profile?.username,
            email: state.authUser.email,
          ),
        ),
      ),
    );
  }

  void _openGoal(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const GoalSettingsPage()),
      ),
    );
  }

  void _openInterestedSubjects(BuildContext context, ProfileState state) {
    final cubit = context.read<ProfileCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: InterestedSubjectsSettingsPage(
            initialSelection: (state.profile?.interestedSubjects ?? []).toSet(),
          ),
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = ProfileStrings(language);
    final xpState = context.watch<XpCubit>().state;
    final streakState = context.watch<StreakCubit>().state;
    final streakDays = switch (streakState) {
      StreakLoaded(:final streak) => streak.currentStreak,
      _ => 0,
    };
    final statsState = context.watch<ProfileStatsCubit>().state;
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        return Scaffold(
          backgroundColor: context.colors.background,
          body: Column(
            children: [
              ModernAppBar(title: t.profilePageTitle),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xxl,
                    AppSpacing.pageHorizontal,
                    AppSpacing.md,
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: context.colors.primary.withValues(
                              alpha: 0.14,
                            ),
                            child: Icon(
                              Icons.person_outline,
                              color: context.colors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (profile?.name.isNotEmpty ?? false)
                                      ? profile!.name
                                      : t.namePlaceholder,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                                if ((profile?.username ?? '').isNotEmpty)
                                  Text(
                                    '@${profile!.username}',
                                    style: TextStyle(
                                      color: context.colors.textSecondary,
                                    ),
                                  ),
                                Text(
                                  state.authUser.email,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (xpState is XpLoaded) ...[
                      const SizedBox(height: AppSpacing.sm),
                      XpLevelCard(strings: t, xp: xpState.xp),
                    ],
                    if (statsState is ProfileStatsLoaded) ...[
                      const SizedBox(height: AppSpacing.sm),
                      ProfileStatsRow(
                        strings: t,
                        streakDays: streakDays,
                        stats: statsState.stats,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    SectionLabel(t.studiesSectionLabel),
                    SettingsGroup(
                      children: [
                        SettingsTile(
                          icon: Icons.flag_outlined,
                          title: t.goalRowLabel,
                          subtitle:
                              profile?.goal?.label(language) ??
                              t.notInformedLabel,
                          onTap: () => _openGoal(context),
                        ),
                        SettingsTile(
                          icon: Icons.menu_book_outlined,
                          title: t.interestedSubjectsRowLabel,
                          subtitle:
                              (profile?.interestedSubjects.isNotEmpty ?? false)
                              ? t.interestedSubjectsCount(
                                  profile!.interestedSubjects.length,
                                )
                              : t.notInformedLabel,
                          onTap: () => _openInterestedSubjects(context, state),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SectionLabel(t.accountSectionLabel),
                    SettingsGroup(
                      children: [
                        SettingsTile(
                          icon: Icons.person_outline,
                          title: t.myAccountRowLabel,
                          subtitle: t.myAccountRowSubtitle,
                          onTap: () => _openMyAccount(context, state),
                        ),
                        SettingsTile(
                          icon: Icons.settings_outlined,
                          title: t.settingsRowLabel,
                          subtitle: t.settingsRowSubtitle,
                          onTap: () => _openSettings(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SettingsGroup(
                      children: [
                        SettingsTile(
                          icon: Icons.logout_rounded,
                          title: t.signOutButtonLabel,
                          // Acts here instead of opening a screen, and is
                          // toned down to say so.
                          showChevron: false,
                          tone: SettingsTileTone.muted,
                          onTap: () => _confirmSignOut(context, t),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // In a group of its own: ending the account is not one
                    // more setting, and it should never be the row next to
                    // the one you meant to tap.
                    const SettingsGroup(children: [DeleteAccountTile()]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
