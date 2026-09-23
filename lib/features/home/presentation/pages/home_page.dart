import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/features/home/l10n/home_strings.dart';
import 'package:aura/features/home/presentation/widgets/streak_card.dart';
import 'package:aura/features/practice/l10n/practice_strings.dart';
import 'package:aura/features/practice/presentation/widgets/practice_options_list.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/streak/presentation/cubit/streak_state.dart';
import 'package:aura/features/streak/presentation/widgets/streak_lost_bottom_sheet.dart';

/// Home is where a session starts without having to decide on a subject
/// first: the streak, then the three shortcuts that pick the questions for
/// you. Browsing the catalog by subject lives on the Practice tab.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _displayName(String name, String email) {
    if (name.isNotEmpty) return name.split(' ').first;
    final localPart = email.split('@').first;
    if (localPart.isEmpty) return localPart;
    return localPart[0].toUpperCase() + localPart.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = HomeStrings(language);
    final practiceStrings = PracticeStrings(language);
    final profileState = context.watch<ProfileCubit>().state;
    final displayName = _displayName(
      profileState.profile?.name ?? '',
      profileState.authUser.email,
    );
    final streakState = context.watch<StreakCubit>().state;
    final streakDays = switch (streakState) {
      StreakLoaded(:final streak) => streak.currentStreak,
      _ => 0,
    };
    return BlocListener<StreakCubit, StreakState>(
      listenWhen: (previous, current) =>
          current is StreakLoaded && current.streak.hasUnseenBreak,
      listener: (context, state) {
        final streak = (state as StreakLoaded).streak;
        context.read<StreakCubit>().dismissBreakNotice();
        StreakLostBottomSheet.show(
          context,
          lostDays: streak.lastBrokenStreak ?? 0,
        );
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.greeting(displayName),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.homeSubtitle,
                  style: TextStyle(color: context.colors.textSecondary),
                ),
                const SizedBox(height: 20),
                StreakCard(strings: t, streakDays: streakDays),
                const SizedBox(height: 24),
                Text(
                  practiceStrings.pageSubtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const PracticeOptionsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
