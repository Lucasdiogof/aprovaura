import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/app.dart';
import 'package:aura/core/di/injection_container.dart';
import 'package:aura/core/error/result.dart';
import 'package:aura/core/l10n/locale_cubit.dart';
import 'package:aura/core/theme/theme_cubit.dart';
import 'package:aura/features/auth/domain/entities/app_user.dart';
import 'package:aura/features/auth/domain/repositories/auth_repository.dart';
import 'package:aura/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:aura/features/streak/domain/entities/streak.dart';
import 'package:aura/features/streak/domain/repositories/streak_repository.dart';
import 'package:aura/features/streak/presentation/cubit/streak_cubit.dart';
import 'package:aura/features/xp/domain/entities/user_xp.dart';
import 'package:aura/features/xp/domain/repositories/xp_repository.dart';
import 'package:aura/features/xp/presentation/cubit/xp_cubit.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<Result<void>> sendPasswordReset({required String email}) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();

  @override
  Future<Result<void>> deleteAccount() => throw UnimplementedError();

  @override
  AppUser? get currentUser => null;
}

// StreakCubit/XpCubit don't auto-load (see their own doc comments), so the
// login screen never calls these -- these fakes just need to exist to
// satisfy GetIt, not do anything.
class _FakeStreakRepository implements StreakRepository {
  @override
  Future<Result<Streak>> getOrRefresh() => throw UnimplementedError();

  @override
  Future<Result<Streak>> registerActivityCompletion() =>
      throw UnimplementedError();

  @override
  Future<Result<void>> markBreakSeen() => throw UnimplementedError();
}

class _FakeXpRepository implements XpRepository {
  @override
  Future<Result<UserXp>> getCurrent() => throw UnimplementedError();

  @override
  Future<Result<UserXp>> awardQuizXp({
    required String attemptId,
    required int correctCount,
  }) => throw UnimplementedError();
}

void main() {
  testWidgets('app opens directly on the login screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    if (!sl.isRegistered<ThemeCubit>()) {
      sl.registerLazySingleton<ThemeCubit>(ThemeCubit.new);
    }
    if (!sl.isRegistered<LocaleCubit>()) {
      sl.registerLazySingleton<LocaleCubit>(LocaleCubit.new);
    }
    if (!sl.isRegistered<AuthRepository>()) {
      sl.registerLazySingleton<AuthRepository>(_FakeAuthRepository.new);
    }
    if (!sl.isRegistered<AuthCubit>()) {
      sl.registerFactory<AuthCubit>(() => AuthCubit(sl()));
    }
    if (!sl.isRegistered<StreakRepository>()) {
      sl.registerLazySingleton<StreakRepository>(_FakeStreakRepository.new);
    }
    if (!sl.isRegistered<StreakCubit>()) {
      sl.registerLazySingleton<StreakCubit>(() => StreakCubit(sl()));
    }
    if (!sl.isRegistered<XpRepository>()) {
      sl.registerLazySingleton<XpRepository>(_FakeXpRepository.new);
    }
    if (!sl.isRegistered<XpCubit>()) {
      sl.registerLazySingleton<XpCubit>(() => XpCubit(sl()));
    }

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.byWidgetPredicate((w) => w is Image), findsWidgets);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
