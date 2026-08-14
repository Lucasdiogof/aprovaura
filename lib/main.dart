import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/app.dart';
import 'package:aura/core/config/env_config.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/theme_cubit.dart';
import 'package:aura/features/map_quiz/data/map_quiz_repository_impl.dart';
import 'package:aura/features/map_quiz/domain/repositories/map_quiz_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EnvConfig.validate();

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    publishableKey: EnvConfig.supabasePublishableKey,
  );

  sl.registerLazySingleton<ThemeCubit>(ThemeCubit.new);
  sl.registerLazySingleton<LocaleCubit>(LocaleCubit.new);
  sl.registerLazySingleton<MapQuizRepository>(MapQuizRepositoryImpl.new);
  registerSupabaseDependencies();

  runApp(const App());
}
