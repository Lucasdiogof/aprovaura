import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/features/xp/presentation/cubit/xp_state.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/theme/app_spacing.dart';
import 'package:aura/features/aurudo_reaction/presentation/aurudo_achievement_overlay.dart';
import 'package:aura/features/aurudo_reaction/presentation/pending_home_reaction.dart';
import 'package:aura/features/home/l10n/home_strings.dart';
import 'package:aura/features/home/presentation/cubit/home_summary_cubit.dart';
import 'package:aura/features/home/presentation/cubit/home_summary_state.dart';
import 'package:aura/features/home/presentation/widgets/daily_goal_card.dart';
import 'package:aura/features/home/presentation/widgets/home_hero.dart';
import 'package:aura/features/home/presentation/widgets/streak_card.dart';
import 'package:aura/features/practice/presentation/widgets/practice_options_list.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/streak/presentation/cubit/streak_state.dart';
import 'package:aura/features/streak/presentation/widgets/streak_lost_bottom_sheet.dart';
import 'package:aura/features/home/domain/entities/daily_goal.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';

/// Home is where a session starts without having to decide on a subject
/// first: the streak, then the three shortcuts that pick the questions for
/// you. Browsing the catalog by subject lives on the Practice tab.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// An achievement that happened while no result screen was in a
  /// position to show it -- see [pendingHomeReaction]. Home is the
  /// fallback, once, and then never again.
  PendingHomeReaction? _pending;

  String _displayName(String name, String email) {
    if (name.isNotEmpty) return name.split(' ').first;
    final localPart = email.split('@').first;
    if (localPart.isEmpty) return localPart;
    return localPart[0].toUpperCase() + localPart.substring(1);
  }

  /// Asked on every build, and answered by the ledger: an achievement
  /// has one life, so once it is written down this returns null forever
  /// after. Nothing is decided while a number is still loading -- a
  /// celebration chosen on half the picture would be a guess.
  void _checkPending({
    required UserXp? xp,
    required Streak? streak,
    required DailyGoal? dailyGoal,
  }) {
    if (_pending != null) return;
    if (xp == null || streak == null || dailyGoal == null) return;
    final pending = pendingHomeReaction(
      xp: xp,
      streak: streak,
      dailyGoal: dailyGoal,
      today: DateTime.now(),
    );
    if (pending == null) return;
    // Spent the moment it starts playing, so a rebuild, a theme change or
    // coming back later finds nothing left to celebrate.
    pending.markCelebrated();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _pending = pending);
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleCubit>().state;
    final t = HomeStrings(language);
    final profileState = context.watch<ProfileCubit>().state;
    // Blank while the profile is still loading: falling back to the email
    // right away flashed "Appleteste" before the real "Apple" arrived.
    final displayName = profileState.profile == null && profileState.loading
        ? ''
        : _displayName(
            profileState.profile?.name ?? '',
            profileState.authUser.email,
          );
    final streakState = context.watch<StreakCubit>().state;
    final xpState = context.watch<XpCubit>().state;
    final streakDays = switch (streakState) {
      StreakLoaded(:final streak) => streak.currentStreak,
      _ => 0,
    };
    final summaryState = context.watch<HomeSummaryCubit>().state;
    // Null while loading: the goal card waits for the real state before
    // animating anything.
    final dailyGoal = switch (summaryState) {
      HomeSummaryLoaded(:final dailyGoal) => dailyGoal,
      _ => null,
    };
    _checkPending(
      xp: switch (xpState) {
        XpLoaded(:final xp) => xp,
        _ => null,
      },
      streak: switch (streakState) {
        StreakLoaded(:final streak) => streak,
        _ => null,
      },
      dailyGoal: dailyGoal,
    );
    final pending = _pending;

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
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxl,
                  AppSpacing.pageHorizontal,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeHero(
                      strings: t,
                      displayName: displayName,
                      // Hidden (not a misleading 0) until the real total loads.
                      auraTotal: switch (xpState) {
                        XpLoaded(:final xp) => xp.totalXp,
                        _ => null,
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DailyGoalCard(strings: t, goal: dailyGoal),
                    const SizedBox(height: AppSpacing.sm),
                    StreakCard(
                      strings: t,
                      streakDays: streakDays,
                      activeToday: switch (streakState) {
                        StreakLoaded(:final streak) => streak.isActiveToday(),
                        _ => false,
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      t.homeActionsHeading,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const PracticeOptionsList(),
                  ],
                ),
              ),
            ),
            if (pending != null)
              AurudoAchievementOverlay(
                reaction: pending.reaction,
                message: achievementOverlayMessage(
                  pending.reaction,
                  levelUp: t.levelUpCheer(switch (xpState) {
                    XpLoaded(:final xp) => xp.level,
                    _ => 0,
                  }),
                  streakMilestone: t.streakMilestoneCheer(streakDays),
                  dailyGoal: t.dailyGoalReachedCheer,
                ),
                onDismissed: () {
                  if (mounted) setState(() => _pending = null);
                },
              ),
          ],
        ),
      ),
    );
  }
}
