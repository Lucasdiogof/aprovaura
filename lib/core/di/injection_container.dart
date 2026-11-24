import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/core/cache/offline_cache.dart';
import 'package:aura/core/network/connection_monitor.dart';
import 'package:aura/core/network/request_guard.dart';
import 'package:aura/core/sync/pending_sync_queue.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/features/access/data/access_grant_verifier.dart';
import 'package:aura/features/access/data/access_repository_impl.dart';
import 'package:aura/features/access/domain/repositories/access_repository.dart';
import 'package:aura/features/access/domain/entities/access_status.dart';
import 'package:aura/features/access/presentation/cubit/access_cubit.dart';
import 'package:aura/features/payments/data/payments_repository_impl.dart';
import 'package:aura/features/payments/domain/payments.dart';
import 'package:aura/features/payments/presentation/cubit/payments_cubit.dart';
import 'package:aura/core/router/app_router.dart';
import 'package:aura/features/partners/data/partners_repository_impl.dart';
import 'package:aura/features/partners/domain/repositories/partners_repository.dart';
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
    () => StreakRepositoryImpl(
      sl(),
      sl<ConnectionMonitor>(),
      sl<PendingSyncQueue>(),
    ),
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
  sl.registerLazySingleton<AccessRepository>(
    () => AccessRepositoryImpl(
      sl(),
      sl<SharedPreferences>(),
      const AccessGrantVerifier(),
    ),
  );
  sl.registerLazySingleton<AccessCubit>(
    () => AccessCubit(sl<AccessRepository>()),
  );
  sl.registerLazySingleton<PartnersRepository>(
    () => PartnersRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PaymentsRepository>(
    () => PaymentsRepositoryImpl(sl()),
  );
  sl.registerFactory<PaymentsCubit>(
    () => PaymentsCubit(sl<PaymentsRepository>(), sl<AccessCubit>()),
  );
}

/// Liga o estado de acesso Premium ao ciclo de vida do app: login/abertura
/// (sessão inicial), saída da conta, retorno do segundo plano, reconexão e
/// resposta 402 do servidor. Chamar uma vez, depois de registrar tudo.
/// Com o modelo comercial desligado no servidor, nada disto bloqueia ninguém.
void wireAccessSupport() {
  final cubit = sl<AccessCubit>();
  onPremiumRequired = () => unawaited(cubit.refresh(force: true));
  // E-mail sem prova: sai da conta e o login retoma pelo código de 6 dígitos.
  onEmailUnverified = () => unawaited(() async {
    await sl<AuthRepository>().signOut();
    appRouter.go('/login');
  }());
  sl<ConnectionMonitor>().onReconnect(() => cubit.refresh(force: true));
  // Atividade feita dentro de uma autorização válida e adiada pelo 402 (fila
  // intacta) é enviada assim que o acesso reabre — nunca antes, nunca perdida.
  var wasOpen = false;
  cubit.stream.listen((_) {
    final open = cubit.gate == AccessGate.open;
    if (open && !wasOpen && sl.isRegistered<PendingSyncQueue>()) {
      unawaited(sl<PendingSyncQueue>().flush());
    }
    wasOpen = open;
  });
  sl<SupabaseClient>().auth.onAuthStateChange.listen((change) {
    switch (change.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.initialSession:
        if (change.session != null) {
          unawaited(cubit.refresh(force: true));
          unawaited(_touchActivity());
        }
      case AuthChangeEvent.signedOut:
        unawaited(cubit.reset());
      default:
        break;
    }
  });
  WidgetsBinding.instance.addObserver(_AccessLifecycleObserver(cubit));
}

class _AccessLifecycleObserver with WidgetsBindingObserver {
  _AccessLifecycleObserver(this._cubit);

  final AccessCubit _cubit;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_cubit.refresh());
      unawaited(_touchActivity());
    }
  }
}

DateTime? _lastTouch;

/// "Última atividade no app" para o portal administrativo: no máximo 1 gravação
/// a cada 10 min por aparelho (o servidor também limita), só com sessão, sem
/// dados além da plataforma. Falhas (offline, 402) são ignoradas.
Future<void> _touchActivity() async {
  final now = DateTime.now();
  if (_lastTouch != null && now.difference(_lastTouch!) < const Duration(minutes: 10)) return;
  final client = sl<SupabaseClient>();
  if (client.auth.currentSession == null) return;
  _lastTouch = now;
  try {
    final platform = kIsWeb
        ? 'web'
        : (defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android');
    await client.rpc<dynamic>('touch_activity', params: {'p_platform': platform});
  } catch (_) {}
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
    if (synced.contains(PendingKind.streak) && sl.isRegistered<StreakCubit>()) {
      sl<StreakCubit>().load();
    }
  });
  sl<SupabaseClient>().auth.onAuthStateChange.listen((change) {
    if (change.event == AuthChangeEvent.signedIn ||
        change.event == AuthChangeEvent.initialSession) {
      queue.flush();
    }
  });
}
