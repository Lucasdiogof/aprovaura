import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aura/features/atualidades/data/atualidades_repository_impl.dart';
import 'package:aura/features/atualidades/data/dossier_question_repository_impl.dart';
import 'package:aura/features/atualidades/domain/repositories/atualidades_repository.dart';
import 'package:aura/features/auth/data/auth_repository_impl.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/catalog/data/catalog_repository_impl.dart';
import 'package:aura/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:aura/features/error_review/data/error_review_repository_impl.dart';
import 'package:aura/features/error_review/domain/repositories/error_review_repository.dart';
import 'package:aura/features/profile/data/profile_repository_impl.dart';
import 'package:aura/features/profile/domain/repositories/profile_repository.dart';
import 'package:aura/features/progress/data/progress_repository_impl.dart';
import 'package:aura/features/progress/domain/repositories/progress_repository.dart';
import 'package:aura/features/questions/data/question_repository_impl.dart';
import 'package:aura/features/questions/data/review_question_repository_impl.dart';
import 'package:aura/features/questions/domain/repositories/question_repository.dart';
import 'package:aura/features/streak/data/streak_repository_impl.dart';
import 'package:aura/features/streak/domain/repositories/streak_repository.dart';
import 'package:aura/features/xp/data/xp_repository_impl.dart';
import 'package:aura/features/xp/domain/repositories/xp_repository.dart';

final GetIt sl = GetIt.instance;

void registerSupabaseDependencies() {
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AtualidadesRepository>(
    () => AtualidadesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<QuestionRepository>(
    () => DossierQuestionRepositoryImpl(sl()),
    instanceName: 'dossierQuestions',
  );
  sl.registerLazySingleton<StreakRepository>(() => StreakRepositoryImpl(sl()));
  sl.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<QuestionRepository>(
    () => ReviewQuestionRepositoryImpl(sl()),
    instanceName: 'reviewQuestions',
  );
  sl.registerLazySingleton<ErrorReviewRepository>(
    () => ErrorReviewRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<XpRepository>(() => XpRepositoryImpl(sl()));
}
