import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/loading/app_blocking_loading_cubit.dart';
import 'package:aura/core/router/app_router.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/core/theme/theme_cubit.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/shared/widgets/app_loading_overlay.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ThemeCubit>()),
        BlocProvider.value(value: sl<LocaleCubit>()),
        BlocProvider.value(value: sl<StreakCubit>()),
        BlocProvider.value(value: sl<XpCubit>()),
        BlocProvider.value(value: sl<AppBlockingLoadingCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, AppLanguage>(
            builder: (context, language) {
              return MaterialApp.router(
                title: language.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                locale: language.locale,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('pt', 'BR'),
                  Locale('en'),
                  Locale('es'),
                ],
                routerConfig: appRouter,
                // One overlay, above everything the router shows (every
                // route, dialog and bottom sheet) -- never a Stack rebuilt
                // per screen. See AppBlockingLoadingCubit/AppLoadingOverlay.
                builder: (context, child) =>
                    Stack(children: [?child, const AppLoadingOverlay()]),
              );
            },
          );
        },
      ),
    );
  }
}
