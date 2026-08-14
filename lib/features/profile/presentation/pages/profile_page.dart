import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/profile/l10n/profile_strings.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/profile/presentation/cubit/profile_state.dart';
import 'package:aura/features/profile/presentation/pages/goal_settings_page.dart';
import 'package:aura/features/profile/presentation/pages/interested_subjects_settings_page.dart';
import 'package:aura/features/profile/presentation/pages/my_account_page.dart';
import 'package:aura/features/profile/presentation/pages/settings_page.dart';
import 'package:aura/features/profile/presentation/widgets/profile_row.dart';
import 'package:aura/shared/widgets/modern_app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthCubit>().signOut();
    if (context.mounted) context.go('/login');
  }

  void _openMyAccount(BuildContext context, ProfileState state) {
    final cubit = context.read<ProfileCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
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
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(20),
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (profile?.name.isNotEmpty ?? false)
                                      ? profile!.name
                                      : t.notInformedLabel,
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
                    const SizedBox(height: 20),
                    ProfileRow(
                      icon: Icons.flag_outlined,
                      label: t.goalRowLabel,
                      value:
                          profile?.goal?.label(language) ?? t.notInformedLabel,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: context.colors.textSecondary,
                      ),
                      onTap: () => _openGoal(context),
                    ),
                    const SizedBox(height: 8),
                    ProfileRow(
                      icon: Icons.menu_book_outlined,
                      label: t.interestedSubjectsRowLabel,
                      value: (profile?.interestedSubjects.isNotEmpty ?? false)
                          ? t.interestedSubjectsCount(
                              profile!.interestedSubjects.length,
                            )
                          : t.notInformedLabel,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: context.colors.textSecondary,
                      ),
                      onTap: () => _openInterestedSubjects(context, state),
                    ),
                    const SizedBox(height: 8),
                    ProfileRow(
                      icon: Icons.person_outline,
                      label: t.myAccountRowLabel,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: context.colors.textSecondary,
                      ),
                      onTap: () => _openMyAccount(context, state),
                    ),
                    const SizedBox(height: 8),
                    ProfileRow(
                      icon: Icons.settings_outlined,
                      label: t.settingsRowLabel,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: context.colors.textSecondary,
                      ),
                      onTap: () => _openSettings(context),
                    ),
                    const SizedBox(height: 8),
                    ProfileRow(
                      icon: Icons.logout,
                      label: t.signOutButtonLabel,
                      onTap: () => _signOut(context),
                    ),
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
