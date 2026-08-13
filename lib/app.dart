import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/app_language.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/router/app_router.dart';
import 'package:aura/core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<LocaleCubit>(),
      child: BlocBuilder<LocaleCubit, AppLanguage>(
        builder: (context, language) {
          return MaterialApp.router(
            title: language.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            locale: language.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('pt', 'BR'), Locale('en')],
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
