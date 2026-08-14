import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/app_colors.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/home/l10n/home_strings.dart';
import 'package:aura/features/home/presentation/cubit/home_shell_cubit.dart';
import 'package:aura/features/home/presentation/cubit/home_shell_state.dart';
import 'package:aura/features/home/presentation/pages/home_page.dart';
import 'package:aura/features/practice/presentation/pages/practice_page.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:aura/features/profile/presentation/pages/profile_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({required this.user, super.key});

  final AppUser user;

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  final _shellCubit = HomeShellCubit();
  late final _profileCubit = ProfileCubit(sl<ProfileRepository>(), widget.user);

  @override
  void dispose() {
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
      ],
      child: BlocBuilder<HomeShellCubit, HomeShellState>(
        builder: (context, shellState) {
          const pages = [HomePage(), PracticePage(), ProfilePage()];
          return Scaffold(
            body: IndexedStack(index: shellState.index, children: pages),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(top: BorderSide(color: context.colors.border)),
              ),
              child: SafeArea(
                top: false,
                child: NavigationBar(
                  selectedIndex: shellState.index,
                  onDestinationSelected: _shellCubit.navigateToTab,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  indicatorColor: context.colors.primary.withValues(
                    alpha: 0.15,
                  ),
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.home_outlined),
                      selectedIcon: Icon(
                        Icons.home,
                        color: context.colors.primary,
                      ),
                      label: t.navHome,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.bolt_outlined),
                      selectedIcon: Icon(
                        Icons.bolt,
                        color: context.colors.primary,
                      ),
                      label: t.navPractice,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.person_outline),
                      selectedIcon: Icon(
                        Icons.person,
                        color: context.colors.primary,
                      ),
                      label: t.navProfile,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
