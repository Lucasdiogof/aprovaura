import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/app.dart';
import 'package:aura/core/auth/secure_session_storage.dart';
import 'package:aura/core/config/env_config.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/loading/app_blocking_loading_cubit.dart';
import 'package:aura/core/theme/theme_cubit.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/home/domain/repositories/daily_goal_repository.dart';
import 'package:aura/features/home/presentation/cubit/home_summary_cubit.dart';
import 'package:aura/features/map_quiz/data/map_quiz_repository_impl.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/map_quiz/domain/repositories/map_quiz_repository.dart';
import 'package:aura/features/streak/domain/repositories/streak_repository.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/partners/domain/entities/partner.dart';
import 'package:aura/features/xp/domain/repositories/xp_repository.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';

void main() async {
  // URLs sem '#': o portal precisa responder em /partners (acesso direto e F5).
  // Links antigos '#/rota' continuam funcionando (ver _initialLocation).
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  EnvConfig.validate();

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    publishableKey: EnvConfig.supabasePublishableKey,
    authOptions: FlutterAuthClientOptions(
      localStorage: kIsWeb
          ? null
          : SecureSessionStorage(
              persistSessionKey: supabaseSessionKey(EnvConfig.supabaseUrl),
            ),
    ),
  );

  // Registered eagerly (not a factory): the reaction ledger and other
  // callers need it synchronously, and getInstance() is only genuinely
  // async on its very first call per process.
  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );

  // Link de indicação (?ref=CODE): guarda só o código, e só sem sessão ativa
  // (um aluno já logado nunca tem a indicação alterada por um link).
  final ref = Uri.base.queryParameters['ref'];
  if (kIsWeb &&
      ref != null &&
      Supabase.instance.client.auth.currentSession == null &&
      RegExp(r'^[A-Za-z0-9]{4,12}$').hasMatch(ref)) {
    await sl<SharedPreferences>().setString(kReferralKey, ref.toUpperCase());
  }

  sl.registerLazySingleton<ThemeCubit>(ThemeCubit.new);
  sl.registerLazySingleton<LocaleCubit>(LocaleCubit.new);
  sl.registerLazySingleton<AppBlockingLoadingCubit>(
    AppBlockingLoadingCubit.new,
  );
  sl.registerLazySingleton<MapQuizRepository>(MapQuizRepositoryImpl.new);
  registerSupabaseDependencies();
  wireOfflineSupport();
  wireAccessSupport();
  sl.registerLazySingleton<StreakCubit>(
    () => StreakCubit(sl<StreakRepository>()),
  );
  sl.registerLazySingleton<XpCubit>(() => XpCubit(sl<XpRepository>()));
  sl.registerLazySingleton<HomeSummaryCubit>(
    () => HomeSummaryCubit(
      sl<DailyGoalRepository>(),
      sl<ErrorReviewRepository>(),
      sl<FavoritesRepository>(),
      sl<MockExamRepository>(),
    ),
  );

  runApp(const App());
}
