import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/router/app_route_observer.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/home/l10n/home_strings.dart';
import 'package:aura/features/home/presentation/cubit/home_shell_cubit.dart';
import 'package:aura/features/home/presentation/cubit/home_shell_state.dart';
import 'package:aura/features/home/presentation/cubit/home_summary_cubit.dart';
import 'package:aura/features/home/presentation/pages/home_page.dart';
import 'package:aura/features/practice/presentation/pages/practice_page.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/profile/presentation/pages/profile_page.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/shared/widgets/aura_bottom_nav_bar.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({required this.user, super.key});

  final AppUser user;

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> with RouteAware {
  final _shellCubit = HomeShellCubit();
  late final _profileCubit = ProfileCubit(sl<ProfileRepository>(), widget.user);

  @override
  void initState() {
    super.initState();
    sl<StreakCubit>().load();
    sl<XpCubit>().load();
    sl<HomeSummaryCubit>().load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) appRouteObserver.subscribe(this, route);
  }

  // Fires when a pushed screen (quick practice, review errors, favorites,
  // a catalog activity) pops back to the shell -- refreshes the daily-goal
  // and pending/favorites counts without needing a real navigation event
  // wired through every one of those screens.
  @override
  void didPopNext() => sl<HomeSummaryCubit>().refresh();

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _shellCubit.close();
    _profileCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HomeStrings(context.watch<LocaleCubit>().state);
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _shellCubit),
        BlocProvider.value(value: _profileCubit),
        BlocProvider.value(value: sl<HomeSummaryCubit>()),
      ],
      child: BlocBuilder<HomeShellCubit, HomeShellState>(
        builder: (context, shellState) {
          const pages = [HomePage(), PracticePage(), ProfilePage()];
          return Scaffold(
            body: IndexedStack(index: shellState.index, children: pages),
            bottomNavigationBar: AuraBottomNavBar(
              currentIndex: shellState.index,
              onTap: _shellCubit.navigateToTab,
              destinations: [
                AuraNavDestination(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: t.navHome,
                ),
                AuraNavDestination(
                  icon: Icons.bolt_outlined,
                  selectedIcon: Icons.bolt_rounded,
                  label: t.navPractice,
                ),
                AuraNavDestination(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person_rounded,
                  label: t.navProfile,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
