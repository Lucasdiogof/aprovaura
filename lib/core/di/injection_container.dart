import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/cache/offline_cache.dart';
import 'package:aura/core/network/connection_monitor.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/core/sync/pending_sync_queue.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/atualidades/data/atualidades_repository_impl.dart';
import 'package:aura/features/atualidades/data/dossier_question_repository_impl.dart';
import 'package:aura/features/atualidades/domain/repositories/atualidades_repository.dart';
import 'package:aura/features/auth/data/auth_repository_impl.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/catalog/data/catalog_repository_impl.dart';
import 'package:aura/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:aura/features/error_review/data/error_review_repository_impl.dart';
import 'package:aura/features/essay/data/essay_repository_impl.dart';
import 'package:aura/features/essay/domain/repositories/essay_repository.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';
import 'package:aura/features/favorites/data/favorites_repository_impl.dart';
import 'package:aura/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:aura/features/home/data/daily_goal_repository_impl.dart';
import 'package:aura/features/home/domain/repositories/daily_goal_repository.dart';
import 'package:aura/features/mock_exam/data/mock_exam_repository_impl.dart';
import 'package:aura/features/mock_exam/domain/repositories/mock_exam_repository.dart';
import 'package:aura/features/profile/data/profile_repository_impl.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/progress/data/progress_repository_impl.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/data/question_report_repository_impl.dart';
import 'package:aura/features/questions/data/question_repository_impl.dart';
import 'package:aura/features/questions/data/quick_practice_question_repository_impl.dart';
import 'package:aura/features/questions/data/review_question_repository_impl.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';
import 'package:aura/features/questions/domain/repositories/question_report_repository.dart';
import 'package:aura/features/streak/data/streak_repository_impl.dart';
import 'package:aura/features/streak/domain/repositories/streak_repository.dart';
import 'package:aura/features/xp/data/xp_repository_impl.dart';
import 'package:aura/features/xp/domain/repositories/xp_repository.dart';

final GetIt sl = GetIt.instance;

void registerSupabaseDependencies() {
  sl.registerLazySingleton<OfflineCache>(() => OfflineCache(sl()));
  sl.registerLazySingleton<ConnectionMonitor>(() => ConnectionMonitor(sl()));
  sl.registerLazySingleton<PendingSyncQueue>(
    () => PendingSyncQueue(sl(), sl()),
  );
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl<OfflineCache>(), sl<PendingSyncQueue>()),
  );
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(sl(), sl<LocaleCubit>(), sl<OfflineCache>()),
  );
  sl.registerLazySingleton<AtualidadesRepository>(
    () =>
        AtualidadesRepositoryImpl(sl(), sl<LocaleCubit>(), sl<OfflineCache>()),
  );
  sl.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(sl(), sl<LocaleCubit>(), sl<OfflineCache>()),
  );
  sl.registerLazySingleton<QuestionRepository>(
    () => DossierQuestionRepositoryImpl(sl(), sl<LocaleCubit>()),
    instanceName: 'dossierQuestions',
  );
  sl.registerLazySingleton<StreakRepository>(
    () => StreakRepositoryImpl(sl(), sl<ConnectionMonitor>()),
  );
  sl.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(
      sl(),
      sl<OfflineCache>(),
      sl<PendingSyncQueue>(),
      sl<ConnectionMonitor>(),
    ),
  );
  sl.registerLazySingleton<QuestionRepository>(
    () => ReviewQuestionRepositoryImpl(
      sl(),
      sl<LocaleCubit>(),
      sl<OfflineCache>(),
    ),
    instanceName: 'reviewQuestions',
  );
  sl.registerLazySingleton<EssayRepository>(
    () => EssayRepositoryImpl(sl(), sl<LocaleCubit>()),
  );
  sl.registerLazySingleton<ErrorReviewRepository>(
    () =>
        ErrorReviewRepositoryImpl(sl(), sl<LocaleCubit>(), sl<OfflineCache>()),
  );
  sl.registerLazySingleton<XpRepository>(
    () =>
        XpRepositoryImpl(sl(), sl<PendingSyncQueue>(), sl<ConnectionMonitor>()),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(
      sl(),
      sl<LocaleCubit>(),
      sl<OfflineCache>(),
      sl<PendingSyncQueue>(),
      sl<ConnectionMonitor>(),
    ),
  );
  sl.registerLazySingleton<QuestionRepository>(
    () => QuickPracticeQuestionRepositoryImpl(
      sl(),
      sl<LocaleCubit>(),
      sl<OfflineCache>(),
      sl<PendingSyncQueue>(),
      sl<ConnectionMonitor>(),
    ),
    instanceName: 'quickPracticeQuestions',
  );
  sl.registerLazySingleton<MockExamRepository>(
    () => MockExamRepositoryImpl(
      sl(),
      sl<LocaleCubit>(),
      sl<ConnectionMonitor>(),
    ),
  );
  sl.registerLazySingleton<DailyGoalRepository>(
    () => DailyGoalRepositoryImpl(sl(), sl<ConnectionMonitor>()),
  );
  sl.registerLazySingleton<QuestionReportRepository>(
    () => QuestionReportRepositoryImpl(sl()),
  );
}

/// Connects the connection monitor and the pending-sync queue to the rest of
/// the app. Call once after every dependency is registered.
///
/// Every request feeds the monitor (through request_guard's hooks); coming
/// back online -- or signing in -- sends whatever was kept on the device,
/// and the XP total is re-read if an award was among it.
void wireOfflineSupport() {
  final monitor = sl<ConnectionMonitor>();
  final queue = sl<PendingSyncQueue>();
  onRequestFailure = monitor.reportFailure;
  onRequestSuccess = monitor.reportSuccess;
  monitor.onReconnect(queue.flush);
  queue.onFlushed((synced) {
    if (synced.contains(PendingKind.xp) && sl.isRegistered<XpCubit>()) {
      sl<XpCubit>().load();
    }
  });
  sl<SupabaseClient>().auth.onAuthStateChange.listen((change) {
    if (change.event == AuthChangeEvent.signedIn ||
        change.event == AuthChangeEvent.initialSession) {
      queue.flush();
    }
  });
}
